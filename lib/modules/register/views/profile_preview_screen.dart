import 'package:chat_x/device_manager/screen_constants.dart';
import 'dart:io';

import 'package:chat_x/modules/register/controller/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';
import '../../../utils/image_utils/image_utils.dart';

/// Read-only aggregation of everything the member picked across the earlier
/// register steps. It only READS existing [RegisterController] fields; it adds
/// no new input state and nothing here is editable except the two action
/// buttons (Edit -> back, Publish -> payment). Data-driven pieces are wrapped
/// in [Obx] so a change on an earlier screen is reflected if the user returns.
class ProfilePreviewScreen extends GetView<RegisterController> {
  const ProfilePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: CustomColor.colorWhite,
        elevation: 0,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.onBack,
          child: Icon(
            Icons.arrow_back_ios_new,
            size: ScreenConstant.smallIconSize,
            color: CustomColor.color0F172A,
          ),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              "PREVIEW MODE",
              textAlign: TextAlign.center,
              style: TextStyles.policiesBadgeText.copyWith(
                color: CustomColor.colorBE123C,
              ),
            ),
            Text(
              "Profile Preview",
              textAlign: TextAlign.center,
              style: TextStyles.registerTitle,
            ),
          ],
        ),
        actions: [
          // Icon(
          //   Icons.lock_outline,
          //   size: ScreenConstant.smallIconSize,
          //   color: CustomColor.color94A3B8,
          // ),
          // SizedBox(width: ScreenConstant.defaultWidthTen),
          // Container(
          //   height: ScreenConstant.defaultHeightForty,
          //   width: ScreenConstant.defaultWidthForty,
          //   margin: EdgeInsets.only(right: ScreenConstant.sizeMedium),
          //   decoration: BoxDecoration(
          //     shape: BoxShape.circle,
          //     color: CustomColor.colorFFF1F2,
          //     border: Border.all(color: CustomColor.colorFFE4E6, width: 2),
          //   ),
          //   child: Icon(
          //     Icons.person_outline,
          //     color: CustomColor.colorE11D48,
          //     size: ScreenConstant.smallIconSize - 2,
          //   ),
          // ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            ScreenConstant.defaultWidthTwenty,
            ScreenConstant.defaultHeightTen,
            ScreenConstant.defaultWidthTwenty,
            ScreenConstant.defaultHeightThirty,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMemberViewStrip(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildHeroCard(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildPrivacyStealthCard(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              Container(padding:EdgeInsets.symmetric(vertical: ScreenConstant.sizeMedium,horizontal: ScreenConstant.sizeMedium,),decoration: BoxDecoration(color: CustomColor.colorWhite,borderRadius: BorderRadius.circular(15)), child: _buildAboutMe()),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _previewCard(_buildLookingFor()),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              Container(padding:EdgeInsets.symmetric(vertical: ScreenConstant.sizeMedium,horizontal: ScreenConstant.sizeMedium,),decoration: BoxDecoration(color: CustomColor.colorWhite,borderRadius: BorderRadius.circular(15)), child: _buildSeekingDynamics()),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              Container(padding:EdgeInsets.symmetric(vertical: ScreenConstant.sizeMedium,horizontal: ScreenConstant.sizeMedium,),decoration: BoxDecoration(color: CustomColor.colorWhite,borderRadius: BorderRadius.circular(15)), child: _buildIntimateChemistry()),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _previewCard(_buildExplorationKink()),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              Container(padding:EdgeInsets.symmetric(vertical: ScreenConstant.sizeMedium,horizontal: ScreenConstant.sizeMedium,),decoration: BoxDecoration(color: CustomColor.colorWhite,borderRadius: BorderRadius.circular(15)), child:  _buildPassionsLifestyle(),),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildSafetyStandards(),
              SizedBox(height: ScreenConstant.defaultHeightThirty),
              _buildActionRow(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              Center(child: _buildFooter()),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // (2) Member-view note strip
  // ---------------------------------------------------------------------------
  Widget _buildMemberViewStrip() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenConstant.sizeMedium),
      decoration: BoxDecoration(
        color: CustomColor.colorFFF1F2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CustomColor.colorFECDD3, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.visibility_outlined,
            size: ScreenConstant.smallIconSize,
            color: CustomColor.colorBE123C,
          ),
          SizedBox(width: ScreenConstant.sizeSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "MEMBER VIEW",
                  style: TextStyles.policiesBadgeText.copyWith(
                    color: CustomColor.colorBE123C,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "This is how your unlocked profile card appears to verified "
                  "matches in Belgium.",
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
  // (3) Hero photo card with reactive overlays
  // ---------------------------------------------------------------------------
  Widget _buildHeroCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: ScreenConstant.defaultSizeThreeTwenty,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background: a swipeable carousel of all preview photos (main
            // photo first, then vault gallery), or a neutral placeholder.
            Positioned.fill(
              child: Obx(() {
                final List<File> photos = controller.previewPhotos;
                if (photos.isEmpty) {
                  return _heroPlaceholder();
                }
                return PageView.builder(
                  controller: controller.heroPageController,
                  onPageChanged: controller.onHeroPageChanged,
                  itemCount: photos.length,
                  itemBuilder: (context, index) => Image.file(
                    photos[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                );
              }),
            ),
            // Bottom dark scrim so white text stays readable over any photo.
            // IgnorePointer lets swipe gestures pass through to the PageView.
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
            // Top-left: presence pill. PLACEHOLDER: presence not backed by
            // any controller field; shown statically as "Online Now".
            Positioned(
              top: ScreenConstant.sizeMedium,
              left: ScreenConstant.sizeMedium,
              child: _heroPill(
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
                      "Online Now",
                      style: TextStyles.policiesBadgeText.copyWith(
                        color: CustomColor.colorWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Top-center: carousel page-indicator dashes (one per available
            // photo, capped; the first is active since the hero shows photo 1).
            Positioned(
              top: ScreenConstant.sizeMedium + ScreenConstant.defaultHeightThirty,
              left: 0,
              right: 0,
              child: Obx(() {
                final int total = controller.previewPhotos.length;
                final int dashCount = total < 1 ? 1 : (total > 8 ? 8 : total);
                final int current = controller.heroPageIndex.value;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(dashCount, (i) {
                    final bool active = i == current;
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
                );
              }),
            ),
            // Top-right: photo counter. Counts the hero photo as 1 plus every
            // gallery photo; falls back to a minimum of 1 defensively.
            Positioned(
              top: ScreenConstant.sizeMedium,
              right: ScreenConstant.sizeMedium,
              child: Obx(() {
                final int total = controller.previewPhotos.length;
                final int shown = total < 1 ? 1 : total;
                final int current =
                    total < 1 ? 1 : controller.heroPageIndex.value + 1;
                return _heroPill(
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
                        "$current / $shown",
                        style: TextStyles.policiesBadgeText.copyWith(
                          color: CustomColor.colorWhite,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            // Bottom-left stacked identity text.
            Positioned(
              left: ScreenConstant.sizeMedium,
              right: ScreenConstant.sizeMedium,
              bottom: ScreenConstant.sizeMedium,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name (+ age when DOB year is set) with a verified check.
                  Obx(() {
                    final String name =
                        controller.profileNameController.text.trim().isEmpty
                            ? "Your Name"
                            : controller.profileNameController.text.trim();
                    final int? age = controller.previewAge;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: CustomColor.colorWhite,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (age != null) ...[
                          SizedBox(width: ScreenConstant.sizeExtraSmall),
                          Text(
                            ", $age",
                            style: const TextStyle(
                              color: CustomColor.colorWhite,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        SizedBox(width: ScreenConstant.sizeExtraSmall),
                        // PLACEHOLDER: verification status not backed by
                        // controller; shown as a static verified badge.
                        Icon(
                          Icons.verified,
                          size: ScreenConstant.smallIconSize,
                          color: CustomColor.colorE11D48,
                        ),
                      ],
                    );
                  }),
                  // Gender + orientation as dark pills, matching the mock.
                  Obx(() {
                    final String gender = controller.selectedGender.value;
                    final String orientation =
                        controller.selectedOrientation.value;
                    return Wrap(
                      spacing: ScreenConstant.sizeSmall,
                      runSpacing: ScreenConstant.sizeExtraSmall,
                      children: [
                        _identityPill(Icons.female, gender),
                        if (orientation.isNotEmpty)
                          _identityPill(Icons.favorite_border, orientation),
                      ],
                    );
                  }),
                  SizedBox(height: ScreenConstant.defaultHeightTen,),
                  // Location is intentionally hidden regardless of the chosen
                  // city. PLACEHOLDER: literal "Remains hidden", not the raw
                  // selectedProfileCity value.
                  _identityPill(
                    Icons.location_off_outlined,
                    iconColor: CustomColor.colorFBCFE8,
                    "Location: Remains hidden",
                    textStyle: TextStyle(
                      color: CustomColor.colorFBCFE8,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Neutral placeholder shown when no photos have been added yet.
  Widget _heroPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CustomColor.color0F172A,
            CustomColor.color334155,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera_outlined,
            size: ScreenConstant.texIconSize,
            color: CustomColor.color94A3B8,
          ),
          SizedBox(height: ScreenConstant.sizeSmall),
          Text(
            "No photo yet",
            style: TextStyles.registerFieldNote.copyWith(
              color: CustomColor.color94A3B8,
            ),
          ),
        ],
      ),
    );
  }

  /// Dark rounded identity pill (icon + label) overlaid on the hero photo.
  Widget _identityPill(
    IconData icon,
    String label, {
    Color iconColor = CustomColor.colorWhite,
    TextStyle? textStyle,
  }) {
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
            color: iconColor,
          ),
          SizedBox(width: ScreenConstant.sizeExtraSmall),
          Text(
            label,
            style: textStyle ??
                const TextStyle(
                  color: CustomColor.colorWhite,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  /// Small rounded overlay pill used across the hero card.
  Widget _heroPill({required Color bg, required Widget child}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeSmall,
        vertical: ScreenConstant.sizeExtraSmall / 1.2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: child,
    );
  }

  // ---------------------------------------------------------------------------
  // (4) Privacy & Stealth card
  // ---------------------------------------------------------------------------
  Widget _buildPrivacyStealthCard() {
    return Container(
      decoration: BoxDecoration(
        color: CustomColor.colorFFF5F8,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(ScreenConstant.sizeMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(padding: EdgeInsets.all(ScreenConstant.sizeDefault),height:ScreenConstant.defaultHeightThirty,width:ScreenConstant.defaultWidthThirty,decoration: BoxDecoration(shape: BoxShape.circle, color: CustomColor.colorWhite),child: Image.asset(ImageUtils.privacy, height: ScreenConstant.minimumIconSize,)),
                SizedBox(width: ScreenConstant.sizeSmall),
                Expanded(
                  child: Text(
                    "Privacy & Stealth Active",
                    style: TextStyles.registerSectionTitle,
                  ),
                ),
                SizedBox(width: ScreenConstant.sizeExtraSmall),
                // PLACEHOLDER: "Belgian Shield" badge is static copy.
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenConstant.sizeSmall,
                    vertical: ScreenConstant.sizeExtraSmall / 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: CustomColor.colorFECDD3,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    "Belgian Shield",
                    style: TextStyles.policiesBadgeText.copyWith(
                      color: CustomColor.colorBE123C,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenConstant.sizeSmall),
            Text(
              "Exact location, contacts, and personal identifiers are "
              "cryptographically masked until you grant mutual private lounge "
              "access.",
              style: TextStyles.registerFieldNote.copyWith(
                color: CustomColor.color64748B,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // (5) About Me
  // ---------------------------------------------------------------------------
  Widget _buildAboutMe() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(Image.asset(ImageUtils.aboutMe,height: ScreenConstant.minimumIconSize-5,), "ABOUT ME",textStyle:   TextStyles.registerSectionTitle.copyWith(
          letterSpacing: 0.5,
          color: CustomColor.colorBE185D
        ),),
        SizedBox(height: ScreenConstant.sizeSmall),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(ScreenConstant.sizeMedium),
          child: Obx(() {
            // Touch the reactive length so Obx tracks About Me edits.
            controller.aboutMeLength.value;
            final String text = controller.aboutMeController.text.trim();
            final bool empty = text.isEmpty;
            return Text(
              empty ? "No bio added yet." : text,
              style: TextStyles.registerFieldNote.copyWith(
                fontSize: FontSize.s14,
                color: CustomColor.color334155,
              ),
            );
          }),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // (6) Seeking / Dynamics
  // ---------------------------------------------------------------------------
  Widget _buildSeekingDynamics() {
    return Obx(() {
      final List<String> prefs = controller.relationshipPrefs.toList();
      return _buildSection(
        imageAsset: (ImageUtils.seeking),
        label: "RELATIONSHIP PREFERENCES",
        textStyle: TextStyles.registerSectionTitle.copyWith(
         color: CustomColor.colorBE185D
        ),
        rightPillText: "${prefs.length} selected",
        child: _readonlyChips(prefs),
      );
    });
  }

  /// White rounded wrapper matching the other preview section cards.
  Widget _previewCard(Widget child) {
    return Container(
      padding: EdgeInsets.all(ScreenConstant.sizeMedium),
      decoration: BoxDecoration(
        color: CustomColor.colorWhite,
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }

  // ---------------------------------------------------------------------------
  // Looking for (Profile Setup, multi-select)
  // ---------------------------------------------------------------------------
  Widget _buildLookingFor() {
    return Obx(() {
      final List<String> items = controller.selectedLookingFor.toList();
      return _buildSection(
        icon: Icons.favorite_border,
        label: "LOOKING FOR",
        textStyle: _previewSectionStyle,
        rightPillText: "${items.length} selected",
        child: _readonlyChips(items),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // (7) Core Physical & Intimate (multi-select)
  // ---------------------------------------------------------------------------
  Widget _buildIntimateChemistry() {
    return Obx(() {
      final List<String> items = controller.physicalPrefs.toList();
      return _buildSection(
        icon: Icons.auto_awesome_outlined,
        label: "CORE PHYSICAL & INTIMATE",
        textStyle: _previewSectionStyle,
        rightPillText: "${items.length} selected",
        child: _readonlyChips(items),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Exploration & Kink (multi-select)
  // ---------------------------------------------------------------------------
  Widget _buildExplorationKink() {
    return Obx(() {
      final List<String> items = controller.kinkPrefs.toList();
      return _buildSection(
        icon: Icons.local_fire_department_outlined,
        label: "EXPLORATION & KINK",
        textStyle: _previewSectionStyle,
        rightPillText: "${items.length} selected",
        child: _readonlyChips(items),
      );
    });
  }

  TextStyle get _previewSectionStyle => TextStyles.registerSectionTitle
      .copyWith(letterSpacing: 0.5, color: CustomColor.colorBE185D);

  // ---------------------------------------------------------------------------
  // (8) Passions & Lifestyle
  // ---------------------------------------------------------------------------
  Widget _buildPassionsLifestyle() {
    return Obx(() {
      final List<String> items = controller.interests.toList();
      return _buildSection(
        icon: Icons.interests_outlined,
        label: "INTERESTS & PASSIONS",
        textStyle: TextStyles.registerSectionTitle.copyWith(
            letterSpacing: 0.5,
            color: CustomColor.colorBE185D
        ),
        child: _readonlyChips(items, neutral: true),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // (9) Safety & Standards
  // ---------------------------------------------------------------------------
  Widget _buildSafetyStandards() {
    // Outer section card (F8FAFC + soft shadow) wrapping the header and the
    // three individual sub-cards, matching the mock.
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenConstant.sizeMedium),
      decoration: BoxDecoration(
        color: CustomColor.colorF8FAFC,
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
          _sectionHeader(Icons.verified_user_outlined, "SAFETY & STANDARDS"),
          SizedBox(height: ScreenConstant.sizeMedium),
          // Personal & safety information (Intimate Desires "Able to accept").
          Obx(() {
            final List<String> accept = controller.ableToAccept.toList();
            return _safetyCard(
              icon: Icons.health_and_safety_outlined,
              iconBg: CustomColor.colorFFF1F2,
              iconColor: CustomColor.colorBE123C,
              title: "Personal & Safety",
              subtitle: accept.isEmpty ? "None selected" : accept.join(", "),
            );
          }),
          SizedBox(height: ScreenConstant.sizeSmall),
          // Sexual health routine, reactive on stiStatus.
          Obx(() => _safetyCard(
                icon: Icons.medical_services_outlined,
                iconBg: CustomColor.colorECFDF5,
                iconColor: CustomColor.color059669,
                title: "Sexual Health Routine",
                // PLACEHOLDER: testing cadence is static copy.
                subtitle: "Tested every 3 months",
                pill: _stiPill(controller.stiStatus.value),
              )),
          // SizedBox(height: ScreenConstant.sizeSmall),
          // // Languages. PLACEHOLDER: no language field in the controller; both
          // // value and subtitle are static copy.
          // _safetyCard(
          //   icon: Icons.translate_outlined,
          //   iconBg: CustomColor.colorAF5FF,
          //   iconColor: CustomColor.color9333EA,
          //   title: "Languages",
          //   subtitle: "Brussels tri-lingual",
          //   trailingText: "English, Francais, Nederlands",
          // ),
          SizedBox(height: ScreenConstant.sizeSmall),
          // Preference visibility mode (single choice from Intimate Desires).
          Obx(() {
            final String mode = controller.visibilityMode.value;
            final bool mutualOnly = mode == 'Mutual Matches Only';
            return _safetyCard(
              icon: mutualOnly
                  ? Icons.lock_outline
                  : Icons.verified_user_outlined,
              iconBg: CustomColor.colorFFF1F2,
              iconColor: CustomColor.colorBE123C,
              title: "Preference Visibility",
              subtitle: mode.isEmpty ? "Not set" : mode,
              pill: _simplePill(
                mutualOnly ? "Private" : "ID-Verified",
                bg: CustomColor.colorFFF1F2,
                fg: CustomColor.colorBE123C,
              ),
            );
          }),
        ],
      ),
    );
  }

  /// A single Safety & Standards item: a white rounded sub-card with a round
  /// leading icon badge, a title/subtitle, and a right-hand pill or value.
  Widget _safetyCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? pill,
    String? trailingText,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenConstant.sizeMedium),
      decoration: BoxDecoration(
        color: CustomColor.colorWhite,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Round leading icon badge.
          Container(
            height: ScreenConstant.defaultHeightForty,
            width: ScreenConstant.defaultWidthForty,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBg,
            ),
            child: Icon(
              icon,
              size: ScreenConstant.smallIconSize,
              color: iconColor,
            ),
          ),
          SizedBox(width: ScreenConstant.sizeMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyles.registerFieldLabel.copyWith(
                    color: CustomColor.color0F172A,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyles.registerFieldNote.copyWith(
                    color: CustomColor.color64748B,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: ScreenConstant.sizeSmall),
          if (pill != null)
            pill
          else if (trailingText != null)
            Flexible(
              child: Text(
                trailingText,
                textAlign: TextAlign.right,
                style: TextStyles.registerFieldLabel.copyWith(
                  color: CustomColor.color334155,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Maps the stored STI status to its display pill.
  Widget _stiPill(String status) {
    switch (status) {
      case 'No':
        return _simplePill(
          "Negative / Up-to-date",
          bg: CustomColor.colorECFDF5,
          fg: CustomColor.color059669,
        );
      case 'Yes':
        return _simplePill(
          "Positive - disclosed",
          bg: CustomColor.colorFEF3C7,
          fg: CustomColor.colorD97706,
        );
      case 'Prefer not to say':
      default:
        return _simplePill(
          "Not disclosed",
          bg: CustomColor.colorF1F5F9,
          fg: CustomColor.color64748B,
        );
    }
  }

  Widget _simplePill(String text, {required Color bg, required Color fg}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeSmall,
        vertical: ScreenConstant.sizeExtraSmall / 1.5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: TextStyles.policiesBadgeText.copyWith(color: fg),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // (10) Bottom action row — Edit / Publish
  // ---------------------------------------------------------------------------
  Widget _buildActionRow() {
    return Row(
      children: [
        // Secondary: Edit Profile -> back to the previous step.
        Expanded(
          flex: 2,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: controller.onBack,
            child: Container(
              height: ScreenConstant.defaultHeightFifty,
              decoration: BoxDecoration(
                color: CustomColor.colorWhite,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: CustomColor.colorE2E8F0, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: ScreenConstant.smallIconSize,
                    color: CustomColor.color334155,
                  ),
                  SizedBox(width: ScreenConstant.sizeExtraSmall),
                  Text(
                    "Edit Profile",
                    style: TextStyles.registerFieldLabel.copyWith(
                      color: CustomColor.color334155,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: ScreenConstant.sizeSmall),
        // Primary: Publish Profile -> payment (clones sibling gradient button).
        Expanded(
          flex: 3,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: controller.onPublishProfile,
            child: Container(
              height: ScreenConstant.defaultHeightFifty,
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
                boxShadow: [
                  BoxShadow(
                    color: CustomColor.colorDB2777.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Publish Profile",
                    style: TextStyles.loginButtonText.copyWith(
                      color: CustomColor.colorWhite,
                    ),
                  ),
                  SizedBox(width: ScreenConstant.sizeSmall),
                  Icon(
                    Icons.arrow_forward,
                    color: CustomColor.colorWhite,
                    size: ScreenConstant.smallIconSize,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // (11) Footer line
  // ---------------------------------------------------------------------------
  Widget _buildFooter() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.lock_outline,
          size: ScreenConstant.minimumIconSize,
          color: CustomColor.colorBE185D,
        ),
        SizedBox(width: ScreenConstant.sizeExtraSmall),
        Flexible(
          child: Text(
            "Protected under Belgian GDPR law - 100% Discreet",
            textAlign: TextAlign.center,
            style: TextStyles.registerFooterStrip,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------

  /// Section wrapper: an uppercase header with an optional right-aligned pill,
  /// followed by [child].
  Widget _buildSection({
    dynamic icon,
    required String label,
    required Widget child,
    String? rightPillText,
    String? imageAsset,
    Widget? leading,
    TextStyle? textStyle,
    Color? iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _sectionHeader(
                icon,
                label,
                imageAsset: imageAsset,
                leading: leading,
                textStyle: textStyle,
                iconColor: iconColor,
              ),
            ),
            if (rightPillText != null)
              _simplePill(
                rightPillText,
                bg: CustomColor.colorFFF1F2,
                fg: CustomColor.colorBE123C,
              ),
          ],
        ),
        SizedBox(height: ScreenConstant.sizeSmall),
        child,
      ],
    );
  }

  /// Icon, asset image, or custom widget + label used by section headers.
  Widget _sectionHeader(
    dynamic icon,
    String label, {
    String? imageAsset,
    Widget? leading,
    TextStyle? textStyle,
    Color? iconColor,
  }) {
    final Color effectiveIconColor = iconColor ?? CustomColor.colorBE123C;

    Widget? leadingWidget = leading;
    if (leadingWidget == null) {
      final String? assetPath = imageAsset ?? (icon is String ? icon : null);
      if (assetPath != null && assetPath.isNotEmpty) {
        leadingWidget = Image.asset(
          assetPath,
          height: ScreenConstant.smallIconSize-5,
          width: ScreenConstant.smallIconSize-5,
          color: iconColor,
          fit: BoxFit.contain,
        );
      } else if (icon is IconData) {
        leadingWidget = Icon(
          icon,
          size: ScreenConstant.smallIconSize,
          color: effectiveIconColor,
        );
      } else if (icon is Widget) {
        leadingWidget = icon;
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingWidget != null) ...[
          leadingWidget,
          SizedBox(width: ScreenConstant.sizeExtraSmall + 2),
        ],
        Flexible(
          child: Text(
            label,
            style: textStyle ??
                TextStyles.registerSectionTitle.copyWith(
                  letterSpacing: 0.5,
                ),
          ),
        ),
      ],
    );
  }

  /// Read-only, non-tappable chips. [neutral] uses a grey palette (for
  /// passions); otherwise the rose palette matching selected chips elsewhere.
  Widget _readonlyChips(List<String> labels, {bool neutral = false}) {
    if (labels.isEmpty) {
      return _readonlyChip("None selected", neutral: true, muted: true);
    }
    return Wrap(
      spacing: ScreenConstant.sizeSmall,
      runSpacing: ScreenConstant.sizeSmall,
      children: labels
          .map((label) => _readonlyChip(label, neutral: neutral))
          .toList(),
    );
  }

  Widget _readonlyChip(
    String label, {
    bool neutral = false,
    bool muted = false,
  }) {
    final Color bg = neutral
        ? CustomColor.colorF1F5F9
        : CustomColor.colorFFF1F2;
    final Color border = neutral
        ? CustomColor.colorE2E8F0
        : CustomColor.colorFECDD3;
    final Color fg = muted
        ? CustomColor.color94A3B8
        : (neutral ? CustomColor.color475569 : CustomColor.colorBE123C);
    final Color dot = neutral
        ? CustomColor.color64748B
        : CustomColor.colorBE123C;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeMedium,
        vertical: ScreenConstant.sizeSmall,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!muted) ...[
            Icon(Icons.circle, size: 6, color: dot),
            SizedBox(width: ScreenConstant.sizeExtraSmall + 1),
          ],
          Text(
            label,
            style: TextStyles.registerFieldLabel.copyWith(
              color: fg,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
