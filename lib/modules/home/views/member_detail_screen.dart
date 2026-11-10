import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../device_manager/screen_constants.dart';
import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';
import '../../../utils/custom_widgets/universal_button.dart';
import '../controller/home_controller.dart';
import '../controller/member_detail_controller.dart';
import '../model/member.dart';
import '../model/presence_label.dart';
import 'widgets/member_network_image.dart';

/// Full member profile, opened from the grid card or the deck. The member is
/// passed via [Get.arguments]; the screen reads it defensively and shows a
/// "Member not found" fallback if the argument is missing or the wrong type.
/// Styling mirrors the register profile preview: a swipeable photo hero with
/// overlay pills, then white rounded cards on a light background, and a pinned
/// bottom action bar.
class MemberDetailScreen extends GetView<MemberDetailController> {
  const MemberDetailScreen({super.key});

  /// Connect / Pass / Block actions live on the shared [HomeController].
  HomeController get home => Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    if (!controller.isValid) {
      return _notFound();
    }
    return Obx(() {
      final Member member = controller.member.value;
      return Scaffold(
        backgroundColor: CustomColor.colorAF5FF,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      color: CustomColor.colorBE185D,
                      onRefresh: controller.load,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
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
                                      style: TextStyles.registerFieldNote
                                          .copyWith(
                                            fontSize: FontSize.s14,
                                            color: CustomColor.color334155,
                                            height: 1.5,
                                          ),
                                    ),
                                  ),
                                  SizedBox(
                                    height:
                                        ScreenConstant.defaultHeightTwentyThree,
                                  ),
                                  _sectionCard(
                                    "Looking for",
                                    _chipWrap(
                                      member.profile.lookingFor,
                                      rose: true,
                                    ),
                                  ),
                                  SizedBox(
                                    height:
                                        ScreenConstant.defaultHeightTwentyThree,
                                  ),
                                  _sectionCard(
                                    "Orientation",
                                    _chipWrap(
                                      member.profile.orientations,
                                      rose: true,
                                    ),
                                  ),
                                  SizedBox(
                                    height:
                                        ScreenConstant.defaultHeightTwentyThree,
                                  ),
                                  _sectionCard(
                                    "Interests",
                                    _chipWrap(
                                      member.profile.interests,
                                      rose: false,
                                    ),
                                  ),
                                  SizedBox(
                                    height:
                                        ScreenConstant.defaultHeightTwentyThree,
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
                                    height:
                                        ScreenConstant.defaultHeightTwentyThree,
                                  ),
                                  _locationCard(member),
                                  if (member.isFriendshipNone) ...[
                                    SizedBox(
                                      height:
                                          ScreenConstant.defaultHeightTwentyThree,
                                    ),
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
                                            color: CustomColor.color717B96
                                                .withOpacity(0.12),
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
                                                home.onPassFromDetail(member),
                                            child: Container(
                                              height: ScreenConstant
                                                  .defaultHeightSixty,
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    ScreenConstant.sizeLarge,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                border: Border.all(
                                                  color: CustomColor.colorE2E8F0,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.close,
                                                    size: ScreenConstant
                                                        .smallIconSize,
                                                    color:
                                                        CustomColor.color64748B,
                                                  ),
                                                  SizedBox(
                                                    width: ScreenConstant
                                                        .sizeExtraSmall,
                                                  ),
                                                  Text(
                                                    "Pass",
                                                    style: TextStyles
                                                        .browseToggleLabel,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: ScreenConstant.sizeMedium,
                                          ),
                                          Expanded(
                                              child: _connectButton(member)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // _actionBar(member),
                ],
              ),
              // Thin loader over the top edge; never blocks the hero.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Obx(
                  () => controller.isLoading.value
                      ? const LinearProgressIndicator(
                          minHeight: 2,
                          color: CustomColor.colorBE185D,
                          backgroundColor: CustomColor.colorFDF2F8,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      );
    });
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
              onTap: () => home.onPassFromDetail(member),
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
            Expanded(child: _connectButton(member)),
          ],
        ),
      ),
    );
  }

  /// Connect CTA: sends a friend request. While it's in flight the pill shows
  /// a white spinner (same style as the Login button) and ignores taps.
  Widget _connectButton(Member member) {
    return Obx(() {
      if (home.isSendingRequest(member.id)) {
        return Container(
          height: ScreenConstant.defaultHeightSixty,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [CustomColor.colorBE185D, CustomColor.color581C87],
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
      // Blocked members can't be connected with: dimmed and non-interactive.
      final bool blocked = home.isBlocked(member);
      // A fetched friendship_status other than 'none' (request sent/received,
      // friends…) means Connect no longer applies.
      final String status = member.friendshipStatus;
      final bool related = status != 'none' && status != 'blocked';
      final bool disabled = blocked || related;
      return Semantics(
        button: true,
        enabled: !disabled,
        label: blocked ? "Connect unavailable, member is blocked" : null,
        child: IgnorePointer(
          ignoring: disabled,
          child: Opacity(
            opacity: disabled ? 0.4 : 1,
            child: buildLoginButton(
              related ? _relationLabel(status) : "Connect",
              true,
              () => home.onConnect(member),
              Icons.favorite,
            ),
          ),
        ),
      );
    });
  }

  String _relationLabel(String status) {
    switch (status) {
      case 'request_sent':
        return "Request sent";
      case 'request_received':
        return "Request received";
      case 'friends':
        return "Friends";
      default:
        return "Connect";
    }
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

  HomeController get _home => Get.find<HomeController>();
  MemberDetailController get _detail => Get.find<MemberDetailController>();

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
          // Blocked indicator over the hero (covers both the placeholder and
          // the photo PageView). Renders nothing when not blocked.
          Positioned.fill(child: _blockedOverlay(member)),
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
                  member.age > 0
                      ? "${member.displayName}, ${member.age}"
                      : member.displayName,
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
                    // Availability (GET users/{id}/availability). Always shown
                    // on this screen: "Checking…" while loading, then
                    // "Active now" / "Last seen …" / "Offline" (also the
                    // fallback if the call failed).
                    Obx(() {
                      final UserAvailability? a = _detail.availability.value;
                      final bool loading =
                          _detail.isAvailabilityLoading.value;
                      final PresenceLabel? p = presenceLabel(a);
                      final String text = p?.text ??
                          (loading ? 'Checking…' : 'Offline');
                      final bool online = p?.kind == PresenceKind.online;
                      return Semantics(
                        label: 'Status: $text',
                        child: _overlayPill(
                          Icons.circle,
                          text,
                          iconColor: online
                              ? CustomColor.color10B981
                              : CustomColor.color64748B,
                        ),
                      );
                    }),
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
                    _blockPill(member),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Block / unblock
  // ---------------------------------------------------------------------------

  /// "Block" / "Blocked" pill. Shows a small spinner and ignores taps while a
  /// block/unblock call is in flight.
  Widget _blockPill(Member member) {
    return Obx(() {
      final bool busy = _home.isBlockBusy(member.id);
      final bool blocked = _home.isBlocked(member);
      final String label = blocked ? "Blocked" : "Block";
      return Semantics(
        button: true,
        enabled: !busy,
        label: blocked
            ? "Blocked. Tap to unblock ${member.displayName}"
            : "Block ${member.displayName}",
        excludeSemantics: true,
        child: Tooltip(
          message: blocked ? "Unblock" : "Block",
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: busy
                ? null
                : () =>
                      blocked ? _confirmUnblock(member) : _confirmBlock(member),
            child: busy
                ? _overlayPillWithLeading(
                    SizedBox(
                      height: ScreenConstant.minimumIconSize,
                      width: ScreenConstant.minimumIconSize,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          CustomColor.colorWhite,
                        ),
                      ),
                    ),
                    label,
                  )
                : _overlayPill(
                    blocked ? Icons.block : Icons.app_blocking_outlined,
                    label,
                    iconColor: CustomColor.colorBE123C,
                  ),
          ),
        ),
      );
    });
  }

  /// Dark scrim + centered block icon shown while [member] is blocked. Only
  /// the center indicator is tappable (→ unblock flow); the scrim ignores
  /// pointers so photos stay swipeable.
  Widget _blockedOverlay(Member member) {
    return Obx(() {
      if (!_home.isBlocked(member)) return const SizedBox.shrink();
      final bool busy = _home.isBlockBusy(member.id);
      return Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: ColoredBox(color: CustomColor.color0F172A.withOpacity(0.55)),
          ),
          Center(
            child: Semantics(
              button: true,
              enabled: !busy,
              label: "${member.displayName} is blocked. Tap to unblock",
              excludeSemantics: true,
              child: Tooltip(
                message: "Unblock",
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: busy ? null : () => _confirmUnblock(member),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(ScreenConstant.sizeMedium),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CustomColor.colorWhite.withOpacity(0.9),
                        ),
                        child: busy
                            ? SizedBox(
                                height: ScreenConstant.miniIconSize,
                                width: ScreenConstant.miniIconSize,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    CustomColor.colorBE123C,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.block,
                                size: ScreenConstant.miniIconSize,
                                color: CustomColor.colorBE123C,
                              ),
                      ),
                      SizedBox(height: ScreenConstant.sizeSmall),
                      Text(
                        "Blocked",
                        style: TextStyles.loginWelcome.copyWith(
                          fontSize: FontSize.s18,
                          color: CustomColor.colorWhite,
                        ),
                      ),
                      SizedBox(height: ScreenConstant.sizeExtraSmall / 2),
                      Text(
                        "Tap to unblock",
                        style: TextStyles.loginWelcomeSubtitle.copyWith(
                          fontSize: FontSize.s12,
                          color: CustomColor.colorWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  void _confirmBlock(Member member) => _confirmBlockAction(
    title: "Block ${member.displayName}?",
    body: "Are you sure you want to block ${member.displayName}?",
    actionLabel: "Block",
    onConfirm: () => _home.blockMember(member),
  );

  void _confirmUnblock(Member member) => _confirmBlockAction(
    title: "Unblock ${member.displayName}?",
    body: "Are you sure you want to unblock ${member.displayName}?",
    actionLabel: "Unblock",
    onConfirm: () => _home.unblockMember(member),
  );

  /// Same dialog look as the Friends "Remove friend?" confirm.
  void _confirmBlockAction({
    required String title,
    required String body,
    required String actionLabel,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: CustomColor.colorWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s18),
          ),
          content: Text(body, style: TextStyles.loginWelcomeSubtitle),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "Cancel",
                style: TextStyles.loginWelcome.copyWith(
                  fontSize: FontSize.s14,
                  color: CustomColor.color64748B,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // Async; the pill/overlay show a spinner via blockingUserIds.
                onConfirm();
              },
              child: Text(
                actionLabel,
                style: TextStyles.loginWelcome.copyWith(
                  fontSize: FontSize.s14,
                  color: CustomColor.colorBE123C,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _overlayPill(IconData icon, String label, {Color? iconColor}) {
    return _overlayPillWithLeading(
      Icon(
        icon,
        size: ScreenConstant.minimumIconSize,
        color: iconColor ?? CustomColor.colorWhite,
      ),
      label,
    );
  }

  Widget _overlayPillWithLeading(Widget leading, String label) {
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
          leading,
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
