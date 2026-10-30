import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/routes.dart';
import '../../../utils/Store/HiveStore.dart';
import '../../../utils/lib/otp_text_field.dart';
import '../../login/controller/login_controller.dart';
import '../../login/services/login_services.dart';
import '../../notification/services/notification_services.dart';
import '../model/member.dart';
import '../services/friend_services.dart';
import '../services/member_services.dart';

/// The two ways the browse-members home renders its list.
enum HomeViewMode { grid, deck }

/// Drives the authenticated "Browse Members" home: loads members from the
/// GET /users API (paged, with server-side gender/age filters), exposes the
/// grid/deck view mode, client-side city/search/interest filtering, and the
/// deck swipe cursor. All UI state is reactive so the views can wrap the
/// relevant pieces in [Obx].
class HomeController extends GetxController with WidgetsBindingObserver {
  /// Page size sent as `limit`.
  static const int membersPageSize = 20;

  /// Default (unfiltered) age range shown in the filter sheet.
  static const RangeValues defaultAgeRange = RangeValues(18, 55);

  /// Every member loaded so far (all pages), already filtered server-side by
  /// gender/age. Client-side filters run over this in [filteredMembers].
  final RxList<Member> allMembers = <Member>[].obs;

  /// True while the first page is loading (full-area spinner).
  final RxBool isLoading = true.obs;

  /// True while a next page is loading (small footer spinner).
  final RxBool isLoadingMore = false.obs;

  /// Error from the last first-page load; shown with Retry when nothing is
  /// loaded.
  final RxString errorMessage = ''.obs;

  /// Server-reported total for the current gender/age query.
  /// Reactive so [onlineCount] rebuilds when it changes.
  final RxInt _total = 0.obs;

  /// Guards the first-page load (isLoading starts true for the initial
  /// spinner, so it can't double as the guard).
  bool _isFetchingFirst = false;

  /// True once the user applied an age range different from the default;
  /// only then are min_age/max_age sent. Cleared by [resetFilters].
  bool _ageFilterActive = false;

  /// Grid scroll controller; nearing the bottom loads the next page.
  final ScrollController membersScrollController = ScrollController();

  /// Rows the server has returned so far for the current query; the next
  /// page's `offset`. Kept separate from [allMembers].length because local
  /// passes ([passMember]) shrink the list without changing server paging.
  int _serverOffset = 0;

  /// Ids passed locally since the last first-page load. Filtered out of later
  /// pages and subtracted from [onlineCount]; cleared by [fetchFirstPage]
  /// (a refetch may bring passed members back).
  /// Reactive so [onlineCount] rebuilds on a pass.
  final RxSet<String> _passedIds = <String>{}.obs;

  /// Ids of server rows hidden because their friendship_status isn't "none"
  /// (or a request was just sent to them), from the pages loaded since the
  /// last first-page load. Subtracted from [onlineCount] like [_passedIds];
  /// cleared and rebuilt by [fetchFirstPage]. Also used to de-dupe later
  /// pages. Reactive so [onlineCount] rebuilds.
  final RxSet<String> _hiddenByStatusIds = <String>{}.obs;

  /// Ids a friend request was successfully sent to during this session. Kept
  /// across refetches so a racing/stale response that still reports "none"
  /// can't bring them back into the list.
  final Set<String> _requestedIds = <String>{};

  /// Whether [m] may appear in the browse list (no friendship/request yet).
  bool _isBrowsable(Member m) =>
      m.isFriendshipNone && !_requestedIds.contains(m.id);

  bool get hasMore => _serverOffset < _total.value;

  /// Active view mode (grid by default).
  final Rx<HomeViewMode> viewMode = HomeViewMode.grid.obs;

  /// User profile info loaded from HiveStore.
  final RxString userAvatarUrl = ''.obs;
  final RxString userProfileName = ''.obs;

