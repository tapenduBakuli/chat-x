# Implementation Plan — Profile Photos / "Curate Your Gallery" screen

Insert a new screen into the registration flow:
`Policies Agreement -> Profile Setup -> Profile Photos (NEW) -> Intimate Desires -> Payment`.

All four touched areas (new screen, controller, routes, pages) share one GetX
controller (`RegisterController`) via `RegisterBinding()`, exactly like every
sibling register screen.

---

## Design decisions (made during exploration, grounded in the codebase)

- **Reuse the existing picker, do not reimplement.** `RegisterController` already
  has `_showPhotoSourceSheet()`, `_pickImage(source)`, `_ensurePermission`,
  `_resolve`, `_isAllowed`, `_showPermissionDeniedSnack`, a single
  `ImagePicker _imagePicker`, and `Rx<File?> profileImage`. The gallery feature
  must route through the SAME chooser and permission path. Decision: extract a
  `Future<File?> _pickImageFile(ImageSource source)` that returns the picked
  `File?` (moving the try/permission/`_imagePicker.pickImage(maxWidth:1800,
  maxHeight:1800, imageQuality:85)` body out of `_pickImage`), then have
  `_pickImage` delegate (assign to `profileImage`) and `onAddGalleryPhoto` append
  to `galleryPhotos`. This keeps `onAddPhotoTap`/`profileImage` behavior byte-for-byte
  identical while sharing one code path. Rationale: avoids a second `ImagePicker`
  or duplicated permission logic, which the task forbids.

- **AppBar is cloned from `intimate_desires_screen.dart`, not `profile_setup_screen.dart`.**
  The intimate screen's AppBar is the richer one the spec wants: back arrow +
  centered title Column + trailing `lock_outline` icon + circular person-outline
  avatar. Note: that file's AppBar literally already reads `"STEP 4 OF 4"` /
  `"Profile Photos"` (the user pre-staged those strings there). The NEW screen
  must own that exact AppBar block with those exact strings. Do NOT edit
  `intimate_desires_screen.dart` — leave its AppBar as-is (its internals are
  out of scope).

- **Gallery state is `RxList<File> galleryPhotos`, capped at 15.** A plain
  reactive list mirrors the existing `RxList<String>` groups in the controller
  (`selectedOrientations`, etc.). The grid, the "N / 15" pill, and the fill
  tiles all derive from `galleryPhotos.length` inside `Obx`.

- **Overlay chips, 3-dot menu, Focus Mode, empty "+" tiles, "+N more", and the
  reorder caption/button are visual-only.** Spec says drag-reorder is out of
  scope. `onReorderGallery()` and `onMainPhotoMenu()` are `debugPrint` stubs.
  Tapping the main photo card, every Add/"+"/"+N more" tile, and the Upload/
  Camera buttons all funnel into the one picker entry points
  (`onAddPhotoTap` for the main photo, `onAddGalleryPhoto` for gallery).

- **No new constants or assets needed.** Every `CustomColor`, `ScreenConstant`,
  `TextStyles`, and `FontSize` member the screen uses already exists (verified
  below). No pubspec change (`assets/images/` already declared). The screen uses
  only material icons.

---

## Verified existing members (coder: use these names verbatim; do NOT invent)

**CustomColor** (`lib/utils/colors/app_colors.dart`) — all confirmed present:
`colorWhite`, `color0F172A`, `color334155`, `color475569`, `color64748B`,
`color94A3B8`, `colorE2E8F0`, `colorF8FAFC`, `colorFFF1F2`, `colorFECDD3`,
`colorFFE4E6`, `colorBE123C`, `colorBE185D`, `color581C87`, `colorDB2777`,
`colorEC4899`, `colorF43F5E`, `color9333EA`, `colorE11D48`, `colorEF4444`,
`colorECFDF5`, `color10B981`, `color059669`, `colorAF5FF` (= `0xFFFAF5FF`).

**TextStyles** (`lib/utils/TextStyles.dart`) — all confirmed present (all are
getters, use `TextStyles.<name>`): `policiesBadgeText`, `registerTitle`,
`registerSectionTitle`, `registerFieldLabel`, `registerFieldNote`,
`registerFooterStrip`, `loginButtonText`, `paymentCancelLink`,
`registerVerifyNoteHighlight` (the red-asterisk style — color `colorEF4444`).

