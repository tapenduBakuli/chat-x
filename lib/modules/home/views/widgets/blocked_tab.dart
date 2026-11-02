import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../device_manager/screen_constants.dart';
import '../../../../utils/TextStyles.dart';
import '../../../../utils/colors/app_colors.dart';
import '../../controller/blocked_controller.dart';
import '../../model/friend.dart';
import 'member_network_image.dart';

/// Blocked tab (bottom nav index 4): a single "Blocked Users" section styled
/// like Friends > "Sent Requests", with an "Unblock" pill per row. When the
/// list is empty the caller-supplied [emptyState] is shown (still
/// pull-to-refresh).
class BlockedTab extends StatelessWidget {
  /// Shown when there are no blocked users.
  final Widget emptyState;

  const BlockedTab({super.key, required this.emptyState});

  BlockedController get controller => Get.find<BlockedController>();

  /// Clears the floating bottom nav bar.
  static const double _bottomNavClearance = 80;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool loading = controller.isLoading.value;
      final bool hasLoaded = controller.hasLoaded.value;
      final List<BlockedUser> blocked = controller.blockedUsers.toList();
      final int count = math.max(controller.total.value, blocked.length);

      // First load: same spinner as the Friends tab.
      if (blocked.isEmpty && (loading || !hasLoaded)) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: const AlwaysStoppedAnimation<Color>(
              CustomColor.colorBE185D,
            ),
          ),
        );
      }

      if (blocked.isEmpty) {
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
                "Blocked",
                style: TextStyles.registerTitle.copyWith(
                  fontSize: FontSize.s24,
                ),
              ),
              SizedBox(height: ScreenConstant.sizeExtraSmall),
              Text(
                "Members you blocked. Unblock to see them in Browse again.",
                style: TextStyles.loginWelcomeSubtitle,
              ),
              SizedBox(height: ScreenConstant.sizeMedium),
              _sectionTitleRow(Icons.block, "Blocked Users", count),
              SizedBox(height: ScreenConstant.sizeSmall),
              ...blocked.map(
                (b) => Padding(
                  padding: EdgeInsets.only(bottom: ScreenConstant.sizeSmall),
                  child: _blockedCard(context, b),
                ),
              ),
              _loadMoreFooter(),
            ],
          ),
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Empty state — pull-to-refreshable.
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
  // Building blocks (copied from FriendsTab so both stay independent)
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
            color: CustomColor.color717B96.withValues(alpha: 0.12),
            blurRadius: 16,
            spreadRadius: -6,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Rose icon + bold title + count pill (non-collapsible header).
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

  /// Circular avatar (initials when there is no photo) with a translucent
  /// overlay holding a red block icon.
  Widget _avatar(FriendUser user) {
    final double size = ScreenConstant.defaultWidthFifty;
    return Semantics(
      label: "${user.displayName}, blocked",
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
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
            // Blocked indicator over the avatar.
            Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CustomColor.colorWhite.withValues(alpha: 0.55),
              ),
              child: Icon(
                Icons.block,
                size: size * 0.6,
                color: CustomColor.colorBE123C,
              ),
            ),
          ],
        ),
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
  // Blocked row
  // ---------------------------------------------------------------------------
  Widget _blockedCard(BuildContext context, BlockedUser b) {
    final FriendUser user = b.user;
    return _card(
      child: Row(
        children: [
          _avatar(user),
          SizedBox(width: ScreenConstant.sizeSmallHighest),
          Expanded(
            child: _nameBlock(
              user,
              trailingNote: user.since == null ? null : _timeAgo(user.since!),
            ),
          ),
          SizedBox(width: ScreenConstant.sizeSmall),
          Obx(() {
            final bool busy = controller.busyUserIds.contains(user.id);
            return SizedBox(
              width: ScreenConstant.defaultWidthEighty,
              child: _unblockButton(context, b, busy),
            );
          }),
        ],
      ),
    );
  }

  /// Outlined pill matching the Sent "Cancel"; grey spinner while
  /// unblocking.
  Widget _unblockButton(BuildContext context, BlockedUser b, bool busy) {
    final FriendUser user = b.user;
    return Semantics(
      button: true,
      enabled: !busy,
      label: busy
          ? "Unblocking ${user.displayName}"
          : "Unblock ${user.displayName}",
      excludeSemantics: true,
      child: GestureDetector(
        onTap: busy ? null : () => _confirmUnblock(context, b),
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
            child: busy
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        CustomColor.color475569,
                      ),
                    ),
                  )
                : Text(
                    "Unblock",
                    style: TextStyles.loginButtonText.copyWith(
                      fontSize: FontSize.s14,
                      color: CustomColor.color475569,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// Same dialog look as the "Cancel request?" confirm.
  void _confirmUnblock(BuildContext context, BlockedUser b) {
    final FriendUser user = b.user;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: CustomColor.colorWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Unblock ${user.displayName}?",
            style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s18),
          ),
          content: Text(
            "${user.displayName} may appear in Browse again.",
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
                // Async; the pill shows a spinner via busyUserIds.
                controller.unblock(b);
              },
              child: Text(
                "Unblock",
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
      if (!controller.hasMore) return const SizedBox.shrink();
      return Center(
        child: Semantics(
          button: true,
          label: "Load more blocked users",
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

  /// "just now", "12m ago", "3h ago", "4d ago".
  static String _timeAgo(DateTime since) {
    final diff = DateTime.now().difference(since);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