  void loadUserData() {
    final String? avatar = HiveStore().getString(Keys.SAVEDAVATAR);
    final String? name = HiveStore().getString(Keys.SAVEDPROFILENAME) ??
        HiveStore().getString(Keys.SAVEDNAME) ??
        HiveStore().getString(Keys.SESSIONDISPLAYNAME);
    if (avatar != null && avatar.isNotEmpty) {
      userAvatarUrl.value = avatar;
    }
    if (name != null && name.isNotEmpty) {
      userProfileName.value = name;
    }
  }

  /// Active bottom navigation bar index (0: Explore, 1: Chat, 2: Friends).
  final RxInt selectedNavIndex = 0.obs;

  /// Unread notification count shown as a badge on the header bell.
  /// TODO: update from the notifications API / push handler when available
  /// (call [setUnreadNotifications] or [incrementUnreadNotifications]).
  final RxInt unreadNotifications = 0.obs;

  void setUnreadNotifications(int count) =>
      unreadNotifications.value = count < 0 ? 0 : count;

  void incrementUnreadNotifications([int by = 1]) =>
      unreadNotifications.value += by;

  /// Tapping the bell: open Notifications, then re-check the unread count when
  /// the user comes back (the server's is_read is the source of truth).
  Future<void> onNotificationsTap() async {
    await Get.toNamed(Routes.NOTIFICATION);
    refreshUnreadNotifications(force: true);
  }

  // --- Unread-badge sync ---------------------------------------------------
  // Checkpoints that call [refreshUnreadNotifications]:
  //   • onInit (home opened after login / app launch)
  //   • every tab switch (selectNavTab)
  //   • app returns to foreground (didChangeAppLifecycleState → resumed)
  //   • back from the Notifications screen (onNotificationsTap)
  //   • a periodic poll while home is alive (catches new ones while idle)

  /// How often to poll while the home screen is open.
  static const Duration _badgePollInterval = Duration(seconds: 60);

  /// Minimum gap between non-forced checks (rapid tab taps → one request).
  static const Duration _badgeThrottle = Duration(seconds: 10);

  Timer? _badgePollTimer;
  bool _isCheckingBadge = false;
  DateTime? _lastBadgeCheck;

  /// Fetches the unread count and updates the bell badge. Skips if a check is
  /// already running or one ran within [_badgeThrottle] (unless [force]).
  /// On failure the current badge is kept as-is.
  Future<void> refreshUnreadNotifications({bool force = false}) async {
    if (_isCheckingBadge) return;
    final now = DateTime.now();
    if (!force &&
        _lastBadgeCheck != null &&
        now.difference(_lastBadgeCheck!) < _badgeThrottle) {
      return;
    }
    // Only meaningful with a logged-in session token.
    final token = HiveStore().getString(Keys.ACCESSTOKEN);
    if (token == null || token.toString().isEmpty) return;

    _isCheckingBadge = true;
    _lastBadgeCheck = now;
    try {
      final count = await NotificationService.instance.fetchUnreadCount();
      if (count != null) setUnreadNotifications(count);
    } finally {
      _isCheckingBadge = false;
    }
  }

  void _startBadgePolling() {
    _badgePollTimer?.cancel();
    _badgePollTimer = Timer.periodic(
      _badgePollInterval,
      (_) => refreshUnreadNotifications(),
    );
  }

