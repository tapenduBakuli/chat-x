# Implementation Plan — Profile Preview Screen

## Context & decisions (grounded in the codebase)

- **App stack:** Flutter + GetX (`get: ^4.6.1`). Screens are `GetView<RegisterController>`; routing via `Theme1AppPages.routes` with `GetPage(name, page, binding)`. Verified in `lib/routes/app_pages.dart` and `lib/modules/register/views/*`.
- **No design doc exists** for `profile-preview` (`.agents/tasks/profile-preview` was empty). This plan therefore makes the design decisions, grounded in the two sibling screens read in full: `intimate_desires_screen.dart` and `profile_photos_screen.dart`.
- **This screen is READ-ONLY.** It reuses the existing `RegisterController` (binding `RegisterBinding` already `lazyPut`s it) and only *reads* existing Rx fields. No new input state, no new toggles. All reactive reads wrapped in `Obx`.
- **Decision — skip navigation:** per the task, `onSkipIntimateDesires()` is repointed to `Routes.PROFILE_PREVIEW` (not PAYMENT) so the preview is ALWAYS shown before payment. Recorded here as the chosen resolution.
- **Decision — age computation:** add a `String get previewAge` getter on the controller rather than computing in the view, so the view stays declarative and the "omit age if year null" rule lives in one place. Age = full years from `selectedDobYear/Month/Day` to `DateTime.now()`; returns `''` when `selectedDobYear.value == null`.
- **Decision — location is hidden:** per task, the location row shows the literal "Remains hidden" (muted), NOT `selectedProfileCity`. The raw city is intentionally not surfaced.
- **Decision — gradient button + arrow** is the shared idiom (`colorBE185D -> color581C87`, radius 100, shadow `colorDB2777.withOpacity(0.35)`, trailing `Icons.arrow_forward`); the "Publish Profile" primary button clones `_buildSaveButton` from the siblings verbatim in structure.
- **Decision — hero photo** clones the `DragTarget`/`Stack`/`Obx(profileImage)` idiom from `profile_photos_screen._buildMainPhoto`, but WITHOUT drag/tap editing (read-only): a plain `Obx` of `profileImage.value` with `Image.file` or a gradient placeholder, plus reactive overlay pills.
- **Static/placeholder copy** that has NO backing controller field (Languages, Online Now, Belgian Shield / verified badge, Match Filter, Ultra High discretion, "Tested every 3 months"): render as literal strings AND flag each with a `// PLACEHOLDER:` code comment so a later data wiring pass can find them.

### Member mapping (confirmed names)

Colors (`CustomColor`, from `lib/utils/colors/app_colors.dart`):
- Surfaces/borders: `colorWhite`, `colorF8FAFC`, `colorE2E8F0`, `colorFFF1F2`, `colorFECDD3`, `colorFFE4E6`.
- Rose/brand text & accents: `colorBE123C`, `colorBE185D`, `colorDB2777`, `colorE11D48`.
- Purple accent (kink card idiom): `color9333EA`, `colorAF5FF` (note: value `0xFFFAF5FF`), `color581C87`.
- Green (safety/positive): `color059669`, `colorECFDF5`, `color10B981`.
- Slate text ramp: `color0F172A`, `color334155`, `color475569`, `color64748B`, `color94A3B8`, `color1E293B`.
- Hero placeholder gradient: `color0F172A -> color334155` (same as sibling).
- Gradient button: `colorBE185D -> color581C87`; shadow `colorDB2777`.
- Hero primary pill gradient (sibling "PRIMARY / AVATAR"): `colorEC4899 -> colorBE185D -> color9333EA`.

