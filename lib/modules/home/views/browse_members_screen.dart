import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../device_manager/screen_constants.dart';
import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';
import '../../../utils/custom_widgets/universal_button.dart';
import '../controller/home_controller.dart';
import '../model/member.dart';
import 'widgets/member_network_image.dart';

/// The authenticated home: browse member profiles in a Grid or a Tinder-style
/// Deck, filterable by city. Light/whitish aesthetic with rose accents, reused
/// from the auth flow. The header and city chips stay pinned; only the body
/// (grid/deck) area reacts to state.
class BrowseMembersScreen extends GetView<HomeController> {
  const BrowseMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.colorAF5FF,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Obx(() {
                switch (controller.selectedNavIndex.value) {
                  case 0:
                    return _buildExploreTab();
                  case 1:
                    return _buildBlankTab("Chat", Icons.chat_bubble_outline);
                  case 2:
                    return _buildBlankTab("Friends", Icons.people_outline);
                  case 3:
                    return _buildBlankTab("Account", Icons.account_circle_outlined);
                  case 4:
                    return _buildBlankTab("Blocked", Icons.block);
                  default:
                    return _buildExploreTab();
                }
              }),
            ),
            Positioned(
              left: ScreenConstant.defaultWidthTen,
              right: ScreenConstant.defaultWidthTen,
              bottom: 0,
              child: Obx(() => _buildBottomNavBar()),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Tab Views
  // ---------------------------------------------------------------------------
  Widget _buildExploreTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        _buildSearchRow(),
        SizedBox(height: ScreenConstant.defaultHeightTen),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    CustomColor.colorBE185D,
                  ),
                ),
              );
            }
            if (controller.filteredMembers.isEmpty) {
              return _emptyFiltered();
            }
            return controller.viewMode.value == HomeViewMode.grid
                ? _buildGrid()
                : _buildDeck();
          }),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildBlankTab(String title, IconData icon) {
    return Column(
      children: [
        // _buildHeader(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 48,
                  color: CustomColor.color94A3B8,
                ),
                SizedBox(height: ScreenConstant.sizeSmall),
                Text(
                  title,
                  style: TextStyles.registerTitle.copyWith(
                    color: CustomColor.color64748B,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Floating Bottom Navigation Bar
  // ---------------------------------------------------------------------------
  Widget _buildBottomNavBar() {
    final int selectedIndex = controller.selectedNavIndex.value;

    return Container(
    //  height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1FA),
        borderRadius: BorderRadius.circular(80),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: CustomColor.color0F172A.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _navNavItem(
              index: 0,
              icon: Icons.explore_outlined,
              label: "Search",
              isSelected: selectedIndex == 0,
            ),
          ),
          Expanded(
            child: _navNavItem(
              index: 1,
              icon: Icons.mark_chat_unread_outlined,
              label: "Chat",
              isSelected: selectedIndex == 1,
            ),
          ),
          Expanded(
            child: _navNavItem(
              index: 2,
              icon: Icons.people_outline,
              label: "Friends",
              isSelected: selectedIndex == 2,
            ),
          ),
          Expanded(
            child: _navNavItem(
              index: 3,
              icon: Icons.account_circle_outlined,
              label: "Accounts",
              isSelected: selectedIndex == 3,
            ),
          ),
          Expanded(
            child: _navNavItem(
              index: 4,
              icon: Icons.block,
              label: "Blocked",
              isSelected: selectedIndex == 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.selectNavTab(index),
      child: AnimatedContainer(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    CustomColor.colorBE185D,
                    CustomColor.color581C87,
                  ],
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: CustomColor.colorBE185D.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 10,
              color: isSelected
                  ? CustomColor.colorWhite
                  : CustomColor.color0F172A.withOpacity(0.5),
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? CustomColor.colorWhite
                    : CustomColor.color0F172A.withOpacity(0.5),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: "Liberation",
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Profile Popup Menu
  // ---------------------------------------------------------------------------
  Widget _buildProfileMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: CustomColor.colorWhite,
      elevation: 12,
      onSelected: (value) {
        if (value == 'logout') {
          controller.onLogout();
        }else if (value == 'profile') {
          print("Profile");
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "JerryTwo",
                style: TextStyles.policiesItemTitle.copyWith(
                  fontSize: 16,
                  color: CustomColor.color0F172A,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 14,
                    color: CustomColor.color059669,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Verified 18+ Member",
                    style: TextStyle(
                      color: CustomColor.color059669,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Liberation",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'profile',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 20, color: CustomColor.colorBE123C),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  "Profile",
                  style: TextStyles.policiesConsentTitle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'banking',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.credit_card_outlined, size: 20, color: CustomColor.colorBE123C),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  "Banking and Subscription Details",
                  style: TextStyles.policiesConsentTitle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'security',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.shield_outlined, size: 20, color: CustomColor.colorBE123C),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  "Security",
                  style: TextStyles.policiesConsentTitle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'blocked',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.block_outlined, size: 20, color: CustomColor.color64748B),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  "Blocked Members",
                  style: TextStyles.policiesConsentTitle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'logout',
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.logout_outlined, size: 20, color: CustomColor.colorE11D48),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  "Log Out",
                  style: TextStyle(
                    color: CustomColor.colorE11D48,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Liberation",
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        height: ScreenConstant.defaultHeightForty,
        width: ScreenConstant.defaultWidthForty,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CustomColor.colorFFF1F2,
          border: Border.all(color: CustomColor.colorFFE4E6, width: 2),
        ),
        child: Icon(
          Icons.person_outline,
          color: CustomColor.colorE11D48,
          size: ScreenConstant.smallIconSize - 2,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ScreenConstant.defaultWidthTen,
        ScreenConstant.defaultHeightTen,
        ScreenConstant.defaultWidthTen,
        ScreenConstant.sizeSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Eyebrow pill with reactive online count.
          Row(
            children: [
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenConstant.sizeSmall,
                    vertical: ScreenConstant.sizeExtraSmall / 1.2,
                  ),
                  decoration: BoxDecoration(
                    color: CustomColor.colorECFDF5,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: CustomColor.color10B981,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: ScreenConstant.sizeExtraSmall),
                      Text(
                        "Active Members in Belgium",
                        style: TextStyles.registerZeroRisk,
                      ),
                      SizedBox(width: ScreenConstant.sizeExtraSmall),
                      Text(
                        "• ${controller.onlineCount} members online",
                        style: TextStyles.registerZeroRisk.copyWith(
                          color: CustomColor.color059669,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              _buildProfileMenu(),
            ],
          ),
          SizedBox(height: ScreenConstant.defaultHeightTen),
          // Title row with the view toggle + refresh.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  "Browse Members",
                  style: TextStyles.registerTitle.copyWith(
                    fontSize: FontSize.s18,
                  ),
                ),
              ),
              SizedBox(width: ScreenConstant.sizeSmall),
              Obx(() => _viewToggle()),
              // SizedBox(width: ScreenConstant.sizeSmall),
              // _refreshButton(),
            ],
          ),
          // SizedBox(height: ScreenConstant.sizeExtraSmall),
          // Text(
          //   "Verified active members across Belgium. For discretion, exact "
          //   "locations remain hidden.",
          //   style: TextStyles.registerFieldNote,
          // ),
        ],
      ),
    );
  }

  Widget _viewToggle() {
    final mode = controller.viewMode.value;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: CustomColor.colorWhite,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: CustomColor.colorE2E8F0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _togglePill(
            label: "Grid",
            icon: Icons.grid_view_rounded,
            active: mode == HomeViewMode.grid,
            onTap: () => controller.setViewMode(HomeViewMode.grid),
          ),
          _togglePill(
            label: "Deck",
            icon: Icons.style_outlined,
            active: mode == HomeViewMode.deck,
            onTap: () => controller.setViewMode(HomeViewMode.deck),
          ),
        ],
      ),
    );
  }

  Widget _togglePill({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenConstant.sizeSmall,
          vertical: ScreenConstant.sizeExtraSmall,
        ),
        decoration: BoxDecoration(
          color: active ? CustomColor.colorBE185D : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: ScreenConstant.minimumIconSize,
              color: active ? CustomColor.colorWhite : CustomColor.color64748B,
            ),
            SizedBox(width: ScreenConstant.sizeExtraSmall),
            Text(
              label,
              style: TextStyles.browseToggleLabel.copyWith(
                color:
                    active ? CustomColor.colorWhite : CustomColor.color334155,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _refreshButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.reload,
      child: Container(
        height: ScreenConstant.defaultHeightThirty,
        width: ScreenConstant.defaultWidthThirty,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          //border: Border.all(color: CustomColor.colorE2E8F0),
        ),
        child: Icon(
          Icons.refresh,
          size: ScreenConstant.smallIconSize,
          color: CustomColor.colorBE185D,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Search row (search box + city dropdown + Filters button)
  // ---------------------------------------------------------------------------
  Widget _buildSearchRow() {
    // Wrapped in a Builder so the city picker / filter sheet get a context
    // beneath the Navigator without changing the context-free tab method.
    return Builder(
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ScreenConstant.defaultWidthTen,
          ),
          child: Row(
            children: [
              // (a) Search box — grows to fill remaining width.
              Expanded(
                child: Container(
                  height: ScreenConstant.defaultHeightForty,
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenConstant.sizeSmall,
                  ),
                  decoration: BoxDecoration(
                    color: CustomColor.colorF8FAFC,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: CustomColor.colorE2E8F0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        size: ScreenConstant.smallIconSize,
                        color: CustomColor.color94A3B8,
                      ),
                      SizedBox(width: ScreenConstant.sizeExtraSmall),
                      Expanded(
                        child: TextField(
                          controller: controller.searchController,
                          onChanged: controller.setSearchQuery,
                          cursorColor: CustomColor.colorDB2777,
                          style: TextStyles.browseToggleLabel.copyWith(
                            color: CustomColor.color0F172A,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText:
                                "Search verified members by name, city, interests...",
                            hintStyle: TextStyles.browseToggleLabel.copyWith(
                              color: CustomColor.color94A3B8,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: ScreenConstant.sizeSmall),
              // (b) City dropdown pill.
              _cityPill(context),
              //SizedBox(width: ScreenConstant.sizeSmall),
              // (c) Filters pill.
              _filtersPill(context),
            ],
          ),
        );
      },
    );
  }

  Widget _cityPill(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openCityPicker(context),
      child: Container(
        height: ScreenConstant.defaultHeightForty,
        padding: EdgeInsets.symmetric(horizontal: ScreenConstant.sizeSmall),
        decoration: BoxDecoration(
          color: CustomColor.colorWhite,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: CustomColor.colorE2E8F0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on,
              size: ScreenConstant.minimumIconSize,
              color: CustomColor.colorBE185D,
            ),
            SizedBox(width: ScreenConstant.sizeExtraSmall),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 70),
              child: Obx(
                () => Text(
                  controller.selectedCity.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.browseToggleLabel.copyWith(
                    color: CustomColor.color334155,
                  ),
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: ScreenConstant.minimumIconSize,
              color: CustomColor.color64748B,
            ),
          ],
        ),
      ),
    );
  }

  Widget _filtersPill(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openFilterSheet(context),
      child: Container(
        height: ScreenConstant.defaultHeightForty,
        padding: EdgeInsets.symmetric(horizontal: ScreenConstant.sizeSmall),
        // decoration: BoxDecoration(
        //   color: CustomColor.colorWhite,
        //   borderRadius: BorderRadius.circular(100),
        //   border: Border.all(color: CustomColor.colorE2E8F0),
        // ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              size: ScreenConstant.minimumIconSize,
              color: CustomColor.colorBE185D,
            ),
            // SizedBox(width: ScreenConstant.sizeExtraSmall),
            // Text(
            //   "Filters",
            //   style: TextStyles.browseToggleLabel.copyWith(
            //     color: CustomColor.colorBE123C,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // City picker bottom-sheet (reused by the header pill and the filter sheet)
  // ---------------------------------------------------------------------------
  void _openCityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CustomColor.colorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: ScreenConstant.sizeMedium,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenConstant.defaultWidthTwenty,
                  ),
                  child: Text(
                    "Select City",
                    style: TextStyles.registerSectionTitle,
                  ),
                ),
                SizedBox(height: ScreenConstant.sizeSmall),
                Flexible(
                  child: Obx(() {
                    final selected = controller.selectedCity.value;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.cities.length,
                      itemBuilder: (_, index) {
                        final city = controller.cities[index];
                        final active = city == selected;
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            controller.selectCity(city);
                            Navigator.pop(sheetContext);
                          },
                          child: Container(
                            color: active
                                ? CustomColor.colorFFF1F2
                                : Colors.transparent,
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenConstant.defaultWidthTwenty,
                              vertical: ScreenConstant.sizeMedium,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    city,
                                    style:
                                        TextStyles.browseToggleLabel.copyWith(
                                      color: active
                                          ? CustomColor.colorBE123C
                                          : CustomColor.color334155,
                                      fontWeight: active
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (active)
                                  Icon(
                                    Icons.check,
                                    size: ScreenConstant.minimumIconSize,
                                    color: CustomColor.colorBE123C,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Filter bottom-sheet: "Regional Search & Match Criteria"
  // ---------------------------------------------------------------------------
  void _openFilterSheet(BuildContext context) {
    // Seed the sheet controls from the currently-applied filters so edits
    // start from the active state and only take effect on "Apply Criteria".
    controller.initDraftFromApplied();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CustomColor.colorWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        // Cap the sheet so it never covers the status bar / notch — leave a
        // gap at the top and let the content scroll within.
        final double maxSheetHeight =
            MediaQuery.of(sheetContext).size.height * 0.9;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxSheetHeight),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  ScreenConstant.defaultWidthTwenty,
                  ScreenConstant.sizeMedium,
                  ScreenConstant.defaultWidthTwenty,
                  ScreenConstant.sizeLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  // Header row.
                  Row(
                    children: [
                      Icon(
                        Icons.tune,
                        size: ScreenConstant.smallIconSize,
                        color: CustomColor.colorBE185D,
                      ),
                      SizedBox(width: ScreenConstant.sizeSmall),
                      Expanded(
                        child: Text(
                          "Regional Search & Match Criteria",
                          style: TextStyles.registerSectionTitle.copyWith(
                            fontSize: FontSize.s16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.pop(sheetContext),
                        child: Icon(
                          Icons.close,
                          size: ScreenConstant.smallIconSize,
                          color: CustomColor.color64748B,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenConstant.sizeLarge),

                  // Location & Search Radius (draft until Apply).
                  Obx(
                    () => Text(
                      "Location & Search Radius: "
                      "${controller.draftSearchRadiusKm.value.round()} km",
                      style: TextStyles.registerFieldLabel,
                    ),
                  ),
                  SizedBox(height: ScreenConstant.sizeSmall),
                  _sheetCityField(sheetContext),
                  Obx(
                    () => Slider(
                      value: controller.draftSearchRadiusKm.value,
                      min: 1,
                      max: 100,
                      activeColor: CustomColor.colorBE185D,
                      inactiveColor: CustomColor.colorE2E8F0,
                      onChanged: controller.setSearchRadius,
                    ),
                  ),
                  Text(
                    "Radius is approximate and used for display only.",
                    style: TextStyles.registerFieldNote,
                  ),
                  SizedBox(height: ScreenConstant.sizeLarge),

                  // Gender.
                  Text("Gender", style: TextStyles.registerFieldLabel),
                  SizedBox(height: ScreenConstant.sizeSmall),
                  Obx(
                    () => Wrap(
                      spacing: ScreenConstant.sizeSmall,
                      runSpacing: ScreenConstant.sizeSmall,
                      children: const ['All', 'Female', 'Male', 'Other']
                          .map(
                            (g) => _genderFilterPill(
                              g,
                              controller.draftGenderFilter.value == g,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  SizedBox(height: ScreenConstant.sizeLarge),

                  // Age range.
                  Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Age Range:",
                            style: TextStyles.registerFieldLabel,
                          ),
                        ),
                        Text(
                          "${controller.draftAgeRange.value.start.round()} – "
                          "${controller.draftAgeRange.value.end.round()} years",
                          style: TextStyles.registerFieldLabel.copyWith(
                            color: CustomColor.colorBE123C,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => RangeSlider(
                      values: controller.draftAgeRange.value,
                      min: 18,
                      max: 80,
                      activeColor: CustomColor.colorBE185D,
                      inactiveColor: CustomColor.colorE2E8F0,
                      labels: RangeLabels(
                        controller.draftAgeRange.value.start.round().toString(),
                        controller.draftAgeRange.value.end.round().toString(),
                      ),
                      onChanged: controller.setAgeRange,
                    ),
                  ),
                  SizedBox(height: ScreenConstant.sizeLarge),

                  // Interests.
                  Text(
                    "Include Interests Criteria:",
                    style: TextStyles.registerFieldLabel,
                  ),
                  SizedBox(height: ScreenConstant.sizeSmall),
                  Obx(
                    () => Wrap(
                      spacing: ScreenConstant.sizeSmall,
                      runSpacing: ScreenConstant.sizeSmall,
                      children: HomeController.interestOptions
                          .map(
                            (label) => _interestChip(
                              label,
                              controller.draftSelectedInterests
                                  .contains(label),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  SizedBox(height: ScreenConstant.sizeLarge),

                  Divider(color: CustomColor.colorE2E8F0),
                  SizedBox(height: ScreenConstant.sizeSmall),

                  // Footer: Reset link + Apply CTA.
                  Row(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: controller.resetFilters,
                        child: Text(
                          "Reset to Default",
                          style: TextStyles.browseToggleLabel.copyWith(
                            color: CustomColor.colorBE185D,
                            decorationColor: CustomColor.colorBE185D,
                          ),
                        ),
                      ),
                      SizedBox(width: ScreenConstant.sizeMedium),
                      Expanded(
                        child: buildLoginButton(
                          "Apply Criteria",
                          true,
                          () {
                            controller.applyFilters();
                            Navigator.pop(sheetContext);
                          },
                          Icons.check,
                          height: ScreenConstant.defaultHeightFifty,
                          fontSize: FontSize.s14,
                          iconSize: ScreenConstant.minimumIconSize,
                        ),
                      ),
                    ],
                  ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// City field inside the filter sheet; reuses the shared city picker.
  Widget _sheetCityField(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openCityPicker(context),
      child: Container(
        height: ScreenConstant.defaultHeightForty,
        padding: EdgeInsets.symmetric(horizontal: ScreenConstant.sizeMedium),
        decoration: BoxDecoration(
          color: CustomColor.colorF8FAFC,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CustomColor.colorE2E8F0),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              size: ScreenConstant.minimumIconSize,
              color: CustomColor.colorBE185D,
            ),
            SizedBox(width: ScreenConstant.sizeSmall),
            Expanded(
              child: Obx(
                () => Text(
                  controller.selectedCity.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.browseToggleLabel.copyWith(
                    color: CustomColor.color334155,
                  ),
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: ScreenConstant.minimumIconSize,
              color: CustomColor.color64748B,
            ),
          ],
        ),
      ),
    );
  }

  /// Gender pill: selected uses the rose→purple gradient; unselected is light.
  Widget _genderFilterPill(String label, bool selected) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.setGenderFilter(label),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenConstant.sizeLarge,
          vertical: ScreenConstant.sizeSmall,
        ),
        decoration: BoxDecoration(
          color: selected ? null : CustomColor.colorFFF1F2,
          gradient: selected
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    CustomColor.colorBE185D,
                    CustomColor.color581C87,
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : CustomColor.colorE2E8F0,
          ),
        ),
        child: Text(
          label,
          style: TextStyles.browseToggleLabel.copyWith(
            color: selected ? CustomColor.colorWhite : CustomColor.color334155,
          ),
        ),
      ),
    );
  }

  /// Interest chip mirroring the register-flow selectable chip visual.
  Widget _interestChip(String label, bool selected) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.toggleInterest(label),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenConstant.sizeMedium,
          vertical: ScreenConstant.sizeSmall,
        ),
        decoration: BoxDecoration(
          color: selected ? CustomColor.colorFFF1F2 : CustomColor.colorWhite,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected
                ? CustomColor.colorBE123C
                : CustomColor.colorE2E8F0,
          ),
        ),
        child: Text(
          label,
          style: TextStyles.browseToggleLabel.copyWith(
            color: selected ? CustomColor.colorBE123C : CustomColor.color334155,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Grid
  // ---------------------------------------------------------------------------
  Widget _buildGrid() {
    final members = controller.filteredMembers;
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        ScreenConstant.defaultWidthTwenty,
        ScreenConstant.sizeSmall,
        ScreenConstant.defaultWidthTwenty,
        90,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.66,
        crossAxisSpacing: ScreenConstant.sizeMedium,
        mainAxisSpacing: ScreenConstant.sizeMedium,
      ),
      itemCount: members.length,
      itemBuilder: (context, index) => _gridCard(members[index]),
    );
  }

  Widget _gridCard(Member member) {
    final photoCount = member.photoUrls.length;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.openMemberDetail(member),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: MemberNetworkImage(url: member.firstPhotoUrl),
            ),
            // Bottom scrim for readable white text.
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        CustomColor.color0F172A,
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            // Top-left "Active" pill.
            Positioned(
              top: ScreenConstant.sizeSmall,
              left: ScreenConstant.sizeSmall,
              child: _smallPill(
                bg: CustomColor.color0D1527,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: CustomColor.color10B981,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: ScreenConstant.sizeExtraSmall),
                    Text(
                      "Active",
                      style: TextStyles.policiesBadgeText.copyWith(
                        color: CustomColor.colorWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Top-right photo count (only when > 1 photo).
            if (photoCount > 1)
              Positioned(
                top: ScreenConstant.sizeSmall,
                right: ScreenConstant.sizeSmall,
                child: _smallPill(
                  bg: CustomColor.color0D1527,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_camera_outlined,
                        size: ScreenConstant.minimumIconSize,
                        color: CustomColor.colorWhite,
                      ),
                      SizedBox(width: ScreenConstant.sizeExtraSmall),
                      Text(
                        "$photoCount",
                        style: TextStyles.policiesBadgeText.copyWith(
                          color: CustomColor.colorWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Bottom-left name/age + gender pill.
            Positioned(
              left: ScreenConstant.sizeSmall,
              right: ScreenConstant.sizeSmall,
              bottom: ScreenConstant.sizeSmall,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${member.displayName}, ${member.age}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: CustomColor.colorWhite,
                      fontSize: FontSize.s16,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Liberation",
                    ),
                  ),
                  if (member.genderLabel.isNotEmpty) ...[
                    SizedBox(height: ScreenConstant.sizeExtraSmall),
                    _genderPill(member.genderLabel),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderPill(String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeSmall,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: CustomColor.colorWhite.withOpacity(0.2),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyles.policiesBadgeText.copyWith(
          color: CustomColor.colorWhite,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _smallPill({required Color bg, required Widget child}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeSmall,
        vertical: ScreenConstant.sizeExtraSmall / 1.3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: child,
    );
  }

  // ---------------------------------------------------------------------------
  // Deck
  // ---------------------------------------------------------------------------
  Widget _buildDeck() {
    final member = controller.currentDeckMember;
    if (member == null) {
      return _deckExhausted();
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ScreenConstant.defaultWidthTwenty,
        ScreenConstant.sizeSmall,
        ScreenConstant.defaultWidthTwenty,
        80,
      ),
      child: Column(
        children: [
          Expanded(
            child: Dismissible(
              key: ValueKey(member.id),
              direction: DismissDirection.horizontal,
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  controller.likeCurrent();
                } else {
                  controller.passCurrent();
                }
                // Let deckIndex drive the rebuild instead of removing a child.
                return false;
              },
              child: _deckCard(member),
            ),
          ),
          SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
          _deckActions(member),
          SizedBox(height: ScreenConstant.sizeMedium),
          Text(
            "Showing active members deck • Like or pass",
            style: TextStyles.registerFieldNote,
          ),
        ],
      ),
    );
  }

  Widget _deckCard(Member member) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: MemberNetworkImage(url: member.firstPhotoUrl),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      CustomColor.color0F172A,
                    ],
                    stops: [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Top-left presence + city pill.
          Positioned(
            top: ScreenConstant.sizeMedium,
            left: ScreenConstant.sizeMedium,
            child: _smallPill(
              bg: CustomColor.color0D1527,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: CustomColor.color10B981,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: ScreenConstant.sizeExtraSmall),
                  Text(
                    "Active • ${member.profile.city}",
                    style: TextStyles.policiesBadgeText.copyWith(
                      color: CustomColor.colorWhite,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom identity + bio + interests.
          Positioned(
            left: ScreenConstant.sizeMedium,
            right: ScreenConstant.sizeMedium,
            bottom: ScreenConstant.sizeMedium,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${member.displayName}, ${member.age}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CustomColor.colorWhite,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Liberation",
                  ),
                ),
                if (member.profile.bio.isNotEmpty) ...[
                  SizedBox(height: ScreenConstant.sizeExtraSmall),
                  Text(
                    member.profile.bio,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: CustomColor.colorWhite.withOpacity(0.9),
                      fontSize: FontSize.s13,
                      fontFamily: "Liberation",
                      height: 1.4,
                    ),
                  ),
                ],
                if (member.profile.interests.isNotEmpty) ...[
                  SizedBox(height: ScreenConstant.sizeSmall),
                  Wrap(
                    spacing: ScreenConstant.sizeExtraSmall,
                    runSpacing: ScreenConstant.sizeExtraSmall,
                    children: member.profile.interests
                        .take(3)
                        .map(_deckInterestChip)
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _deckInterestChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeSmall,
        vertical: ScreenConstant.sizeExtraSmall / 1.2,
      ),
      decoration: BoxDecoration(
        color: CustomColor.colorWhite.withOpacity(0.2),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyles.policiesBadgeText.copyWith(
          color: CustomColor.colorWhite,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _deckActions(Member member) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _circleAction(
          icon: Icons.close,
          bg: CustomColor.colorWhite,
          iconColor: CustomColor.color64748B,
          border: CustomColor.colorE2E8F0,
          onTap: controller.passCurrent,
        ),
        SizedBox(width: ScreenConstant.sizeLarge),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => controller.openMemberDetail(member),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenConstant.sizeLarge,
              vertical: ScreenConstant.sizeSmall,
            ),
            decoration: BoxDecoration(
              color: CustomColor.colorWhite,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: CustomColor.colorE2E8F0),
            ),
            child: Text(
              "View Details",
              style: TextStyles.browseToggleLabel,
            ),
          ),
        ),
        SizedBox(width: ScreenConstant.sizeLarge),
        _circleAction(
          icon: Icons.favorite,
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [CustomColor.colorBE185D, CustomColor.color581C87],
          ),
          iconColor: CustomColor.colorWhite,
          onTap: controller.likeCurrent,
        ),
      ],
    );
  }

  Widget _circleAction({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    Color? bg,
    Color? border,
    Gradient? gradient,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: ScreenConstant.defaultHeightSixty,
        width: ScreenConstant.defaultHeightSixty,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: gradient == null ? bg : null,
          gradient: gradient,
          border: border == null ? null : Border.all(color: border),
        ),
        child: Icon(
          icon,
          size: ScreenConstant.smallIconSize,
          color: iconColor,
        ),
      ),
    );
  }

  Widget _deckExhausted() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenConstant.defaultWidthTwenty),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: ScreenConstant.defaultIconSize,
              color: CustomColor.color10B981,
            ),
            SizedBox(height: ScreenConstant.sizeMedium),
            Text(
              "You're all caught up",
              style: TextStyles.registerTitle.copyWith(fontSize: FontSize.s20),
            ),
            SizedBox(height: ScreenConstant.sizeExtraSmall),
            Text(
              "You've seen every active member in this view.",
              textAlign: TextAlign.center,
              style: TextStyles.registerFieldNote,
            ),
            SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
            buildLoginButton(
              "Start over",
              true,
              controller.resetDeck,
              Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty filtered state
  // ---------------------------------------------------------------------------
  Widget _emptyFiltered() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(ScreenConstant.defaultWidthTwenty),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: ScreenConstant.defaultIconSize,
              color: CustomColor.color94A3B8,
            ),
            SizedBox(height: ScreenConstant.sizeMedium),
            Text(
              "No members found",
              style: TextStyles.registerTitle.copyWith(fontSize: FontSize.s20),
            ),
            SizedBox(height: ScreenConstant.sizeExtraSmall),
            Text(
              "No active members match your search and filters right now. "
              "Try adjusting the search, city, or filters.",
              textAlign: TextAlign.center,
              style: TextStyles.registerFieldNote,
            ),
          ],
        ),
      ),
    );
  }
}
