import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../routes/routes.dart';
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

  /// Fixed city filter options shown as chips.
  final List<String> cities = const [
    'All Belgium',
    'Brussels',
    'Antwerp',
    'Ghent',
    'Bruges',
    'Leuven',
    'Liège',
    'Namur',
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

  /// Members matching the active city filter.
  List<Member> get filteredMembers {
    if (selectedCity.value == 'All Belgium') return allMembers.toList();
    return allMembers
        .where((m) => m.profile.city == selectedCity.value)
        .toList();
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

  /// Log out action.
  void onLogout() {
    Get.offAllNamed(Routes.LOGIN);
  }
}
