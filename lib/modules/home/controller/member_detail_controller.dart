import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';
import '../model/member.dart';
import '../services/member_services.dart';

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

  @override
  void onInit() {
    super.onInit();
    final dynamic arg = Get.arguments;
    Member? initial;
    if (arg is Member) {
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
