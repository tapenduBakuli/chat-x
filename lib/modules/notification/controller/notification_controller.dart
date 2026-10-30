import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../home/controller/home_controller.dart';
import '../model/notification_model.dart';
import '../services/notification_services.dart';

/// Drives the Notifications screen: first page on open, pull-to-refresh
/// (reloads from offset 0), and infinite-scroll pagination (loads the next
/// page when the user nears the bottom).
class NotificationController extends GetxController {
  /// Page size sent as `limit`.
  static const int pageSize = 20;

  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;

  /// First load (or refresh with nothing shown yet) — full-screen spinner.
  final RxBool isLoading = false.obs;

  /// Loading the next page — small spinner at the bottom of the list.
  final RxBool isLoadingMore = false.obs;

  /// Error from the last first-page load, shown with a Retry when the list is
  /// empty.
  final RxString errorMessage = ''.obs;

  /// Server-reported total; used to know whether more pages exist.
  int _total = 0;

  final ScrollController scrollController = ScrollController();

  bool get hasMore => notifications.length < _total;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    fetchFirstPage();
  }

  /// Loads page 1 (offset 0). Used on open, by pull-to-refresh, and by Retry.
  Future<void> fetchFirstPage() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await NotificationService.instance
          .fetchNotifications(limit: pageSize, offset: 0);
      if (res.success) {
        notifications.assignAll(res.items);
        _total = res.total;
      } else {
        errorMessage.value = res.message;
        // Keep any list already on screen; only surface the error.
        if (notifications.isNotEmpty) {
          Get.snackbar('Could not refresh', res.message,
              snackPosition: SnackPosition.BOTTOM);
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Pull-to-refresh handler (RefreshIndicator needs a Future).
  Future<void> onRefresh() => fetchFirstPage();

  /// Loads the next page using offset = items already loaded.
  Future<void> fetchNextPage() async {
    if (isLoading.value || isLoadingMore.value || !hasMore) return;
    isLoadingMore.value = true;
    try {
      final res = await NotificationService.instance.fetchNotifications(
        limit: pageSize,
        offset: notifications.length,
      );
      if (res.success) {
        // De-dupe in case items shifted between pages.
        final existing = notifications.map((n) => n.id).toSet();
        notifications.addAll(res.items.where((n) => !existing.contains(n.id)));
        _total = res.total;
        // Stop paging if the server returned nothing new.
        if (res.items.isEmpty) _total = notifications.length;
      } else {
        Get.snackbar('Could not load more', res.message,
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final pos = scrollController.position;
    // Start loading a bit before the very bottom.
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      fetchNextPage();
    }
  }

  /// Whether "Mark all" is in flight.
  final RxBool isMarkingAll = false.obs;

  /// Tap on a notification: POST /notifications/{id}/read. Updates the
  /// highlight immediately (optimistic) and reverts if the API fails.
  Future<void> markAsRead(NotificationItem item) async {
    if (item.isRead) return;
    _setRead(item.id, true);

    final res = await NotificationService.instance.markAsRead(item.id);
    if (!res.success) {
      _setRead(item.id, false); // revert
      Get.snackbar('Could not mark as read', res.message,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    _refreshHomeBadge();
  }

  /// "Mark all": POST /notifications/read-all. Optimistic; reverts on failure.
  Future<void> markAllAsRead() async {
    if (isMarkingAll.value || unreadCount == 0) return;
    isMarkingAll.value = true;

    final snapshot = notifications.toList();
    notifications.assignAll(
      notifications.map((n) => n.isRead ? n : n.copyWith(isRead: true)),
    );
    try {
      final res = await NotificationService.instance.markAllAsRead();
      if (!res.success) {
        notifications.assignAll(snapshot); // revert
        Get.snackbar('Could not mark all as read', res.message,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      _refreshHomeBadge();
    } finally {
      isMarkingAll.value = false;
    }
  }

  /// DELETE /notifications/{id}. Returns true on success (200/204). The caller
  /// (swipe-to-delete) removes the row; then the list is re-fetched from the
  /// GET API so pagination/total stay correct.
  Future<bool> deleteNotification(NotificationItem item) async {
    final res = await NotificationService.instance.deleteNotification(item.id);
    if (!res.success) {
      Get.snackbar('Could not delete', res.message,
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    return true;
  }

  /// Called right after a successful swipe-delete: drop the row locally (a
  /// dismissed Dismissible must leave the tree immediately), then refresh the
  /// list and the home badge from the server.
  void onNotificationDeleted(NotificationItem item) {
    notifications.removeWhere((n) => n.id == item.id);
    if (_total > 0) _total--;
    fetchFirstPage();
    _refreshHomeBadge();
  }

  void _setRead(String id, bool read) {
    final i = notifications.indexWhere((n) => n.id == id);
    if (i != -1) notifications[i] = notifications[i].copyWith(isRead: read);
  }

  /// Keep the home bell badge in sync with server-side read state.
  void _refreshHomeBadge() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().refreshUnreadNotifications(force: true);
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