**ScreenConstant** (`lib/device_manager/screen_constants.dart`) — confirmed:
`defaultWidthTwenty`, `defaultWidthTen`, `defaultWidthThirty`, `defaultWidthForty`,
`defaultHeightTen`, `defaultHeightThirty`, `defaultHeightForty`,
`defaultHeightFifteen`, `defaultHeightFifty`, `defaultHeightTwentyThree`,
`defaultSizeOneTwenty`, `defaultSizeOneTen`, `sizeExtraSmall`, `sizeSmall`,
`sizeMedium`, `smallIconSize`, `minimumIconSize`, `texIconSize`. `FontSize.s11`
… `s24` all exist (use `FontSize.s16`/`s20` to enlarge the header title).

**MISSING constants: NONE.** Nothing new to add in app_colors / screen_constants
/ TextStyles. If, while coding, you believe one is genuinely missing, STOP and
re-check this list first — the needed member almost certainly already exists
under a slightly different name.

**Required-asterisk idiom** (from `profile_setup_screen.dart` `_label`):
`Text(" *", style: TextStyles.registerVerifyNoteHighlight)`.

**Gradient button idiom** (identical in both siblings — clone exactly):
`GestureDetector(onTap: ...)` wrapping a `Container(height: defaultHeightFifty,
decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), gradient:
LinearGradient(begin: centerLeft, end: centerRight, colors: [colorBE185D,
color581C87]), boxShadow: [BoxShadow(color: colorDB2777.withOpacity(0.35),
blurRadius: 20, offset: Offset(0,6))]))` with a centered `Row` of white
`loginButtonText` label + `SizedBox(width: sizeSmall)` + `Icon(Icons.arrow_forward,
color: colorWhite, size: smallIconSize)`.

**Discreet banner palette** (from `_buildDiscreetBadge`): bg `colorFFF1F2`,
border `colorFECDD3`, accent `colorBE123C`.

**Footer idiom** (`_buildFooter`/`_footerBadge`): `Wrap(alignment: center,
spacing: sizeMedium, runSpacing: sizeExtraSmall)` of `_footerBadge(icon, text,
color)` rows; badge = `Icon(size: minimumIconSize - 2, color)` +
`SizedBox(width: sizeExtraSmall)` + `Text(text, style: registerFooterStrip)`.

---

## Build / test / verification commands (discovered)

This is a Flutter app (`pubspec.yaml`, SDK `^3.13.5`, uses `get`, `image_picker`,
`permission_handler`). There is NO AGENTS.md / CONTRIBUTING / `.kiro/steering`.
Lints come from `flutter_lints: ^6.0.0` via `analysis_options.yaml`.

- Static analysis (primary gate): `flutter analyze`
- Compile sanity (optional, slower): `flutter build apk --debug` or
  `flutter build ios --no-codesign` — not required if analyze is clean.

**Acceptable pre-existing lints — do NOT fix these:** `withOpacity`
deprecation, SCREAMING_CASE route-name constant lints, `unnecessary_underscores`,
and the unused `assetLeading` helper in `intimate_desires_screen.dart`.
**Gate: ZERO NEW errors** on the touched files after the change.

There is no unit-test harness for these UI screens in the repo, and the task is
visual/navigational; `flutter analyze` is the verification of record.

---

# Implementation steps (ordered by dependency)

- [ ] 1. Add the route constant.
      Add `static const PROFILE_PHOTOS = '/profile_photos';` to `class Routes`,
      placed right after the `PROFILE_SETUP` line (keep the file's existing
      indentation style). This must exist before the controller references it.
      Files: `lib/routes/routes.dart`
      Verify: `flutter analyze lib/routes/routes.dart` — no new errors.