Sizes (`ScreenConstant`, from `lib/device_manager/screen_constants.dart`):
- Body padding: `EdgeInsets.fromLTRB(defaultWidthTwenty, defaultHeightTen, defaultWidthTwenty, defaultHeightThirty)`.
- Vertical rhythm: `defaultHeightTwentyThree` (section gaps), `defaultHeightThirty`, `defaultHeightFifteen`, `sizeMedium`, `sizeSmall`, `sizeExtraSmall`.
- Icon sizes: `smallIconSize`, `minimumIconSize`, `texIconSize`.
- Button height: `defaultHeightFifty`. Hero height: `defaultSizeThreeTwenty`.
- AppBar avatar: `defaultHeightForty` / `defaultWidthForty`; accent badge 44x44 (literal, matches sibling cards).

Text styles (`TextStyles`, from `lib/utils/TextStyles.dart`):
- Eyebrow / pills / small badges: `policiesBadgeText`.
- Screen title: `registerTitle` (hero/intro uses `.copyWith(fontSize: FontSize.s16/s20)` like siblings).
- Card header title: `registerSectionTitle`.
- Field labels: `registerFieldLabel`.
- Notes / muted body / placeholders: `registerFieldNote` (muted via `color64748B` / `color94A3B8`).
- Primary button label: `loginButtonText`.
- Skip/secondary link: `paymentCancelLink`.
- Footer badges: `registerFooterStrip`.
- "Recommended"/positive pill text: `policiesBadgeText.copyWith(color: color059669)`.

### Controller fields READ by the screen (confirmed in `register_controller.dart`)
`profileNameController` (fallback "Your Name"), `previewAge` (new getter), `selectedGender`, `selectedOrientations`, `aboutMeController` (muted placeholder if empty), `relationshipPrefs`, `physicalPrefs` + `kinkPrefs` (combined), `interests`, `stiStatus`, `visibilityMode`, `profileImage` (`Rx<File?>`), `galleryPhotos` (`RxList<File>`, for "1 / N" counter). Location: literal "Remains hidden" (do NOT read `selectedProfileCity`).

---

## Steps

- [ ] 1. Add the `PROFILE_PREVIEW` route constant.
      Add `static const PROFILE_PREVIEW = '/profile_preview';` to the `Routes` class, placed right after `INTIMATE_DESIRES`.
      Files: `lib/routes/routes.dart`
      Verify: `flutter analyze lib/routes/routes.dart` reports no errors.

- [ ] 2. Add controller navigation + age getter changes.
      In `RegisterController`: (a) repoint `onSaveCompleteSetup()` from `Routes.PAYMENT` to `Routes.PROFILE_PREVIEW`; (b) repoint `onSkipIntimateDesires()` from `Routes.PAYMENT` to `Routes.PROFILE_PREVIEW` (decision: preview always shown); (c) add `void onPublishProfile() { ...debugPrint...; Get.toNamed(Routes.PAYMENT); }`; (d) add `String get previewAge` that returns `''` when `selectedDobYear.value == null`, else the whole-years age computed from day/month/year vs `DateTime.now()` (guard month/day nulls by defaulting to 1). Keep the existing `debugPrint` lines in the two edited methods.
      Files: `lib/modules/register/controller/register_controller.dart`
      Verify: `flutter analyze lib/modules/register/controller/register_controller.dart` reports no errors. Depends on step 1 (uses `Routes.PROFILE_PREVIEW`).

- [ ] 3. Create the Profile Preview screen scaffold + AppBar + body skeleton.
      Create `ProfilePreviewScreen extends GetView<RegisterController>` cloning the sibling `Scaffold`+`AppBar`: leading back arrow -> `controller.onBack`, `centerTitle`, title `Column` with eyebrow line in `TextStyles.policiesBadgeText` (e.g. "STEP 5 OF 5") + title "Profile Preview" in `TextStyles.registerTitle`, trailing `Icons.lock_outline` + circular `person_outline` avatar (same `colorFFF1F2`/`colorFFE4E6` idiom). Body = `SafeArea` > `SingleChildScrollView` with the standard `fromLTRB` padding > `Column(crossAxisAlignment: start)` whose children are the section builder calls added in steps 4–12 (stub each builder to `const SizedBox.shrink()` for now so the file compiles).
      Files: `lib/modules/register/views/profile_preview_screen.dart`
      Verify: `flutter analyze lib/modules/register/views/profile_preview_screen.dart` reports no errors.

