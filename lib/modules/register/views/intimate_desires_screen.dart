import 'package:chat_x/device_manager/screen_constants.dart';
import 'package:chat_x/modules/register/controller/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';

/// Base path for the chip glyph assets.
const String _assetDir = "assets/images/";

/// The red "selected" check asset shown on any activated chip.
const String _selectedChipAsset = "${_assetDir}selected.png";

/// Size of the small glyph rendered before a chip label.
const double _chipGlyphSize = 18;

/// Describes the default (unselected) leading glyph of a chip. It can be a
/// material [IconData] or an asset image; either is tinted with the chip's
/// content color. When a chip is selected it is replaced by [_selectedChipAsset].
class _ChipLeading {
  final IconData? icon;
  final String? asset;

  const _ChipLeading.icon(this.icon) : asset = null;
  const _ChipLeading.asset(this.asset) : icon = null;

  Widget build(Color color) {
    if (asset != null) {
      return Image.asset(
        asset!,
        height: _chipGlyphSize,
        width: _chipGlyphSize,
        color: color,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.circle_outlined, size: _chipGlyphSize, color: color),
      );
    }
    return Icon(icon, size: _chipGlyphSize, color: color);
  }
}

class IntimateDesiresScreen extends GetView<RegisterController> {
  const IntimateDesiresScreen({super.key});

