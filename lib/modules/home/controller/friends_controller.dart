import 'package:get/get.dart';

import '../model/friend.dart';

/// Drives the Friends tab: "Friend Requests" (shown first) and "My Friends".
/// Uses DEMO data until the friends APIs are provided — every spot that needs
/// a real call is marked `// TODO(api)`.
class FriendsController extends GetxController {
  final RxList<FriendUser> friendRequests = <FriendUser>[].obs;
  final RxList<FriendUser> friends = <FriendUser>[].obs;

  final RxBool isLoading = false.obs;

  /// Request ids currently being accepted/declined (per-row button spinner).
  final RxSet<String> busyRequestIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  /// Loads both lists. TODO(api): replace the demo data with the
  /// friend-requests and friends list calls (run them in parallel).
  Future<void> loadAll() async {
    if (isLoading.value) return;
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 400)); // DEMO latency
      friendRequests.assignAll(_demoRequests());
      friends.assignAll(_demoFriends());
    } finally {
      isLoading.value = false;
    }
  }

  /// Pull-to-refresh handler.
  Future<void> onRefresh() => loadAll();

  /// Accept a request: moves the user into My Friends.
  /// TODO(api): call the accept endpoint; only move on success.
  Future<void> acceptRequest(FriendUser user) async {
    if (busyRequestIds.contains(user.id)) return;
    busyRequestIds.add(user.id);
    try {
      await Future.delayed(const Duration(milliseconds: 300)); // DEMO
      friendRequests.removeWhere((r) => r.id == user.id);
      friends.insert(
        0,
        FriendUser(
          id: user.id,
          displayName: user.displayName,
          age: user.age,
          avatarUrl: user.avatarUrl,
          subtitle: user.subtitle,
          since: DateTime.now(),
          isOnline: user.isOnline,
        ),
      );
      Get.snackbar('Friend added',
          'You and ${user.displayName} are now friends.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      busyRequestIds.remove(user.id);
    }
  }

  /// Decline a request. TODO(api): call the decline endpoint.
  Future<void> declineRequest(FriendUser user) async {
    if (busyRequestIds.contains(user.id)) return;
    busyRequestIds.add(user.id);
    try {
      await Future.delayed(const Duration(milliseconds: 300)); // DEMO
      friendRequests.removeWhere((r) => r.id == user.id);
    } finally {
      busyRequestIds.remove(user.id);
    }
  }

  /// Remove a friend. TODO(api): call the remove-friend endpoint.
  void removeFriend(FriendUser user) {
    friends.removeWhere((f) => f.id == user.id);
    Get.snackbar('Friend removed',
        '${user.displayName} was removed from your friends.',
        snackPosition: SnackPosition.BOTTOM);
  }

  /// Start a chat. TODO: open the chat screen for [user] once chat exists.
  void openChat(FriendUser user) {
    Get.snackbar('Coming soon', 'Chat with ${user.displayName} is coming soon.',
        snackPosition: SnackPosition.BOTTOM);
  }

  // --- DEMO data (remove when the APIs are wired) --------------------------
  List<FriendUser> _demoRequests() => [
        FriendUser(
          id: 'req-1',
          displayName: 'Jerry Ten',
          age: 33,
          avatarUrl:
              'https://chatx-4le7.onrender.com/uploads/avatars/35c872ae8fdc4f9f9c01c92d6e42e884.jpg',
          subtitle: 'Wants to connect with you',
          since: DateTime.now().subtract(const Duration(minutes: 12)),
        ),
        FriendUser(
          id: 'req-2',
          displayName: 'Alexy',
          age: 31,
          avatarUrl:
              'https://chatx-4le7.onrender.com/uploads/avatars/13c1f47edebf4edfac655d53f496432a.jpg',
          subtitle: 'Wants to connect with you',
          since: DateTime.now().subtract(const Duration(hours: 3)),
        ),
      ];

  List<FriendUser> _demoFriends() => [
        FriendUser(
          id: 'fr-1',
          displayName: 'Jerry Twelve',
          age: 28,
          avatarUrl:
              'https://chatx-4le7.onrender.com/uploads/avatars/4b1244e03ca6493dbed6ce3ae38d7395.jpg',
          subtitle: 'Straight',
          isOnline: true,
          since: DateTime.now().subtract(const Duration(days: 4)),
        ),
        FriendUser(
          id: 'fr-2',
          displayName: 'Max',
          age: 21,
          avatarUrl:
              'https://chatx-4le7.onrender.com/uploads/avatars/c087d746275d40e2a31f1b250eadb098.jpg',
          subtitle: 'Heterosexual',
          since: DateTime.now().subtract(const Duration(days: 20)),
        ),
        const FriendUser(
          id: 'fr-3',
          displayName: 'Zoro',
          age: 23,
          subtitle: 'No photo yet',
        ),
      ];
}
