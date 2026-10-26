# Implementation Plan — Profile Setup screen + navigation wiring

## Context the coder must reuse (verified by reading the files)

### Project / build
- Flutter + GetX (`get: ^4.6.1`). Pattern: `class XxxScreen extends GetView<RegisterController>` with `const XxxScreen({super.key})`.
- Build/analyze verification command: `flutter analyze` (expect "No issues found!" for the touched files). Full build: `flutter build apk --debug` or run the app. There are no unit tests for the register module (grep found none), so verification is static analysis + manual nav walk-through.
- All view files are self-contained with private `_buildXxx()` helpers and a small private data class at the bottom (see `_PolicyItemData` in `policies_agreement_screen.dart`).

### Imports every register view uses (copy verbatim)
```dart
import 'package:chat_x/device_manager/screen_constants.dart';
import 'package:chat_x/modules/register/controller/register_controller.dart';
import 'package:chat_x/utils/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';
```
(Drop `custom_text_field.dart` import only if CustomTextField ends up unused — it IS used here, so keep it. Do NOT import `universal_button.dart`; the gradient button is hand-built, see below.)

### Exact CustomColor members available (lib/utils/colors/app_colors.dart) — do NOT hardcode hex
- Accent gradient (required by spec): `CustomColor.colorBE185D` → `CustomColor.color581C87`.
- Rose/pink family: `colorBE123C`, `colorE11D48`, `colorDB2777`, `colorBE185D`, `colorFFF1F2`, `colorFFE4E6`, `colorFECDD3`, `colorFCE7F3`, `colorFDF2F8`, `colorFEF2F2`.
- Green (for "OK"/"Hidden"/"Remains Hidden" pills): `color059669`, `color047857`, `color10B981`, `colorECFDF5`.
- Neutrals: `colorWhite`, `color0F172A`, `color334155`, `color1E293B`, `color475569`, `color64748B`, `color94A3B8`, `colorE2E8F0`, `colorF1F5F9`, `colorF8FAFC`.
- Red asterisk / warning: `colorEF4444`.
- NOTE: there is NO dedicated green-background constant like `colorDCFCE7`. For the green "Pseudonym OK" / "Remains Hidden" pills use background `CustomColor.colorECFDF5` (light green already in palette) with text/icon `CustomColor.color059669` and (if a border is wanted) `CustomColor.color10B981.withOpacity(0.3)` or `colorE2E8F0`. Do NOT add a new color unless genuinely needed; if one is, add it in the `//chat_x register` block following the `colorXXXXXX = const Color(0xFFXXXXXX)` naming.

### Exact ScreenConstant members to use (lib/device_manager/screen_constants.dart) — do NOT hardcode sizes
- Spacing/padding: `sizeExtraSmall` (5), `sizeDefault` (8), `sizeSmall` (10), `sizeSmallHighest` (12), `sizeMedium` (15), `sizeLarge` (20), `sizeMidLarge` (25).
- Heights/widths used in register screens: `defaultHeightFifty` (field/button height), `defaultHeightForty`/`defaultWidthForty` (circular appbar avatar), `defaultHeightThirty`/`defaultWidthThirty`, `defaultHeightTwentyThree` (section gaps), `defaultHeightTen`, `defaultHeightFifteen`, `defaultHeightThirty`, `defaultWidthTwenty` (horizontal page padding), `defaultSizeOneTwenty` (120 — use for the ~120px add-photo circle), `defaultHeightOneHundred`.
- Icons: `smallIconSize` (20), `minimumIconSize` (15), `texIconSize` (30).
- `FontSize.s9..s39` for one-off font sizes (e.g. `FontSize.s14`, `FontSize.s10`).
- These are mutable `static double` fields set at runtime by `ScreenConstant.setScreenAwareConstant`; reference them, never redefine.

