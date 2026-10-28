import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../routes/routes.dart';
import '../../../utils/Store/HiveStore.dart';
import '../../../utils/lib/otp_text_field.dart';
import '../../login/services/login_services.dart';
import '../model/member.dart';

/// The two ways the browse-members home renders its list.
enum HomeViewMode { grid, deck }

/// Drives the authenticated "Browse Members" home: loads members from the
/// bundled mock JSON, exposes the grid/deck view mode, city filtering, and the
/// deck swipe cursor. All UI state is reactive so the views can wrap the
/// relevant pieces in [Obx].
class HomeController extends GetxController {
  /// Full, unfiltered list of members parsed from the asset.
  final RxList<Member> allMembers = <Member>[].obs;

  /// True while the asset is being read/parsed.
  final RxBool isLoading = true.obs;

  /// Active view mode (grid by default).
  final Rx<HomeViewMode> viewMode = HomeViewMode.grid.obs;

  /// Active bottom navigation bar index (0: Explore, 1: Chat, 2: Friends).
  final RxInt selectedNavIndex = 0.obs;

  /// Selected city filter; 'All Belgium' means no filtering.
  final RxString selectedCity = 'All Belgium'.obs;

  /// Cursor into [filteredMembers] for the deck view.
  final RxInt deckIndex = 0.obs;

  /// Free-text search; matched (case-insensitive contains) against
  /// [Member.displayName]. Empty means no filtering.
  final RxString searchQuery = ''.obs;

  /// Text controller bound to the search box in the header. Kept in sync with
  /// [searchQuery] via [setSearchQuery]; cleared by [resetFilters].
  final TextEditingController searchController = TextEditingController();

  /// Gender filter: one of 'All', 'Female', 'Male', 'Other'. 'All' = no filter.
  /// Mapped to the model's lowercase [MemberProfile.gender] when matching.
  final RxString genderFilter = 'All'.obs;

  /// Inclusive age range filter; members whose [Member.age] falls within
  /// [start, end] (rounded to ints) pass.
  final Rx<RangeValues> ageRange = const RangeValues(18, 55).obs;

  /// Search radius in km. PLACEHOLDER: cosmetic only — the mock data has no
  /// lat/long, so this never filters members. It drives only its own label +
  /// slider in the filter sheet.
  final RxDouble searchRadiusKm = 30.0.obs;

  /// Selected interest chips; a member matches if ANY of its interests matches
  /// ANY selected chip (OR). Empty = no filter.
  final RxList<String> selectedInterests = <String>[].obs;

  // --- DRAFT filter state (edited inside the filter sheet) -----------------
  // The sheet controls bind to these drafts so changes do NOT affect the list
  // until the user taps "Apply Criteria" (which copies drafts -> applied).
  // (City + search stay live from the header; only the sheet filters are
  // staged behind Apply.)
  final RxString draftGenderFilter = 'All'.obs;
  final Rx<RangeValues> draftAgeRange = const RangeValues(18, 55).obs;
  final RxDouble draftSearchRadiusKm = 30.0.obs;
  final RxList<String> draftSelectedInterests = <String>[].obs;

  /// Fixed city filter options (mirrors the web dropdown).
  final List<String> cities = const [
    'All Belgium',
    'Brussels',
    'Antwerp',
    'Ghent',
    'Bruges',
    'Leuven',
    'Liège',
    'Namur',
    'Charleroi',
    'Mons',
    'Hasselt',
    'Kortrijk',
  ];

  /// Fixed interest chip labels shown in the filter sheet.
  static const List<String> interestOptions = [
    'Sports',
    'Gaming',
    'Movies',
    'Music & genres',
    'Drawing / Painting / Art',
    'Specialty Coffee',
    'Travel & Road trips',
    'Fitness & Gym',
    'Belgian Gastronomy',
    'Literature & Books',
    'Serious relationship',
    "Has SOA's (STI status open)",
  ];

  // ===========================================================================
  // --- Accounts tab -----------------------------------------------------------
  // Local UI state for the Accounts tab. All visual/demo only (no APIs yet).
  // ===========================================================================

  /// Selected subscription plan card (visual highlight only). Defaults to the
  /// "1 Month" card (index 1), which is pre-selected in the mock.
  final RxInt selectedPlanIndex = 1.obs;
  void selectPlan(int i) => selectedPlanIndex.value = i;

