import 'dart:math' as math;

import 'package:get/get.dart';

import '../../../routes/routes.dart';
import '../../chat/model/conversation_model.dart';
import '../../chat/services/chat_websocket_service.dart';
import '../../chat/services/conversation_services.dart';
import '../model/friend.dart';
import '../model/member.dart';
import '../services/friend_services.dart';
import 'conversations_controller.dart';
import 'home_controller.dart';

/// Drives the Friends tab: a single "Saved profiles" list (GET friends, paged,
/// page size [pageSize]) with message + remove actions. The old friend-request
/// sections are kept below as commented `[OLD FLOW]` blocks.
class FriendsController extends GetxController {
  static const int pageSize = 20;

  // [OLD FLOW – friend requests, disabled 2026-11]
  // // --- Friend Requests (GET friends/requests) -------------------------------
  // final RxList<IncomingFriendRequest> friendRequests =
  //     <IncomingFriendRequest>[].obs;

  // /// Server `total` for incoming requests — shown in the section header.
  // final RxInt incomingTotal = 0.obs;

  // /// Raw server rows loaded so far (next page offset).
  // final RxInt _incomingOffset = 0.obs;

  // final RxBool isLoadingMoreIncoming = false.obs;

  // /// Bumped by every page-1 load so stale in-flight responses are dropped.
  // int _incomingGen = 0;

  // bool get hasMoreIncoming => _incomingOffset.value < incomingTotal.value;

  // // --- My Friends (GET friends) ---------------------------------------------
  // final RxList<Friendship> friends = <Friendship>[].obs;

  // /// Server `total` for friends — shown in the section header.
  // final RxInt friendsTotal = 0.obs;

  // /// Raw server rows loaded so far (next page offset).
  // final RxInt _friendsOffset = 0.obs;

  // final RxBool isLoadingMoreFriends = false.obs;

  // /// Bumped by every page-1 load so stale in-flight responses are dropped.
  // int _friendsGen = 0;

  // bool get hasMoreFriends => _friendsOffset.value < friendsTotal.value;

  // // --- Sent Requests (GET friends/requests/sent) ----------------------------
  // /// Pending requests I sent. Refreshed by HomeController after a successful
  // /// send from Browse.
  // final RxList<SentFriendRequest> sentRequests = <SentFriendRequest>[].obs;

  // /// Server `total` for sent requests (decremented on cancel) — shown in the
  // /// section header.
  // final RxInt sentTotal = 0.obs;

  // /// Raw server rows loaded so far (next page offset).
  // final RxInt _sentOffset = 0.obs;

  // final RxBool isLoadingMoreSent = false.obs;

  // /// Bumped by every page-1 load so stale in-flight responses are dropped.
  // int _sentGen = 0;

  // bool get hasMoreSent => _sentOffset.value < sentTotal.value;
  // [/OLD FLOW]
  // --- Saved profiles (GET friends) -----------------------------------------
  /// "Group by status" toggle and the two section expanded states. Session
  /// only (not persisted across app restarts); they live here so they survive
  /// tab switches.
  final RxBool groupByStatus = false.obs;
  final RxBool activeExpanded = true.obs;
  final RxBool inactiveExpanded = true.obs;

  final RxList<SavedProfile> saved = <SavedProfile>[].obs;

  /// Server `total` for saved profiles — shown in the section header.
  final RxInt savedTotal = 0.obs;

  /// Raw server rows loaded so far (next page offset).
  final RxInt _savedOffset = 0.obs;

  final RxBool isLoadingMoreSaved = false.obs;

  /// Bumped by every page-1 load so stale in-flight responses are dropped.
  int _savedGen = 0;

  bool get hasMoreSaved => _savedOffset.value < savedTotal.value;


  final RxBool isLoading = false.obs;

  // [OLD FLOW – friend requests, disabled 2026-11]
  // /// Incoming request ids (`requestId`) currently being accepted/declined
  // /// (per-row button spinner).
  // final RxSet<String> busyRequestIds = <String>{}.obs;

  // /// Subset of [busyRequestIds] being declined (spinner on Decline instead
  // /// of Accept).
  // final RxSet<String> decliningRequestIds = <String>{}.obs;

