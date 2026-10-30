import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../device_manager/screen_constants.dart';
import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';
import '../controller/notification_controller.dart';
import '../model/notification_model.dart';

/// Notifications list: pull down to refresh, scroll to the bottom to load the
/// next page. Unread items (is_read == false) are highlighted with a rose tint
/// + dot; read items render plain.
class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.colorAF5FF,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: CustomColor.colorWhite,
        centerTitle: true,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: Get.back,
          child: Icon(
            Icons.arrow_back_ios_new,
            size: ScreenConstant.smallIconSize,
            color: CustomColor.color0F172A,
          ),
        ),
        title: Text(
          "Notifications",
          textAlign: TextAlign.center,
          style: TextStyles.registerAppBarTitle,
        ),
        actions: [
          Obx(() {
            if (controller.isMarkingAll.value) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenConstant.sizeMedium,
                ),
                child: const Center(
                  child: SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          CustomColor.colorBE185D),
                    ),
                  ),
                ),
              );
            }
            final bool enabled = controller.unreadCount > 0;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: enabled ? controller.markAllAsRead : null,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenConstant.sizeMedium,
                  vertical: ScreenConstant.sizeSmall,
                ),
                child: Text(
                  "Mark all",
                  style: TextStyles.registerSubtitle.copyWith(
                    color: enabled
                        ? CustomColor.colorBE185D
                        : CustomColor.color94A3B8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        final items = controller.notifications;

        // First load with nothing to show yet.
        if (controller.isLoading.value && items.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(CustomColor.colorBE185D),
            ),
          );
        }

        return RefreshIndicator(
          color: CustomColor.colorBE185D,
          onRefresh: controller.onRefresh,
          child: items.isEmpty
              ? _buildEmptyOrError()
              : ListView.separated(
                  controller: controller.scrollController,
                  // Always scrollable so pull-to-refresh works on short lists.
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenConstant.defaultWidthTwenty,
                    vertical: ScreenConstant.sizeMedium,
                  ),
                  itemCount: items.length + 1, // +1 for the footer
                  separatorBuilder: (_, __) =>
                      SizedBox(height: ScreenConstant.sizeSmall),
                  itemBuilder: (context, index) {
                    if (index == items.length) return _buildFooter();
                    return _buildDismissible(items[index]);
                  },
                ),
        );
      }),
    );
  }

  // Empty / error states live inside a scrollable so pull-to-refresh works.
  Widget _buildEmptyOrError() {
    final bool hasError = controller.errorMessage.value.isNotEmpty;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: Get.height * 0.25),
        Icon(
          hasError ? Icons.cloud_off_outlined : Icons.notifications_none,
          size: 48,
          color: CustomColor.color94A3B8,
        ),
        SizedBox(height: ScreenConstant.sizeMedium),
        Text(
          hasError ? "Couldn't load notifications" : "No notifications yet",
          textAlign: TextAlign.center,
          style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s16),
        ),
        SizedBox(height: ScreenConstant.sizeExtraSmall),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenConstant.defaultWidthTwenty * 2,
          ),
          child: Text(
            hasError
                ? controller.errorMessage.value
                : "You'll see friend requests and updates here.",
            textAlign: TextAlign.center,
            style: TextStyles.registerFieldNote,
          ),
        ),
        if (hasError) ...[
          SizedBox(height: ScreenConstant.sizeMedium),
          Center(
            child: TextButton(
              onPressed: controller.fetchFirstPage,
              child: Text(
                "Retry",
                style: TextStyles.loginForgotPassword
                    .copyWith(fontSize: FontSize.s14),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Bottom of the list: spinner while loading the next page, otherwise a
  // subtle end marker once everything is loaded.
  Widget _buildFooter() {
    if (controller.isLoadingMore.value) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: ScreenConstant.sizeMedium),
        child: const Center(
          child: SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(CustomColor.colorBE185D),
            ),
          ),
        ),
      );
    }
    if (!controller.hasMore && controller.notifications.length > 5) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: ScreenConstant.sizeMedium),
        child: Text(
          "You're all caught up",
          textAlign: TextAlign.center,
          style: TextStyles.registerFieldNote,
        ),
      );
    }
    return SizedBox(height: ScreenConstant.sizeMedium);
  }

  /// Swipe left to delete. The DELETE call runs in confirmDismiss: the row is
  /// only removed if the API succeeds (otherwise it springs back and a
  /// snackbar explains why). After success the list is re-fetched.
  Widget _buildDismissible(NotificationItem n) {
    return Dismissible(
      key: ValueKey(n.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => controller.deleteNotification(n),
      onDismissed: (_) => controller.onNotificationDeleted(n),
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: ScreenConstant.sizeLarge),
        decoration: BoxDecoration(
          color: CustomColor.colorE11D48,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_outline, color: CustomColor.colorWhite),
            SizedBox(width: ScreenConstant.sizeExtraSmall),
            Text(
              "Delete",
              style: TextStyles.loginButtonText.copyWith(
                fontSize: FontSize.s14,
              ),
            ),
          ],
        ),
      ),
      child: _buildTile(n),
    );
  }

  Widget _buildTile(NotificationItem n) {
    final bool unread = !n.isRead;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.markAsRead(n),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(ScreenConstant.sizeMedium),
        decoration: BoxDecoration(
          // Unread = rose tint + rose border; read = plain white.
          color: unread ? CustomColor.colorFFF1F2 : CustomColor.colorWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unread ? CustomColor.colorFECDD3 : CustomColor.colorE2E8F0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: ScreenConstant.defaultHeightForty,
              width: ScreenConstant.defaultWidthForty,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: unread
                    ? CustomColor.colorWhite
                    : CustomColor.colorF8FAFC,
              ),
              child: Icon(
                _iconFor(n.eventType),
                size: ScreenConstant.smallIconSize,
                color: unread
                    ? CustomColor.colorBE185D
                    : CustomColor.color94A3B8,
              ),
            ),
            SizedBox(width: ScreenConstant.sizeMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.registerFieldLabel.copyWith(
                            color: CustomColor.color0F172A,
                            fontWeight:
                                unread ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: ScreenConstant.sizeSmall),
                      Text(
                        _timeAgo(n.createdAt),
                        style: TextStyles.registerFieldNote.copyWith(
                          fontSize: FontSize.s11,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    n.body,
                    style: TextStyles.registerFieldNote.copyWith(
                      color: unread
                          ? CustomColor.color334155
                          : CustomColor.color64748B,
                    ),
                  ),
                ],
              ),
            ),
            if (unread) ...[
              SizedBox(width: ScreenConstant.sizeSmall),
              Container(
                margin: const EdgeInsets.only(top: 6),
                height: 8,
                width: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: CustomColor.colorBE185D,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String eventType) {
    switch (eventType) {
      case 'friend_request':
        return Icons.person_add_alt_1_outlined;
      case 'friend_accept':
      case 'friend_accepted':
        return Icons.how_to_reg_outlined;
      case 'message':
      case 'new_message':
        return Icons.chat_bubble_outline;
      case 'match':
        return Icons.favorite_border;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  /// "just now", "5m", "3h", "2d", else "12 Oct".
  String _timeAgo(DateTime? t) {
    if (t == null) return '';
    final diff = DateTime.now().difference(t.toLocal());
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final l = t.toLocal();
    return '${l.day} ${months[l.month - 1]}';
  }
}