### Exact TextStyles available (lib/utils/TextStyles.dart) — reuse, do not invent inline TextStyle where one fits
- App bar title: `TextStyles.registerAppBarTitle`.
- Field label: `TextStyles.registerFieldLabel`. Red asterisk ` *`: `TextStyles.registerVerifyNoteHighlight` (color `colorEF4444`).
- Helper/caption under fields: `TextStyles.registerFieldNote` (grey, s11). Body/notes: `TextStyles.registerTrialBody`, `TextStyles.policiesItemBody`.
- Section/large title: `TextStyles.registerTitle` (s24) or `TextStyles.policiesHeaderTitle` (s22). Centered screen title "Profile Setup" — use `TextStyles.registerAppBarTitle` in the AppBar (mirrors other screens).
- Small caps badge/pill text: `TextStyles.policiesBadgeText` (rose, bold s11), `TextStyles.policiesPillText`, `TextStyles.paymentEncryptedBadge` (s9 caps), `TextStyles.registerSupportedLabel` (grey caps s10, letterSpacing). Use `policiesBadgeText` for "STEP 3 OF 4" and the "100% DISCREET & PROTECTED" pill text.
- Green status pill text (Pseudonym OK / Remains Hidden): `TextStyles.paymentValidFormat` (green s11 w600) or `TextStyles.registerZeroRisk` (green bold s11).
- Button label: `TextStyles.loginButtonText` (white bold s16) — used inside the gradient button.
- Footer strip text: `TextStyles.registerFooterStrip`.
- Chip/selectable text: there is NO dedicated chip style; use `TextStyles.registerFieldLabel` (unselected) and for a selected rose variant use `TextStyles.registerFieldLabel.copyWith(color: CustomColor.colorBE123C)` or `TextStyles.loginButtonText.copyWith(color: CustomColor.colorWhite)` depending on fill. Keep it consistent across all chip groups.
- Dropdown item text: `TextStyles.loginTopText.copyWith(fontSize: FontSize.s14)` (exact pattern used in `_buildCountryField`).
- If a genuinely new style is needed (e.g. a "profileSetupStepLabel"), add it to TextStyles.dart under a new `// ------------------------- profile setup -------------------------` section following the `static TextStyle get profileSetupXxx => TextStyle(... fontFamily: "Liberation" ...)` naming. Prefer reusing the styles above; only add if none fits.

### CustomTextField call signature (lib/utils/custom_text_field.dart)
Named params: `controller`, `hintText`, `prefix` (Widget), `suffix` (Widget), `obscureText`, `keyboardType`, `maxLines` (default 1), `textAlign`, `fillColor`, `borderColor`, `borderRadius` (default 16), `textStyle`, `hintStyle`, `contentPadding`. The field already has `maxLength`? NO — CustomTextField does NOT expose `maxLength` or an onChanged-driven counter param. For the About Me field (needs maxLength 500 + live counter) use CustomTextField with `maxLines: 5` and `onChanged`? NOTE: CustomTextField has NO `onChanged`-only counter and NO `maxLength`. Decision: for About Me, EITHER (a) use CustomTextField with `maxLines: 5` plus add a listener on `aboutMeController` in the controller for the counter and rely on it (no hard 500 cap enforced by the widget), OR (b) use a plain `TextField` with `maxLength: 500`, `maxLines: 5`, `buildCounter: (_, {required currentLength, maxLength, required isFocused}) => null` to hide the default counter, styled to match (fill `CustomColor.colorF8FAFC`, rounded `OutlineInputBorder` radius 16, hint `TextStyles.loginFieldHint`). **Chosen approach: (b) plain `TextField`** because it enforces the 500 cap the spec requires and the spec explicitly allows "CustomTextField (or TextField)". Drive the "0 / 500" counter from controller state (see controller step).
- Standard single-line field pattern (reuse from payment screen `_buildTextField`): wrap in `SizedBox(height: ScreenConstant.defaultHeightFifty)`, `borderRadius: 26`, `borderColor: CustomColor.colorE2E8F0`, `hintStyle: TextStyles.loginTopText.copyWith(fontSize: FontSize.s14)`.

