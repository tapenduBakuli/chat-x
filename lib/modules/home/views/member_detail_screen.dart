import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../device_manager/screen_constants.dart';
import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';
import '../../../utils/custom_widgets/universal_button.dart';
import '../controller/home_controller.dart';
import '../model/member.dart';
import 'widgets/member_network_image.dart';

/// Full member profile, opened from the grid card or the deck. The member is
/// passed via [Get.arguments]; the screen reads it defensively and shows a
/// "Member not found" fallback if the argument is missing or the wrong type.
/// Styling mirrors the register profile preview: a swipeable photo hero with
/// overlay pills, then white rounded cards on a light background, and a pinned
/// bottom action bar.
class MemberDetailScreen extends GetView<HomeController> {
  const MemberDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arg = Get.arguments;
    if (arg is! Member) {
      return _notFound();
    }
    final Member member = arg;

    return Scaffold(
      backgroundColor: CustomColor.colorAF5FF,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroCarousel(member: member),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        ScreenConstant.defaultWidthTwenty,
                        ScreenConstant.defaultHeightTwentyThree,
                        ScreenConstant.defaultWidthTwenty,
                        ScreenConstant.defaultHeightThirty,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionCard(
                            "About",
                            Text(
                              member.profile.bio.isEmpty
                                  ? "No bio added yet."
                                  : member.profile.bio,
                              style: TextStyles.registerFieldNote.copyWith(
                                fontSize: FontSize.s14,
                                color: CustomColor.color334155,
                                height: 1.5,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: ScreenConstant.defaultHeightTwentyThree,
                          ),
                          _sectionCard(
                            "Looking for",
                            _chipWrap(member.profile.lookingFor, rose: true),
                          ),
                          SizedBox(
                            height: ScreenConstant.defaultHeightTwentyThree,
                          ),
                          _sectionCard(
                            "Orientation",
                            _chipWrap(member.profile.orientations, rose: true),
                          ),
                          SizedBox(
                            height: ScreenConstant.defaultHeightTwentyThree,
                          ),
                          _sectionCard(
                            "Interests",
                            _chipWrap(member.profile.interests, rose: false),
                          ),
                          SizedBox(
                            height: ScreenConstant.defaultHeightTwentyThree,
                          ),
                          _sectionCard(
                            "Intimate preferences",
                            // API `relationship_preferences`.
                            _chipWrap(
                              member.profile.relationshipIntents,
                              rose: true,
                            ),
                          ),
                          SizedBox(
                            height: ScreenConstant.defaultHeightTwentyThree,
                          ),
                          _locationCard(member),
                          Container(
                            padding: EdgeInsets.fromLTRB(
                              ScreenConstant.defaultWidthTen,
                              ScreenConstant.sizeSmall,
                              ScreenConstant.defaultWidthTen,
                              ScreenConstant.sizeSmall,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: CustomColor.colorWhite,
                              boxShadow: [
                                BoxShadow(
                                  color: CustomColor.color717B96.withOpacity(0.12),
                                  blurRadius: 16,
                                  spreadRadius: -4,
                                  offset: const Offset(0, -4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () =>
                                      controller.onPassFromDetail(member),
                                  child: Container(
                                    height: ScreenConstant.defaultHeightSixty,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: ScreenConstant.sizeLarge,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(color: CustomColor.colorE2E8F0),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.close,
                                          size: ScreenConstant.smallIconSize,
                                          color: CustomColor.color64748B,
                                        ),
                                        SizedBox(width: ScreenConstant.sizeExtraSmall),
                                        Text("Pass", style: TextStyles.browseToggleLabel),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: ScreenConstant.sizeMedium),
                                Expanded(
                                  child: _connectButton(member),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // _actionBar(member),

          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Cards
  // ---------------------------------------------------------------------------
  Widget _sectionCard(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenConstant.sizeMedium),
      decoration: BoxDecoration(
        color: CustomColor.colorWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CustomColor.color717B96.withOpacity(0.12),
            blurRadius: 16,
            spreadRadius: -6,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyles.registerSectionTitle),
          SizedBox(height: ScreenConstant.sizeSmall),
          child,
        ],
      ),
    );
  }

  Widget _chipWrap(List<String> items, {required bool rose}) {
    if (items.isEmpty) {
      return Text("Nothing shared yet.", style: TextStyles.registerFieldNote);
    }
    return Wrap(
      spacing: ScreenConstant.sizeSmall,
      runSpacing: ScreenConstant.sizeSmall,
      children: items.map((e) => _chip(e, rose: rose)).toList(),
    );
  }

  Widget _chip(String label, {required bool rose}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeMedium,
        vertical: ScreenConstant.sizeExtraSmall + 1,
      ),
      decoration: BoxDecoration(
        color: rose ? CustomColor.colorFFF1F2 : CustomColor.colorF1F5F9,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: rose ? CustomColor.colorFECDD3 : CustomColor.colorE2E8F0,
        ),
      ),
      child: Text(
        label,
        style: TextStyles.policiesPillText.copyWith(
          color: rose ? CustomColor.colorBE123C : CustomColor.color334155,
        ),
      ),
    );
  }

  /// "City, Region" from whichever parts are non-empty ('' when neither).
  String _cityRegion(Member member) => [
    member.profile.city,
    member.profile.region,
  ].where((s) => s.isNotEmpty).join(', ');

  Widget _locationCard(Member member) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenConstant.sizeMedium),
      decoration: BoxDecoration(
        color: CustomColor.colorFFF5F8,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            height: ScreenConstant.defaultHeightForty,
            width: ScreenConstant.defaultWidthForty,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: CustomColor.colorWhite,
            ),
            child: Icon(
              Icons.location_off_outlined,
              size: ScreenConstant.smallIconSize,
              color: CustomColor.colorBE123C,
            ),
          ),
          SizedBox(width: ScreenConstant.sizeMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // city/region aren't in the users API yet; the title only
                // shows when there is something to show.
                if (_cityRegion(member).isNotEmpty) ...[
                  Text(
                    _cityRegion(member),
                    style: TextStyles.registerFieldLabel.copyWith(
                      color: CustomColor.color0F172A,
                    ),
                  ),
                  SizedBox(height: 2),
                ],
                Text(
                  "Location: ${member.profile.location.isNotEmpty ? member.profile.location : 'Remains Hidden'}",
                  style: TextStyles.registerFieldNote.copyWith(
                    color: CustomColor.color64748B,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom action bar
  // ---------------------------------------------------------------------------
  Widget _actionBar(Member member) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        ScreenConstant.defaultWidthTwenty,
        ScreenConstant.sizeSmall,
        ScreenConstant.defaultWidthTwenty,
        ScreenConstant.sizeMedium,
      ),
      decoration: BoxDecoration(
        color: CustomColor.colorWhite,
        boxShadow: [
          BoxShadow(
            color: CustomColor.color717B96.withOpacity(0.12),
            blurRadius: 16,
            spreadRadius: -4,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => controller.onPassFromDetail(member),
              child: Container(
                height: ScreenConstant.defaultHeightSixty,
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenConstant.sizeLarge,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: CustomColor.colorE2E8F0),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.close,
                      size: ScreenConstant.smallIconSize,
                      color: CustomColor.color64748B,
                    ),
                    SizedBox(width: ScreenConstant.sizeExtraSmall),
                    Text("Pass", style: TextStyles.browseToggleLabel),
                  ],
                ),
              ),
            ),
            SizedBox(width: ScreenConstant.sizeMedium),
            Expanded(
              child: _connectButton(member),
            ),
          ],
        ),
      ),
    );
  }

  /// Connect CTA: sends a friend request. While it's in flight the pill shows
  /// a white spinner (same style as the Login button) and ignores taps.
  Widget _connectButton(Member member) {
    return Obx(() {
      if (controller.isSendingRequest(member.id)) {
        return Container(
          height: ScreenConstant.defaultHeightSixty,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                CustomColor.colorBE185D,
                CustomColor.color581C87,
              ],
            ),
          ),
          alignment: Alignment.center,
          child: const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(CustomColor.colorWhite),
            ),
          ),
        );
      }
      return buildLoginButton(
        "Connect",
        true,
        () => controller.onConnect(member),
        Icons.favorite,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Not-found fallback
  // ---------------------------------------------------------------------------
  Widget _notFound() {
    return Scaffold(
      backgroundColor: CustomColor.colorAF5FF,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: ScreenConstant.defaultIconSize,
                color: CustomColor.color94A3B8,
              ),
              SizedBox(height: ScreenConstant.sizeMedium),
              Text(
                "Member not found",
                style: TextStyles.registerTitle.copyWith(
                  fontSize: FontSize.s20,
                ),
              ),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenConstant.sizeLarge,
                    vertical: ScreenConstant.sizeSmall,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: CustomColor.colorE2E8F0),
                  ),
                  child: Text("Go back", style: TextStyles.browseToggleLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Swipeable photo hero with page dashes + "x / N" counter, a back arrow, and
/// identity overlay pills. Kept as a private [StatefulWidget] so the page index
/// lives here instead of on the shared [HomeController].
class _HeroCarousel extends StatefulWidget {
  final Member member;

  const _HeroCarousel({required this.member});

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  final PageController _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final member = widget.member;
    final photos = member.photoUrls;
    final total = photos.isEmpty ? 1 : photos.length;

    return SizedBox(
      height: ScreenConstant.defaultSizeThreeTwenty,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: photos.isEmpty
                ? const MemberNetworkImage(url: '')
                : PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemCount: photos.length,
                    itemBuilder: (context, index) =>
                        MemberNetworkImage(url: photos[index]),
                  ),
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
                    stops: [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // Back arrow.
          Positioned(
            top: ScreenConstant.sizeSmall,
            left: ScreenConstant.sizeSmall,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Get.back(),
              child: Container(
                height: ScreenConstant.defaultHeightForty,
                width: ScreenConstant.defaultWidthForty,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CustomColor.color0D1527.withOpacity(0.5),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: ScreenConstant.minimumIconSize,
                  color: CustomColor.colorWhite,
                ),
              ),
            ),
          ),
          // Top-right photo counter.
          Positioned(
            top: ScreenConstant.sizeMedium,
            right: ScreenConstant.sizeMedium,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenConstant.sizeSmall,
                vertical: ScreenConstant.sizeExtraSmall / 1.2,
              ),
              decoration: BoxDecoration(
                color: CustomColor.color0D1527,
                borderRadius: BorderRadius.circular(100),
              ),
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
                    "${_index + 1} / $total",
                    style: TextStyles.policiesBadgeText.copyWith(
                      color: CustomColor.colorWhite,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Page dashes.
          if (total > 1)
            Positioned(
              top:
                  ScreenConstant.sizeMedium + ScreenConstant.defaultHeightForty,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(total, (i) {
                  final active = i == _index;
                  return Container(
                    width: active
                        ? ScreenConstant.defaultWidthThirty
                        : ScreenConstant.defaultWidthTwenty,
                    height: 4,
                    margin: EdgeInsets.symmetric(
                      horizontal: ScreenConstant.sizeExtraSmall / 2,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? CustomColor.colorWhite
                          : CustomColor.colorWhite.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  );
                }),
              ),
            ),
          // Identity overlay.
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
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Liberation",
                  ),
                ),
                SizedBox(height: ScreenConstant.sizeExtraSmall),
                Wrap(
                  spacing: ScreenConstant.sizeSmall,
                  runSpacing: ScreenConstant.sizeExtraSmall,
                  children: [
                    if (member.genderLabel.isNotEmpty)
                      _overlayPill(Icons.person_outline, member.genderLabel),
                    _overlayPill(
                      Icons.circle,
                      // The users API has no city yet → plain "Active".
                      member.profile.city.isEmpty
                          ? "Active"
                          : "Active • ${member.profile.city}",
                      iconColor: CustomColor.color10B981,
                    ),
                  ],
                ),
                SizedBox(height: ScreenConstant.sizeExtraSmall),
                Row(
                  children: [
                    _overlayPill(
                      Icons.location_off_outlined,
                      "Location: Remains Hidden",
                      iconColor: CustomColor.colorFBCFE8,
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: (){print("Block the user");},
                      child: _overlayPill(
                        Icons.app_blocking_outlined,
                        "Block",
                        iconColor: CustomColor.colorBE123C,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overlayPill(IconData icon, String label, {Color? iconColor}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeSmall,
        vertical: ScreenConstant.sizeExtraSmall / 1.2,
      ),
      decoration: BoxDecoration(
        color: CustomColor.colorWhite.withOpacity(0.2),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: ScreenConstant.minimumIconSize,
            color: iconColor ?? CustomColor.colorWhite,
          ),
          SizedBox(width: ScreenConstant.sizeExtraSmall),
          Text(
            label,
            style: const TextStyle(
              color: CustomColor.colorWhite,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: "Liberation",
            ),
          ),
        ],
      ),
    );
  }
}
