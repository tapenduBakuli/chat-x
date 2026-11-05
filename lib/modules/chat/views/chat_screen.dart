import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:get/get.dart';

import '../../../device_manager/screen_constants.dart';
import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';
import '../controller/chat_controller.dart';
import '../model/chat_message.dart';
import '../../home/model/friend.dart';
import '../../home/views/widgets/member_network_image.dart';

/// 1:1 chat with a friend, opened from the Friends tab chat button. The peer
/// ([FriendUser]) is passed via [Get.arguments] and read by [ChatController];
/// a "Chat unavailable" fallback is shown when it's missing. Design only —
/// messages are DEMO data until the chat APIs/socket are provided.
class ChatScreen extends GetView<ChatController> {
  const ChatScreen({super.key});

  static const LinearGradient _brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [CustomColor.colorBE185D, CustomColor.color581C87],
  );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final FriendUser? peer = controller.peer.value;
      if (peer == null) return _notFound();
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: CustomColor.colorAF5FF,
          resizeToAvoidBottomInset: true,
          appBar: _appBar(peer),
          body: Column(
            children: [
              Expanded(child: _messageList(peer)),
              _typingIndicator(peer),
              _composer(),
            ],
          ),
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------
  PreferredSizeWidget _appBar(FriendUser peer) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: CustomColor.colorWhite,
      titleSpacing: 0,
      leading: IconButton(
        tooltip: 'Back',
        icon: Icon(
          Icons.arrow_back_ios_new,
          size: ScreenConstant.smallIconSize,
          color: CustomColor.color0F172A,
        ),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          _avatar(peer),
          SizedBox(width: ScreenConstant.sizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  peer.age > 0
                      ? '${peer.displayName}, ${peer.age}'
                      : peer.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.registerAppBarTitle.copyWith(
                    fontSize: FontSize.s16,
                  ),
                ),
                // Obx(() {
                //   final typing = controller.peerTyping.value;
                //   return Text(
                //     typing ? 'typing…' : controller.statusLine(peer),
                //     maxLines: 1,
                //     overflow: TextOverflow.ellipsis,
                //     style: TextStyles.registerFieldNote.copyWith(
                //       fontSize: FontSize.s12,
                //       fontWeight: typing ? FontWeight.w600 : null,
                //       color: typing
                //           ? CustomColor.colorBE185D
                //           : (peer.isOnline
                //               ? CustomColor.color10B981
                //               : CustomColor.color64748B),
                //     ),
                //   );
                // }),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // IconButton(
        //   tooltip: 'Voice call (coming soon)',
        //   icon: Icon(
        //     Icons.call_outlined,
        //     size: ScreenConstant.smallIconSize,
        //     color: CustomColor.colorBE185D,
        //   ),
        //   onPressed: () => controller.comingSoon('Calls'),
        // ),
        PopupMenuButton<String>(
          tooltip: 'More options',
          icon: Icon(
            Icons.more_vert,
            size: ScreenConstant.smallIconSize,
            color: CustomColor.color64748B,
          ),
          color: CustomColor.colorWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          onSelected: (value) {
            switch (value) {
              case 'profile':
                controller.viewProfile();
                break;
              case 'block':
                controller.blockUser();
                break;
              case 'report':
                controller.reportUser();
                break;
            }
          },
          itemBuilder: (_) => [
            _menuItem(
              'profile',
              Icons.person_outline,
              'View profile',
              CustomColor.color0F172A,
            ),
            _menuItem('block', Icons.block, 'Block', CustomColor.color0F172A),
            _menuItem(
              'report',
              Icons.flag_outlined,
              'Report',
              CustomColor.colorE11D48,
            ),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(
    String value,
    IconData icon,
    String label,
    Color color,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: ScreenConstant.smallIconSize, color: color),
          SizedBox(width: ScreenConstant.sizeSmall),
          Text(
            label,
            style: TextStyles.loginWelcome.copyWith(
              fontSize: FontSize.s14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Circular avatar (initials when there is no photo) + green online dot.
  Widget _avatar(FriendUser user) {
    final double size = ScreenConstant.defaultWidthForty;
    return Semantics(
      label: user.isOnline ? '${user.displayName}, online' : user.displayName,
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: CustomColor.colorFBCFE8, width: 1.5),
              ),
              child: ClipOval(
                child: user.avatarUrl.isNotEmpty
                    ? MemberNetworkImage(url: user.avatarUrl)
                    : Container(
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          gradient: _brandGradient,
                        ),
                        child: Text(
                          _initials(user.displayName),
                          style: TextStyles.registerSectionTitle.copyWith(
                            fontSize: FontSize.s14,
                            color: CustomColor.colorWhite,
                          ),
                        ),
                      ),
              ),
            ),
            if (user.isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: ScreenConstant.sizeSmall,
                  height: ScreenConstant.sizeSmall,
                  decoration: BoxDecoration(
                    color: CustomColor.color10B981,
                    shape: BoxShape.circle,
                    border: Border.all(color: CustomColor.colorWhite, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Messages
  // ---------------------------------------------------------------------------
  Widget _messageList(FriendUser peer) {
    return Obx(() {
      final bool loading = controller.isLoading.value;
      final List<ChatMessage> items = controller.messages.toList();
      if (items.isEmpty) {
        if (loading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                CustomColor.colorBE185D,
              ),
            ),
          );
        }
        if (controller.loadFailed.value) {
          return Center(
            child: _retryRow("Couldn't load messages", controller.loadMessages),
          );
        }
        return _emptyState(peer);
      }
      final int n = items.length;
      return ListView.builder(
        controller: controller.scrollController,
        reverse: true,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.symmetric(
          horizontal:
              ScreenConstant.defaultWidthTen + ScreenConstant.sizeExtraSmall,
          vertical: ScreenConstant.sizeMedium,
        ),
        itemCount: n + 1,
        itemBuilder: (context, i) {
          // Reversed list: the last index is the TOP (older-messages row).
          if (i == n) return _olderRow();
          // Reversed list: index 0 is the newest message.
          final int ci = n - 1 - i;
          final ChatMessage m = items[ci];
          final bool newDay =
              ci == 0 || !controller.isSameDay(items[ci - 1].sentAt, m.sentAt);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (newDay) _dateSeparator(controller.dayLabel(m.sentAt)),
              _bubble(
                context,
                peer,
                m,
                groupedPrev: controller.isGroupedWithPrevious(ci),
                groupedNext: controller.isGroupedWithNext(ci),
              ),
            ],
          );
        },
      );
    });
  }

  /// Top of the list: small spinner while loading older messages, or a retry
  /// row when that load failed.
  Widget _olderRow() {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: ScreenConstant.sizeSmall),
          child: Center(
            child: SizedBox(
              width: ScreenConstant.smallIconSize,
              height: ScreenConstant.smallIconSize,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  CustomColor.colorBE185D,
                ),
              ),
            ),
          ),
        );
      }
      if (controller.loadMoreFailed.value) {
        return _retryRow("Couldn't load older messages", controller.loadOlder);
      }
      return const SizedBox.shrink();
    });
  }

  Widget _retryRow(String title, VoidCallback onRetry) {
    return Semantics(
      button: true,
      label: '$title. Tap to retry',
      excludeSemantics: true,
      child: InkWell(
        onTap: onRetry,
        borderRadius: BorderRadius.circular(100),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenConstant.sizeMedium,
            vertical: ScreenConstant.sizeSmall,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh,
                size: ScreenConstant.smallIconSize,
                color: CustomColor.colorBE185D,
              ),
              SizedBox(width: ScreenConstant.sizeExtraSmall),
              Flexible(
                child: Text(
                  '$title - Tap to retry',
                  style: TextStyles.registerFieldNote.copyWith(
                    color: CustomColor.colorBE185D,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateSeparator(String label) {
    return Semantics(
      header: true,
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(
            vertical: ScreenConstant.sizeSmallHighest,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: ScreenConstant.sizeSmall,
            vertical: ScreenConstant.sizeExtraSmall,
          ),
          decoration: BoxDecoration(
            color: CustomColor.colorWhite,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: CustomColor.colorE2E8F0),
          ),
          child: Text(
            label,
            style: TextStyles.registerFieldNote.copyWith(
              color: CustomColor.color64748B,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// Chat bubble. The tail-side bottom corner is tight on the last bubble of a
  /// group; the same-side top corner is tight when it continues a group.
  Widget _bubble(
    BuildContext context,
    FriendUser peer,
    ChatMessage m, {
    required bool groupedPrev,
    required bool groupedNext,
  }) {
    const Radius big = Radius.circular(18);
    const Radius small = Radius.circular(4);
    final bool mine = m.isMine;
    final BorderRadius radius = BorderRadius.only(
      topLeft: !mine && groupedPrev ? small : big,
      topRight: mine && groupedPrev ? small : big,
      bottomLeft: !mine && !groupedNext ? small : big,
      bottomRight: mine && !groupedNext ? small : big,
    );
    final String time = controller.timeLabel(m.sentAt);
    final String statusText = mine ? ', ${_statusLabel(m.status)}' : '';
    final bool failed = mine && m.status == MessageStatus.failed;

    return Padding(
      padding: EdgeInsets.only(
        bottom: groupedNext
            ? ScreenConstant.defaultHeightFour
            : ScreenConstant.sizeSmall,
      ),
      child: Semantics(
        label:
            '${mine ? 'You' : peer.displayName}, $time$statusText: ${m.text}'
            '${failed ? '. Tap to retry' : ''}',
        button: failed,
        onTap: failed ? () => controller.retryMessage(m.id) : null,
        onLongPress: failed ? () => controller.deleteFailedMessage(m.id) : null,
        customSemanticsActions: failed
            ? <CustomSemanticsAction, VoidCallback>{
                const CustomSemanticsAction(label: 'Delete message'): () =>
                    controller.deleteFailedMessage(m.id),
              }
            : null,
        excludeSemantics: true,
        child: _retryWrap(
          context: context,
          failed: failed,
          message: m,
          child: Column(
            crossAxisAlignment: mine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ScreenConstant.screenWidthHalf * 1.5,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenConstant.sizeSmallHighest,
                    vertical: ScreenConstant.sizeSmall,
                  ),
                  decoration: BoxDecoration(
                    gradient: mine ? _brandGradient : null,
                    color: mine ? null : CustomColor.colorWhite,
                    borderRadius: radius,
                    boxShadow: mine
                        ? null
                        : [
                            BoxShadow(
                              color: CustomColor.color717B96.withOpacity(0.12),
                              blurRadius: 16,
                              spreadRadius: -6,
                              offset: const Offset(0, 8),
                            ),
                          ],
                  ),
                  child: Text(
                    m.text,
                    style: TextStyles.loginFieldText.copyWith(
                      fontSize: FontSize.s15,
                      color: mine
                          ? CustomColor.colorWhite
                          : CustomColor.color0F172A,
                    ),
                  ),
                ),
              ),
              if (failed)
                _failedFooter(m)
              else if (!groupedNext)
                Padding(
                  padding: EdgeInsets.only(
                    top: ScreenConstant.defaultHeightFour,
                    left: ScreenConstant.defaultHeightFour,
                    right: ScreenConstant.defaultHeightFour,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(time, style: TextStyles.registerFieldNote),
                      if (mine) ...[
                        SizedBox(width: ScreenConstant.defaultHeightFour),
                        _statusIcon(m.status),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Failed bubbles tap to retry; long-press on any bubble confirms deletion via API.
  Widget _retryWrap({
    required BuildContext context,
    required bool failed,
    required ChatMessage message,
    required Widget child,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: failed ? () => controller.retryMessage(message.id) : null,
      onLongPress: () => controller.confirmDeleteMessage(context, message),
      child: child,
    );
  }

  /// Red error icon + "Tap to retry" + a small x that deletes the message.
  Widget _failedFooter(ChatMessage m) {
    return Padding(
      padding: EdgeInsets.only(top: ScreenConstant.defaultHeightFour),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: ScreenConstant.smallIconSize,
            color: CustomColor.colorE11D48,
          ),
          SizedBox(width: ScreenConstant.defaultHeightFour),
          Text(
            'Not sent - Tap to retry',
            style: TextStyles.registerFieldNote.copyWith(
              color: CustomColor.colorE11D48,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: ScreenConstant.defaultHeightFour),
          InkWell(
            onTap: () => controller.deleteFailedMessage(m.id),
            borderRadius: BorderRadius.circular(100),
            child: Padding(
              padding: EdgeInsets.all(ScreenConstant.defaultHeightFour),
              child: Icon(
                Icons.close,
                size: ScreenConstant.minimumIconSize,
                color: CustomColor.color64748B,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusIcon(MessageStatus s) {
    late final IconData icon;
    Color color = CustomColor.color94A3B8;
    switch (s) {
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = CustomColor.colorE11D48;
        break;
      case MessageStatus.sending:
        icon = Icons.schedule;
        break;
      case MessageStatus.sent:
        icon = Icons.done;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = CustomColor.colorBE185D;
        break;
    }
    return Icon(
      icon,
      size: ScreenConstant.minimumIconSize,
      color: color,
      semanticLabel: _statusLabel(s),
    );
  }

  static String _statusLabel(MessageStatus s) {
    switch (s) {
      case MessageStatus.failed:
        return 'Not sent';
      case MessageStatus.sending:
        return 'Sending';
      case MessageStatus.sent:
        return 'Sent';
      case MessageStatus.delivered:
        return 'Delivered';
      case MessageStatus.read:
        return 'Read';
    }
  }

  Widget _emptyState(FriendUser peer) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: ScreenConstant.sizeXXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: ScreenConstant.defaultIconSize,
              height: ScreenConstant.defaultIconSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: _brandGradient,
              ),
              child: Icon(
                Icons.waving_hand_outlined,
                size: ScreenConstant.texIconSize,
                color: CustomColor.colorWhite,
              ),
            ),
            SizedBox(height: ScreenConstant.sizeMedium),
            Text(
              'Say hi to ${peer.displayName}',
              textAlign: TextAlign.center,
              style: TextStyles.registerTitle.copyWith(fontSize: FontSize.s20),
            ),
            SizedBox(height: ScreenConstant.sizeExtraSmall),
            Text(
              'Start the conversation with a friendly hello.',
              textAlign: TextAlign.center,
              style: TextStyles.loginWelcomeSubtitle,
            ),
          ],
        ),
      ),
    );
  }

  /// DEMO "typing…" bubble under the list. TODO(api): realtime typing event.
  Widget _typingIndicator(FriendUser peer) {
    return Obx(() {
      final bool typing = controller.peerTyping.value;
      return Semantics(
        liveRegion: true,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: !typing
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: EdgeInsets.fromLTRB(
                    ScreenConstant.defaultWidthTen +
                        ScreenConstant.sizeExtraSmall,
                    0,
                    ScreenConstant.defaultWidthTen,
                    ScreenConstant.sizeSmall,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ScreenConstant.sizeSmallHighest,
                          vertical: ScreenConstant.sizeSmall,
                        ),
                        decoration: const BoxDecoration(
                          color: CustomColor.colorWhite,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                            bottomRight: Radius.circular(18),
                            bottomLeft: Radius.circular(4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (i) {
                            final double d =
                                ScreenConstant.defaultHeightFour * 2;
                            return Container(
                              width: d,
                              height: d,
                              margin: EdgeInsets.only(
                                left: i == 0
                                    ? 0
                                    : ScreenConstant.defaultHeightFour,
                              ),
                              decoration: const BoxDecoration(
                                color: CustomColor.color94A3B8,
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ),
                      ),
                      SizedBox(width: ScreenConstant.sizeSmall),
                      Flexible(
                        child: Text(
                          '${peer.displayName} is typing…',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.registerFieldNote.copyWith(
                            color: CustomColor.color64748B,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Composer
  // ---------------------------------------------------------------------------
  Widget _composer() {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: color),
    );

    return Container(
      decoration: const BoxDecoration(
        color: CustomColor.colorWhite,
        border: Border(top: BorderSide(color: CustomColor.colorE2E8F0)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(ScreenConstant.sizeSmall),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              Expanded(
                child: TextField(
                  controller: controller.textController,
                  focusNode: controller.inputFocus,
                  minLines: 1,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: controller.onDraftChanged,
                  style: TextStyles.loginFieldText.copyWith(
                    fontSize: FontSize.s15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type a message…',
                    hintStyle: TextStyles.loginFieldHint.copyWith(
                      fontSize: FontSize.s15,
                    ),
                    filled: true,
                    fillColor: CustomColor.colorF8FAFC,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: ScreenConstant.sizeMedium,
                      vertical: ScreenConstant.sizeSmallHighest,
                    ),
                    border: border(CustomColor.colorE2E8F0),
                    enabledBorder: border(CustomColor.colorE2E8F0),
                    focusedBorder: border(CustomColor.colorBE185D),
                  ),
                ),
              ),
             // SizedBox(width: ScreenConstant.sizeSmall),
              IconButton(
                tooltip: 'Emoji (coming soon)',
                icon: Icon(
                  Icons.emoji_emotions_outlined,
                  size: ScreenConstant.smallIconSize,
                  color: CustomColor.color64748B,
                ),
                onPressed: () => controller.comingSoon('Emoji'),
              ),
              // IconButton(
              //   tooltip: 'Attach (coming soon)',
              //   icon: Icon(
              //     Icons.attach_file,
              //     size: ScreenConstant.smallIconSize,
              //     color: CustomColor.color64748B,
              //   ),
              //   onPressed: () => controller.comingSoon('Attachments'),
              // ),
              Obx(() => _sendButton(controller.draft.value.trim().isNotEmpty)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sendButton(bool enabled) {
    final double size =
        ScreenConstant.defaultHeightForty + ScreenConstant.defaultHeightFour;
    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Send message',
      onTap: enabled ? controller.sendMessage : null,
      excludeSemantics: true,
      child: Tooltip(
        message: 'Send',
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: enabled ? _brandGradient : null,
              color: enabled ? null : CustomColor.colorE2E8F0,
            ),
            child: InkWell(
              onTap: enabled ? controller.sendMessage : null,
              child: Icon(
                Icons.send_rounded,
                size: ScreenConstant.smallIconSize,
                color: enabled
                    ? CustomColor.colorWhite
                    : CustomColor.color94A3B8,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Not-found fallback
  // ---------------------------------------------------------------------------
  Widget _notFound() {
    return Scaffold(
      backgroundColor: CustomColor.colorAF5FF,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: ScreenConstant.defaultIconSize,
                color: CustomColor.color94A3B8,
              ),
              SizedBox(height: ScreenConstant.sizeMedium),
              Text(
                'Chat unavailable',
                style: TextStyles.registerTitle.copyWith(
                  fontSize: FontSize.s20,
                ),
              ),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenConstant.sizeLarge,
                    vertical: ScreenConstant.sizeSmall,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: CustomColor.colorE2E8F0),
                  ),
                  child: Text('Go back', style: TextStyles.browseToggleLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