### Gradient "Agree & Continue" button pattern to copy for "Complete Profile →" (from `_buildSubmitButton` in policies_agreement_screen.dart)
`GestureDetector(onTap: ...)` → `Container`/`AnimatedContainer(height: ScreenConstant.defaultHeightFifty, decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), gradient: const LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [CustomColor.colorBE185D, CustomColor.color581C87]), boxShadow: [BoxShadow(color: CustomColor.colorDB2777.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 6))]))` with a centered `Row` of `Text("Complete Profile", style: TextStyles.loginButtonText.copyWith(color: CustomColor.colorWhite))` + `SizedBox(width: sizeSmall)` + `Icon(Icons.arrow_forward, color: colorWhite, size: smallIconSize)`. The profile button is always enabled (no `isAllConsentAgreed` guard here).

### Footer security strip pattern to copy (from `_buildFooterSecurityStrip` + `_footerSecurityBadge`)
`Container(padding: EdgeInsets.all(sizeMedium), decoration: BoxDecoration(color: colorF8FAFC, borderRadius: BorderRadius.circular(12), border: Border.all(color: colorE2E8F0, width: 1)))` wrapping a `Wrap(alignment: WrapAlignment.center, spacing: sizeMedium, runSpacing: sizeExtraSmall, children: [...])` of badge rows: `Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: minimumIconSize - 2, color: color), SizedBox(width: sizeExtraSmall), Text(text, style: TextStyles.registerFooterStrip)])`. Badges required: "Zero Indexing" (e.g. `Icons.visibility_off` / `color: CustomColor.colorBE185D`) and "Belgian GDPR Protected" (e.g. `Icons.gavel_outlined` / `CustomColor.colorBE123C`).

### AppBar actions (circular person-outline avatar) pattern to mirror (from policies_agreement_screen.dart `actions`)
`Container(height: defaultHeightForty, width: defaultWidthForty, padding: EdgeInsets.all(sizeSmall), margin: EdgeInsets.only(right: sizeMedium), decoration: BoxDecoration(shape: BoxShape.circle, color: colorFFF1F2, border: Border.all(color: colorFFE4E6, width: 2)), child: Icon(Icons.person_outline, color: colorE11D48, size: smallIconSize - 2))`. Leading back arrow: `GestureDetector(behavior: HitTestBehavior.opaque, onTap: controller.onBack, child: Icon(Icons.arrow_back_ios_new, size: smallIconSize, color: color0F172A))`. AppBar `backgroundColor: colorWhite, elevation: 0`.

### Exact CURRENT bodies that change
`onAgreeAndContinue()` current:
```dart
void onAgreeAndContinue() {
  if (isAllConsentAgreed) {
    debugPrint('All consents agreed. Navigating to payment...');
    Get.toNamed(Routes.PAYMENT);
  }
}
```
`onClose()` current disposes 13 controllers (email, password, confirmPassword, cardNumber, expiry, cvc, promo, accountHolder, iban, bic, street, postalCode, city) then `super.onClose()`.

### app_pages.dart insertion point
`Theme1AppPages.routes` list order today is: ROOT, LOGIN, REGISTER, PAYMENT, POLICIES_AGREEMENT. The new `GetPage` for PROFILE_SETUP must be added "between the policies and payment entries" per spec — i.e. after the POLICIES_AGREEMENT GetPage block (list order is cosmetic; place it adjacent to POLICIES_AGREEMENT). Add the import `import 'package:chat_x/modules/register/views/profile_setup_screen.dart';` alongside the other register view imports.

---

# Implementation Plan

- [ ] 1. Add the PROFILE_SETUP route constant.
      Add `static const PROFILE_SETUP = '/profile_setup';` to class `Routes`, directly after the `POLICIES_AGREEMENT` line, matching the existing indentation/style.
      Files: lib/routes/routes.dart
      Verify: `flutter analyze lib/routes/routes.dart` — no issues; constant resolves when referenced in later steps.

