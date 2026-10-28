import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../routes/routes.dart';
import '../../../utils/Store/HiveStore.dart';
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

  @override
  void onInit() {
    super.onInit();
    loadMembers();
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
    super.onClose();
  }
}
