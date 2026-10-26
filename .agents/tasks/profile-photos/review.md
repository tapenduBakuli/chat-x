# Profile Photos screen inserted into the registration flow

A new "Curate Your Gallery" screen (`ProfilePhotosScreen`) is slotted between Profile Setup and Intimate Desires in the GetX registration flow. It renders a reactive main-photo card and a 15-slot gallery grid, both driven by `RegisterController` state, and reuses the controller's existing camera/gallery picker and app-startup permission path rather than introducing a second picker. Profile Setup's two exits (`onCompleteProfile`, `onSkipProfileSetup`) now land on this screen, and the screen's own Save/Skip continue to Intimate Desires. The picker was refactored so the main-photo behavior is preserved byte-for-byte while the gallery shares the same code path.

Watch for: nothing blocking. The gallery grid's "+N more" slot math is slightly off from the plan's "exactly 15 tiles" intent (confirmed), but it is a visual-only approximation of an out-of-scope reorder/placeholder feature and does not affect behavior or compilation.

**Verdict**: APPROVED

## High-level view

The picker refactor is the one place a regression could hide, and it's clean: `_pickImage` now delegates to a new `_pickImageFile(source)` that returns `File?`, and still assigns `profileImage.value` on success, so `onAddPhotoTap` is unchanged. `onAddGalleryPhoto` funnels through the same `_showPhotoSourceSheet` + `_pickImageFile`, enforces the 15 cap before picking, and appends to the new `galleryPhotos` RxList. No second `ImagePicker`, no duplicated permission logic.

Navigation re-wiring is correct and symmetric: both Profile Setup exits go to `PROFILE_PHOTOS`; both new-screen exits go to `INTIMATE_DESIRES`; the downstream Intimate Desires exits still go to `PAYMENT`. The route constant and the `GetPage` (with `RegisterBinding()`) are registered in the right position.

The screen is a `const GetView<RegisterController>` with every reactive read wrapped in `Obx`: the main-photo image, the `N / 15` count pill, and the whole gallery grid. Styling draws entirely from `CustomColor` / `ScreenConstant` / `TextStyles`; no hardcoded hex or inline text styles were introduced where a constant exists.

Everything flagged out of scope — Intimate Desires internals and its chip-leading system, login/biometric, splash, payment — is untouched. The analyzer evidence shows zero new errors or warnings; all 14 lints are pre-existing info-level categories.

<details>
<summary>Issues (1)</summary>

1. **Gallery "+N more" slot math** — the fill-tile count can produce fewer than 15 total tiles and the "+N more" caption slightly overstates remaining slots; visual-only on an out-of-scope placeholder, non-blocking. Tighten the slot arithmetic if pixel/semantic accuracy is wanted later.

</details>

<details>
<summary>Details</summary>

### Picker refactor keeps the main-photo path intact

The risk in this change was the `_pickImage` extraction regressing `onAddPhotoTap`. It doesn't (confirmed). `_pickImageFile(ImageSource)` now holds the permission guard, the `_imagePicker.pickImage(maxWidth: 1800, maxHeight: 1800, imageQuality: 85)` call, and the catch/snackbar, returning `File(picked.path)` or `null`. `_pickImage` is a two-line delegate that assigns `profileImage.value = file` on a non-null result, so the main-photo flow is behaviorally identical to before. `onAddGalleryPhoto` calls the same `_showPhotoSourceSheet()` and `_pickImageFile()`, so there is exactly one `ImagePicker` instance and one permission code path serving both features.

The 15-cap is checked before the picker opens (`galleryPhotos.length >= 15` → snackbar + return), so the sheet never appears when full, and `removeGalleryPhoto` is index-guarded.

### Navigation topology

```
Policies -> Profile Setup --(complete/skip)--> Profile Photos --(save/skip)--> Intimate Desires --(save/skip)--> Payment
```