  // /// Subset of [busyRequestIds] being deleted (spinner on the trash icon
  // /// instead of Accept).
  // final RxSet<String> deletingRequestIds = <String>{}.obs;

  // /// Sent request ids (`requestId`) currently being cancelled.
  // final RxSet<String> busySentIds = <String>{}.obs;
  // [/OLD FLOW]

  /// Friends' USER ids (`f.user.id`) currently being removed. Separate from
  /// the request-id sets so ids never collide.
  final RxSet<String> busyFriendIds = <String>{}.obs;
  /// Friends' USER ids (`f.user.id`) for which POST conversations is
  /// in-flight (opening chat). Treated as busy in the UI like
  /// [busyFriendIds] so the chat icon shows a spinner and the Remove menu
  /// is disabled while opening.
  final RxSet<String> openingChatIds = <String>{}.obs;

  // [OLD FLOW – friend requests, disabled 2026-11]
  // /// Collapsible section state. Expanded by default; lives on the controller
  // /// so it survives tab switches during the session.
  // final RxBool requestsExpanded = true.obs;
  // final RxBool friendsExpanded = true.obs;
  // final RxBool sentExpanded = true.obs;
  // [/OLD FLOW]

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  // [OLD FLOW – friend requests, disabled 2026-11]
  // /// Loads page 1 of all three lists in parallel; at most one error snackbar.
  // Future<void> loadAll() async {
  //   if (isLoading.value) return;
  //   isLoading.value = true;
  //   try {
  //     final errors = await Future.wait<String?>(<Future<String?>>[
  //       refreshIncomingRequests(showError: false),
  //       refreshFriends(showError: false),
  //       refreshSentRequests(showError: false),
  //     ]);
  //     _showLoadError(errors);
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
  // [/OLD FLOW]
  /// Loads page 1 of saved profiles; at most one error snackbar.
  /// (Name kept: chat_controller calls it after blocking.)
  Future<void> loadAll() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      final String? err = await refreshSaved(showError: false);
      _showLoadError(<String?>[err]);
    } finally {
      isLoading.value = false;
    }
  }


  /// Pull-to-refresh handler (all three lists reset to page 1).
  Future<void> onRefresh() => loadAll();

  /// One snackbar for the first failed load in [errors] (null = ok).
  void _showLoadError(List<String?> errors) {
    final String? first =
        errors.firstWhereOrNull((e) => e != null);
    if (first == null) return;
    Get.snackbar('Could not load friends', first,
        snackPosition: SnackPosition.BOTTOM);
  }

  // [OLD FLOW – friend requests, disabled 2026-11]
  // /// Loads page 1 of incoming requests, replacing the list. On failure the
  // /// existing list is kept; returns the error message (snackbar only when
  // /// [showError]) or null on success / when superseded.
  // Future<String?> refreshIncomingRequests({bool showError = true}) async {
  //   final int gen = ++_incomingGen;
  //   isLoadingMoreIncoming.value = false;
  //   final res = await FriendService.instance
  //       .fetchIncomingRequests(limit: pageSize, offset: 0);
  //   if (gen != _incomingGen) return null; // superseded by a newer page-1 load
  //   if (!res.success) {
  //     if (showError) {
  //       Get.snackbar('Could not load friend requests', res.message,
  //           snackPosition: SnackPosition.BOTTOM);
  //     }
  //     return res.message;
  //   }
  //   friendRequests.assignAll(res.items);
  //   incomingTotal.value = res.total;
  //   _incomingOffset.value = res.items.length;
  //   return null;
  // }

  // /// Appends the next page of incoming requests (no-op while loading or when
  // /// everything is loaded).
  // Future<void> loadMoreIncoming() async {
  //   if (isLoadingMoreIncoming.value || !hasMoreIncoming) return;
  //   final int gen = _incomingGen;
  //   isLoadingMoreIncoming.value = true;
  //   try {
  //     final res = await FriendService.instance.fetchIncomingRequests(
  //         limit: pageSize, offset: _incomingOffset.value);
  //     if (gen != _incomingGen) return;
  //     if (!res.success) {
  //       Get.snackbar('Could not load more', res.message,
  //           snackPosition: SnackPosition.BOTTOM);
  //       return;
  //     }
  //     final known = friendRequests.map((r) => r.requestId).toSet();
  //     friendRequests
  //         .addAll(res.items.where((r) => !known.contains(r.requestId)));
  //     incomingTotal.value = res.total;
  //     _incomingOffset.value += res.items.length;
  //     // Server returned nothing: stop paging (header count unchanged).
  //     if (res.items.isEmpty) _incomingOffset.value = incomingTotal.value;
  //   } finally {
  //     if (gen == _incomingGen) isLoadingMoreIncoming.value = false;
  //   }
  // }

  // /// Loads page 1 of friends, replacing the list. On failure the existing
  // /// list is kept; returns the error message (snackbar only when
  // /// [showError]) or null on success / when superseded.
  // Future<String?> refreshFriends({bool showError = true}) async {
  //   final int gen = ++_friendsGen;
  //   isLoadingMoreFriends.value = false;
  //   final res =
  //       await FriendService.instance.fetchFriends(limit: pageSize, offset: 0);
  //   if (gen != _friendsGen) return null; // superseded by a newer page-1 load
  //   if (!res.success) {
  //     if (showError) {
  //       Get.snackbar('Could not load friends', res.message,
  //           snackPosition: SnackPosition.BOTTOM);
  //     }
  //     return res.message;
  //   }
  //   friends.assignAll(res.items);
  //   friendsTotal.value = res.total;
  //   _friendsOffset.value = res.items.length;
  //   return null;
  // }

  // /// Appends the next page of friends (no-op while loading or when
  // /// everything is loaded).
  // Future<void> loadMoreFriends() async {
  //   if (isLoadingMoreFriends.value || !hasMoreFriends) return;
  //   final int gen = _friendsGen;
  //   isLoadingMoreFriends.value = true;
  //   try {
  //     final res = await FriendService.instance
  //         .fetchFriends(limit: pageSize, offset: _friendsOffset.value);
  //     if (gen != _friendsGen) return;
  //     if (!res.success) {
  //       Get.snackbar('Could not load more', res.message,
  //           snackPosition: SnackPosition.BOTTOM);
  //       return;
  //     }
  //     final known = friends.map((f) => f.friendshipId).toSet();
  //     friends.addAll(res.items.where((f) => !known.contains(f.friendshipId)));
  //     friendsTotal.value = res.total;
  //     _friendsOffset.value += res.items.length;
  //     // Server returned nothing: stop paging (header count unchanged).
  //     if (res.items.isEmpty) _friendsOffset.value = friendsTotal.value;
  //   } finally {
  //     if (gen == _friendsGen) isLoadingMoreFriends.value = false;
  //   }
  // }

  // /// Loads page 1 of sent requests, replacing the list. On failure the
  // /// existing list is kept; returns the error message (snackbar only when
  // /// [showError]) or null on success / when superseded.
  // Future<String?> refreshSentRequests({bool showError = true}) async {
  //   final int gen = ++_sentGen;
  //   isLoadingMoreSent.value = false;
  //   final res = await FriendService.instance
  //       .fetchSentRequests(limit: pageSize, offset: 0);
  //   if (gen != _sentGen) return null; // superseded by a newer page-1 load
  //   if (!res.success) {
  //     if (showError) {
  //       Get.snackbar('Could not load sent requests', res.message,
  //           snackPosition: SnackPosition.BOTTOM);
  //     }
  //     return res.message;
  //   }
  //   sentRequests.assignAll(res.items);
  //   sentTotal.value = res.total;
  //   _sentOffset.value = res.items.length;
  //   return null;
  // }

  // /// Appends the next page of sent requests (no-op while loading or when
  // /// everything is loaded).
  // Future<void> loadMoreSent() async {
  //   if (isLoadingMoreSent.value || !hasMoreSent) return;
  //   final int gen = _sentGen;
  //   isLoadingMoreSent.value = true;
  //   try {
  //     final res = await FriendService.instance.fetchSentRequests(
  //         limit: pageSize, offset: _sentOffset.value);
  //     if (gen != _sentGen) return;
  //     if (!res.success) {
  //       Get.snackbar('Could not load more', res.message,
  //           snackPosition: SnackPosition.BOTTOM);
  //       return;
  //     }
  //     final known = sentRequests.map((r) => r.requestId).toSet();
  //     sentRequests.addAll(res.items.where((r) => !known.contains(r.requestId)));
  //     sentTotal.value = res.total;
  //     _sentOffset.value += res.items.length;
  //     // Server returned nothing: stop paging (header count unchanged).
  //     if (res.items.isEmpty) _sentOffset.value = sentTotal.value;
  //   } finally {
  //     if (gen == _sentGen) isLoadingMoreSent.value = false;
  //   }
  // }

  // /// Drops a server-confirmed accepted/declined request from the list. The
  // /// server list shifted by one, so the total and next-page offset shrink
  // /// too (same as cancelSentRequest); the page-1 refetch that follows then
  // /// replaces all three with server values. If that refetch fails, the list
  // /// and paging stay consistent with the server.
  // void _removeIncomingLocally(IncomingFriendRequest req) {
  //   final int before = friendRequests.length;
  //   friendRequests.removeWhere((r) => r.requestId == req.requestId);
  //   if (friendRequests.length == before) return; // already gone
  //   incomingTotal.value = math.max(0, incomingTotal.value - 1);
  //   _incomingOffset.value = math.max(0, _incomingOffset.value - 1);
  // }

  // /// Accept a request (POST by request id). On success: remove the row
  // /// immediately, snackbar, then re-fetch page 1 of incoming requests and
  // /// friends in parallel and let Browse refresh. On failure: error snackbar,
  // /// row kept.
  // Future<void> acceptRequest(IncomingFriendRequest req) async {
  //   if (req.requestId.isEmpty || busyRequestIds.contains(req.requestId)) {
  //     return;
  //   }
  //   busyRequestIds.add(req.requestId);
  //   try {
  //     final res =
  //         await FriendService.instance.acceptFriendRequest(req.requestId);
  //     if (!res.success) {
  //       Get.snackbar('Could not accept request', res.message,
  //           snackPosition: SnackPosition.BOTTOM);
  //       return;
  //     }
  //     _removeIncomingLocally(req);
  //     Get.snackbar('Friend added',
  //         'You and ${req.user.displayName} are now friends',
  //         snackPosition: SnackPosition.BOTTOM);
  //     final errors = await Future.wait<String?>(<Future<String?>>[
  //       refreshIncomingRequests(showError: false),
  //       refreshFriends(showError: false),
  //     ]);
  //     _showLoadError(errors);
  //     // Not awaited, same as onSentRequestCancelled.
  //     if (Get.isRegistered<HomeController>()) {
  //       Get.find<HomeController>().onRefresh();
  //     }
  //   } finally {
  //     busyRequestIds.remove(req.requestId);
  //   }
  // }

  // /// Decline a request (POST .../reject by request id). On success: remove
  // /// the row immediately, snackbar, then re-fetch page 1 of incoming
  // /// requests and let Browse refresh. On failure: error snackbar, row kept.
  // Future<void> declineRequest(IncomingFriendRequest req) async {
  //   if (req.requestId.isEmpty || busyRequestIds.contains(req.requestId)) {
  //     return;
  //   }
  //   busyRequestIds.add(req.requestId);
  //   decliningRequestIds.add(req.requestId);
  //   try {
  //     final res =
  //         await FriendService.instance.rejectFriendRequest(req.requestId);
  //     if (!res.success) {
  //       Get.snackbar('Could not decline request', res.message,
  //           snackPosition: SnackPosition.BOTTOM);
  //       return;
  //     }
  //     _removeIncomingLocally(req);
  //     Get.snackbar('Request declined',
  //         'Request from ${req.user.displayName} declined',
  //         snackPosition: SnackPosition.BOTTOM);
  //     _showLoadError(<String?>[await refreshIncomingRequests(showError: false)]);
  //     // Not awaited, same as acceptRequest.
  //     if (Get.isRegistered<HomeController>()) {
  //       Get.find<HomeController>().onRefresh();
  //     }
  //   } finally {
  //     decliningRequestIds.remove(req.requestId);
  //     busyRequestIds.remove(req.requestId);
  //   }
  // }

  // /// Delete a request without accepting or rejecting it (DELETE by request
  // /// id). Shares [busyRequestIds] with accept/decline so all three lock
  // /// together. On success: remove the row immediately, snackbar, then
  // /// re-fetch page 1 of incoming requests and let Browse refresh. On
  // /// failure: error snackbar, row kept.
  // Future<void> deleteRequest(IncomingFriendRequest req) async {
  //   if (req.requestId.isEmpty || busyRequestIds.contains(req.requestId)) {
  //     return;
  //   }
  //   busyRequestIds.add(req.requestId);
  //   deletingRequestIds.add(req.requestId);
  //   try {
  //     final res =
  //         await FriendService.instance.deleteFriendRequest(req.requestId);
  //     if (!res.success) {
  //       Get.snackbar('Could not delete request', res.message,
  //           snackPosition: SnackPosition.BOTTOM);
  //       return;
  //     }
  //     _removeIncomingLocally(req);
  //     Get.snackbar('Request deleted',
  //         'Request from ${req.user.displayName} deleted',
  //         snackPosition: SnackPosition.BOTTOM);
  //     _showLoadError(<String?>[await refreshIncomingRequests(showError: false)]);
  //     // Not awaited, same as declineRequest.
  //     if (Get.isRegistered<HomeController>()) {
  //       Get.find<HomeController>().onRefresh();
  //     }
  //   } finally {
  //     deletingRequestIds.remove(req.requestId);
  //     busyRequestIds.remove(req.requestId);
  //   }
  // }

  // /// Cancel a request I sent (DELETE by request id). On success: remove the
  // /// row, decrement the total and let Browse show the member again. On
  // /// failure: error snackbar, row kept.
  // Future<void> cancelSentRequest(SentFriendRequest req) async {
  //   if (req.requestId.isEmpty || busySentIds.contains(req.requestId)) return;
  //   busySentIds.add(req.requestId);
  //   try {
  //     final res =
  //         await FriendService.instance.cancelSentRequest(req.requestId);
  //     if (!res.success) {
  //       Get.snackbar('Could not cancel request', res.message,
  //           snackPosition: SnackPosition.BOTTOM);
  //       return;
  //     }
  //     sentRequests.removeWhere((r) => r.requestId == req.requestId);
  //     sentTotal.value = math.max(0, sentTotal.value - 1);
  //     // The server list shifted by one; keep the next page from skipping a row.
  //     _sentOffset.value = math.max(0, _sentOffset.value - 1);
  //     Get.snackbar('Request cancelled',
  //         'Request to ${req.user.displayName} cancelled',
  //         snackPosition: SnackPosition.BOTTOM);
  //     if (Get.isRegistered<HomeController>()) {
  //       Get.find<HomeController>().onSentRequestCancelled(req.user.id);
  //     }
  //   } finally {
  //     busySentIds.remove(req.requestId);
  //   }
  // }

  // /// Remove a friend (DELETE by the friend's USER id, not the friendship
  // /// id). On success: remove the row immediately, snackbar, then re-fetch
  // /// page 1 of friends and let Browse refresh (the member may reappear
  // /// there). On failure: error snackbar, row kept.
  // Future<void> removeFriend(Friendship f) async {
  //   final String userId = f.user.id;
  //   if (userId.isEmpty || busyFriendIds.contains(userId)) return;
  //   busyFriendIds.add(userId);
  //   try {
  //     final res = await FriendService.instance.removeFriend(userId);
  //     if (!res.success) {
  //       Get.snackbar('Could not remove friend', res.message,
  //           snackPosition: SnackPosition.BOTTOM);
  //       return;
  //     }
  //     final int before = friends.length;
  //     friends.removeWhere((x) => x.user.id == userId);
  //     if (friends.length != before) {
  //       friendsTotal.value = math.max(0, friendsTotal.value - 1);
  //     }
  //     Get.snackbar('Friend removed',
  //         '${f.user.displayName} was removed from your friends',
  //         snackPosition: SnackPosition.BOTTOM);
  //     _showLoadError(<String?>[await refreshFriends(showError: false)]);
  //     // Not awaited, same as acceptRequest.
  //     if (Get.isRegistered<HomeController>()) {
  //       Get.find<HomeController>().onRefresh();
  //     }
  //   } finally {
  //     busyFriendIds.remove(userId);
  //   }
  // }
  // [/OLD FLOW]

  /// Loads page 1 of saved profiles, replacing the list. On failure the
  /// existing list is kept; returns the error message (snackbar only when
  /// [showError]) or null on success / when superseded.
  Future<String?> refreshSaved({bool showError = true}) async {
    final int gen = ++_savedGen;
    isLoadingMoreSaved.value = false;
    final res = await FriendService.instance
        .fetchSavedProfiles(limit: pageSize, offset: 0);
    if (gen != _savedGen) return null; // superseded by a newer page-1 load
    if (!res.success) {
      if (showError) {
        Get.snackbar('Could not load saved profiles', res.message,
            snackPosition: SnackPosition.BOTTOM);
      }
      return res.message;
    }
    saved.assignAll(res.items);
    savedTotal.value = res.total;
    _savedOffset.value = res.items.length;
    return null;
  }

  /// Appends the next page of saved profiles (no-op while loading or when
  /// everything is loaded).
  Future<void> loadMoreSaved() async {
    if (isLoadingMoreSaved.value || !hasMoreSaved) return;
    final int gen = _savedGen;
    isLoadingMoreSaved.value = true;
    try {
      final res = await FriendService.instance
          .fetchSavedProfiles(limit: pageSize, offset: _savedOffset.value);
      if (gen != _savedGen) return;
      if (!res.success) {
        Get.snackbar('Could not load more', res.message,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      final known = saved.map((s) => s.user.id).toSet();
      saved.addAll(res.items.where((s) => !known.contains(s.user.id)));
      savedTotal.value = res.total;
      _savedOffset.value += res.items.length;
      // Server returned nothing: stop paging (header count unchanged).
      if (res.items.isEmpty) _savedOffset.value = savedTotal.value;
    } finally {
      if (gen == _savedGen) isLoadingMoreSaved.value = false;
    }
  }

  /// Remove a saved profile (DELETE friends/{USER id}, not the item id). On
  /// success: remove the row immediately, total--, snackbar, then re-fetch
  /// page 1. On failure: error snackbar, row kept.
  Future<void> removeSaved(SavedProfile p) async {
    final String userId = p.user.id;
    if (userId.isEmpty || busyFriendIds.contains(userId)) return;
    busyFriendIds.add(userId);
    try {
      final res = await FriendService.instance.removeFriend(userId);
      if (!res.success) {
        Get.snackbar('Could not remove friend', res.message,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      final int before = saved.length;
      saved.removeWhere((x) => x.user.id == userId);
      if (saved.length != before) {
        savedTotal.value = math.max(0, savedTotal.value - 1);
        _savedOffset.value = math.max(0, _savedOffset.value - 1);
      }
      Get.snackbar('Friend removed',
          '${p.user.displayName} was removed from your saved profiles',
          snackPosition: SnackPosition.BOTTOM);
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().onSavedRemoved(userId);
      }
      _showLoadError(<String?>[await refreshSaved(showError: false)]);
    } finally {
      busyFriendIds.remove(userId);
    }
  }

  // [SUPERSEDED DRAFT – saved-card-details]
  // /// Opens [SavedProfile] details in MemberDetailScreen.
  // void openSavedProfileDetail(SavedProfile p) {
  //   final member = Member(
  //     id: p.user.id,
  //     displayName: p.user.displayName,
  //     age: p.user.age,
  //     role: 'user',
  //     friendshipStatus: 'saved',
  //     avatarUrl: p.user.avatarUrl,
  //     profile: MemberProfile(
  //       gender: '',
  //       orientations: const <String>[],
  //       bio: p.user.subtitle,
  //       location: '',
  //       city: '',
  //       region: '',
  //       interests: const <String>[],
  //       lookingFor: const <String>[],
  //       relationshipIntents: const <String>[],
  //       photos: const <MemberPhoto>[],
  //       avatarUrl: p.user.avatarUrl,
  //     ),
  //   );
  //
  //   if (Get.isRegistered<HomeController>()) {
  //     Get.find<HomeController>().openMemberDetail(member, savedProfile: p);
  //   } else {
  //     Get.toNamed(Routes.MEMBER_DETAIL, arguments: member);
  //   }
  // }
  // [/SUPERSEDED DRAFT]

  /// Opens the member details screen for a saved profile (card tap). The
  /// member is marked saved before navigating so the screen shows
  /// Remove | Saved | Message straight away.
  void openSavedProfileDetail(SavedProfile p) {
    final String id = p.user.id;
    if (id.isEmpty) return;
    final member = Member(
      id: id,
      displayName: p.user.displayName,
      age: p.user.age,
      role: 'user',
      isSaved: true,
      avatarUrl: p.user.avatarUrl,
      profile: MemberProfile.empty,
    );
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().savedStates[id] = true;
    }
    Get.toNamed(Routes.MEMBER_DETAIL, arguments: member);
  }

  /// Removes a saved profile by user id for the details screen (the Friends
  /// list may not be loaded). Returns true on success. Failure: error
  /// snackbar, stays saved.
  Future<bool> removeSavedByUserId(String userId, {String? displayName}) async {
    if (userId.isEmpty || busyFriendIds.contains(userId)) return false;
    busyFriendIds.add(userId);
    try {
      final res = await FriendService.instance.removeFriend(userId);
      if (!res.success) {
        Get.snackbar('Could not remove friend', res.message,
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
      final int before = saved.length;
      saved.removeWhere((x) => x.user.id == userId);
      if (saved.length != before) {
        savedTotal.value = math.max(0, savedTotal.value - 1);
        _savedOffset.value = math.max(0, _savedOffset.value - 1);
      }
      final String name = (displayName ?? '').trim();
      Get.snackbar('Friend removed',
          '${name.isEmpty ? 'Profile' : name} was removed from your saved profiles',
          snackPosition: SnackPosition.BOTTOM);
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().onSavedRemoved(userId);
      }
      // Not awaited: refresh the Friends tab list in the background.
      refreshSaved(showError: false);
      return true;
    } finally {
      busyFriendIds.remove(userId);
    }
  }

  /// Opens the 1:1 chat with [user]: POST conversations with their user id,
  /// then navigates to Routes.CHAT with the resulting conversation. On
  /// failure: error snackbar, stays on the Friends tab.
  Future<void> openChat(FriendUser user) async {
    final String userId = user.id;
    if (userId.isEmpty || openingChatIds.contains(userId)) return;
    openingChatIds.add(userId);
    try {
      final res = await ConversationService.instance.openConversation(userId);
      if (!res.success || res.conversation == null) {
        Get.snackbar('Could not open chat', res.message,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      // Mark the Chat list stale so the new conversation shows on next open.
      // Skip while only "prepared": creating it here (e.g. from Member
      // Details) would bind it to that route; a fresh one loads on open.
      if (Get.isRegistered<ConversationsController>() &&
          !Get.isPrepared<ConversationsController>()) {
        Get.find<ConversationsController>().invalidate();
      }
      // This conversation may have been created just now, after the socket
      // connected, so the live session does not know it (no join frame).
      // Reconnect to re-sync the server's conversation set before chatting.
      // Bound it so navigation isn't blocked long; HTTP-primary send covers
      // any remaining gap if the reconnect times out.
      final conversation = res.conversation!;
      await ChatWebSocketService.instance.reconnect().timeout(
        const Duration(seconds: 2),
        onTimeout: () {},
      );
      // Avoid a second reconnect for the same id in ChatController.onInit.
      ChatWebSocketService.instance.markConversationKnown(conversation.id);
      Get.toNamed(Routes.CHAT, arguments: ChatArgs(conversation));
    } finally {
      openingChatIds.remove(userId);
    }
  }
}
