import 'package:chat_x/device_manager/screen_constants.dart';
import 'dart:io';

import 'package:chat_x/modules/register/controller/register_controller.dart';
import 'package:chat_x/utils/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';

class ProfileSetupScreen extends GetView<RegisterController> {
  const ProfileSetupScreen({super.key});

  static const List<String> _genders = ['Woman', 'Man', 'Non-binary'];
  static const List<String> _orientations = [
    'Straight',
    'Bisexual',
    'Gay / Lesbian',
    'Pansexual',
    'Open-minded',
  ];
  static const List<String> _lookingFor = [
    'Intimate connection',
    'Casual dating',
    'Discreet exploration',
    'Regular meetups',
    'Deep friendship',
  ];

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
        title: Column(
          children: [
            Text(
              "STEP 3 OF 4",
              textAlign: TextAlign.center,
              style: TextStyles.policiesBadgeText,
            ),
            Text(
              "Profile Setup",
              textAlign: TextAlign.center,
              style: TextStyles.registerTitle,
            ),
          ],
        ),
        actions: [
          Container(
            height: ScreenConstant.defaultHeightForty,
            width: ScreenConstant.defaultWidthForty,
            margin: EdgeInsets.only(right: ScreenConstant.sizeMedium),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: ScreenConstant.defaultHeightTwentyThree),
                decoration: BoxDecoration(
                  color: CustomColor.colorWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: CustomColor.color717B96.withOpacity(0.18),
                      blurRadius: 16,
                      spreadRadius: -4,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDiscreetBadge(),
                    SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                    _buildAddPhoto(),
                  ],
                ),
              ),
              // SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              // _buildProfileName(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildGender(),
              // SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              // _buildDob(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildOrientation(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildLocationCard(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildLookingFor(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildAboutMe(),
              SizedBox(height: ScreenConstant.defaultHeightThirty),
              _buildCompleteButton(),
              SizedBox(height: ScreenConstant.defaultHeightFifteen),
              _buildSkipLink(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------
  Widget _label(String text, {bool required = true, Widget? trailing}) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenConstant.sizeSmall),
      child: Row(
        children: [
          Text(text, style: TextStyles.registerFieldLabel),
          if (required)
            Text(" *", style: TextStyles.registerVerifyNoteHighlight),
          if (trailing != null) ...[
            const Spacer(),
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _greenPill(String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeSmall,
        vertical: ScreenConstant.sizeExtraSmall / 1.5,
      ),
      decoration: BoxDecoration(
        color: CustomColor.colorECFDF5,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: CustomColor.color10B981.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_open_outlined,
            size: ScreenConstant.minimumIconSize - 2,
            color: CustomColor.color059669,
          ),
          SizedBox(width: ScreenConstant.sizeExtraSmall / 2),
          Text(text, style: TextStyles.paymentValidFormat),
        ],
      ),
    );
  }

  Widget _selectableChip(
    String label,
    bool selected,
    VoidCallback onTap, {
    bool expand = false,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: expand ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: ScreenConstant.sizeMedium,
          vertical: ScreenConstant.sizeSmall,
        ),
        decoration: BoxDecoration(
          color: selected ? CustomColor.colorFFF1F2 : CustomColor.colorWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? CustomColor.colorBE123C
                : CustomColor.colorE2E8F0,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyles.registerFieldLabel.copyWith(
            color: selected
                ? CustomColor.colorBE123C
                : CustomColor.color334155,
          ),
        ),
      ),
    );
  }

  /// Lays out [labels] as equal-width selectable chips filling the full row
  /// width, with [ScreenConstant.sizeSmall] gaps between them.
  Widget _equalWidthChipRow({
    required List<String> labels,
    required bool Function(String) isSelected,
    required void Function(String) onTap,
  }) {
    final double spacing = ScreenConstant.sizeSmall;
    final List<Widget> children = [];
    for (int i = 0; i < labels.length; i++) {
      if (i > 0) children.add(SizedBox(width: spacing));
      final String label = labels[i];
      children.add(
        Expanded(
          child: _selectableChip(
            label,
            isSelected(label),
            () => onTap(label),
            expand: true,
          ),
        ),
      );
    }
    return Row(children: children);
  }

  Widget _dropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? hint,
  }) {
    return Container(
      height: ScreenConstant.defaultHeightFifty,
      padding: EdgeInsets.symmetric(horizontal: ScreenConstant.sizeMedium),
      decoration: BoxDecoration(
        color: CustomColor.colorF8FAFC,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: CustomColor.colorE2E8F0, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: hint == null
              ? null
              : Text(
                  hint,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.loginTopText.copyWith(
                    fontSize: FontSize.s14,
                    color: CustomColor.color94A3B8,
                  ),
                ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: CustomColor.color64748B,
            size: ScreenConstant.smallIconSize,
          ),
          style: TextStyles.loginTopText.copyWith(fontSize: FontSize.s14),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // (1) Step header
  // ---------------------------------------------------------------------------
  Widget _buildStepHeader() {
    return Column(
      children: [
        Text(
          "STEP 3 OF 4",
          textAlign: TextAlign.center,
          style: TextStyles.policiesBadgeText,
        ),
        SizedBox(height: ScreenConstant.sizeExtraSmall),
        Text(
          "Profile Setup",
          textAlign: TextAlign.center,
          style: TextStyles.registerTitle,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // (2) Discreet & protected badge
  // ---------------------------------------------------------------------------
  Widget _buildDiscreetBadge() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenConstant.sizeMedium,
          vertical: ScreenConstant.sizeExtraSmall,
        ),
        decoration: BoxDecoration(
          color: CustomColor.colorFFF1F2,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: CustomColor.colorFECDD3, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/images/100percent_discreet.png",
              height: ScreenConstant.minimumIconSize,
              color: CustomColor.colorBE123C,
            ),
            SizedBox(width: ScreenConstant.sizeExtraSmall),
            Text(
              "100% DISCREET & PROTECTED",
              style: TextStyles.policiesBadgeText,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // (3) Add photo control
  // ---------------------------------------------------------------------------
  Widget _buildAddPhoto() {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
         // onTap: controller.onAddPhotoTap,
          child: SizedBox(
            height: ScreenConstant.defaultSizeOneTen,
            width: ScreenConstant.defaultSizeOneTen,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: ScreenConstant.defaultSizeOneTwenty,
                  width: ScreenConstant.defaultSizeOneTwenty,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        CustomColor.colorEC4899,
                        CustomColor.colorF43F5E,
                        CustomColor.color9333EA,
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Obx(() {
                      final File? photo = controller.profileImage.value;
                      return Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: CustomColor.colorWhite,
                        ),
                        child: photo != null
                            ? Image.file(
                                photo,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/add_photo.png",
                                    height: ScreenConstant.texIconSize,
                                    color: CustomColor.color475569,
                                  ),
                                  SizedBox(height: ScreenConstant.sizeSmall),
                                  Text(
                                    "ADD PHOTO",
                                    style: TextStyles.policiesBadgeText.copyWith(
                                      color: CustomColor.color334155,
                                    ),
                                  ),
                                ],
                              ),
                      );
                    }),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: ScreenConstant.defaultHeightThirty,
                    width: ScreenConstant.defaultWidthThirty,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CustomColor.color0F172A,
                      border: Border.all(
                        color: CustomColor.colorWhite,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.photo_camera,
                      size: ScreenConstant.minimumIconSize,
                      color: CustomColor.colorWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: ScreenConstant.sizeSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/photos_can_be_blurred.png",
              height: ScreenConstant.minimumIconSize,
              color: CustomColor.colorF43F5E,
            ),
            SizedBox(width: ScreenConstant.defaultWidthTen,),
            Text(
              "Photos can be blurred or hidden anytime.",
              textAlign: TextAlign.center,
              style: TextStyles.registerFieldNote,
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // (4) Profile name
  // ---------------------------------------------------------------------------
  Widget _buildProfileName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Profile Name", trailing: _greenPill("Pseudonym OK")),
        SizedBox(
          height: ScreenConstant.defaultHeightFifty,
          child: CustomTextField(
            borderRadius: 26,
            controller: controller.profileNameController,
            hintText: "e.g. Alex_BXL or VelvetMystique",
            hintStyle: TextStyles.loginTopText.copyWith(fontSize: FontSize.s14),
            borderColor: CustomColor.colorE2E8F0,
          ),
        ),
        SizedBox(height: ScreenConstant.sizeExtraSmall + 2),
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: ScreenConstant.minimumIconSize - 2,
              color: CustomColor.color94A3B8,
            ),
            SizedBox(width: ScreenConstant.sizeExtraSmall + 2),
            Expanded(
              child: Text(
                "This is your public display name. Never use your real legal name.",
                style: TextStyles.registerFieldNote,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // (5) Gender (single-select)
  // ---------------------------------------------------------------------------
  Widget _buildGender() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Gender"),
        Obx(
          () => _equalWidthChipRow(
            labels: _genders,
            isSelected: (g) => controller.selectedGender.value == g,
            onTap: controller.selectGender,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // (6) Date of birth / age verification
  // ---------------------------------------------------------------------------
  Widget _buildDob() {
    final int currentYear = DateTime.now().year;
    final List<int> days = List.generate(31, (i) => i + 1);
    final List<int> months = List.generate(12, (i) => i + 1);
    final List<int> years =
        List.generate(currentYear - 18 - 1950 + 1, (i) => currentYear - 18 - i);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Date of Birth / Age Verification"),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _dropdown<int>(
                  value: controller.selectedDobDay.value,
                  hint: "Day",
                  items: days
                      .map(
                        (d) => DropdownMenuItem<int>(
                          value: d,
                          child: Text(
                            "$d",
                            style: TextStyles.loginTopText
                                .copyWith(fontSize: FontSize.s14),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: controller.setDobDay,
                ),
              ),
            ),
            SizedBox(width: ScreenConstant.sizeSmall),
            Expanded(
              child: Obx(
                () => _dropdown<int>(
                  value: controller.selectedDobMonth.value,
                  hint: "Month",
                  items: months
                      .map(
                        (m) => DropdownMenuItem<int>(
                          value: m,
                          child: Text(
                            "$m",
                            style: TextStyles.loginTopText
                                .copyWith(fontSize: FontSize.s14),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: controller.setDobMonth,
                ),
              ),
            ),
            SizedBox(width: ScreenConstant.sizeSmall),
            Expanded(
              child: Obx(
                () => _dropdown<int>(
                  value: controller.selectedDobYear.value,
                  hint: "Year",
                  items: years
                      .map(
                        (y) => DropdownMenuItem<int>(
                          value: y,
                          child: Text(
                            "$y",
                            style: TextStyles.loginTopText
                                .copyWith(fontSize: FontSize.s14),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: controller.setDobYear,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenConstant.sizeExtraSmall + 2),
        Text(
          "Only your calculated age (e.g. 28) will be displayed. Your exact "
          "birth date remains completely hidden.",
          style: TextStyles.registerFieldNote,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // (7) Orientation (multi-select)
  // ---------------------------------------------------------------------------
  Widget _buildOrientation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Orientation"),
        Obx(
          () => Wrap(
            spacing: ScreenConstant.sizeSmall,
            runSpacing: ScreenConstant.sizeSmall,
            children: _orientations
                .map(
                  (o) => _selectableChip(
                    o,
                    controller.selectedOrientations.contains(o),
                    () => controller.toggleOrientation(o),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // (8) Belgian location card
  // ---------------------------------------------------------------------------
  Widget _buildLocationCard() {
    return Container(
      padding: EdgeInsets.all(ScreenConstant.sizeMedium),
      decoration: BoxDecoration(
        color: CustomColor.colorF8FAFC,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CustomColor.colorE2E8F0, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: ScreenConstant.defaultHeightThirty,
                width: ScreenConstant.defaultWidthThirty,
                decoration: BoxDecoration(
                  color: CustomColor.colorECFDF5,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: CustomColor.colorE2E8F0, width: 1),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  size: ScreenConstant.minimumIconSize,
                  color: CustomColor.color059669,
                ),
              ),
              SizedBox(width: ScreenConstant.sizeExtraSmall),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Belgian Location", style: TextStyles.registerSectionTitle),
                  Text("Regional proximity matching", style: TextStyles.registerSupportedLabel.copyWith(fontWeight: FontWeight.normal)),
                ],
              ),
              const Spacer(),
              _greenPill("Remains Hidden"),
            ],
          ),
          SizedBox(height: ScreenConstant.sizeSmall),
          Obx(
            () => _dropdown<String>(
              value: controller.selectedProfileCity.value,
              items: controller.belgianCities
                  .map(
                    (c) => DropdownMenuItem<String>(
                      value: c,
                      child: Text(
                        c,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyles.loginTopText
                            .copyWith(fontSize: FontSize.s14),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) controller.onProfileCitySelected(value);
              },
            ),
          ),
          SizedBox(height: ScreenConstant.sizeSmall),
          Container(
            padding: EdgeInsets.all(ScreenConstant.sizeMedium),
            decoration: BoxDecoration(
              color: CustomColor.colorWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CustomColor.colorE2E8F0, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  "assets/images/card_verification_logo.png",
                  height: ScreenConstant.minimumIconSize,
                  color: CustomColor.colorEF4444,
                ),
                SizedBox(width: ScreenConstant.sizeExtraSmall),
                Expanded(
                  child: Text(
                    "Privacy Shield Active: Exact GPS coordinates were not captured. "
                    "Other members only see broad distance estimates "
                    "(e.g. '~12 km away').",
                    style: TextStyles.registerFieldNote.copyWith(color: CustomColor.color475569),
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
  // (9) Looking for (multi-select)
  // ---------------------------------------------------------------------------
  Widget _buildLookingFor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(
          "Looking for",
          required: false,
          trailing: Text("(Select multiple)", style: TextStyles.registerOptional),
        ),
        Obx(
          () => Wrap(
            spacing: ScreenConstant.sizeSmall,
            runSpacing: ScreenConstant.sizeSmall,
            children: _lookingFor
                .map(
                  (v) => _selectableChip(
                    v,
                    controller.selectedLookingFor.contains(v),
                    () => controller.toggleLookingFor(v),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // (10) About me / desires
  // ---------------------------------------------------------------------------
  Widget _buildAboutMe() {
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: CustomColor.colorE2E8F0, width: 1),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(
          "About Me / Desires",
          required: false,
          trailing: Obx(
            () => Text(
              "${controller.aboutMeLength.value} / 500",
              style: TextStyles.registerFieldNote,
            ),
          ),
        ),
        TextField(
          controller: controller.aboutMeController,
          maxLength: 500,
          maxLines: 5,
          cursorColor: CustomColor.colorDB2777,
          style: TextStyles.loginFieldText,
          buildCounter: (
            BuildContext context, {
            required int currentLength,
            required int? maxLength,
            required bool isFocused,
          }) =>
              null,
          decoration: InputDecoration(
            filled: true,
            fillColor: CustomColor.colorF8FAFC,
            hintText:
                "Share a bit about your desires, personality, or what brings "
                "you to ChatX...",
            hintStyle: TextStyles.loginFieldHint.copyWith(fontSize: FontSize.s14),
            contentPadding: EdgeInsets.all(ScreenConstant.sizeMedium),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: const BorderSide(
                color: CustomColor.colorDB2777,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // (11) Complete profile button
  // ---------------------------------------------------------------------------
  Widget _buildCompleteButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.onCompleteProfile,
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
              "Complete Profile",
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
    );
  }

  // ---------------------------------------------------------------------------
  // (12) Skip link
  // ---------------------------------------------------------------------------
  Widget _buildSkipLink() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.onSkipProfileSetup,
      child: Text(
        "Skip for now & browse members",
        textAlign: TextAlign.center,
        style: TextStyles.paymentCancelLink,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // (13) Footer security strip
  // ---------------------------------------------------------------------------
  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(ScreenConstant.sizeMedium),
      // decoration: BoxDecoration(
      //   color: CustomColor.colorF8FAFC,
      //   borderRadius: BorderRadius.circular(12),
      //   border: Border.all(color: CustomColor.colorE2E8F0, width: 1),
      // ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: ScreenConstant.sizeMedium,
        runSpacing: ScreenConstant.sizeExtraSmall,
        children: [
          _footerBadge(
            Icons.visibility_off,
            "Zero Indexing",
            CustomColor.colorBE185D,
          ),
          _footerBadge(
            Icons.gavel_outlined,
            "Belgian GDPR Protected",
            CustomColor.colorBE123C,
          ),
        ],
      ),
    );
  }

  Widget _footerBadge(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: ScreenConstant.minimumIconSize - 2, color: color),
        SizedBox(width: ScreenConstant.sizeExtraSmall),
        Text(text, style: TextStyles.registerFooterStrip),
      ],
    );
  }
}
