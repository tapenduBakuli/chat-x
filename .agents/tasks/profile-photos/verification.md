# Verification — Profile Photos / "Curate Your Gallery" screen

## Command run

```
flutter analyze lib/modules/register/views/profile_photos_screen.dart \
                lib/modules/register/controller/register_controller.dart \
                lib/routes/routes.dart \
                lib/routes/app_pages.dart
```

## Result

`14 issues found. (ran in 1.5s)` — **ZERO errors, ZERO warnings. All 14 are
`info`-level and fall entirely within the acceptable pre-existing categories.**

### Breakdown of the 14 info lints (all acceptable, NOT fixed)

- **5 × `deprecated_member_use` (`withOpacity`)** in
  `profile_photos_screen.dart` (lines 259, 274, 290, 471, 678). This is the
  same `colorXXX.withOpacity(0.xx)` idiom used verbatim across the sibling
  register screens (e.g. the gradient Save button shadow
  `colorDB2777.withOpacity(0.35)` and the dark overlay pills). Explicitly listed
  as an acceptable pre-existing lint that must NOT be fixed.
- **1 × `constant_identifier_names` `INITIAL`** in `app_pages.dart:17` —
  pre-existing, untouched.
- **8 × `constant_identifier_names`** for the SCREAMING_CASE route constants in
  `routes.dart` (`ROOT`, `LOGIN`, `REGISTER`, `PAYMENT`, `POLICIES_AGREEMENT`,
  `PROFILE_SETUP`, `PROFILE_PHOTOS`, `INTIMATE_DESIRES`). The newly added
  `PROFILE_PHOTOS` deliberately mirrors the existing route-name style; this lint
  is explicitly listed as acceptable and must NOT be fixed.

No new errors or warnings were introduced by this change. The full analyzer
output is reproduced below for the reviewer.

```
   info • 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss. • lib/modules/register/views/profile_photos_screen.dart:259:51 • deprecated_member_use
   info • 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss. • lib/modules/register/views/profile_photos_screen.dart:274:58 • deprecated_member_use
   info • 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss. • lib/modules/register/views/profile_photos_screen.dart:290:51 • deprecated_member_use
   info • 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss. • lib/modules/register/views/profile_photos_screen.dart:471:46 • deprecated_member_use
   info • 'withOpacity' is deprecated and shouldn't be used. Use .withValues() to avoid precision loss. • lib/modules/register/views/profile_photos_screen.dart:678:46 • deprecated_member_use
   info • The constant name 'INITIAL' isn't a lowerCamelCase identifier. • lib/routes/app_pages.dart:17:16 • constant_identifier_names
   info • The constant name 'ROOT' isn't a lowerCamelCase identifier. • lib/routes/routes.dart:4:16 • constant_identifier_names
   info • The constant name 'LOGIN' isn't a lowerCamelCase identifier. • lib/routes/routes.dart:5:16 • constant_identifier_names
   info • The constant name 'REGISTER' isn't a lowerCamelCase identifier. • lib/routes/routes.dart:6:18 • constant_identifier_names
   info • The constant name 'PAYMENT' isn't a lowerCamelCase identifier. • lib/routes/routes.dart:7:18 • constant_identifier_names
   info • The constant name 'POLICIES_AGREEMENT' isn't a lowerCamelCase identifier. • lib/routes/routes.dart:8:18 • constant_identifier_names
   info • The constant name 'PROFILE_SETUP' isn't a lowerCamelCase identifier. • lib/routes/routes.dart:9:18 • constant_identifier_names
   info • The constant name 'PROFILE_PHOTOS' isn't a lowerCamelCase identifier. • lib/routes/routes.dart:10:18 • constant_identifier_names
   info • The constant name 'INTIMATE_DESIRES' isn't a lowerCamelCase identifier. • lib/routes/routes.dart:11:18 • constant_identifier_names

14 issues found. (ran in 1.5s)
```

## Files changed

- `lib/routes/routes.dart` — added `PROFILE_PHOTOS` route constant.
- `lib/modules/register/controller/register_controller.dart` — added
  `galleryPhotos` RxList, extracted `_pickImageFile`, added `onAddGalleryPhoto`,
  `removeGalleryPhoto`, `onReorderGallery`, `onMainPhotoMenu`,
  `onSavePhotosContinue`, `onSkipPhotos`; re-wired `onCompleteProfile` and
  `onSkipProfileSetup` to navigate to `PROFILE_PHOTOS`.
- `lib/modules/register/views/profile_photos_screen.dart` — new screen.
- `lib/routes/app_pages.dart` — registered `PROFILE_PHOTOS` GetPage between
  `PROFILE_SETUP` and `INTIMATE_DESIRES`.