- [ ] 2. Add gallery state + refactor the picker + add handlers in the controller.
      In `RegisterController`:
      (a) Add field near `profileImage`: `final RxList<File> galleryPhotos = <File>[].obs;`
      (b) Extract `Future<File?> _pickImageFile(ImageSource source) async` holding
          the current body of `_pickImage` (the `_ensurePermission`/
          `_showPermissionDeniedSnack` guard, the `try/catch`, and
          `_imagePicker.pickImage(source: source, maxWidth: 1800, maxHeight: 1800,
          imageQuality: 85)`), but RETURN `File(picked.path)` (or `null`) instead
          of assigning `profileImage`. Keep the same catch + `Get.snackbar('Could
          not add photo', ...)`.
      (c) Rewrite `_pickImage(source)` to `final f = await _pickImageFile(source);
          if (f != null) profileImage.value = f;` — preserving `onAddPhotoTap`
          behavior exactly.
      (d) Add `Future<void> onAddGalleryPhoto() async`: if
          `galleryPhotos.length >= 15` call
          `Get.snackbar('Limit reached', 'You can add up to 15 photos.',
          snackPosition: SnackPosition.BOTTOM)` and `return;` else
          `final source = await _showPhotoSourceSheet(); if (source == null)
          return; final f = await _pickImageFile(source); if (f != null)
          galleryPhotos.add(f);`
      (e) Add `void removeGalleryPhoto(int index) { if (index >= 0 && index <
          galleryPhotos.length) galleryPhotos.removeAt(index); }`
      (f) Add `void onReorderGallery() => debugPrint('Reorder gallery tapped');`
      (g) Add `void onMainPhotoMenu() => debugPrint('Main photo menu tapped');`
      (h) Add `void onSavePhotosContinue() { debugPrint('Save photos -> main: ...
          gallery: ${galleryPhotos.length}'); Get.toNamed(Routes.INTIMATE_DESIRES); }`
      (i) Add `void onSkipPhotos() { debugPrint('Skip photos'); Get.toNamed(
          Routes.INTIMATE_DESIRES); }`
      (j) RE-WIRE navigation: in `onCompleteProfile()` change the final
          `Get.toNamed(Routes.INTIMATE_DESIRES)` to `Get.toNamed(
          Routes.PROFILE_PHOTOS)` (keep the debugPrint). In `onSkipProfileSetup()`
          change `Get.toNamed(Routes.INTIMATE_DESIRES)` to `Get.toNamed(
          Routes.PROFILE_PHOTOS)` (keep the debugPrint).
      Do NOT touch `onSaveCompleteSetup`/`onSkipIntimateDesires` (stay -> PAYMENT),
      nor any login/biometric/splash/payment/chip-leading code. No new
      `TextEditingController`, so `onClose()` is unchanged.
      Files: `lib/modules/register/controller/register_controller.dart`
      Depends on: step 1.
      Verify: `flutter analyze lib/modules/register/controller/register_controller.dart`
      — no new errors.

