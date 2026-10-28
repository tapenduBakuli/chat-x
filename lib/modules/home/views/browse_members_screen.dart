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
        _buildCityChips(),
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
              label: "Explore",
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
              size: 20,
              color: isSelected
                  ? CustomColor.colorWhite
                  : CustomColor.color0F172A.withOpacity(0.5),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? CustomColor.colorWhite
                    : CustomColor.color0F172A.withOpacity(0.5),
                fontSize: 15,
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
        ScreenConstant.defaultWidthTwenty,
        ScreenConstant.defaultHeightTen,
        ScreenConstant.defaultWidthTwenty,
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
  // City chips
  // ---------------------------------------------------------------------------
  Widget _buildCityChips() {
    return SizedBox(
      height: ScreenConstant.defaultHeightForty,
      child: Obx(() {
        // Read the observable inside the Obx build scope (not lazily in
        // itemBuilder) so Obx can track it.
        final String selected = controller.selectedCity.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: ScreenConstant.defaultWidthTwenty,
          ),
          itemCount: controller.cities.length + 1,
          separatorBuilder: (_, __) =>
              SizedBox(width: ScreenConstant.sizeSmall),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Center(
                child: Text(
                  "CITY:",
                  style: TextStyles.registerSupportedLabel,
                ),
              );
            }
            final city = controller.cities[index - 1];
            return _cityChip(city, selected == city);
          },
        );
      }),
    );
  }

  Widget _cityChip(String city, bool active) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.selectCity(city),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          horizontal: ScreenConstant.sizeMedium,
        ),
        decoration: BoxDecoration(
          color: active ? CustomColor.colorBE185D : CustomColor.colorWhite,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: active ? CustomColor.colorBE185D : CustomColor.colorE2E8F0,
          ),
        ),
        child: Text(
          city,
          style: TextStyles.browseToggleLabel.copyWith(
            color: active ? CustomColor.colorWhite : CustomColor.color334155,
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
              "No active members match this city right now. Try another city.",
              textAlign: TextAlign.center,
              style: TextStyles.registerFieldNote,
            ),
          ],
        ),
      ),
    );
  }
}
