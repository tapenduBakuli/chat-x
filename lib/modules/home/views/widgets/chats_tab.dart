import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../device_manager/screen_constants.dart';
import '../../../../utils/TextStyles.dart';
import '../../../../utils/colors/app_colors.dart';
import '../../../chat/model/conversation_model.dart';
import '../../controller/conversations_controller.dart';
import '../../model/friend.dart';
import 'member_network_image.dart';

/// Chat tab (bottom nav index 1): the user's conversations. When the list is
/// empty the caller-supplied [emptyState] is shown (still pull-to-refresh).
class ChatsTab extends StatelessWidget {
  /// Shown when there are no conversations.
  final Widget emptyState;

  const ChatsTab({super.key, required this.emptyState});

  ConversationsController get controller => Get.find<ConversationsController>();

  /// Clears the floating bottom nav bar.
  static const double _bottomNavClearance = 80;

  static const List<String> _months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool loading = controller.isLoading.value;
      final bool hasLoaded = controller.hasLoaded.value;
      final List<Conversation> list = controller.conversations.toList();
      final int count = math.max(controller.total.value, list.length);

      if (list.isEmpty && (loading || !hasLoaded)) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: const AlwaysStoppedAnimation<Color>(
              CustomColor.colorBE185D,
            ),
          ),
        );
      }
      if (list.isEmpty) return _buildEmpty();

      return RefreshIndicator(
        color: CustomColor.colorBE185D,
        onRefresh: controller.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            ScreenConstant.defaultWidthTwenty,
            ScreenConstant.defaultHeightTen,
            ScreenConstant.defaultWidthTwenty,
            _bottomNavClearance,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Messages",
                style: TextStyles.registerTitle.copyWith(
                  fontSize: FontSize.s24,
                ),
              ),
              SizedBox(height: ScreenConstant.sizeExtraSmall),
              Text("Your conversations", style: TextStyles.loginWelcomeSubtitle),
              SizedBox(height: ScreenConstant.sizeMedium),
              _sectionTitleRow(Icons.chat_bubble_outline, "Chats", count),
              SizedBox(height: ScreenConstant.sizeSmall),
              ...list.map(
                (c) => Padding(
                  padding: EdgeInsets.only(bottom: ScreenConstant.sizeSmall),
                  child: _conversationCard(c),
                ),
              ),
              _loadMoreFooter(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEmpty() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          color: CustomColor.colorBE185D,
          onRefresh: controller.onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                minHeight: constraints.maxHeight,
              ),
              child: Center(child: emptyState),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitleRow(IconData icon, String title, int count) {
    return Semantics(
      header: true,
      label: "$title, $count",
      excludeSemantics: true,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: ScreenConstant.sizeExtraSmall),
        child: Row(
          children: [
            Icon(icon,
                size: ScreenConstant.smallIconSize,
                color: CustomColor.colorBE185D),
            SizedBox(width: ScreenConstant.sizeSmall),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.registerSectionTitle.copyWith(
                  fontSize: FontSize.s16,
                  color: CustomColor.color0F172A,
                ),
              ),
            ),
            SizedBox(width: ScreenConstant.sizeSmall),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenConstant.sizeSmall,
                vertical: ScreenConstant.sizeExtraSmall / 1.6,
              ),
              decoration: BoxDecoration(
                color: CustomColor.colorFCE7F3,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                "$count",
                style: TextStyles.registerFieldNote.copyWith(
                  color: CustomColor.colorBE185D,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Conversation card
  // ---------------------------------------------------------------------------
  Widget _conversationCard(Conversation c) {
    final FriendUser user = c.otherUser;
    final String name =
        user.displayName.trim().isEmpty ? "Unknown" : user.displayName.trim();
    final String label = c.unreadCount > 0
        ? "Open chat with $name, ${c.unreadCount} unread"
        : "Open chat with $name";
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: CustomColor.colorWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CustomColor.color717B96.withValues(alpha: 0.12),
              blurRadius: 16,
              spreadRadius: -6,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => controller.openConversation(c),
            child: Padding(
              padding: EdgeInsets.all(ScreenConstant.sizeSmallHighest),
              child: Row(
                children: [
                  _avatar(user, name),
                  SizedBox(width: ScreenConstant.sizeSmallHighest),
                  Expanded(child: _textBlock(c, name)),
                  SizedBox(width: ScreenConstant.sizeSmall),
                  _trailing(c),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatar(FriendUser user, String name) {
    final double size = ScreenConstant.defaultWidthFifty;
    return Container(
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      CustomColor.colorBE185D,
                      CustomColor.color581C87,
                    ],
                  ),
                ),
                child: Text(
                  _initials(name),
                  style: TextStyles.registerSectionTitle.copyWith(
                    fontSize: FontSize.s16,
                    color: CustomColor.colorWhite,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _textBlock(Conversation c, String name) {
    final FriendUser user = c.otherUser;
    final bool unread = c.unreadCount > 0;
    final String snippet = c.lastMessageSnippet?.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          user.age > 0 ? "$name, ${user.age}" : name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.registerSectionTitle.copyWith(
            fontSize: FontSize.s15,
            color: CustomColor.color0F172A,
          ),
        ),
        SizedBox(height: ScreenConstant.defaultHeightFour / 2),
        if (snippet.isNotEmpty)
          Text(
            snippet,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.loginWelcomeSubtitle.copyWith(
              fontSize: FontSize.s12,
              color: unread ? CustomColor.color0F172A : CustomColor.color64748B,
              fontWeight: unread ? FontWeight.w600 : FontWeight.normal,
            ),
          )
        else
          Text(
            "No messages yet — say hi",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.loginWelcomeSubtitle.copyWith(
              fontSize: FontSize.s12,
              color: CustomColor.color94A3B8,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _trailing(Conversation c) {
    final bool unread = c.unreadCount > 0;
    final DateTime? at = c.lastMessageAt;
    if (at == null && !unread) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (at != null)
          Text(
            _timeLabel(at),
            style: TextStyles.registerFieldNote.copyWith(
              fontSize: FontSize.s11,
              color: unread ? CustomColor.colorBE185D : CustomColor.color64748B,
            ),
          ),
        if (at != null && unread) SizedBox(height: ScreenConstant.sizeExtraSmall),
        if (unread)
          Container(
            constraints: const BoxConstraints(minWidth: 20),
            padding: EdgeInsets.symmetric(
              horizontal: ScreenConstant.sizeSmall,
              vertical: ScreenConstant.sizeExtraSmall / 1.6,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [CustomColor.colorBE185D, CustomColor.color581C87],
              ),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              c.unreadCount > 99 ? "99+" : "${c.unreadCount}",
              style: TextStyles.registerFieldNote.copyWith(
                fontSize: FontSize.s11,
                color: CustomColor.colorWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  /// Spinner while the next page loads, "Load more" while the server has
  /// more rows, otherwise nothing.
  Widget _loadMoreFooter() {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return Padding(
          padding: EdgeInsets.only(bottom: ScreenConstant.sizeSmall),
          child: const Center(
            child: SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(CustomColor.colorBE185D),
              ),
            ),
          ),
        );
      }
      // Read directly so the footer rebuilds when the total changes.
      controller.total.value;
      if (!controller.hasMore) return const SizedBox.shrink();
      return Center(
        child: Semantics(
          button: true,
          label: "Load more conversations",
          excludeSemantics: true,
          child: TextButton(
            onPressed: controller.loadMore,
            child: Text(
              "Load more",
              style: TextStyles.loginWelcome.copyWith(
                fontSize: FontSize.s14,
                color: CustomColor.colorBE185D,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  /// "now", "12m", "3h", "Yesterday", "Nov 4" (", 2025" if another year).
  static String _timeLabel(DateTime at) {
    final now = DateTime.now();
    final diff = now.difference(at);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (at.year == now.year && at.month == now.month && at.day == now.day) {
      return '${diff.inHours}h';
    }
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    if (at.year == yesterday.year &&
        at.month == yesterday.month &&
        at.day == yesterday.day) {
      return 'Yesterday';
    }
    final base = '${_months[at.month - 1]} ${at.day}';
    return at.year == now.year ? base : '$base, ${at.year}';
  }
}