  /// Whether the account is set to "invisible" (local toggle, no API). Drives
  /// both the Switch and the leading eye/eye-off icon.
  final RxBool isAccountInvisible = false.obs;
  void toggleInvisible(bool v) => isAccountInvisible.value = v;

  /// Whether the three Change-Password card fields are shown (not obscured).
  final RxBool showChangePwd = false.obs;
  void toggleShowChangePwd() => showChangePwd.value = !showChangePwd.value;

  /// Local controllers for the (design-only) Change-Password card fields. The
  /// direct change-password API is not wired yet (Coming-soon stub).
  final TextEditingController changeCurrentPasswordController =
      TextEditingController();
  final TextEditingController changeNewPasswordController =
      TextEditingController();
  final TextEditingController changeConfirmPasswordController =
      TextEditingController();

  // ===========================================================================
  // --- Reset-password dialog flow ---------------------------------------------
  // Shared state for the three reset-password dialogs (email -> OTP -> new
  // password). Reuses LoginService; disposed in onClose.
  // ===========================================================================

  final TextEditingController resetEmailController = TextEditingController();

  final OtpFieldController resetOtpController = OtpFieldController();
  final RxString resetOtpCode = ''.obs;
  void onResetOtpChanged(String v) => resetOtpCode.value = v;
  bool get isResetOtpComplete => resetOtpCode.value.length == 4;

  final TextEditingController resetNewPasswordController =
      TextEditingController();
  final TextEditingController resetConfirmPasswordController =
      TextEditingController();

  /// Live mirrors of the two reset fields (drive the strength UI).
  final RxString resetNewPassword = ''.obs;
  final RxString resetConfirmPassword = ''.obs;

  final RxBool obscureResetNew = true.obs;
  final RxBool obscureResetConfirm = true.obs;
  void toggleObscureResetNew() =>
      obscureResetNew.value = !obscureResetNew.value;
  void toggleObscureResetConfirm() =>
      obscureResetConfirm.value = !obscureResetConfirm.value;

  // In-flight flags for each dialog step.
  final RxBool isSendingResetOtp = false.obs;
  final RxBool isVerifyingResetOtp = false.obs;
  final RxBool isResettingPassword = false.obs;
  final RxBool isResendingResetOtp = false.obs;

  /// Token captured from verify-email; required to set the new password.
  final RxString resetToken = ''.obs;

  // 60s resend cooldown (mirrors LoginController.startResendTimer).
  static const int kResetResendCooldown = 60;
  final RxInt resetResendSeconds = 0.obs;
  Timer? _resetResendTimer;
  bool get canResendResetOtp => resetResendSeconds.value == 0;