- [ ] 4. Build the top eyebrow pill + intro heading.
      Add `_buildTopEyebrow()` (rose pill: `colorFFF1F2` bg, `colorFECDD3` border, two dot markers + "PROFILE SETUP"/"STEP 5 OF 5" in `policiesBadgeText.copyWith(color: colorBE123C)`) cloning `intimate_desires_screen._buildTopEyebrow`, and `_buildIntro()` ("Preview Your Profile" title in `registerTitle.copyWith(fontSize: FontSize.s16)` + muted paragraph in `registerFieldNote.copyWith(color: color64748B)` explaining this is how members see them).
      Files: `lib/modules/register/views/profile_preview_screen.dart`
      Verify: `flutter analyze` on the file passes.

- [ ] 5. Build the "member-view" strip.
      Add `_buildMemberViewStrip()`: a full-width info banner (reuse `colorFFF1F2` bg + `colorFECDD3` border card idiom) with an eye/visibility icon and copy stating this is the read-only member-facing preview. Any status words with no backing field get a `// PLACEHOLDER:` comment.
      Files: `lib/modules/register/views/profile_preview_screen.dart`
      Verify: `flutter analyze` on the file passes.

- [ ] 6. Build the hero photo card with reactive overlays.
      Add `_buildHeroCard()`: a `ClipRRect(radius 20)` over a fixed-height (`defaultSizeThreeTwenty`) `Stack`. `Positioned.fill` wraps `Obx(() => profileImage.value != null ? Image.file(..., fit: cover) : <gradient placeholder color0F172A->color334155 with camera icon + "No photo added">)`. Overlay pills (clone sibling `_overlayPill`): top-left name+age pill driven by `Obx` reading `profileNameController.text` (fallback "Your Name") + `controller.previewAge` (omit ", age" when empty); bottom-left location pill rendering literal "Remains hidden" (`// PLACEHOLDER: location display is intentionally hidden`); top-right a photo counter `Obx(() => "1 / ${galleryPhotos.length + (profileImage.value != null ? 1 : 0)}")` — document the counting choice in a comment; a verified/"Belgian Shield" badge pill with `// PLACEHOLDER: verification status not backed by controller`; an "Online Now" dot pill with `// PLACEHOLDER: presence not backed by controller`. No `DragTarget`/`onTap` — read-only.
      Files: `lib/modules/register/views/profile_preview_screen.dart`
      Verify: `flutter analyze` on the file passes.

- [ ] 7. Build the Privacy & Stealth card.
      Add `_buildPrivacyStealthCard()`: a white rounded card (`colorE2E8F0` border, radius 16) titled "Privacy & Stealth" (`registerSectionTitle`) listing rows: a reactive "Discretion / Visibility" row from `Obx(() => visibilityMode.value)`, and the static "Stealth / Match Filter" and "Ultra High" discretion-level labels. Flag the static ones: `// PLACEHOLDER: "Match Filter" static`, `// PLACEHOLDER: "Ultra High" static`. Use the shared label/value row helper added in step 11.
      Files: `lib/modules/register/views/profile_preview_screen.dart`
      Verify: `flutter analyze` on the file passes.