- [ ] 2. Extend RegisterController with Profile Setup state and handlers.
      Add two controllers `final TextEditingController profileNameController = TextEditingController();` and `final TextEditingController aboutMeController = TextEditingController();`. Add Rx state: `final RxString selectedGender = 'Woman'.obs;` with `void selectGender(String g) => selectedGender.value = g;`; DOB `final RxnInt selectedDobDay = RxnInt(); final RxnInt selectedDobMonth = RxnInt(); final RxnInt selectedDobYear = RxnInt();` with setters `setDobDay/Month/Year(int?)`; orientation `final RxList<String> selectedOrientations = <String>['Straight', 'Open-minded'].obs;` with `void toggleOrientation(String o){ selectedOrientations.contains(o) ? selectedOrientations.remove(o) : selectedOrientations.add(o);}`; location `final RxString selectedProfileCity = 'Brussels / Bruxelles (1000)'.obs;` plus a static `final List<String> belgianCities = const ['Brussels / Bruxelles (1000)', 'Antwerp / Antwerpen (2000)', 'Ghent / Gent (9000)', 'Liège (4000)', 'Bruges / Brugge (8000)', 'Namur (5000)'];` and `void onProfileCitySelected(String c) => selectedProfileCity.value = c;`; looking-for `final RxList<String> selectedLookingFor = <String>['Intimate connection', 'Discreet exploration'].obs;` with `void toggleLookingFor(String v){...}` (same toggle shape); counter `final RxInt aboutMeLength = 0.obs;`. In `onInit()` (add the override if absent) attach `aboutMeController.addListener(() => aboutMeLength.value = aboutMeController.text.length);`. Add handlers: `onAddPhotoTap()` → `debugPrint('Add photo tapped');`; `onCompleteProfile()` → debugPrint the collected state (gender, dob, orientations, city, lookingFor, name, aboutMe length) then `Get.toNamed(Routes.PAYMENT);`; `onSkipProfileSetup()` → `debugPrint('Skip profile setup'); Get.toNamed(Routes.PAYMENT);`. In `onClose()` add `profileNameController.dispose();` and `aboutMeController.dispose();` alongside the existing disposes (before `super.onClose()`).
      Files: lib/modules/register/controller/register_controller.dart
      Verify: `flutter analyze lib/modules/register/controller/register_controller.dart` — no issues; all new members compile and `RxnInt`/`RxList` imports come from `get`.

- [ ] 3. Change the policies navigation target.
      In `onAgreeAndContinue()` change `Get.toNamed(Routes.PAYMENT);` to `Get.toNamed(Routes.PROFILE_SETUP);` (keep the `if (isAllConsentAgreed)` guard and the debugPrint, update the debugPrint text to say navigating to profile setup).
      Files: lib/modules/register/controller/register_controller.dart
      Verify: `flutter analyze` on the controller — no issues; reference to `Routes.PROFILE_SETUP` (from step 1) resolves.