  /// Maps each chip label to its default (unselected) leading glyph. Labels
  /// absent from this map get no leading. When a chip is selected the leading
  /// is swapped for the shared red check asset, regardless of this value.
  static const Map<String, _ChipLeading> _chipLeadings = {
    // Relationship Preferences
    "One time": _ChipLeading.icon(Icons.looks_one_outlined),
    "Multiple times": _ChipLeading.asset("${_assetDir}multipletime.png"),
    "In-life friendship": _ChipLeading.asset("${_assetDir}inlife.png"),
    "Serious relationship": _ChipLeading.asset("${_assetDir}serious.png"),
    "Other - optional": _ChipLeading.asset("${_assetDir}other.png"),
    // Core Physical & Intimate
    "Anal": _ChipLeading.icon(Icons.airline_seat_legroom_extra_outlined),
    "Oral": _ChipLeading.icon(Icons.memory_outlined),
    "Vaginal": _ChipLeading.icon(Icons.airline_seat_legroom_extra_outlined),
    "Outdoor": _ChipLeading.asset("${_assetDir}outdoor.png"),
    "Sensual Tantric": _ChipLeading.asset("${_assetDir}sensual.png"),
    "Threesome (FMF/MFM)": _ChipLeading.asset("${_assetDir}3some.png"),
    // Exploration & Kink
    "Roleplay": _ChipLeading.icon(Icons.theater_comedy_outlined),
    "Feet": _ChipLeading.asset("${_assetDir}feet.png"),
    "BDSM / Bondage": _ChipLeading.asset("${_assetDir}bdsm.png"),
    "Sensory Blindfold": _ChipLeading.asset("${_assetDir}sensory.png"),
    "Exhibitionism": _ChipLeading.asset("${_assetDir}exhibi.png"),
    // Interests & Passions
    "Sports": _ChipLeading.asset("${_assetDir}sport.png"),
    "Gaming": _ChipLeading.icon(Icons.sports_esports_outlined),
    "Movies": _ChipLeading.asset("${_assetDir}movies.png"),
    "Music": _ChipLeading.icon(Icons.music_note_outlined),
    "Genres": _ChipLeading.asset("${_assetDir}genre.png"),
    "Drawing / Painting / Art": _ChipLeading.asset("${_assetDir}drawing.png"),
    "Other interests": _ChipLeading.asset("${_assetDir}other.png"),
    // Personal / Safety - "Able to accept"
    "Protected only (Condom required)":
        _ChipLeading.icon(Icons.shield_outlined),
    "PrEP verified": _ChipLeading.asset("${_assetDir}card_verification_logo.png"),
    "Regular testing routine": _ChipLeading.icon(Icons.calendar_today_outlined),
    "Open to discuss": _ChipLeading.icon(Icons.chat_bubble_outline),
  };

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
              "STEP 4 OF 4",
              textAlign: TextAlign.center,
              style: TextStyles.policiesBadgeText,
            ),
            Text(
              "Profile Photos",
              textAlign: TextAlign.center,
              style: TextStyles.registerTitle,
            ),
          ],
        ),
        actions: [
          Icon(
            Icons.lock_outline,
            size: ScreenConstant.smallIconSize,
            color: CustomColor.color94A3B8,
          ),
          SizedBox(width: ScreenConstant.defaultWidthTen,),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopEyebrow(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildIntro(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildFirstFourCards(),
              _buildSafetyCard(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildVisibilityCard(),
              SizedBox(height: ScreenConstant.defaultHeightThirty),
              _buildSaveButton(),
              SizedBox(height: ScreenConstant.defaultHeightFifteen),
              Center(child: _buildSkipLink()),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              Center(child: _buildFooter()),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared helpers (bodies mirror profile_setup_screen.dart)
  // ---------------------------------------------------------------------------
  Widget _label(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenConstant.sizeSmall),
      child: Text(text, style: TextStyles.registerFieldLabel),
    );
  }

  Widget _selectableChip(
    String label,
    bool selected,
    VoidCallback onTap, {
    bool expand = false,
    _ChipLeading? leading,
  }) {
    final Color contentColor =
        selected ? CustomColor.colorBE123C : CustomColor.color64748B;

    final Widget? leadingWidget = leading == null
        ? null
        : (selected
            // Selected: always the red check asset from the design.
            ? Image.asset(
                _selectedChipAsset,
                height: _chipGlyphSize,
                width: _chipGlyphSize,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.check_circle,
                  size: _chipGlyphSize,
                  color: CustomColor.colorBE123C,
                ),
              )
            // Unselected: the chip's own default glyph (icon or asset).
            : leading.build(contentColor));

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
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected
                ? CustomColor.colorBE123C
                : CustomColor.colorE2E8F0,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingWidget != null) ...[
              leadingWidget,
              SizedBox(width: ScreenConstant.sizeExtraSmall + 2),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyles.registerFieldLabel.copyWith(
                  color: contentColor,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
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

  // ---------------------------------------------------------------------------
  // (1) Top eyebrow pill
  // ---------------------------------------------------------------------------
  Widget _buildTopEyebrow() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeMedium,
        vertical: ScreenConstant.sizeSmall,
      ),
      decoration: BoxDecoration(
        color: CustomColor.colorFFF1F2,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: CustomColor.colorFECDD3, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: CustomColor.colorBE123C,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: ScreenConstant.sizeExtraSmall),
          Text(
            "PROFILE SETUP ",
            style: TextStyles.policiesBadgeText.copyWith(
              color: CustomColor.colorBE123C,
            ),
          ),
          SizedBox(width: ScreenConstant.sizeExtraSmall),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: CustomColor.colorBE123C,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: ScreenConstant.sizeExtraSmall),
          Text(
            "STEP 5 OF 5",
            style: TextStyles.policiesBadgeText.copyWith(
              color: CustomColor.colorBE123C,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // (2) Intro heading + paragraph
  // ---------------------------------------------------------------------------
  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Set Your Intimate Desires",
          style: TextStyles.registerTitle.copyWith(fontSize: FontSize.s16),
        ),
        SizedBox(height: ScreenConstant.sizeSmall),
        Text(
          "Choose what you're open to exploring. Preferences power smart "
          "Belgian matchmaking while remaining completely confidential.",
          style: TextStyles.registerFieldNote.copyWith(
            color: CustomColor.color64748B,
              fontSize: FontSize.s16
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // (3) First four data-driven preference cards (a-d)
  // ---------------------------------------------------------------------------
  Widget _buildFirstFourCards() {
    final List<_PrefCardData> cards = [
      _PrefCardData(
        title: "Relationship Preferences",
        subtitle: "What kind of relationship are you looking for?",
        leading: _PrefCardData.iconLeading(Icons.favorite_border_outlined),
        accent: CustomColor.colorBE123C,
        accentBg: CustomColor.colorFFF1F2,
        pillBg: CustomColor.colorFFF1F2,
        pillTextColor: CustomColor.colorBE123C,
        chips: const [
          "One time",
          "Multiple times",
          "In-life friendship",
          "Serious relationship",
          "Other - optional",
        ],
        selected: () => controller.relationshipPrefs,
        onToggle: controller.toggleRelationshipPref,
        expanded: () => controller.relationshipExpanded,
        onToggleExpanded: controller.toggleRelationshipExpanded,
      ),
      _PrefCardData(
        title: "Core Physical & Intimate",
        subtitle: "Essential baseline desires & compatibility",
        leading: _PrefCardData.iconLeading(Icons.favorite_border_outlined),
        accent: CustomColor.colorBE123C,
        accentBg: CustomColor.colorFFF1F2,
        pillBg: CustomColor.colorFFF1F2,
        pillTextColor: CustomColor.colorBE123C,
        chips: const [
          "Anal",
          "Oral",
          "Vaginal",
          "Outdoor",
          "Sensual Tantric",
          "Threesome (FMF/MFM)",
        ],
        selected: () => controller.physicalPrefs,
        onToggle: controller.togglePhysicalPref,
        expanded: () => controller.physicalExpanded,
        onToggleExpanded: controller.togglePhysicalExpanded,
      ),


      _PrefCardData(
        title: "Exploration & Kink",
        subtitle: "Fetishes, roleplay & power dynamics",
        leading: _PrefCardData.iconLeading(Icons.auto_awesome_outlined),
        accent: CustomColor.color9333EA,
        accentBg: CustomColor.colorAF5FF,
        pillBg: CustomColor.colorAF5FF,
        pillTextColor: CustomColor.color9333EA,
        chips: const [
          "Roleplay",
          "Feet",
          "BDSM / Bondage",
          "Sensory Blindfold",
          "Exhibitionism",
        ],
        selected: () => controller.kinkPrefs,
        onToggle: controller.toggleKinkPref,
        expanded: () => controller.kinkExpanded,
        onToggleExpanded: controller.toggleKinkExpanded,
      ),
      _PrefCardData(
        title: "Interests & Passions",
        subtitle: "Select what you enjoy in your free time",
        leading: _PrefCardData.iconLeading(Icons.color_lens_outlined),
        accent: CustomColor.colorBE123C,
        accentBg: CustomColor.colorFFF1F2,
        pillBg: CustomColor.colorFFF1F2,
        pillTextColor: CustomColor.colorBE123C,
        chips: const [
          "Sports",
          "Gaming",
          "Movies",
          "Music",
          "Genres",
          "Drawing / Painting / Art",
          "Other interests",
        ],
        selected: () => controller.interests,
        onToggle: controller.toggleInterest,
        expanded: () => controller.interestsExpanded,
        onToggleExpanded: controller.toggleInterestsExpanded,
      ),
    ];

    return Column(
      children: cards.map(_preferenceCard).toList(),
    );
  }

  Widget _preferenceCard(_PrefCardData d) {
    return Obx(() {
      final bool isExpanded = d.expanded().value;
      final int count = d.selected().length;
      return Container(
        margin: EdgeInsets.only(bottom: ScreenConstant.sizeSmall),
        decoration: BoxDecoration(
          color: CustomColor.colorWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CustomColor.colorE2E8F0, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: d.onToggleExpanded,
          child: Padding(
            padding: EdgeInsets.all(ScreenConstant.sizeMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: d.accentBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: d.leading(d.accent),
                    ),
                    SizedBox(width: ScreenConstant.sizeMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.title,
                            style: TextStyles.registerSectionTitle.copyWith(fontSize: FontSize.s14,color: CustomColor.color0F172A,fontWeight: FontWeight.normal),
                          ),
                          SizedBox(height: 2),
                          Text(
                            d.subtitle,
                            style: TextStyles.registerFieldNote.copyWith(fontSize: FontSize.s11,color: CustomColor.color64748B,fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: ScreenConstant.sizeExtraSmall),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenConstant.sizeSmall,
                        vertical: ScreenConstant.sizeExtraSmall / 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: d.pillBg,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        "$count selected",
                        style: TextStyles.policiesBadgeText.copyWith(
                          color: d.pillTextColor,
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenConstant.sizeExtraSmall),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: CustomColor.color64748B,
                      size: ScreenConstant.smallIconSize,
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  SizedBox(height: ScreenConstant.sizeSmall),
                  Divider(color: CustomColor.colorE2E8F0, thickness: 1),
                  SizedBox(height: ScreenConstant.sizeSmall),
                  Wrap(
                    spacing: ScreenConstant.sizeSmall,
                    runSpacing: ScreenConstant.sizeSmall,
                    children: d.chips
                        .map(
                          (chip) => _selectableChip(
                            chip,
                            d.selected().contains(chip),
                            () => d.onToggle(chip),
                            leading: _chipLeadings[chip],
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // (4) Personal / Safety Information card (bespoke body)
  // ---------------------------------------------------------------------------
  Widget _buildSafetyCard() {
    const List<String> acceptChips = [
      "Protected only (Condom required)",
      "PrEP verified",
      "Regular testing routine",
      "Open to discuss",
    ];
    return Obx(() {
      final bool isExpanded = controller.safetyExpanded.value;
      return Container(
        margin: EdgeInsets.only(bottom: ScreenConstant.sizeSmall),
        decoration: BoxDecoration(
          color: CustomColor.colorWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CustomColor.colorE2E8F0, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: controller.toggleSafetyExpanded,
          child: Padding(
            padding: EdgeInsets.all(ScreenConstant.sizeMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: CustomColor.colorFFF1F2,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.shield_outlined,
                        color: CustomColor.colorBE123C,
                        size: 22,
                      ),
                    ),
                    SizedBox(width: ScreenConstant.sizeMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Personal / Safety Information",
                            style: TextStyles.registerSectionTitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Health transparency and mutual safety standards",
                            style: TextStyles.registerFieldNote,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: ScreenConstant.sizeExtraSmall),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: CustomColor.color64748B,
                      size: ScreenConstant.smallIconSize,
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  SizedBox(height: ScreenConstant.sizeSmall),
                  Divider(color: CustomColor.colorE2E8F0, thickness: 1),
                  SizedBox(height: ScreenConstant.sizeSmall),
                  _label("Able to accept (Requirements & boundary preferences)"),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final chip in acceptChips)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: ScreenConstant.sizeSmall,
                          ),
                          child: _selectableChip(
                            chip,
                            controller.ableToAccept.contains(chip),
                            () => controller.toggleAbleToAccept(chip),
                            leading: _chipLeadings[chip],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                  _label("Has STIs / STDs (Health Transparency)"),
                  Text(
                    "Encouraging open, judgment-free communication and mutual "
                    "sexual health awareness. Can be restricted to mutual "
                    "matches.",
                    style: TextStyles.registerFieldNote,
                  ),
                  SizedBox(height: ScreenConstant.sizeSmall),
                  _equalWidthChipRow(
                    labels: const ['No', 'Yes', 'Prefer not to say'],
                    isSelected: (l) => controller.stiStatus.value == l,
                    onTap: controller.setStiStatus,
                  ),
                  SizedBox(height: ScreenConstant.sizeMedium),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: ScreenConstant.minimumIconSize,
                        color: CustomColor.color475569,
                      ),
                      SizedBox(width: ScreenConstant.sizeExtraSmall),
                      Expanded(
                        child: Text(
                          "Your health disclosures are strictly encrypted and "
                          "protected under Belgian GDPR privacy laws.",
                          style: TextStyles.registerFieldNote,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // (5) Preference Visibility Mode card
  // ---------------------------------------------------------------------------
  Widget _buildVisibilityCard() {
    return Container(
      decoration: BoxDecoration(
        color: CustomColor.colorWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CustomColor.colorE2E8F0, width: 1.5),
      ),
      child: Padding(
        padding: EdgeInsets.all(ScreenConstant.sizeMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: CustomColor.colorFFF1F2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.visibility_outlined,
                    color: CustomColor.colorBE123C,
                    size: 22,
                  ),
                ),
                SizedBox(width: ScreenConstant.sizeMedium),
                Expanded(
                  child: Text(
                    "Preference Visibility Mode",
                    style: TextStyles.registerSectionTitle,
                  ),
                ),
              ],
            ),
            SizedBox(height: ScreenConstant.sizeMedium),
            _visibilityOption(
              title: "Mutual Matches Only",
              subtitle:
                  "Preferences are only revealed when both members match.",
              value: "Mutual Matches Only",
              recommended: true,
            ),
            SizedBox(height: ScreenConstant.sizeSmall),
            _visibilityOption(
              title: "Visible to ID-Verified Belgian Profiles",
              subtitle:
                  "Shown to all verified Belgian members browsing the platform.",
              value: "Visible to ID-Verified Belgian Profiles",
              recommended: false,
            ),
            SizedBox(height: ScreenConstant.sizeMedium),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: ScreenConstant.minimumIconSize,
                  color: CustomColor.color475569,
                ),
                SizedBox(width: ScreenConstant.sizeExtraSmall),
                Expanded(
                  child: Text(
                    "Protected under Belgian GDPR law & End-to-End Vault "
                    "Encryption.",
                    style: TextStyles.registerFieldNote,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _visibilityOption({
    required String title,
    required String subtitle,
    required String value,
    required bool recommended,
  }) {
    return Obx(() {
      final bool isSelected = controller.visibilityMode.value == value;
      return Container(
        decoration: BoxDecoration(
          color: CustomColor.colorWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? CustomColor.colorFECDD3
                : CustomColor.colorE2E8F0,
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => controller.setVisibilityMode(value),
          child: Padding(
            padding: EdgeInsets.all(ScreenConstant.sizeMedium),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 24,
                  width: 24,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CustomColor.colorWhite,
                    border: Border.all(
                      color: isSelected
                          ? CustomColor.colorBE185D
                          : CustomColor.color94A3B8,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            height: 12,
                            width: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: CustomColor.colorBE185D,
                            ),
                          ),
                        )
                      : null,
                ),
                SizedBox(width: ScreenConstant.sizeMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyles.registerSectionTitle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (recommended) ...[
                            SizedBox(width: ScreenConstant.sizeExtraSmall),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ScreenConstant.sizeSmall,
                                vertical: ScreenConstant.sizeExtraSmall / 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: CustomColor.colorECFDF5,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                "Recommended",
                                style: TextStyles.policiesBadgeText.copyWith(
                                  color: CustomColor.color059669,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyles.registerFieldNote,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // (6) Save & Complete Setup button
  // ---------------------------------------------------------------------------
  Widget _buildSaveButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.onSaveCompleteSetup,
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
              "Save & Complete Setup",
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
  // (7) Skip link
  // ---------------------------------------------------------------------------
  Widget _buildSkipLink() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.onSkipIntimateDesires,
      child: Text(
        "Skip for now (configure later in Settings)",
        textAlign: TextAlign.center,
        style: TextStyles.paymentCancelLink,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // (8) Footer security strip
  // ---------------------------------------------------------------------------
  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(ScreenConstant.sizeMedium),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: ScreenConstant.sizeMedium,
        runSpacing: ScreenConstant.sizeExtraSmall,
        children: [
          _footerBadge(
            Icons.visibility_off,
            "Zero Search Indexing",
            CustomColor.colorBE185D,
          ),
          _footerBadge(
            Icons.gavel_outlined,
            "Belgian GDPR",
            CustomColor.colorBE123C,
          ),
          _footerBadge(
            Icons.lock_outline,
            "Vault Encrypted",
            CustomColor.colorBE185D,
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

class _PrefCardData {
  final String title;
  final String subtitle;

  /// Builds the leading glyph shown inside the accent badge. The [accent]
  /// color is passed in so the glyph is tinted to match the card, whether it
  /// is a material [Icon] or an [Image.asset].
  final Widget Function(Color accent) leading;
  final Color accent;
  final Color accentBg;
  final Color pillBg;
  final Color pillTextColor;
  final List<String> chips;
  final RxList<String> Function() selected;
  final void Function(String) onToggle;
  final RxBool Function() expanded;
  final void Function() onToggleExpanded;

  _PrefCardData({
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.accent,
    required this.accentBg,
    required this.pillBg,
    required this.pillTextColor,
    required this.chips,
    required this.selected,
    required this.onToggle,
    required this.expanded,
    required this.onToggleExpanded,
  });

  /// Convenience: a leading built from a material [IconData], tinted with the
  /// card accent.
  static Widget Function(Color) iconLeading(IconData icon) =>
      (Color accent) => Icon(icon, color: accent, size: 22);

  /// Convenience: a leading built from an asset image, tinted with the accent.
  /// Pass [tint] = false for a full-color image that should not be recolored.
  /// Use for a card whose header glyph is a PNG rather than a material icon.
  static Widget Function(Color) assetLeading(
    String assetPath, {
    bool tint = true,
    double size = 22,
  }) =>
      (Color accent) => Image.asset(
            assetPath,
            height: size,
            width: size,
            color: tint ? accent : null,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.image_outlined, color: accent, size: size),
          );
}
