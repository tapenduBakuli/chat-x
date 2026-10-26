# Implementation Plan — Intimate Desires ("Profile Photos") Screen

Insert a new screen into the registration flow:
`Policies Agreement -> Profile Setup -> Intimate Desires (NEW) -> Payment`.

## Design decisions (made during exploration, with rationale)

- **No new TextStyles, colors, or sizes needed.** I read `lib/utils/TextStyles.dart`,
  `lib/utils/colors/app_colors.dart`, and `lib/device_manager/screen_constants.dart` in full. Every
  style/color/size the spec calls for already exists (policiesBadgeText, registerTitle,
  registerSectionTitle, registerFieldNote, registerFieldLabel, loginButtonText, paymentCancelLink,
  registerFooterStrip, paymentValidFormat; colors colorBE123C, colorBE185D, color581C87, color9333EA,
  colorECFDF5, color059669, color10B981, colorE2E8F0, colorFFF1F2, colorFECDD3, color475569, etc.; sizes
  defaultWidthTwenty, defaultHeightTen/Thirty/Fifty/TwentyThree/Fifteen, sizeSmall/Medium/ExtraSmall,
  smallIconSize, minimumIconSize, defaultHeightForty, defaultWidthForty). Decision: add nothing to those
  three files. This keeps the diff tight and matches the task's "add only if truly missing" constraint.

- **Chip helpers are re-implemented, not imported.** `_selectableChip`, `_equalWidthChipRow`, and `_label`
  in `profile_setup_screen.dart` are PRIVATE instance methods, so they cannot be reused across files.
  Decision: copy their bodies verbatim into the new screen's private helpers. This mirrors the sibling's
  conventions exactly (same colors, radius 10, selected rose border) rather than refactoring shared code
  into a new public util — refactoring is out of scope and would touch profile_setup_screen.dart.

- **Expansion state uses individual RxBool per card** (relationshipExpanded, physicalExpanded,
  kinkExpanded, interestsExpanded, safetyExpanded), not an `RxList<bool>`. Rationale: the five cards are
  heterogeneous (card e has a different body), so index-based list access (policies' pattern) would be
  less readable than named flags. Named flags also match the controller's existing per-field idiom
  (selectedGender, selectedProfileCity are individual Rx fields).

- **Multi-select groups reuse the exact `toggleOrientation` idiom** (`contains ? remove : add` on an
  `RxList<String>`), one list + one toggle method per group. Single-selects (`stiStatus`,
  `visibilityMode`) are `RxString` with a plain setter, mirroring `selectedGender`/`onCountrySelected`.

- **"N selected" pill color.** Default pill = rose family (colorFFF1F2 bg / colorBE123C text, matching the
  selected-chip look). The Exploration & Kink card's pill is purple-tinted (color9333EA text /
  colorAF5FF-or-E9D5FF-tinted bg). Decision: drive the pill accent from a per-card `accent` field in the
  card config struct so the one `_preferenceCard` helper handles both without branching logic.

- **First four cards are data-driven.** Cards a–d share one shape (icon badge, title, subtitle, accent,
  chip list, multi-select list + toggle). Decision: describe them with a small private `_PrefCardData`
  struct + a list, and render with one `_preferenceCard` helper (mirrors how
  `policies_agreement_screen.dart` drives its 7 cards from `_PolicyItemData`). Card e (Personal/Safety) has
  a bespoke body, so it is a separate `_buildSafetyCard` helper that still uses the shared card chrome.

- **Visibility card radios reuse the consent-card idiom** from `policies_agreement_screen.dart`
  (`_consentCheckboxCard`): selected-border (colorFECDD3 when selected, else colorE2E8F0) + a filled inner
  dot (circular, colorBE185D when selected). Adapted from checkbox (square) to radio (circle).

- **AppBar** mirrors `profile_setup_screen.dart` exactly: back arrow -> `controller.onBack`, centered
  Column title ("STEP 4 OF 4" in policiesBadgeText + "Profile Photos" in registerTitle). Spec also asks for
  a leading/trailing lock icon alongside the circular person-outline avatar action; the avatar action block
  is copied verbatim, and a `Icons.lock_outline` (color colorBE123C, size minimumIconSize) is placed in the
  `actions` row just before the avatar.

## Conventions verified by reading files

- `register_controller.dart`: `toggleOrientation`/`toggleLookingFor` use `contains ? remove : add` on
  `RxList<String>`; `selectedGender` is `RxString` with `selectGender` setter; `expandedPolicySections` is
  `RxList<bool>` toggled by index; `onCompleteProfile()` and `onSkipProfileSetup()` both currently
  `debugPrint` then `Get.toNamed(Routes.PAYMENT)`; `onInit` adds the about-me listener; `onClose` disposes
  all `TextEditingController`s. No new controllers are introduced here, so `onClose` is untouched.