- [ ] 4. Create the ProfileSetupScreen view file (STEP 3 OF 4) with all 13 sections.
      Create `class ProfileSetupScreen extends GetView<RegisterController>` with `const ProfileSetupScreen({super.key})`, using the imports block above. Scaffold with AppBar (white, elevation 0, back arrow → `controller.onBack`, title Row with a small label; put centered "Profile Setup" title using `TextStyles.registerAppBarTitle`, and the circular person-outline action mirroring policies screen). Body: `SafeArea` → `SingleChildScrollView(padding: EdgeInsets.fromLTRB(defaultWidthTwenty, defaultHeightTen, defaultWidthTwenty, defaultHeightThirty))` → `Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [...])` with `SizedBox(height: defaultHeightTwentyThree)` gaps between sections. Build these private helpers, each returning one section, in order:
      (1) `_buildStepHeader()` — "STEP 3 OF 4" in accent (`policiesBadgeText`) + centered "Profile Setup".
      (2) `_buildDiscreetBadge()` — rose pill `Container` (color `colorFFF1F2`, radius 100, border `colorFECDD3`) with `Icon(Icons.shield_outlined, color: colorBE123C)` + Text "100% DISCREET & PROTECTED" (`policiesBadgeText`).
      (3) `_buildAddPhoto()` — centered `GestureDetector(onTap: controller.onAddPhotoTap)` with a `Stack`: a ~120px (`defaultSizeOneTwenty`) circle with dashed/outlined border (use `BoxDecoration(shape: BoxShape.circle, border: Border.all(color: colorFECDD3, width: 2))`; a true dashed ring is optional — a solid rose ring is acceptable and avoids a new dependency) containing a camera `Icon` + "ADD PHOTO" text, plus a small camera FAB badge `Positioned` bottom-right (rose circle with `Icons.photo_camera`), and caption "Photos can be blurred or hidden anytime." below (`registerFieldNote`).
      (4) `_buildProfileName()` — label row "Profile Name" + red ` *` (`registerVerifyNoteHighlight`) + Spacer + green "Pseudonym OK" pill (bg `colorECFDF5`, text `paymentValidFormat`); CustomTextField bound to `controller.profileNameController`, hint "e.g. Alex_BXL or VelvetMystique" (reuse the payment `_buildTextField` wrapper style: SizedBox height `defaultHeightFifty`, borderRadius 26, borderColor `colorE2E8F0`); helper caption "This is your public display name. Never use your real legal name." (`registerFieldNote`).
      (5) `_buildGender()` — label "Gender" + red ` *`; `Obx` → Row of 3 single-select chips [Woman, Man, Non-binary] via a shared `_selectableChip(label, selected, onTap)` helper; selected = `controller.selectedGender.value == label`, onTap `controller.selectGender(label)`. Selected chip: rose fill `colorFFF1F2` + border `colorBE123C` + text `colorBE123C`; unselected: white fill + border `colorE2E8F0` + text `color334155`.
      (6) `_buildDob()` — label "Date of Birth / Age Verification" + red ` *`; Row of 3 dropdowns (Day 1–31, Month 1–12, Year e.g. 1950..current-18) each wrapped like the payment `_buildCountryField` dropdown container (fill `colorF8FAFC`, radius 26, border `colorE2E8F0`), bound to `controller.selectedDobDay/Month/Year` via `Obx` + `DropdownButtonHideUnderline`; caption "Only your calculated age (e.g. 28) will be displayed. Your exact birth date remains completely hidden." (`registerFieldNote`).
      (7) `_buildOrientation()` — label "Orientation" + red ` *`; `Obx` → `Wrap` of MULTI-select chips [Straight, Bisexual, Gay / Lesbian, Pansexual, Open-minded] using `_selectableChip` where selected = `controller.selectedOrientations.contains(label)`, onTap `controller.toggleOrientation(label)`.
      (8) `_buildLocationCard()` — `Container` card (white, radius 16, border `colorE2E8F0`) with a header Row: `Icon(Icons.location_on_outlined, color: colorBE123C)` + "Belgian Location" (`registerSectionTitle`) + Spacer + green "Remains Hidden" pill (bg `colorECFDF5`, text `paymentValidFormat`); a dropdown bound to `controller.selectedProfileCity` over `controller.belgianCities` (same dropdown container pattern); privacy note "Privacy Shield Active: Exact GPS coordinates were not captured. Other members only see broad distance estimates (e.g. '~12 km away')." (`registerFieldNote` or `policiesItemBody`).
      (9) `_buildLookingFor()` — label "Looking for" + grey "(Select multiple)" hint (`registerOptional`); `Obx` → `Wrap` of MULTI-select chips [Intimate connection, Casual dating, Discreet exploration, Regular meetups, Deep friendship] via `_selectableChip`, selected = `controller.selectedLookingFor.contains(label)`, onTap `controller.toggleLookingFor(label)`.
      (10) `_buildAboutMe()` — label row "About Me / Desires" + Spacer + `Obx(() => Text('${controller.aboutMeLength.value} / 500', style: registerFieldNote))`; a plain multiline `TextField` bound to `controller.aboutMeController` with `maxLength: 500, maxLines: 5, buildCounter: (...) => null`, hint "Share a bit about your desires, personality, or what brings you to ChatX...", styled with fill `colorF8FAFC`, `OutlineInputBorder` radius 16 border `colorE2E8F0`, hint style `loginFieldHint`.
      (11) `_buildCompleteButton()` — the gradient button (pattern above) → `controller.onCompleteProfile`, label "Complete Profile" + `Icons.arrow_forward`.
      (12) `_buildSkipLink()` — centered `GestureDetector(onTap: controller.onSkipProfileSetup)` with Text "Skip for now & browse members" (`paymentCancelLink`).
      (13) `_buildFooter()` — footer strip (pattern above) with badges "Zero Indexing" and "Belgian GDPR Protected".
      Add a shared private `_selectableChip(String label, bool selected, VoidCallback onTap)` helper and a private `_label(String text, {bool required, Widget? trailing})` helper mirroring the payment screen's `_label`. All selection UI wrapped in `Obx`. Keep the file self-contained; add a small private data class only if it reduces duplication (optional).
      Files: lib/modules/register/views/profile_setup_screen.dart
      Verify: `flutter analyze lib/modules/register/views/profile_setup_screen.dart` — "No issues found!"; file compiles against the controller members added in step 2.