- [ ] 3. Create the new screen file.
      Create `class ProfilePhotosScreen extends GetView<RegisterController>` with
      `const ProfilePhotosScreen({super.key})`. Imports (match sibling style):
      `package:chat_x/device_manager/screen_constants.dart`,
      `dart:io`, `package:chat_x/modules/register/controller/register_controller.dart`,
      `package:flutter/material.dart`, `package:get/get.dart`,
      `../../../utils/TextStyles.dart`, `../../../utils/colors/app_colors.dart`.
      Body = `Scaffold(appBar: ..., body: SafeArea(SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(defaultWidthTwenty, defaultHeightTen,
      defaultWidthTwenty, defaultHeightThirty), child: Column(crossAxisAlignment:
      start, children: [... private _build helpers ...]))))`.
      Build these sections top-to-bottom, each as a private `_build…`/helper,
      wrapping EVERY reactive piece in `Obx`:

      1. **AppBar** — clone the `intimate_desires_screen.dart` AppBar verbatim:
         `elevation: 0`; leading `GestureDetector(onTap: controller.onBack,
         child: Icon(Icons.arrow_back_ios_new, size: smallIconSize, color:
         color0F172A))`; `centerTitle: true`; title `Column` with
         `Text("STEP 4 OF 4", style: policiesBadgeText)` + `Text("Profile Photos",
         style: registerTitle)`; actions = `Icon(Icons.lock_outline, size:
         smallIconSize, color: color94A3B8)`, `SizedBox(width: defaultWidthTen)`,
         then the circular avatar `Container(height: defaultHeightForty, width:
         defaultWidthForty, margin: right sizeMedium, decoration: circle, color
         colorFFF1F2, border colorFFE4E6 width 2, child: Icon(Icons.person_outline,
         color: colorE11D48, size: smallIconSize - 2))`.

      2. **Header** — `Text("Curate Your Gallery", style:
         registerTitle.copyWith(fontSize: FontSize.s20))`; muted paragraph
         `Text("Your primary photo appears in verified searches. Add up to 15
         gallery moments in your personal vault.", style:
         registerFieldNote.copyWith(color: color64748B))`; then the rose banner:
         `Container(decoration: bg colorFFF1F2, border colorFECDD3,
         borderRadius 12/16)` with a `Row(crossAxisAlignment: start)` of
         `Icon(Icons.shield_outlined, color: colorBE123C, size: minimumIconSize+?)`
         + `Expanded(RichText/Text.rich)` where the lead-in "100% Discreet &
         Protected:" is bold `colorBE123C` and the remainder "Photos can be
         masked, blurred, or locked in your vault anytime." is normal
         `registerFieldNote`.

      3. **Main Profile Photo** — label row: `Row` of `Text("Main Profile Photo",
         style: registerFieldLabel)` + `Text(" *", style:
         registerVerifyNoteHighlight)` + `Spacer()` + a gradient pill
         `Container(gradient LinearGradient([colorEC4899, colorBE185D,
         color9333EA]) or [colorEC4899, color9333EA], radius 100)` with white
         `policiesBadgeText` "PRIMARY / AVATAR". Below: `Obx(() { final photo =
         controller.profileImage.value; return GestureDetector(onTap:
         controller.onAddPhotoTap, child: ClipRRect(radius ~20, child:
         AspectRatio(aspectRatio: 3/4) OR SizedBox(height ~ defaultSizeThreeTwenty)
         with a Stack))); })`. Stack layers:
         - base: `photo != null ? Image.file(photo, fit: BoxFit.cover,
           width/height double.infinity)` : placeholder `Container(color
           color0F172A tint or soft gradient)` centered `Column(Icon(
           Icons.photo_camera, color: colorWhite/color94A3B8) + Text("Add main
           photo"))`.
         - `Positioned(top-left)` dark pill "Main Feature" (`Icons.star`, white
           text) via `_overlayPill`.
         - `Positioned(top-right)` 3-dot in dark translucent circle:
           `GestureDetector(onTap: controller.onMainPhotoMenu, child: Container(
           circle, color: color0F172A.withOpacity(…), child:
           Icon(Icons.more_vert, color: colorWhite)))`.
         - `Positioned(bottom-left)` dark pill "Hold & Drag"
           (`Icons.drag_handle`).
         - `Positioned(bottom-right)` light pill "Focus Mode" (bg colorWhite,
           dark text).
         Add a private `_overlayPill({IconData icon, String label, Color bg,
         Color fg})` helper for these.

      4. **Personal Vault Gallery header** — `Text("Personal Vault Gallery",
         style: registerSectionTitle)` + `Text("Private photos shared selectively
         or upon mutual match.", style: registerFieldNote)`, with a right-aligned
         rose pill (bg colorFFF1F2, text colorBE123C `policiesBadgeText`) showing
         `Obx(() => Text("${controller.galleryPhotos.length} / 15"))`.

      5. **Gallery grid** — `Obx(() { final photos = controller.galleryPhotos;
         final count = photos.length; final remaining = 15 - count; ... })` build
         a `GridView.count(crossAxisCount: 3, shrinkWrap: true, physics:
         NeverScrollableScrollPhysics(), mainAxisSpacing: sizeSmall,
         crossAxisSpacing: sizeSmall, childAspectRatio: 1, children: tiles)`.
         Tiles, capped so total == 15:
         - For each photo index i: `_galleryThumb(i, photos[i])` =
           `Stack(ClipRRect(radius ~12, Image.file(cover)); Positioned top-left
           dark "#${i+1}" pill; Positioned top-right GestureDetector(onTap: () =>
           controller.removeGalleryPhoto(i), child: white circle with
           Icon(Icons.close, size small)))`.
         - One "Add Photo" tile `_addTile()` = dashed/outlined rose
           (`DottedBorder` not available → use `Container` with
           `Border.all(color: colorFECDD3)` + rose tint) with `Icon(
           Icons.photo_camera_outlined, color: colorBE123C)` + "Add Photo" +
           small "Slot ${count + 1}" caption; `onTap: controller.onAddGalleryPhoto`.
         - Fill the rest up to 15 with grey outlined `_plusTile()` (
           `Icon(Icons.add, color: color94A3B8)`, border colorE2E8F0,
           `onTap: controller.onAddGalleryPhoto`). When `remaining` is large,
           the LAST fill tile is a rose-tinted `_moreTile(remaining)` showing
           "+$remaining more" / "up to 15 slots" (`onTap:
           controller.onAddGalleryPhoto`). Compute slot math so
           `photos + 1 add tile + plus/more tiles == 15` and never exceed 15 (if
           count >= 15, show only the 15 thumbs, no add/plus tiles).
         Below the grid: a caption `Row(Icon(Icons.swap_vert / Icons.open_with,
         color: color94A3B8) + Text("Drag & drop photos to reorder slots.",
         style: registerFieldNote))`. (Static — reorder is out of scope.)

      6. **Action buttons row** — `Row` of three outlined pills
         `_actionButton(icon, label, onTap)`
         (`Container` border colorE2E8F0, radius 100, Row(Icon + label
         registerFieldLabel)): "Upload" (`Icons.file_upload_outlined`) ->
         `controller.onAddGalleryPhoto`; "Camera" (`Icons.photo_camera_outlined`)
         -> `controller.onAddGalleryPhoto`; "Reorder" (`Icons.swap_vert`) ->
         `controller.onReorderGallery`. Use `Expanded` for equal widths with
         `SizedBox(width: sizeSmall)` gaps.

      7. **Save & Continue** — the cloned gradient button (`_buildSaveButton`)
         label "Save & Continue", `onTap: controller.onSavePhotosContinue`.

      8. **Skip link** — centered `GestureDetector(onTap: controller.onSkipPhotos,
         child: Text("Skip photo upload for now", textAlign: center, style:
         paymentCancelLink))`.

      9. **Footer** — clone `_buildFooter`/`_footerBadge`: badges "Zero Indexing"
         (`Icons.visibility_off`, colorBE185D) and "Belgian GDPR Protected"
         (`Icons.gavel_outlined`, colorBE123C).

      Separate sections with `SizedBox(height: defaultHeightTwentyThree)` and use
      `defaultHeightThirty` before the Save button, matching the sibling spacing.
      Keep the file self-contained; no new assets; material icons only.
      Files: `lib/modules/register/views/profile_photos_screen.dart` (new)
      Depends on: steps 1 and 2 (references `controller.galleryPhotos`,
      `onAddGalleryPhoto`, `removeGalleryPhoto`, `onReorderGallery`,
      `onMainPhotoMenu`, `onSavePhotosContinue`, `onSkipPhotos`,
      `onAddPhotoTap`, `profileImage`).
      Verify: `flutter analyze lib/modules/register/views/profile_photos_screen.dart`
      — no new errors.

