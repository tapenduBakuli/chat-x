import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/routes.dart';
import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';
import '../model/friend.dart';
import '../model/member.dart';
import '../services/member_services.dart';
import 'blocked_controller.dart';
import 'friends_controller.dart';
import 'home_controller.dart';

/// State for one Member Detail screen. Created per entry by
/// MemberDetailBinding. Accepts a list [Member] (shown immediately) or just a
/// user id as `Get.arguments`.
class MemberDetailController extends GetxController {
  /// The member on screen: the list member first, then list merged with the
  /// fetched GET users/{id} profile.
  late final Rx<Member> member;

  /// False when the route got neither a [Member] nor a non-empty id.
  late final bool isValid;

  /// GET users/{id}/availability result; null while loading or on failure.
  final Rxn<UserAvailability> availability = Rxn<UserAvailability>();

  /// True while the availability call is in flight (pill shows "Checking…").
  final RxBool isAvailabilityLoading = false.obs;

  /// True while the profile fetch is in flight (drives the thin loader).
  final RxBool isLoading = false.obs;

  /// True while DELETE friends/{id} is in flight (Remove button spinner).
  final RxBool isRemoving = false.obs;

  /// True while POST conversations is in flight (Message button spinner).
  final RxBool isOpeningChat = false.obs;

  HomeController get _home => Get.find<HomeController>();

  FriendsController get _friends => Get.isRegistered<FriendsController>()
      ? Get.find<FriendsController>()
      : Get.put(FriendsController());

  /// Reactive: read inside Obx (HomeController.savedStates). A session
  /// override (saved/removed) wins over the server `is_saved`.
  bool isSaved(Member m) => _home.isSaved(m);

  bool isBlocked(Member m) => _home.isBlocked(m);

  /// True while block/unblock for [id] is in flight (reactive in Obx).
  bool isBlockBusy(String id) => _home.isBlockBusy(id);

  /// True when opened from the Blocked tab (pop back to it after unblock).
  bool fromBlockedTab = false;

  /// Unblock from details. On success refetches the Blocked list (awaited)
  /// and, when opened from the Blocked tab, pops back to it. Otherwise stays
  /// on details (bar switches via blockStates). Failure: stays blocked.
  Future<void> unblockMemberFromDetail(Member m) async {
    if (m.id.isEmpty || _home.isBlockBusy(m.id)) return;
    final bool ok = await _home.unblockMember(m);
    if (!ok) return;
    if (Get.isRegistered<BlockedController>()) {
      await Get.find<BlockedController>().refreshBlocked(showError: false);
    }
    if (fromBlockedTab) {
      _home.selectedNavIndex.value = 4; // Blocked tab
      Get.until((r) => r.settings.name != Routes.MEMBER_DETAIL);
    }
  }

  /// DELETE friends/{id}. On success HomeController.savedStates flips to
  /// false, so the bar returns to Pass + Save without leaving the screen.
  Future<void> removeSaved() async {
    final Member m = member.value;
    if (isRemoving.value || m.id.isEmpty) return;
    isRemoving.value = true;
    try {
      await _friends.removeSavedByUserId(m.id, displayName: m.displayName);
    } finally {
      if (!isClosed) isRemoving.value = false;
    }
  }

  /// POST conversations -> Routes.CHAT (reuses FriendsController.openChat).
  Future<void> openChat() async {
    final Member m = member.value;
    if (isOpeningChat.value || m.id.isEmpty) return;
    isOpeningChat.value = true;
    try {
      await _friends.openChat(FriendUser(
        id: m.id,
        displayName: m.displayName,
        age: m.age,
        avatarUrl: m.avatarUrl,
      ));
    } finally {
      if (!isClosed) isOpeningChat.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    final dynamic arg = Get.arguments;
    Member? initial;
    if (arg is Map && arg['member'] is Member) {
      initial = arg['member'] as Member;
      fromBlockedTab = arg['fromBlockedTab'] == true;
    } else if (arg is Member) {
      initial = arg;
    } else if (arg is String && arg.trim().isNotEmpty) {
      initial = Member(
        id: arg.trim(),
        displayName: '',
        age: 0,
        role: '',
        avatarUrl: '',
        profile: MemberProfile.empty,
      );
    }
    isValid = initial != null && initial.id.isNotEmpty;
    member =
        (initial ??
                const Member(
                  id: '',
                  displayName: '',
                  age: 0,
                  role: '',
                  avatarUrl: '',
                  profile: MemberProfile.empty,
                ))
            .obs;
    // Opened as saved (e.g. from the Friends tab): mirror it into the session
    // state so every screen agrees.
    if (isValid && member.value.isSaved) {
      final home = Get.find<HomeController>();
      if (!home.savedStates.containsKey(member.value.id)) {
        home.savedStates[member.value.id] = true;
      }
    }
    // Blocked-tab entry: session override keeps the Unblock bar after the
    // GET users/{id} merge (isBlocked reads blockStates first).
    if (isValid && fromBlockedTab) {
      Get.find<HomeController>().blockStates[member.value.id] = true;
    }
    if (isValid) load();
  }

  /// Fetches the profile and availability in parallel, each handling its own
  /// failure. Called on every screen entry and from pull-to-refresh / Retry.
  Future<void> load() async {
    final String id = member.value.id;
    if (!isValid || isLoading.value) return;
    isLoading.value = true;
    try {
      await Future.wait<void>(<Future<void>>[
        _loadProfile(id),
        _loadAvailability(id),
      ]);
    } finally {
      if (!isClosed) isLoading.value = false;
    }
  }

  Future<void> _loadProfile(String id) async {
    debugPrint('MemberDetail: GET users/$id');
    final res = await MemberService.instance.fetchMemberById(id);
    if (isClosed) return;
    if (res.success && res.member != null) {
      member.value = member.value.mergeWith(res.member!);
    } else {
      // Keep the list data on screen; surface the error without blocking.
      Get.snackbar(
        'Could not load profile',
        res.message,
        snackPosition: SnackPosition.BOTTOM,
        mainButton: TextButton(
          onPressed: load,
          child: Text(
            'Retry',
            style: TextStyles.browseToggleLabel.copyWith(
              color: CustomColor.colorWhite,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _loadAvailability(String id) async {
    debugPrint('MemberDetail: availability GET users/$id/availability');
    isAvailabilityLoading.value = true;
    try {
      final res = await MemberService.instance.fetchUserAvailability(id);
      if (isClosed) return;
      // Failure: keep the last known value (the pill falls back to
      // "Offline"); no snackbar.
      if (res.success) availability.value = res.availability;
      final a = res.availability;
      debugPrint('MemberDetail: availability -> success=${res.success} '
          'isOnline=${a?.isOnline} lastSeenAt=${a?.lastSeenAt} '
          'message=${res.message}');
    } finally {
      if (!isClosed) isAvailabilityLoading.value = false;
    }
  }
}