- `profile_setup_screen.dart`: const constructor; Scaffold+AppBar structure; body is
  `SafeArea > SingleChildScrollView` with padding `EdgeInsets.fromLTRB(defaultWidthTwenty,
  defaultHeightTen, defaultWidthTwenty, defaultHeightThirty)`, `Column(crossAxisAlignment: stretch)`;
  `_selectableChip` (radius 10, selected = colorFFF1F2 fill + colorBE123C border),
  `_equalWidthChipRow` (Expanded chips with sizeSmall gaps), `_buildCompleteButton` (gradient
  colorBE185D->color581C87, radius 100, colorDB2777 shadow, arrow_forward), `_buildSkipLink`
  (paymentCancelLink), `_buildFooter`/`_footerBadge`.
- `policies_agreement_screen.dart`: `_PolicyItemData` struct + `List.generate` card rendering;
  `_consentCheckboxCard` selected-border + inner-indicator idiom; card radius 16, border colorE2E8F0
  width 1.5; chevron `keyboard_arrow_up`/`keyboard_arrow_down`.
- `app_pages.dart`: `Theme1AppPages.routes` list; every register page uses `binding: RegisterBinding()`.
- `register_binding.dart`: `Get.lazyPut<RegisterController>`.
- `routes.dart`: `class Routes` with static const string names.
- Toolchain verified: `flutter 3.47.6` / `dart 3.13.5` present on PATH. There are NO existing tests and no
  `test/` dir, so verification is `flutter analyze` (static) + a release-mode `flutter build` to confirm it
  compiles. (A widget-test harness for a GetX+Obx+image_picker+permission_handler screen would require
  non-trivial mocking that is out of scope for this UI task.)

---

# Implementation Plan

- [ ] 1. Add the route constant.
      Add `static const INTIMATE_DESIRES = '/intimate_desires';` to class `Routes`, below
      `PROFILE_SETUP`.
      Files: lib/routes/routes.dart
      Verify: `flutter analyze lib/routes/routes.dart` — no new errors (constant resolves).

- [ ] 2. Add all new controller state and handlers to `RegisterController`.
      This is ONE cohesive edit. Add, following existing idioms:
      - Expansion flags (default all true): `final RxBool relationshipExpanded = true.obs;`
        `physicalExpanded`, `kinkExpanded`, `interestsExpanded`, `safetyExpanded` (same pattern).
      - Toggle methods: `toggleRelationshipExpanded()`, `togglePhysicalExpanded()`,
        `toggleKinkExpanded()`, `toggleInterestsExpanded()`, `toggleSafetyExpanded()` — each flips its
        RxBool (`x.value = !x.value`).
      - Multi-select lists with defaults:
        `relationshipPrefs = <String>['One time'].obs`,
        `physicalPrefs = <String>['Anal','Oral','Vaginal'].obs`,
        `kinkPrefs = <String>['Roleplay'].obs`,
        `interests = <String>['Gaming','Music'].obs`,
        `ableToAccept = <String>['Protected only (Condom required)'].obs`.
      - Toggle methods for each (copy the `toggleOrientation` body shape):
        `toggleRelationshipPref`, `togglePhysicalPref`, `toggleKinkPref`, `toggleInterest`,
        `toggleAbleToAccept`.
      - Single-selects: `final RxString stiStatus = 'No'.obs;` with `void setStiStatus(String v)`;
        `final RxString visibilityMode = 'Mutual Matches Only'.obs;` with
        `void setVisibilityMode(String v)`.
      - Handlers:
        `void onSaveCompleteSetup()` -> `debugPrint('Save & Complete -> relationship: ..., physical: ...,
        kink: ..., interests: ..., ableToAccept: ..., sti: ${stiStatus.value}, visibility:
        ${visibilityMode.value}')` then `Get.toNamed(Routes.PAYMENT);`
        `void onSkipIntimateDesires()` -> `debugPrint('Skip intimate desires'); Get.toNamed(Routes.PAYMENT);`
      - Do NOT add TextEditingControllers, so leave `onClose()` and `onInit()` unchanged.
      Files: lib/modules/register/controller/register_controller.dart
      Verify: `flutter analyze lib/modules/register/controller/register_controller.dart` — no errors.

- [ ] 3. Re-wire Profile Setup navigation to the new screen.
      In the same controller, change `onCompleteProfile()` and `onSkipProfileSetup()` to
      `Get.toNamed(Routes.INTIMATE_DESIRES)` instead of `Routes.PAYMENT` (keep their debugPrints). Leave
      `onMoreInfoTap` and every other handler untouched.
      Files: lib/modules/register/controller/register_controller.dart
      Verify: `flutter analyze lib/modules/register/controller/register_controller.dart` — no errors;
      confirm both methods now reference `Routes.INTIMATE_DESIRES`.