- [ ] 8. Build the About Me section.
      Add `_buildAboutMe()`: section title "About Me" (`registerSectionTitle`) + `Obx(() { final t = aboutMeController.text.trim(); return Text(t.isEmpty ? "<muted placeholder>" : t, style: registerFieldNote.copyWith(color: t.isEmpty ? color94A3B8 : color475569)); })`. Note: `aboutMeController` is a plain `TextEditingController`, so wrap the read in `Obx` by referencing `controller.aboutMeLength.value` (an existing `RxInt` updated by the controller's listener) to make it reactive, then read `.text`.
      Files: `lib/modules/register/views/profile_preview_screen.dart`
      Verify: `flutter analyze` on the file passes.

- [ ] 9. Build the three chip sections (Seeking/Dynamics, Intimate Desires & Chemistry, Passions & Lifestyle).
      Add a shared read-only chip renderer `_readonlyChips(List<String> labels)` (a `Wrap` of pill containers styled like the selected chip in `intimate_desires_screen._selectableChip` but non-interactive: `colorFFF1F2` bg, `colorBE123C` border/text, `policiesBadgeText`/`registerFieldLabel`; show a muted "None selected" pill when empty), plus `_buildSection(title, count, child)` wrapper. Then add: `_buildSeekingDynamics()` from `Obx(() => relationshipPrefs...)` with "N selected" count; `_buildIntimateChemistry()` from `Obx` combining `physicalPrefs` + `kinkPrefs` into one deduped list; `_buildPassionsLifestyle()` from `Obx(() => interests...)`. This is ONE step covering all three because they share the same renderer.
      Files: `lib/modules/register/views/profile_preview_screen.dart`
      Verify: `flutter analyze` on the file passes.

- [ ] 10. Build the Safety & Standards rows.
      Add `_buildSafetyStandards()`: card titled "Safety & Standards" with a reactive "Sexual Health" row `Obx(() => stiStatus.value)` (map 'No'/'Yes'/'Prefer not to say' to display text as-is), a reactive "Discretion Level" row `Obx(() => visibilityMode.value)`, and a static "Tested every 3 months" row flagged `// PLACEHOLDER: testing cadence static` and a static "Languages" row flagged `// PLACEHOLDER: languages static`. Use the label/value row helper from step 11.
      Files: `lib/modules/register/views/profile_preview_screen.dart`
      Verify: `flutter analyze` on the file passes.

- [ ] 11. Add the shared label/value row helper + card wrapper used by steps 7 and 10.
      Add `_infoRow(IconData icon, String label, String value, {Color? valueColor})` (icon in `color475569`/accent, label in `registerFieldLabel`, value in `registerFieldNote`/`registerSectionTitle`) and `_card({required String title, required Widget child, IconData? icon, Color accent, Color accentBg})` mirroring the 44x44 accent-badge header + white rounded body from `intimate_desires_screen._preferenceCard`. (Implement this before/with steps 7 and 10 — ordering note: this helper is a dependency of 7 and 10; if the coder does 7/10 first, add the helper there.)
      Files: `lib/modules/register/views/profile_preview_screen.dart`
      Verify: `flutter analyze` on the file passes.

- [ ] 12. Build the bottom action row (Edit / Publish) + skip-less footer.
      Add `_buildActionRow()`: a `Row` with a secondary "Edit Profile" outlined button (`colorE2E8F0` border, radius 100, `onTap: controller.onBack`) and the primary gradient "Publish Profile" button (clone `_buildSaveButton`: gradient `colorBE185D->color581C87`, shadow `colorDB2777.withOpacity(0.35)`, `loginButtonText` label + `Icons.arrow_forward`, `onTap: controller.onPublishProfile`). Then add `_buildFooter()` cloning the sibling footer badge `Wrap` (Zero Indexing / Belgian GDPR / Vault Encrypted via `_footerBadge`). Wire all section builders (steps 4–12) into the `Column` from step 3 in top-to-bottom order with `defaultHeightTwentyThree`/`defaultHeightThirty` spacers, replacing the stubs.
      Files: `lib/modules/register/views/profile_preview_screen.dart`
      Verify: `flutter analyze lib/modules/register/views/profile_preview_screen.dart` reports no errors. Depends on step 2 (`onPublishProfile`).

- [ ] 13. Register the screen in app_pages.
      Add `import 'package:chat_x/modules/register/views/profile_preview_screen.dart';` and insert a `GetPage(name: Routes.PROFILE_PREVIEW, page: () => const ProfilePreviewScreen(), binding: RegisterBinding())` entry positioned BETWEEN the `INTIMATE_DESIRES` entry and the `PAYMENT` entry in the `routes` list (note the current list order puts PAYMENT before the profile pages; place the new entry immediately after the `INTIMATE_DESIRES` entry regardless, so the import/route resolve — logical flow is enforced by the controller navigation, not list order).
      Files: `lib/routes/app_pages.dart`
      Verify: `flutter analyze lib/routes/app_pages.dart` reports no errors. Depends on steps 1, 3.

- [ ] 14. Full build/analyze gate for the whole change.
      Run the project analyzer across the register module and the routing files to confirm the new screen, controller edits, routes, and pages all compile together with no warnings/errors introduced.
      Files: (none — verification only)
      Verify: `flutter analyze lib/modules/register lib/routes` completes with "No issues found!" (or no new issues beyond any pre-existing baseline). If a device/emulator is available, optionally run `flutter run` and walk Intimate Desires -> (Save & Complete) -> Profile Preview -> (Publish Profile) -> Payment to confirm navigation.

---

## Full structure of `profile_preview_screen.dart` (reference for the coder)

```
ProfilePreviewScreen (GetView<RegisterController>)
└── Scaffold
    ├── AppBar  [back arrow -> onBack | eyebrow+title column | lock + person avatar]
    └── SafeArea > SingleChildScrollView (fromLTRB 20/10/20/30)
        └── Column(start)
            ├── _buildTopEyebrow()            // rose pill
            ├── _buildIntro()                 // "Preview Your Profile" + note
            ├── _buildMemberViewStrip()       // read-only member-view banner
            ├── _buildHeroCard()              // Obx(profileImage) + overlay pills
            │     • name+age pill  (profileNameController / previewAge)
            │     • location pill  "Remains hidden"   // PLACEHOLDER
            │     • photo counter  "1 / N"  (galleryPhotos)
            │     • Belgian Shield badge              // PLACEHOLDER
            │     • Online Now dot                    // PLACEHOLDER
            ├── _buildPrivacyStealthCard()    // visibilityMode (Obx) + Match Filter/Ultra High // PLACEHOLDER
            ├── _buildAboutMe()               // aboutMeController via aboutMeLength Obx
            ├── _buildSeekingDynamics()       // relationshipPrefs chips + count
            ├── _buildIntimateChemistry()     // physicalPrefs + kinkPrefs chips
            ├── _buildPassionsLifestyle()     // interests chips
            ├── _buildSafetyStandards()       // stiStatus + visibilityMode + Tested/Languages // PLACEHOLDER
            ├── _buildActionRow()             // Edit (onBack) | Publish (onPublishProfile)
            └── _buildFooter()                // footer badges
        shared helpers: _readonlyChips(), _buildSection(), _infoRow(), _card(),
                        _overlayPill(), _footerBadge()
```

## Placeholder/static-copy inventory (each gets a `// PLACEHOLDER:` comment)
- **Languages** — Safety & Standards row (step 10). No controller field.
- **Online Now** — hero presence pill (step 6). No controller field.
- **Belgian Shield / verified badge** — hero verification pill (step 6). No controller field.
- **Match Filter** — Privacy & Stealth card (step 7). No controller field.
- **Ultra High** — Privacy & Stealth discretion level (step 7). No controller field.
- **Tested every 3 months** — Safety & Standards testing cadence (step 10). No controller field.
- **Location "Remains hidden"** — hero location pill (step 6). Intentionally not reading `selectedProfileCity`.

## Open assumptions (reasonable defaults chosen; flagged for the verifier)
- Eyebrow step label uses "STEP 5 OF 5" to match the Intimate Desires sibling; adjust if the design shows a different step index.
- Photo counter counts the hero photo as "1" plus gallery photos; if the design counts only gallery photos, change the expression in step 6.
- "Edit Profile" secondary button routes via `controller.onBack` (returns to Intimate Desires). If the design expects editing a specific earlier screen, add a dedicated handler instead.
```