  void _stopBadgePolling() {
    _badgePollTimer?.cancel();
    _badgePollTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshUnreadNotifications(force: true);
      _startBadgePolling();
    } else if (state == AppLifecycleState.paused) {
      // Don't poll in the background.
      _stopBadgePolling();
    }
  }

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
  /// Applied SERVER-SIDE via the `gender` query param (see [_apiGender]).
  final RxString genderFilter = 'All'.obs;

  /// Inclusive age range filter. Applied SERVER-SIDE via min_age/max_age, only
  /// when [_ageFilterActive].
  final Rx<RangeValues> ageRange = defaultAgeRange.obs;

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
  final Rx<RangeValues> draftAgeRange = defaultAgeRange.obs;
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

  /// Whether the change-password request is in flight (drives the button
  /// spinner, same style as Login/Register).
  final RxBool isChangingPassword = false.obs;

  // Live mirrors of the Change-Password "new" + "confirm" fields; drive the
  // register-style strength meter / checklist and the match indicator.
  final RxString changeNewPassword = ''.obs;
  final RxString changeConfirmPassword = ''.obs;

  /// Same rules as the Create Account password field.
  static const int kChangeMinPasswordLength = 10;
  bool get changeHasMinLength =>
      changeNewPassword.value.length >= kChangeMinPasswordLength;
  bool get changeHasUppercase =>
      changeNewPassword.value.contains(RegExp(r'[A-Z]'));
  bool get changeHasLowercase =>
      changeNewPassword.value.contains(RegExp(r'[a-z]'));
  bool get changeHasNumber =>
      changeNewPassword.value.contains(RegExp(r'[0-9]'));

  int get changePasswordScore => [
        changeHasMinLength,
        changeHasUppercase,
        changeHasLowercase,
        changeHasNumber,
      ].where((ok) => ok).length;

  bool get isChangePasswordValid => changePasswordScore == 4;

  String get changePasswordStrengthLabel {
    if (changeNewPassword.value.isEmpty) return '';
    switch (changePasswordScore) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      default:
        return 'Strong';
    }
  }

  String get changePasswordError {
    if (changeNewPassword.value.isEmpty) return '';
    if (!changeHasMinLength) {
      return 'Password must be at least $kChangeMinPasswordLength characters';
    }
    if (!changeHasUppercase) return 'Add at least one uppercase letter';
    if (!changeHasLowercase) return 'Add at least one lowercase letter';
    if (!changeHasNumber) return 'Add at least one number';
    return '';
  }

  bool get changePasswordsMatch =>
      changeConfirmPassword.value.isNotEmpty &&
      changeConfirmPassword.value == changeNewPassword.value;

  /// Validates the Change-Password card and calls the API. On success (200 or
  /// 204) shows a snackbar and clears all three fields.
  Future<void> onUpdatePassword() async {
    if (isChangingPassword.value) return;

    final current = changeCurrentPasswordController.text;
    final newPwd = changeNewPasswordController.text;
    final confirm = changeConfirmPasswordController.text;

    if (current.isEmpty || newPwd.isEmpty || confirm.isEmpty) {
      Get.snackbar('Missing fields', 'Please fill in all password fields.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (!isChangePasswordValid) {
      Get.snackbar(
          'Weak password',
          changePasswordError.isNotEmpty
              ? changePasswordError
              : 'Please meet all password requirements.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (newPwd != confirm) {
      Get.snackbar('Passwords do not match',
          'New password and confirmation must be identical.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (newPwd == current) {
      Get.snackbar('Same password',
          'New password must be different from the current one.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isChangingPassword.value = true;
    try {
      final res = await LoginService.instance.changePassword(
        currentPassword: current,
        newPassword: newPwd,
        confirmNewPassword: confirm,
      );
      if (res.success) {
        changeCurrentPasswordController.clear();
        changeNewPasswordController.clear();
        changeConfirmPasswordController.clear();
        Get.snackbar('Password updated', res.message,
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Could not update password', res.message,
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isChangingPassword.value = false;
    }
  }

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
    loadUserData();
    // Unread badge: check now (post-login / app launch), then poll while home
    // is open, and re-check when the app returns to the foreground.
    WidgetsBinding.instance.addObserver(this);
    refreshUnreadNotifications(force: true);
    _startBadgePolling();
    membersScrollController.addListener(_onMembersScroll);
    fetchFirstPage();
    // Mirror the Change-Password card's new/confirm fields for the live
    // strength checklist + match indicator.
    changeNewPasswordController.addListener(() {
      changeNewPassword.value = changeNewPasswordController.text;
    });
    changeConfirmPasswordController.addListener(() {
      changeConfirmPassword.value = changeConfirmPasswordController.text;
    });

    // Mirror the reset-password fields into the reactive strings that drive
    // the strength/match UI in the new-password dialog.
    resetNewPasswordController.addListener(() {
      resetNewPassword.value = resetNewPasswordController.text;
    });
    resetConfirmPasswordController.addListener(() {
      resetConfirmPassword.value = resetConfirmPasswordController.text;
    });
  }

  // ===========================================================================
  // --- Members list (GET /users) ---------------------------------------------
  // ===========================================================================

  /// Bumped by every [fetchFirstPage]; a response whose generation no longer
  /// matches belongs to a superseded query (old filters / refresh) and is
  /// dropped, so pages from different queries never mix.
  int _membersGen = 0;

  /// UI gender → backend `gender` param. 'All' (or unknown) → null = not sent.
  /// ASSUMPTION: the backend accepts lowercase "male"/"female"/"other" even
  /// though stored data mixes "Man"/"Woman"; change the values here if the API
  /// expects a different vocabulary.
  String? get _apiGender {
    switch (genderFilter.value) {
      case 'Male':
        return 'male';
      case 'Female':
        return 'female';
      case 'Other':
        return 'other';
      default:
        return null;
    }
  }

  /// min_age to send, or null when the age filter isn't active.
  int? get _apiMinAge => _ageFilterActive
      ? ageRange.value.start.round().clamp(18, 120).toInt()
      : null;

  /// max_age to send, or null when the age filter isn't active.
  int? get _apiMaxAge => _ageFilterActive
      ? ageRange.value.end.round().clamp(18, 120).toInt()
      : null;

  /// Loads page 1 (offset 0) for the current gender/age filters. Used on open,
  /// by the header refresh, pull-to-refresh, Retry, and Apply/Reset filters.
  /// A new call supersedes any in-flight load (see [_membersGen]).
  /// [showSpinner] = false keeps the current list visible (pull-to-refresh).
  Future<void> fetchFirstPage({bool showSpinner = true}) async {
    final gen = ++_membersGen;
    _isFetchingFirst = true;
    isLoadingMore.value = false;
    if (showSpinner) isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await MemberService.instance.fetchMembers(
        limit: membersPageSize,
        offset: 0,
        gender: _apiGender,
        minAge: _apiMinAge,
        maxAge: _apiMaxAge,
      );
      if (gen != _membersGen) return; // superseded
      if (res.success) {
        _total.value = res.total;
        // Raw server rows (incl. hidden ones) so paging never skips/repeats.
        _serverOffset = res.items.length;
        _passedIds.clear();
        _hiddenByStatusIds.assignAll(
            res.items.where((m) => !_isBrowsable(m)).map((m) => m.id));
        allMembers.assignAll(res.items.where(_isBrowsable));
        deckIndex.value = 0;
        _maybeAutoLoadMore();
      } else if (allMembers.isEmpty) {
        // Nothing to show: the empty state renders this with a Retry.
        errorMessage.value = res.message;
      } else {
        // Keep the list already on screen; just surface the error.
        Get.snackbar('Could not refresh', res.message,
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      if (gen == _membersGen) {
        _isFetchingFirst = false;
        isLoading.value = false;
      }
    }
  }

  /// Pull-to-refresh handler (RefreshIndicator needs a Future). Keeps the
  /// current list visible while reloading.
  Future<void> onRefresh() => fetchFirstPage(showSpinner: false);

  /// Loads the next page using offset = rows the server returned so far
  /// ([_serverOffset]). De-dupes by id (also skipping locally passed members)
  /// and stops when the server returns nothing new.
  Future<void> fetchNextPage() async {
    if (_isFetchingFirst || isLoadingMore.value || !hasMore) return;
    final gen = _membersGen;
    isLoadingMore.value = true;
    try {
      final res = await MemberService.instance.fetchMembers(
        limit: membersPageSize,
        offset: _serverOffset,
        gender: _apiGender,
        minAge: _apiMinAge,
        maxAge: _apiMaxAge,
      );
      if (gen != _membersGen) return; // query changed meanwhile
      if (res.success) {
        _serverOffset += res.items.length;
        final existing = allMembers.map((m) => m.id).toSet()
          ..addAll(_passedIds)
          ..addAll(_hiddenByStatusIds);
        final newRows =
            res.items.where((m) => !existing.contains(m.id)).toList();
        // Stop paging if the server returned nothing (or nothing new).
        _total.value = newRows.isEmpty ? _serverOffset : res.total;
        // Rows with a friendship/request are hidden (counted, not shown).
        _hiddenByStatusIds
            .addAll(newRows.where((m) => !_isBrowsable(m)).map((m) => m.id));
        allMembers.addAll(newRows.where(_isBrowsable));
        // Keep going even if every new row was hidden; each call advances
        // [_serverOffset] and an empty/duplicate page stops paging above.
        if (newRows.isNotEmpty) _maybeAutoLoadMore();
      } else {
        Get.snackbar('Could not load more', res.message,
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      if (gen == _membersGen) isLoadingMore.value = false;
    }
  }

  /// Grid scroll listener: start loading a bit before the very bottom.
  void _onMembersScroll() {
    if (!membersScrollController.hasClients) return;
    final pos = membersScrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) fetchNextPage();
  }

  /// Keeps pages flowing when the visible list is too short to trigger the
  /// usual triggers (client-side city/search/interest filters can hide most
  /// of a page): in deck mode when within 3 cards of the end, in grid mode
  /// when the grid doesn't reach the load threshold (or isn't shown at all
  /// because everything loaded so far is filtered out). Runs after the frame
  /// so the grid's scroll extent is up to date.
  void _maybeAutoLoadMore() {
    if (!hasMore) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClosed || !hasMore) return;
      if (viewMode.value == HomeViewMode.deck) {
        _maybeLoadMoreForDeck();
      } else if (membersScrollController.hasClients) {
        _onMembersScroll();
      } else if (filteredMembers.isEmpty) {
        fetchNextPage();
      }
    });
  }

  /// Deck: prefetch when the cursor is within 3 cards of the end.
  void _maybeLoadMoreForDeck() {
    if (hasMore && filteredMembers.length - deckIndex.value <= 3) {
      fetchNextPage();
    }
  }

  /// Re-queries page 1 (bound to the header refresh button).
  void reload() => fetchFirstPage();

  /// Switch between grid and deck layouts.
  void setViewMode(HomeViewMode mode) {
    viewMode.value = mode;
    _maybeAutoLoadMore();
  }

  /// Apply a city filter and reset the deck cursor to the top.
  void selectCity(String city) {
    selectedCity.value = city;
    deckIndex.value = 0;
    _maybeAutoLoadMore();
  }

  /// Update the free-text search query and restart the deck.
  void setSearchQuery(String q) {
    searchQuery.value = q;
    deckIndex.value = 0;
    _maybeAutoLoadMore();
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
    // Only send min_age/max_age once the user actually moved the range.
    _ageFilterActive = draftAgeRange.value != defaultAgeRange;
    searchRadiusKm.value = draftSearchRadiusKm.value;
    selectedInterests.assignAll(draftSelectedInterests);
    deckIndex.value = 0;
    // Gender/age are server-side: re-query with the new params.
    fetchFirstPage();
  }

  /// Members matching the CLIENT-SIDE filters: city, search query, and
  /// interests. Gender and age are NOT applied here — they're sent to the API
  /// (see [fetchFirstPage]) so [allMembers] is already filtered by them.
  /// Search radius isn't supported by the API and stays cosmetic.
  /// Pure getter over [allMembers] so every [Obx] reading it rebuilds when
  /// any underlying observable changes.
  List<Member> get filteredMembers {
    final String query = searchQuery.value.trim().toLowerCase();
    final List<String> interests = selectedInterests;

    return allMembers.where((m) {
      // (1) City — 'All Belgium' means no filtering. NOTE: the users API has
      // no city yet (profile.city is always ''), so any specific city matches
      // nobody until the API supports it.
      if (selectedCity.value != 'All Belgium' &&
          m.profile.city != selectedCity.value) {
        return false;
      }
      // (2) Search query vs displayName (case-insensitive contains).
      if (query.isNotEmpty && !m.displayName.toLowerCase().contains(query)) {
        return false;
      }
      // (3) Interests — OR match. A member matches a selected chip if any of
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
    ageRange.value = defaultAgeRange;
    _ageFilterActive = false;
    searchRadiusKm.value = 30;
    selectedInterests.clear();

    draftGenderFilter.value = 'All';
    draftAgeRange.value = defaultAgeRange;
    draftSearchRadiusKm.value = 30;
    draftSelectedInterests.clear();

    deckIndex.value = 0;
    // Back to the default query (no gender/age params).
    fetchFirstPage();
  }

  /// True when a client-side filter (city, search, interests) is narrowing
  /// the loaded list.
  bool get _hasClientFilters =>
      selectedCity.value != 'All Belgium' ||
      searchQuery.value.trim().isNotEmpty ||
      selectedInterests.isNotEmpty;

  /// Count shown as "N members online": the server `total` for the current
  /// gender/age query when no client-side filter is active (covers pages not
  /// loaded yet); otherwise the number of loaded members passing the
  /// client-side filters.
  /// Locally passed members and rows hidden by friendship status (from the
  /// pages loaded so far) are excluded from the server total.
  int get onlineCount => _hasClientFilters
      ? filteredMembers.length
      : (_total.value - _passedIds.length - _hiddenByStatusIds.length)
          .clamp(0, _total.value)
          .toInt();

  /// Current member in the deck, or null when the deck is exhausted/empty.
  Member? get currentDeckMember {
    final list = filteredMembers;
    if (list.isEmpty || deckIndex.value >= list.length) return null;
    return list[deckIndex.value];
  }

  /// Deck heart / swipe-right: sends a friend request to the current top
  /// member. On success that member is removed locally and the list is
  /// re-fetched (their friendship_status becomes "request_sent", so they stay
  /// hidden), which also resets the deck cursor to 0.
  Future<void> likeCurrent() async {
    final m = currentDeckMember;
    if (m == null) return;
    await sendFriendRequest(m);
  }

  /// Deck X / swipe-left: pass on the current top member (removed locally;
  /// the next member slides into the same [deckIndex]).
  void passCurrent() {
    final m = currentDeckMember;
    if (m == null) return;
    passMember(m);
  }

  /// Pass on [m]: removes it from [allMembers] (and so [filteredMembers], the
  /// grid and the deck) LOCALLY — no API call, no refetch. A later refresh may
  /// bring the member back. The deck cursor keeps pointing at the same card:
  /// it shifts back by one if [m] sat before it, and is clamped to
  /// 0..filteredMembers.length (length = exhausted, see [currentDeckMember]).
  void passMember(Member m) {
    if (!_removeLocally(m)) return; // not in the list
    _passedIds.add(m.id);
  }

  /// Removes [m] from [allMembers], keeping the deck cursor on the same card
  /// (shifted back if [m] sat before it, clamped to
  /// 0..filteredMembers.length) and keeping pages flowing. Returns false when
  /// [m] wasn't in the list.
  bool _removeLocally(Member m) {
    final filteredIdx = filteredMembers.indexWhere((e) => e.id == m.id);
    final before = allMembers.length;
    allMembers.removeWhere((e) => e.id == m.id);
    if (allMembers.length == before) return false;

    if (filteredIdx >= 0 && filteredIdx < deckIndex.value) {
      deckIndex.value = deckIndex.value - 1;
    }
    deckIndex.value = deckIndex.value.clamp(0, filteredMembers.length).toInt();

    // The list shrank: keep pages flowing (deck near the end, or a grid that
    // no longer reaches the scroll threshold / is now empty).
    _maybeAutoLoadMore();
    return true;
  }

  /// Reset the deck cursor back to the first member.
  void resetDeck() => deckIndex.value = 0;

  /// Open the full profile for [m].
  void openMemberDetail(Member m) =>
      Get.toNamed(Routes.MEMBER_DETAIL, arguments: m);

  /// Ids of members whose friend request is in flight. Drives the Connect /
  /// deck-heart loaders and blocks double taps per member.
  final RxSet<String> sendingRequestIds = <String>{}.obs;

  bool isSendingRequest(String memberId) =>
      sendingRequestIds.contains(memberId);

  /// POST friends/requests/{id}. On success: snackbar, immediate local
  /// removal, then re-fetch page 1 with
  /// the current filters (same as pull-to-refresh). On failure: error
  /// snackbar, no re-fetch. Returns true on success.
  Future<bool> sendFriendRequest(Member m) async {
    if (m.id.isEmpty || sendingRequestIds.contains(m.id)) return false;
    sendingRequestIds.add(m.id);
    try {
      final res = await FriendService.instance.sendFriendRequest(m.id);
      if (!res.success) {
        Get.snackbar('Could not send request', res.message,
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }
      Get.snackbar('Request sent', 'Friend request sent to ${m.displayName}',
          snackPosition: SnackPosition.BOTTOM);
      // Hide them right away (status is now request_sent) so they vanish
      // before the refetch lands, and stay hidden if a stale response races.
      _requestedIds.add(m.id);
      if (_removeLocally(m)) _hiddenByStatusIds.add(m.id);
      await onRefresh();
      return true;
    } finally {
      sendingRequestIds.remove(m.id);
    }
  }

  /// Connect from the detail screen: send the request and, on success, pop
  /// back to Browse Members once the refreshed list is loaded.
  /// NOTE: Get.back() would only dismiss the success snackbar (GetX 4 compat
  /// behaviour), so pop the detail route via the navigator instead. No-op if
  /// the user already left the detail screen.
  Future<void> onConnect(Member m) async {
    if (sendingRequestIds.contains(m.id)) return;
    final ok = await sendFriendRequest(m);
    if (ok) {
      Get.until((route) => route.settings.name != Routes.MEMBER_DETAIL);
    }
  }

  /// Pass from the detail screen: remove [m] locally, then pop back to Browse
  /// Members (Get.back() would only close a snackbar in GetX 4.7.3).
  void onPassFromDetail(Member m) {
    passMember(m);
    Get.until((route) => route.settings.name != Routes.MEMBER_DETAIL);
  }

  /// Switch bottom navigation bar tab.
  void selectNavTab(int index) {
    selectedNavIndex.value = index;
    // Checkpoint: every tab switch re-checks the unread badge (throttled).
    refreshUnreadNotifications();
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

  /// Whether the delete-account request is in flight (drives the dialog's
  /// Delete button spinner).
  final RxBool isDeletingAccount = false.obs;

  /// Deletes the account via DELETE /users/me. On 200/204: clears local
  /// storage and routes to Login (same as logout). Remember-me credentials are
  /// ALSO cleared here because the account no longer exists. Returns true on
  /// success so the caller can close its dialog.
  Future<bool> onDeleteAccount() async {
    if (isDeletingAccount.value) return false;
    isDeletingAccount.value = true;
    try {
      final res = await LoginService.instance.deleteAccount();
      if (!res.success) {
        Get.snackbar('Could not delete account', res.message,
            snackPosition: SnackPosition.BOTTOM);
        return false;
      }

      final store = HiveStore();
      store.clearSession();
      store.remove(Keys.REMEMBERME);
      store.remove(Keys.SAVEDEMAIL);
      store.remove(Keys.SAVEDPASSWORD);

      // LoginController is permanent; clear its in-memory fields too so the
      // deleted account's credentials don't reappear on the Login screen.
      if (Get.isRegistered<LoginController>()) {
        final login = Get.find<LoginController>();
        login.emailController.clear();
        login.passwordController.clear();
        login.rememberMe.value = false;
      }

      Get.offAllNamed(Routes.LOGIN);
      Get.snackbar('Account deleted', res.message,
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } finally {
      isDeletingAccount.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    membersScrollController.dispose();
    // Accounts tab + reset-password dialog flow.
    changeCurrentPasswordController.dispose();
    changeNewPasswordController.dispose();
    changeConfirmPasswordController.dispose();
    resetEmailController.dispose();
    resetNewPasswordController.dispose();
    resetConfirmPasswordController.dispose();
    _resetResendTimer?.cancel();
    // Stop badge polling + lifecycle listening (e.g. on logout).
    _stopBadgePolling();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