- [ ] 4. Create the Intimate Desires screen with its full helper structure.
      Create `class IntimateDesiresScreen extends GetView<RegisterController>` with
      `const IntimateDesiresScreen({super.key})`. Imports: screen_constants.dart, register_controller.dart,
      TextStyles.dart, app_colors.dart, flutter/material.dart, get/get.dart (match sibling import style).
      Structure (private helpers, mirroring the sibling's abstraction level):
      - `build`: Scaffold + AppBar (back arrow -> controller.onBack; centered Column title "STEP 4 OF 4"
        policiesBadgeText + "Profile Photos" registerTitle; actions = `Icons.lock_outline` (colorBE123C,
        minimumIconSize) then the circular person-outline avatar container copied from
        profile_setup_screen.dart). Body = `SafeArea > SingleChildScrollView` with padding
        `EdgeInsets.fromLTRB(defaultWidthTwenty, defaultHeightTen, defaultWidthTwenty,
        defaultHeightThirty)`, `Column(crossAxisAlignment: stretch)` with the ordered children below,
        separated by `SizedBox(height: defaultHeightTwentyThree)`.
      - Copied private helpers (verbatim bodies from profile_setup_screen.dart):
        `_label`, `_selectableChip`, `_equalWidthChipRow`.
      - `_buildTopEyebrow()`: rose dot (6x6 circle colorBE123C) + "PROFILE SETUP - STEP 5 OF 5"
        (policiesBadgeText; override color to colorBE123C via copyWith).
      - `_buildIntro()`: title "Set Your Intimate Desires" (registerTitle) + muted paragraph
        "Choose what you're open to exploring. Preferences power smart Belgian matchmaking while remaining
        completely confidential." (registerFieldNote, color via copyWith color475569).
      - `_PrefCardData` struct (private, bottom of file): `title, subtitle, icon, accent (Color), accentBg
        (Color), pillBg (Color), pillTextColor (Color), chips (List<String>)` + accessors for the matching
        RxList and toggle via function fields (`RxList<String> Function() selected`,
        `void Function(String) onToggle`, `RxBool Function() expanded`,
        `void Function() onToggleExpanded`).
      - `_buildFirstFourCards()`: builds a `List<_PrefCardData>` for cards a–d (data below) and maps each
        through `_preferenceCard`.
      - `_preferenceCard(_PrefCardData d)`: `Obx`-wrapped white card (radius 16, border colorE2E8F0 1.5):
        header Row [rounded-square icon badge (44x44, radius 12, bg d.accentBg, Icon color d.accent),
        Expanded Column(title registerSectionTitle, subtitle registerFieldNote), "N selected" pill
        (bg d.pillBg, text d.pillTextColor, count = d.selected().length), chevron up/down driven by
        d.expanded()]. Tapping header -> d.onToggleExpanded(). When expanded: Divider(colorE2E8F0) + a
        `Wrap(spacing/runSpacing sizeSmall)` of `_selectableChip(chip, d.selected().contains(chip),
        () => d.onToggle(chip))`.
      - `_buildSafetyCard()`: same card chrome (shield icon, rose accent) but bespoke `Obx` body:
        (i) sub-label "Able to accept (Requirements & boundary preferences)" (registerFieldLabel) + Wrap of
        `_selectableChip` over ["Protected only (Condom required)","PrEP verified","Regular testing
        routine","Open to discuss"] bound to `ableToAccept`/`toggleAbleToAccept`;
        (ii) sub-label "Has STIs / STDs (Health Transparency)" + helper text (registerFieldNote) +
        `_equalWidthChipRow(labels: ['No','Yes','Prefer not to say'], isSelected: (l) =>
        controller.stiStatus.value == l, onTap: controller.setStiStatus)`;
        (iii) a Row with `Icons.lock_outline` + note "Your health disclosures are strictly encrypted and
        protected under Belgian GDPR privacy laws." (registerFieldNote).
      - `_buildVisibilityCard()`: white card; header `Icons.visibility_outlined` + "Preference Visibility
        Mode" (registerSectionTitle). Two `_visibilityOption` rows (Obx), single-select on
        `controller.visibilityMode`: "Mutual Matches Only" (+ green "Recommended" pill using colorECFDF5
        bg / color059669 text) with its description, and "Visible to ID-Verified Belgian Profiles" with
        its description. `_visibilityOption` renders the consent-card idiom: selected-border colorFECDD3
        else colorE2E8F0, circular radio with inner colorBE185D dot when selected, tap -> setVisibilityMode.
        Below the two options: a Row `Icons.lock_outline`/`Icons.shield_outlined` + note "Protected under
        Belgian GDPR law & End-to-End Vault Encryption." (registerFieldNote).
      - `_buildSaveButton()`: clone `_buildCompleteButton` (gradient colorBE185D->color581C87, radius 100,
        colorDB2777 shadow 0.35, height defaultHeightFifty) with label "Save & Complete Setup" +
        `Icons.arrow_forward`, onTap -> controller.onSaveCompleteSetup.
      - `_buildSkipLink()`: clone sibling; text "Skip for now (configure later in Settings)"
        (paymentCancelLink), onTap -> controller.onSkipIntimateDesires.
      - `_buildFooter()`/`_footerBadge()`: clone sibling; three badges "Zero Search Indexing"
        (Icons.visibility_off, colorBE185D), "Belgian GDPR" (Icons.gavel_outlined, colorBE123C),
        "Vault Encrypted" (Icons.lock_outline, colorBE185D).
      Card data (a–d):
        a. "Relationship Preferences" / "What kind of relationship are you looking for?" /
           Icons.favorite / rose accent (colorBE123C, bg colorFFF1F2, pill rose) /
           chips ["One time","Multiple times","In-life friendship","Serious relationship",
           "Other - optional"] / relationshipPrefs + toggleRelationshipPref + relationshipExpanded.
        b. "Core Physical & Intimate" / "Essential baseline desires & compatibility" / Icons.favorite /
           rose / ["Anal","Oral","Vaginal","Outdoor","Sensual Tantric","Threesome (FMF/MFM)"] /
           physicalPrefs + togglePhysicalPref + physicalExpanded.
        c. "Exploration & Kink" / "Fetishes, roleplay & power dynamics" / Icons.auto_awesome /
           PURPLE accent (color9333EA, bg colorAF5FF, pill bg colorAF5FF / text color9333EA) /
           ["Roleplay","Feet","BDSM / Bondage","Sensory Blindfold","Exhibitionism"] /
           kinkPrefs + toggleKinkPref + kinkExpanded.
        d. "Interests & Passions" / "Select what you enjoy in your free time" / Icons.auto_awesome /
           rose accent (warm badge bg colorFFF1F2) /
           ["Sports","Gaming","Movies","Music","Genres","Drawing / Painting / Art","Other interests"] /
           interests + toggleInterest + interestsExpanded.
      Wrap every reactive subtree in `Obx`. Use CustomColor/ScreenConstant/TextStyles only — no raw hex,
      no raw sizes, no inline TextStyle where a constant exists.
      Files: lib/modules/register/views/intimate_desires_screen.dart
      Verify: `flutter analyze lib/modules/register/views/intimate_desires_screen.dart` — no errors
      (depends on steps 1 & 2 for Routes.INTIMATE_DESIRES and the new controller members).

- [ ] 5. Register the screen in app_pages between PROFILE_SETUP and PAYMENT.
      Add `import 'package:chat_x/modules/register/views/intimate_desires_screen.dart';` and insert
      `GetPage(name: Routes.INTIMATE_DESIRES, page: () => const IntimateDesiresScreen(), binding:
      RegisterBinding())` into `Theme1AppPages.routes` positioned after the PROFILE_SETUP page (the PAYMENT
      page already sits earlier in the list, so position relative to PROFILE_SETUP is what matters for
      readability).
      Files: lib/routes/app_pages.dart
      Verify: `flutter analyze lib/routes/app_pages.dart` — no errors; import and GetPage resolve.

- [ ] 6. Full static analysis + compile check of the whole app.
      Files: (none — verification only)
      Verify: `flutter analyze` passes with no new errors across the project, then
      `flutter build apk --debug` (or `flutter build ios --no-codesign --debug` on this macOS host)
      completes successfully, confirming the new screen, controller changes, routes, and pages all compile
      and wire together. Manually confirm the flow intent: Profile Setup's Complete/Skip now route to
      INTIMATE_DESIRES, and the new screen's Save/Skip route to PAYMENT.

## Known gaps / assumptions

- The AppBar title reads "STEP 4 OF 4" while the in-body eyebrow reads "PROFILE SETUP - STEP 5 OF 5" —
  this inconsistency is taken verbatim from the spec (two stitched screenshots) and reproduced as-is rather
  than reconciled.
- Purple pill background uses `colorAF5FF` (0xFFFAF5FF, the existing purple-tint in app_colors.dart). If the
  implementer finds it too faint against white, `colorE9D5FF` is the alternative already in the palette; no
  new color is added either way.
- No automated widget test is added: there is no existing test harness, and the screen depends on GetX
  bindings plus platform plugins (image_picker/permission_handler via the shared controller) that would
  need mocking. Verification relies on `flutter analyze` + a debug build, consistent with the rest of this
  UI-only module.