- [ ] 4. Register the page in the GetX route table.
      In `Theme1AppPages.routes`, add
      `import 'package:chat_x/modules/register/views/profile_photos_screen.dart';`
      and insert `GetPage(name: Routes.PROFILE_PHOTOS, page: () => const
      ProfilePhotosScreen(), binding: RegisterBinding())` BETWEEN the
      `PROFILE_SETUP` and `INTIMATE_DESIRES` entries.
      Files: `lib/routes/app_pages.dart`
      Depends on: steps 1 and 3.
      Verify: `flutter analyze lib/routes/app_pages.dart` — no new errors.

- [ ] 5. Full-project analysis gate.
      Run `flutter analyze` on the whole project and confirm there are ZERO NEW
      errors introduced by this change. Pre-existing info/warning lints
      (`withOpacity` deprecation, SCREAMING_CASE route-name lints,
      `unnecessary_underscores`, the unused `assetLeading` helper in
      `intimate_desires_screen.dart`) are acceptable and must NOT be fixed.
      If a `.dart_tool`/package resolution error appears, run `flutter pub get`
      first, then re-run `flutter analyze`.
      Files: none (verification only).
      Depends on: steps 1-4.
      Verify: `flutter analyze` completes with no new errors on the four touched
      files.

---

## Out of scope / do NOT touch
- `intimate_desires_screen.dart` internals (and its AppBar — leave as-is).
- `onSaveCompleteSetup` / `onSkipIntimateDesires` (keep -> PAYMENT).
- login/biometric modules, splash permission logic, payment screen,
  the chip-leading `_ChipLeading`/`_chipLeadings` system.
- `pubspec.yaml` (assets already declared), `app_colors.dart`,
  `screen_constants.dart`, `TextStyles.dart` (no missing members).
- No new `TextEditingController` (so `onClose()` stays unchanged).

## Known gaps / assumptions
- Mock dimensions (card aspect ratio, exact overlay positions) are approximated
  from the spec (3:4 card, radius ~20 / thumbs radius ~12). Reasonable values are
  fine; pixel-perfect match is not required for this step.
- "PRIMARY / AVATAR" pill gradient: use pink->purple
  (`colorEC4899 -> colorBE185D -> color9333EA`) matching the add-photo ring in
  `profile_setup_screen.dart`.