- [ ] 5. Register the route in app_pages.dart.
      Add `import 'package:chat_x/modules/register/views/profile_setup_screen.dart';` with the other register view imports. Add `GetPage(name: Routes.PROFILE_SETUP, page: () => const ProfileSetupScreen(), binding: RegisterBinding())` to `Theme1AppPages.routes`, placed adjacent to the POLICIES_AGREEMENT entry (between policies and payment per spec).
      Files: lib/routes/app_pages.dart
      Verify: `flutter analyze lib/routes/app_pages.dart` — no issues; `const ProfileSetupScreen()` and `Routes.PROFILE_SETUP` resolve.

- [ ] 6. Whole-flow verification.
      Run `flutter analyze` across the project and confirm no new issues in the touched files. Then manually (or via `flutter run`) walk: Register → Continue → Policies → check all 5 consents → Agree & Continue now opens Profile Setup (not Banking & Payment); on Profile Setup, Complete Profile → and Skip both navigate to Payment (Banking & Payment); back arrow pops correctly.
      Files: (none modified) — verification only.
      Verify: `flutter analyze` — no new issues; manual nav walk-through matches the described flow Policies → Profile Setup → Payment.

## Notes / assumptions recorded
- CustomTextField exposes no `maxLength`/counter, so About Me uses a plain `TextField` (spec explicitly permits "or TextField") to enforce the 500 cap; the "0 / 500" counter is driven by `aboutMeLength` updated via an `aboutMeController` listener in `onInit`.
- No existing dedicated green-pill background constant; reuse `colorECFDF5` + `color059669`. Add a new CustomColor only if the coder finds it visually necessary, following the existing `//chat_x register` naming.
- A true dashed photo-ring would need a custom painter or a new package; a solid rose ring is used to avoid adding a dependency, keeping the look consistent with the pink accent. Revisit only if the mock strictly requires dashes.
- The "Complete Profile" button has no enablement guard (unlike policies), per spec it always calls `onCompleteProfile()`.
- No existing tests for the register module; verification is `flutter analyze` + manual navigation. If the coder prefers, a lightweight widget test could be added, but it is not required by the project's current conventions.

## Verification note (coder)
- Command run: `flutter analyze lib/modules/register/views/profile_setup_screen.dart lib/modules/register/controller/register_controller.dart lib/routes/routes.dart lib/routes/app_pages.dart`
- Result: 9 issues found, all `info` level, zero errors/warnings. All are pre-existing project conventions, not new regressions:
  - `deprecated_member_use` for `withOpacity` (2 in profile_setup_screen.dart) — mirrors the exact pattern already used in policies_agreement_screen.dart and payment_details_screen.dart (green-pill border + gradient button shadow).
  - `constant_identifier_names` for UPPER_CASE route constants (ROOT, LOGIN, REGISTER, PAYMENT, POLICIES_AGREEMENT, PROFILE_SETUP, INITIAL) — `PROFILE_SETUP` follows the established naming of every other route in `Routes`.
- Confirmed by reading final code:
  (a) `onAgreeAndContinue()` navigates to `Routes.PROFILE_SETUP` (guard `if (isAllConsentAgreed)` kept).
  (b) `onCompleteProfile()` navigates to `Routes.PAYMENT`.
  (c) `GetPage(name: Routes.PROFILE_SETUP, ...)` registered in app_pages.dart between POLICIES_AGREEMENT and the list end.
  (d) `profileNameController` and `aboutMeController` disposed in `onClose()`.