  void startResetResendTimer() {
    _resetResendTimer?.cancel();
    resetResendSeconds.value = kResetResendCooldown;
    _resetResendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resetResendSeconds.value <= 1) {
        resetResendSeconds.value = 0;
        t.cancel();
      } else {
        resetResendSeconds.value = resetResendSeconds.value - 1;
      }
    });
  }

  // Password-strength rules (match the live /auth/reset-password flow: min 10,
  // one uppercase, one lowercase, one number).
  static const int kResetMinPasswordLength = 10;
  bool get hasMinLength =>
      resetNewPassword.value.length >= kResetMinPasswordLength;
  bool get hasUppercase => resetNewPassword.value.contains(RegExp(r'[A-Z]'));
  bool get hasLowercase => resetNewPassword.value.contains(RegExp(r'[a-z]'));
  bool get hasNumber => resetNewPassword.value.contains(RegExp(r'[0-9]'));
  bool get isResetPasswordValid =>
      hasMinLength && hasUppercase && hasLowercase && hasNumber;
  bool get resetPasswordsMatch =>
      resetConfirmPassword.value.isNotEmpty &&
      resetConfirmPassword.value == resetNewPassword.value;

  /// Validates an email for the reset flow (same regex used across auth).
  bool isValidResetEmail(String e) =>
      RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(e);

  /// Clears all reset-flow state (controllers, codes, token, timer). Called
  /// after a successful reset so a re-entry starts clean.
  void clearResetFlow() {
    resetEmailController.clear();
    resetOtpCode.value = '';
    resetNewPasswordController.clear();
    resetConfirmPasswordController.clear();
    resetNewPassword.value = '';
    resetConfirmPassword.value = '';
    resetToken.value = '';
    obscureResetNew.value = true;
    obscureResetConfirm.value = true;
    _resetResendTimer?.cancel();
    resetResendSeconds.value = 0;
    // OtpFieldController throws if the field isn't mounted — guard.
    try {
      resetOtpController.clear();
    } catch (_) {}
  }

  @override
  void onInit() {
    super.onInit();
    loadMembers();
    // Mirror the reset-password fields into the reactive strings that drive
    // the strength/match UI in the new-password dialog.
    resetNewPasswordController.addListener(() {
      resetNewPassword.value = resetNewPasswordController.text;
    });
    resetConfirmPasswordController.addListener(() {
      resetConfirmPassword.value = resetConfirmPasswordController.text;
    });
  }

  /// Reads the bundled JSON, parses it into [Member]s, and populates
  /// [allMembers]. On any error the list is left empty (never throws).
  Future<void> loadMembers() async {
    isLoading.value = true;
    try {
      final raw =
          await rootBundle.loadString('assets/mock_profile_data.json');
      final decoded = jsonDecode(raw);
      final parsed = <Member>[];
      if (decoded is List) {
        for (final item in decoded) {
          if (item is Map) {
            parsed.add(Member.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }
      allMembers.assignAll(parsed);
    } catch (e) {
      debugPrint('HomeController.loadMembers failed: $e');
      allMembers.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Re-runs the asset load (bound to the header refresh button).
  void reload() => loadMembers();

  /// Switch between grid and deck layouts.
  void setViewMode(HomeViewMode mode) => viewMode.value = mode;

  /// Apply a city filter and reset the deck cursor to the top.
  void selectCity(String city) {
    selectedCity.value = city;
    deckIndex.value = 0;
  }

  /// Update the free-text search query and restart the deck.
  void setSearchQuery(String q) {
    searchQuery.value = q;
    deckIndex.value = 0;
  }

  // The sheet filters edit DRAFT state only; nothing changes the member list
  // until [applyFilters] runs. Call [initDraftFromApplied] when opening the
  // sheet so the controls start from the currently-applied values.

  /// Seeds the draft values from the currently applied filters. Call this when
  /// the filter sheet opens.
  void initDraftFromApplied() {
    draftGenderFilter.value = genderFilter.value;
    draftAgeRange.value = ageRange.value;
    draftSearchRadiusKm.value = searchRadiusKm.value;
    draftSelectedInterests.assignAll(selectedInterests);
  }

  /// Update the DRAFT gender filter (applied on [applyFilters]).
  void setGenderFilter(String g) => draftGenderFilter.value = g;

  /// Update the DRAFT age range (applied on [applyFilters]).
  void setAgeRange(RangeValues r) => draftAgeRange.value = r;

  /// PLACEHOLDER: update the cosmetic draft search radius (no real filtering).
  void setSearchRadius(double km) => draftSearchRadiusKm.value = km;

  /// Toggle an interest chip in the DRAFT set (applied on [applyFilters]).
  void toggleInterest(String i) {
    if (draftSelectedInterests.contains(i)) {
      draftSelectedInterests.remove(i);
    } else {
      draftSelectedInterests.add(i);
    }
  }

  /// Commit the draft sheet filters to the applied filters, which rebuilds the
  /// member list. Called by the sheet's "Apply Criteria" button.
  void applyFilters() {
    genderFilter.value = draftGenderFilter.value;
    ageRange.value = draftAgeRange.value;
    searchRadiusKm.value = draftSearchRadiusKm.value;
    selectedInterests.assignAll(draftSelectedInterests);
    deckIndex.value = 0;
  }

  /// Members matching ALL active filters combined: city, search query, gender,
  /// age range, and interests. Pure getter over [allMembers] so every [Obx]
  /// reading it rebuilds when any underlying observable changes.
  List<Member> get filteredMembers {
    final String query = searchQuery.value.trim().toLowerCase();
    final String gender = genderFilter.value;
    final int minAge = ageRange.value.start.round();
    final int maxAge = ageRange.value.end.round();
    final List<String> interests = selectedInterests;

    return allMembers.where((m) {
      // (1) City — 'All Belgium' means no filtering.
      if (selectedCity.value != 'All Belgium' &&
          m.profile.city != selectedCity.value) {
        return false;
      }
      // (2) Search query vs displayName (case-insensitive contains).
      if (query.isNotEmpty && !m.displayName.toLowerCase().contains(query)) {
        return false;
      }
      // (3) Gender — 'All' means no filtering; model gender is lowercase.
      if (gender != 'All' &&
          m.profile.gender.toLowerCase() != gender.toLowerCase()) {
        return false;
      }
      // (4) Age range (inclusive).
      if (m.age < minAge || m.age > maxAge) {
        return false;
      }
      // (5) Interests — OR match. A member matches a selected chip if any of
      // its interests, lowercased, equals the chip label lowercased OR
      // contains the chip label's first word lowercased (tolerant match).
      if (interests.isNotEmpty && !_matchesAnyInterest(m, interests)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// True when [m] has at least one interest matching any [selected] chip.
  bool _matchesAnyInterest(Member m, List<String> selected) {
    final memberInterests =
        m.profile.interests.map((e) => e.toLowerCase()).toList();
    for (final chip in selected) {
      final label = chip.toLowerCase();
      final firstWord = label.split(' ').first;
      for (final mi in memberInterests) {
        if (mi == label || mi.contains(firstWord)) return true;
      }
    }
    return false;
  }

  /// Reset every filter to its default and clear the search field. Resets both
  /// the applied values (so the list updates) AND the draft values (so the
  /// sheet controls visibly reset).
  void resetFilters() {
    selectedCity.value = 'All Belgium';
    searchQuery.value = '';
    searchController.clear();

    genderFilter.value = 'All';
    ageRange.value = const RangeValues(18, 55);
    searchRadiusKm.value = 30;
    selectedInterests.clear();

    draftGenderFilter.value = 'All';
    draftAgeRange.value = const RangeValues(18, 55);
    draftSearchRadiusKm.value = 30;
    draftSelectedInterests.clear();

    deckIndex.value = 0;
  }

  /// Count shown as "N members online" (filtered).
  int get onlineCount => filteredMembers.length;

  /// Current member in the deck, or null when the deck is exhausted/empty.
  Member? get currentDeckMember {
    final list = filteredMembers;
    if (list.isEmpty || deckIndex.value >= list.length) return null;
    return list[deckIndex.value];
  }

  /// Record a "like" on the current deck member and advance.
  void likeCurrent() {
    final m = currentDeckMember;
    if (m != null) {
      debugPrint('Liked: ${m.displayName} (${m.id})');
    }
    _advanceDeck();
  }

  /// Record a "pass" on the current deck member and advance.
  void passCurrent() {
    final m = currentDeckMember;
    if (m != null) {
      debugPrint('Passed: ${m.displayName} (${m.id})');
    }
    _advanceDeck();
  }

  void _advanceDeck() {
    deckIndex.value =
        (deckIndex.value + 1).clamp(0, filteredMembers.length);
  }

  /// Reset the deck cursor back to the first member.
  void resetDeck() => deckIndex.value = 0;

  /// Open the full profile for [m].
  void openMemberDetail(Member m) =>
      Get.toNamed(Routes.MEMBER_DETAIL, arguments: m);

  /// Stub connect action from the detail screen.
  void onConnect(Member m) {
    debugPrint('Connect requested: ${m.displayName} (${m.id})');
  }

  /// Switch bottom navigation bar tab.
  void selectNavTab(int index) {
    selectedNavIndex.value = index;
  }

  /// Logs out: calls the logout API with the stored refresh token, then (on a
  /// 2xx/204 ack) clears the auth session from storage — PRESERVING remember-me
  /// — and returns to Login. If the API call fails we still clear locally and
  /// route to Login so the user isn't stuck signed in.
  Future<void> onLogout() async {
    if (_isLoggingOut.value) return;
    _isLoggingOut.value = true;
    try {
      final store = HiveStore();
      final refreshToken = store.getString(Keys.REFRESHTOKEN) ?? '';

      final bool ok = refreshToken.isNotEmpty
          ? await LoginService.instance.logout(refreshToken: refreshToken)
          : false;

      if (!ok) {
        debugPrint('Logout API did not confirm; clearing session locally.');
      }
      store.clearSession();
      Get.offAllNamed(Routes.LOGIN);
    } finally {
      _isLoggingOut.value = false;
    }
  }

  final RxBool _isLoggingOut = false.obs;

  @override
  void onClose() {
    searchController.dispose();
    // Accounts tab + reset-password dialog flow.
    changeCurrentPasswordController.dispose();
    changeNewPasswordController.dispose();
    changeConfirmPasswordController.dispose();
    resetEmailController.dispose();
    resetNewPasswordController.dispose();
    resetConfirmPasswordController.dispose();
    _resetResendTimer?.cancel();
    super.onClose();
  }
}