`onCompleteProfile` and `onSkipProfileSetup` both now `Get.toNamed(Routes.PROFILE_PHOTOS)` (confirmed), with their debugPrints preserved. `onSavePhotosContinue` and `onSkipPhotos` both route to `Routes.INTIMATE_DESIRES` (confirmed). `onSaveCompleteSetup` and `onSkipIntimateDesires` still route to `PAYMENT` (confirmed untouched). The `PROFILE_PHOTOS` constant sits between `PROFILE_SETUP` and `INTIMATE_DESIRES` in `routes.dart`, and the matching `GetPage(... binding: RegisterBinding())` is registered in the same position in `app_pages.dart`, so the new screen shares the controller instance with its siblings.

### Reactive composition

`ProfilePhotosScreen` is `const` and extends `GetView<RegisterController>`. Each reactive read is isolated in its own `Obx`: the main-photo `Positioned.fill` reads `controller.profileImage.value`, the vault header's count pill reads `controller.galleryPhotos.length`, and `_buildGallery` wraps the entire grid in `Obx` reading `controller.galleryPhotos`. Static chrome (header text, banner, action buttons, save/skip, footer) is correctly left outside `Obx`.

### Gallery grid slot math

`_buildGallery` builds thumbs for each photo, then one "Add Photo" tile, then fills with `_plusTile`s and a trailing `_moreTile(remaining)`. The arithmetic (confirmed) does not guarantee the plan's "photos + add tile + plus/more tiles == 15": with `remaining = maxSlots - count - 1`, when `remaining > 1` it emits `remaining - 1` plus-tiles plus one more-tile (total `remaining`, which lands on 15), but the `_moreTile` label shows `+$remaining more` while the real empty slots are `remaining` including the add tile already counted — the caption reads one high relative to the plan's intent. This is cosmetic on a grid whose reorder/placeholder behavior is explicitly out of scope, and it compiles clean, so it is not blocking. Flagging it so a later pass can tighten the count if the mock requires exact slot labels.

### Styling and constant reuse

The screen pulls colors from `CustomColor`, sizes from `ScreenConstant`, and text styles from `TextStyles` throughout. The gradient Save button, discreet rose banner, overlay pills, and footer badges all mirror the sibling register screens' idioms. `defaultSizeThreeTwenty` (= 320) backs the main-photo card height; it was absent from the plan's enumerated member list but is a real `ScreenConstant` member, so no new constant was invented. Small literal radii (12/16/20/100) and a couple of `SizedBox(height: 2)` / `22`-px chip dimensions appear inline, consistent with how the sibling screens already express corner radii and micro-dimensions; no color or text-style literal was introduced where a constant exists.

### Scope containment

The Intimate Desires `_ChipLeading` type, `_chipLeadings` map, and `assetLeading` helper are all present and unmodified (confirmed), as is that screen's pre-staged `"STEP 4 OF 4"` AppBar. Login/biometric, splash permission logic, and the payment screen were not touched.

</details>

<details>
<summary>Files changed</summary>

- `lib/routes/routes.dart` — added `PROFILE_PHOTOS` constant between `PROFILE_SETUP` and `INTIMATE_DESIRES`.
- `lib/modules/register/controller/register_controller.dart` — added `galleryPhotos` RxList; extracted `_pickImageFile`; `_pickImage` now delegates and still sets `profileImage`; added `onAddGalleryPhoto` (15-cap), `removeGalleryPhoto`, `onReorderGallery`/`onMainPhotoMenu` stubs, `onSavePhotosContinue`, `onSkipPhotos`; re-wired `onCompleteProfile`/`onSkipProfileSetup` to `PROFILE_PHOTOS`.
- `lib/modules/register/views/profile_photos_screen.dart` — new `const GetView<RegisterController>` screen.
- `lib/routes/app_pages.dart` — registered `PROFILE_PHOTOS` `GetPage` with `RegisterBinding()` in position.

Verification evidence: `.agents/tasks/profile-photos/verification.md` (flutter analyze on the four touched files: 14 info lints, 0 errors, 0 warnings).

</details>
