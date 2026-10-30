import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../device_manager/screen_constants.dart';
import '../../../../utils/TextStyles.dart';
import '../../../../utils/colors/app_colors.dart';
import '../../controller/friends_controller.dart';
import '../../model/friend.dart';
import 'member_network_image.dart';

/// Friends tab (bottom nav index 2): "Friend Requests" first, then
/// "My Friends". Each section is hidden when its list is empty; when both are
/// empty the caller-supplied [emptyState] is shown (still pull-to-refresh).
class FriendsTab extends StatelessWidget {
  /// Shown when there are no requests and no friends.
  final Widget emptyState;

  const FriendsTab({super.key, required this.emptyState});

  FriendsController get controller => Get.find<FriendsController>();

  /// Clears the floating bottom nav bar.
  static const double _bottomNavClearance = 80;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool loading = controller.isLoading.value;
      final List<FriendUser> requests = controller.friendRequests.toList();
      final List<FriendUser> friends = controller.friends.toList();

      // First load: same spinner as the Explore tab.
      if (loading && requests.isEmpty && friends.isEmpty) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: const AlwaysStoppedAnimation<Color>(
              CustomColor.colorBE185D,
            ),
          ),
        );
      }

      if (requests.isEmpty && friends.isEmpty) {
        return _buildEmpty();
      }

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
                "Friends",
                style: TextStyles.registerTitle.copyWith(
                  fontSize: FontSize.s24,
                ),
              ),
              SizedBox(height: ScreenConstant.sizeExtraSmall),
              Text(
                "Review incoming requests and keep in touch with your friends.",
                style: TextStyles.loginWelcomeSubtitle,
              ),
              SizedBox(height: ScreenConstant.sizeMedium),
              if (requests.isNotEmpty) ...[
                _sectionHeader(
                  Icons.person_add_alt_1_outlined,
                  "Friend Requests",
                  requests.length,
                ),
                SizedBox(height: ScreenConstant.sizeSmall),
                ...requests.map(
                  (r) => Padding(
                    padding: EdgeInsets.only(bottom: ScreenConstant.sizeSmall),
                    child: _requestCard(r),
                  ),
                ),
                SizedBox(height: ScreenConstant.sizeMedium),
              ],
              if (friends.isNotEmpty) ...[
                _sectionHeader(
                  Icons.people_outline,
                  "My Friends",
                  friends.length,
                ),
                SizedBox(height: ScreenConstant.sizeSmall),
                ...friends.map(
                  (f) => Padding(
                    padding: EdgeInsets.only(bottom: ScreenConstant.sizeSmall),
                    child: _friendCard(context, f),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Empty state — the original placeholder, made pull-to-refreshable.
  // ---------------------------------------------------------------------------
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

  // ---------------------------------------------------------------------------
  // Shared building blocks (same look as the Accounts cards)
  // ---------------------------------------------------------------------------

  /// White rounded card with the standard soft shadow.
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenConstant.sizeSmallHighest),
      decoration: BoxDecoration(
        color: CustomColor.colorWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CustomColor.color717B96.withOpacity(0.12),
            blurRadius: 16,
            spreadRadius: -6,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Rose icon + bold title + gradient count pill.
  Widget _sectionHeader(IconData icon, String title, int count) {
    return Row(
      children: [
        Icon(icon, size: ScreenConstant.smallIconSize,
            color: CustomColor.colorBE185D),
        SizedBox(width: ScreenConstant.sizeSmall),
        Text(
          title,
          style: TextStyles.registerSectionTitle.copyWith(
            fontSize: FontSize.s16,
            color: CustomColor.color0F172A,
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
    );
  }

  /// Circular avatar; initials when there is no photo. [showOnline] adds the
  /// green presence dot.
  Widget _avatar(FriendUser user, {bool showOnline = false}) {
    final double size = ScreenConstant.defaultWidthFifty;
    return SizedBox(
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
                        _initials(user.displayName),
                        style: TextStyles.registerSectionTitle.copyWith(
                          fontSize: FontSize.s16,
                          color: CustomColor.colorWhite,
                        ),
                      ),
                    ),
            ),
          ),
          if (showOnline && user.isOnline)
            Positioned(
              right: 1,
              bottom: 1,
              child: Container(
                width: ScreenConstant.sizeSmallHighest,
                height: ScreenConstant.sizeSmallHighest,
                decoration: BoxDecoration(
                  color: CustomColor.color10B981,
                  shape: BoxShape.circle,
                  border: Border.all(color: CustomColor.colorWhite, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// "Name, 33" (age omitted when unknown) + subtitle line.
  Widget _nameBlock(FriendUser user, {String? trailingNote}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                user.age > 0
                    ? "${user.displayName}, ${user.age}"
                    : user.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.registerSectionTitle.copyWith(
                  fontSize: FontSize.s15,
                  color: CustomColor.color0F172A,
                ),
              ),
            ),
            if (trailingNote != null) ...[
              SizedBox(width: ScreenConstant.sizeExtraSmall),
              Text(trailingNote, style: TextStyles.registerFieldNote),
            ],
          ],
        ),
        if (user.subtitle.isNotEmpty) ...[
          SizedBox(height: ScreenConstant.defaultHeightFour / 2),
          Text(
            user.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.loginWelcomeSubtitle.copyWith(
              fontSize: FontSize.s12,
            ),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Friend Requests
  // ---------------------------------------------------------------------------
  Widget _requestCard(FriendUser user) {
    return _card(
      child: Column(
        children: [
          Row(
            children: [
              _avatar(user),
              SizedBox(width: ScreenConstant.sizeSmallHighest),
              Expanded(
                child: _nameBlock(
                  user,
                  trailingNote:
                      user.since == null ? null : _timeAgo(user.since!),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenConstant.sizeSmallHighest),
          Obx(() {
            final bool busy = controller.busyRequestIds.contains(user.id);
            return Row(
              children: [
                Expanded(child: _acceptButton(user, busy)),
                SizedBox(width: ScreenConstant.sizeSmall),
                Expanded(child: _declineButton(user, busy)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _acceptButton(FriendUser user, bool busy) {
    return GestureDetector(
      onTap: busy ? null : () => controller.acceptRequest(user),
      child: Container(
        height: ScreenConstant.defaultHeightForty,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              CustomColor.colorBE185D,
              CustomColor.color581C87,
            ],
          ),
        ),
        // Same loader as Login: white spinner inside the gradient pill.
        child: busy
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(CustomColor.colorWhite),
                ),
              )
            : Text(
                "Accept",
                style: TextStyles.loginButtonText.copyWith(
                  fontSize: FontSize.s14,
                  color: CustomColor.colorWhite,
                ),
              ),
      ),
    );
  }

  Widget _declineButton(FriendUser user, bool busy) {
    return GestureDetector(
      onTap: busy ? null : () => controller.declineRequest(user),
      child: Opacity(
        opacity: busy ? 0.5 : 1,
        child: Container(
          height: ScreenConstant.defaultHeightForty,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: CustomColor.colorWhite,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: CustomColor.colorE2E8F0, width: 1.5),
          ),
          child: Text(
            "Decline",
            style: TextStyles.loginButtonText.copyWith(
              fontSize: FontSize.s14,
              color: CustomColor.color475569,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // My Friends
  // ---------------------------------------------------------------------------
  Widget _friendCard(BuildContext context, FriendUser user) {
    return _card(
      child: Row(
        children: [
          _avatar(user, showOnline: true),
          SizedBox(width: ScreenConstant.sizeSmallHighest),
          Expanded(child: _nameBlock(user)),
          SizedBox(width: ScreenConstant.sizeExtraSmall),
          Material(
            color: CustomColor.colorFDF2F8,
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: "Chat",
              onPressed: () => controller.openChat(user),
              icon: Icon(
                Icons.chat_bubble_outline,
                size: ScreenConstant.smallIconSize,
                color: CustomColor.colorBE185D,
              ),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: "More",
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
              if (value == 'remove') _confirmRemove(context, user);
            },
            itemBuilder: (_) => [
              PopupMenuItem<String>(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(
                      Icons.person_remove_outlined,
                      size: ScreenConstant.smallIconSize,
                      color: CustomColor.colorE11D48,
                    ),
                    SizedBox(width: ScreenConstant.sizeSmall),
                    Text(
                      "Remove friend",
                      style: TextStyles.loginWelcome.copyWith(
                        fontSize: FontSize.s14,
                        color: CustomColor.colorE11D48,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Same dialog look as the Accounts "Delete account?" confirm.
  void _confirmRemove(BuildContext context, FriendUser user) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: CustomColor.colorWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Remove friend?",
            style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s18),
          ),
          content: Text(
            "${user.displayName} will be removed from your friends list.",
            style: TextStyles.loginWelcomeSubtitle,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "Cancel",
                style: TextStyles.loginWelcome.copyWith(
                  fontSize: FontSize.s14,
                  color: CustomColor.color64748B,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                controller.removeFriend(user);
              },
              child: Text(
                "Remove",
                style: TextStyles.loginWelcome.copyWith(
                  fontSize: FontSize.s14,
                  color: CustomColor.colorE11D48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
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

  /// "just now", "12m ago", "3h ago", "4d ago".
  static String _timeAgo(DateTime since) {
    final diff = DateTime.now().difference(since);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
