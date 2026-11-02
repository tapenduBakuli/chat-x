import 'dart:math' as math;

import 'package:get/get.dart';

import '../model/friend.dart';
import '../services/block_services.dart';
import 'home_controller.dart';

/// Drives the Blocked tab (bottom nav index 4): the paged list of users I
/// blocked (GET users/blocked, page size [pageSize]) and the Unblock action
/// (DELETE users/{id}/block).
class BlockedController extends GetxController {
  static const int pageSize = 40;

  final RxList<BlockedUser> blockedUsers = <BlockedUser>[].obs;

  /// Server `total` (decremented on unblock) — shown in the section header.
  final RxInt total = 0.obs;

  /// A page-1 load is in flight (first load or pull-to-refresh).
  final RxBool isLoading = false.obs;

  /// True once the first page-1 load finished (success or failure). The UI
  /// shows the full-screen spinner only before this, so a pull-to-refresh on
  /// the empty state keeps its RefreshIndicator.
  final RxBool hasLoaded = false.obs;

  final RxBool isLoadingMore = false.obs;

  /// Raw server rows loaded so far (next page offset).
  final RxInt _offset = 0.obs;

  /// Bumped by every page-1 load so stale in-flight responses are dropped.
  int _gen = 0;

  bool get hasMore => _offset.value < total.value;

  /// Blocked USER ids currently being unblocked (per-row button spinner).
  final RxSet<String> busyUserIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    refreshBlocked();
  }

  /// Pull-to-refresh handler (resets to page 1).
  Future<void> onRefresh() => refreshBlocked();

  /// Loads page 1, replacing the list. On failure the existing list is kept
  /// and an error snackbar is shown (when [showError]).
  Future<void> refreshBlocked({bool showError = true}) async {
    final int gen = ++_gen;
    isLoadingMore.value = false;
    isLoading.value = true;
    try {
      final res = await BlockService.instance
          .fetchBlockedUsers(limit: pageSize, offset: 0);
      if (gen != _gen) return; // superseded by a newer page-1 load
      if (!res.success) {
        if (showError) {
          Get.snackbar('Could not load blocked users', res.message,
              snackPosition: SnackPosition.BOTTOM);
        }
        return;
      }
      blockedUsers.assignAll(res.items);
      total.value = res.total;
      _offset.value = res.items.length;
    } finally {
      if (gen == _gen) {
        isLoading.value = false;
        hasLoaded.value = true;
      }
    }
  }

  /// Appends the next page (no-op while loading or when everything is
  /// loaded).
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore) return;
    final int gen = _gen;
    isLoadingMore.value = true;
    try {
      final res = await BlockService.instance
          .fetchBlockedUsers(limit: pageSize, offset: _offset.value);
      if (gen != _gen) return;
      if (!res.success) {
        Get.snackbar('Could not load more', res.message,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      final known = blockedUsers.map((b) => b.user.id).toSet();
      blockedUsers.addAll(res.items.where((b) => !known.contains(b.user.id)));
      total.value = res.total;
      _offset.value += res.items.length;
      // Server returned nothing: stop paging (header count unchanged).
      if (res.items.isEmpty) _offset.value = total.value;
    } finally {
      if (gen == _gen) isLoadingMore.value = false;
    }
  }

  /// Unblock (DELETE by the blocked user's id). On success: remove the row,
  /// decrement the total, snackbar, and let Browse show the member again. On
  /// failure: error snackbar, row kept.
  Future<void> unblock(BlockedUser b) async {
    final String userId = b.user.id;
    if (userId.isEmpty || busyUserIds.contains(userId)) return;
    busyUserIds.add(userId);
    try {
      final res = await BlockService.instance.unblockUser(userId);
      if (!res.success) {
        Get.snackbar('Could not unblock', res.message,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      final int before = blockedUsers.length;
      blockedUsers.removeWhere((x) => x.user.id == userId);
      if (blockedUsers.length != before) {
        total.value = math.max(0, total.value - 1);
        // The server list shifted by one; keep the next page from skipping
        // a row.
        _offset.value = math.max(0, _offset.value - 1);
      }
      Get.snackbar(
        'Unblocked',
        res.message.isNotEmpty
            ? res.message
            : '${b.user.displayName} unblocked',
        snackPosition: SnackPosition.BOTTOM,
      );
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().onUserUnblocked(userId);
      }
    } finally {
      busyUserIds.remove(userId);
    }
  }
}
