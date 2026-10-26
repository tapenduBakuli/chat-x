# Read-only Profile Preview screen before payment

A new `ProfilePreviewScreen` aggregates everything the member entered across the earlier register steps into a single read-only card, inserted into the flow between Intimate Desires and Payment. It reuses the existing `RegisterController` through `RegisterBinding` and only reads existing Rx fields — no new input state. The two completion handlers (`onSaveCompleteSetup`, `onSkipIntimateDesires`) now land on the preview, and a new `onPublishProfile` carries the user forward to payment. Static mock copy with no backing field (Online Now, Belgian Shield, Match Filter, Ultra High, Languages, testing cadence) is rendered literally and flagged with `// PLACEHOLDER:` comments.

Watch for: nothing blocking. The prior pass's one blocking finding (Discretion row not reading `visibilityMode`) is fixed and verified — the Discretion row is now `Obx`-wrapped on `controller.visibilityMode.value`. All placeholder copy is comment-flagged and invents no controller state. (confirmed)

**Verdict**: APPROVED

## High-level view

The screen is a `const GetView<RegisterController>` and reads controller state directly; every data-driven region (hero background, photo counter, name/age, gender/orientation, About Me, all three chip groups, both safety rows) sits in its own `Obx`, so returning to the preview after an edit reflects the change. Nothing in the body is interactive except the two action buttons: Edit routes through `controller.onBack`, Publish through `controller.onPublishProfile`.

The hero card matches the spec's reactive contract: `Image.file` when `profileImage` is non-null, a dark `color0F172A → color334155` gradient placeholder otherwise, and a photo-count pill computed as `galleryPhotos.length + (profileImage != null ? 1 : 0)` floored at 1. Location is rendered as the literal "Location: Remains hidden" and never touches `selectedProfileCity`.

The controller changes are tightly scoped: the age rule lives in a single `int? get previewAge` getter (null when `selectedDobYear` is unset, so the view omits the age), the two completion handlers repoint to `Routes.PROFILE_PREVIEW` keeping their original `debugPrint` lines, `onPublishProfile` navigates to `Routes.PAYMENT`, and `onClose` is untouched. The STI pill maps No→green, Yes→amber, Prefer-not-to-say→grey, and the Discretion row reflects `visibilityMode`.

Routing adds `Routes.PROFILE_PREVIEW` and a `GetPage` with `RegisterBinding()` registered immediately after the Intimate Desires entry. One note on the registration order below, which is cosmetic and not a defect.

<details>
<summary>Issues (1)</summary>

1. **GetPage not literally between INTIMATE_DESIRES and PAYMENT** — the spec phrasing says "BETWEEN INTIMATE_DESIRES and PAYMENT", but the existing `routes` list places PAYMENT far earlier (right after REGISTER), so the new entry sits last, right after INTIMATE_DESIRES. The plan explicitly chose this (logical flow is enforced by controller navigation, not list order). Non-blocking; flagged only for visibility. (confirmed)

</details>

<details>
<summary>Details</summary>

### Reactive contract and read-only posture

Every data region is wrapped in its own `Obx` and reads an existing field. The hero background reads `profileImage.value`; the photo counter reads `galleryPhotos.length` plus the hero; the identity line reads `profileNameController.text` with the "Your Name" fallback and `previewAge`; gender/orientation reads `selectedGender` and `selectedOrientations`; the three chip groups read `relationshipPrefs`, `physicalPrefs + kinkPrefs`, and `interests`; the safety rows read `stiStatus` and `visibilityMode`. About Me is a plain `TextEditingController`, so the view touches the existing `aboutMeLength` RxInt inside the `Obx` to establish a reactive dependency before reading `.text` — the right way to keep a non-Rx text field reactive without inventing new state.

No chip, row, or pill carries a gesture handler. The only tappable widgets are the Edit button (`controller.onBack`) and the Publish button (`controller.onPublishProfile`), matching the read-only requirement.

### Hero card

The photo-count expression is exactly the spec's: `galleryPhotos.length + (profileImage.value != null ? 1 : 0)`, with `shown = total < 1 ? 1 : total` enforcing the minimum of 1. The displayed string is `"1 / $shown"` — the leading "1" is a fixed current-photo index for the static hero. Location renders the literal "Location: Remains hidden" and does not read `selectedProfileCity`, as required.

### Safety & Standards

The STI pill mapping covers all three cases: `No` → `colorECFDF5`/`color059669` "Negative / Up-to-date", `Yes` → `colorFEF3C7`/`colorD97706` "Positive - disclosed", `Prefer not to say` / default → grey "Not disclosed". The Discretion row — the prior pass's blocking finding — is now `Obx(() => _safetyRow(... subtitle: controller.visibilityMode.value ...))`, so the subtitle tracks the chosen visibility mode. The "Ultra High" grade pill remains static and is comment-flagged as a placeholder, which the spec permits.

### Controller changes

`previewAge` isolates the age rule: returns null when `selectedDobYear` is null (view omits the age), otherwise computes whole years with a month/day guard defaulting to 1 and a birthday-not-yet-reached decrement, floored at 0. `onSaveCompleteSetup` and `onSkipIntimateDesires` now route to `Routes.PROFILE_PREVIEW` while keeping their original `debugPrint` payloads; `onPublishProfile` logs a summary and routes to `Routes.PAYMENT`. `onClose` and every other handler are unchanged, and no new input state was introduced for the data sections.

### Styling and placeholders

Colors, sizes, and text styles come from `CustomColor` / `ScreenConstant` / `TextStyles`. The analyzer ran clean of errors across all four touched files, which confirms every referenced constant resolves. A few raw literals remain for geometry that has no matching constant (border widths of 1/1.5/2, dot sizes of 6, radii 16/20/100, gradient stops) — consistent with how the sibling screens express the same idioms, so not stray hardcoding of theme values. Each static-copy spot (Online Now, verified badge, Belgian Shield, Match Filter, Ultra High, Languages, "Tested every 3 months") carries a `// PLACEHOLDER:` comment and reads no controller field, exactly as the spec requires.

### Verification evidence

The coder's note records `flutter analyze` over the four touched files reporting 13 `info`-level lints and zero errors/warnings. The lints are `withOpacity` deprecations (identical to the sibling screens) and `constant_identifier_names` SCREAMING_CASE on the route constants (matching the existing `Routes` convention the task said to mirror). No new errors, so the no-rebuild constraint is satisfied and there is no articulable doubt requiring a re-run.

</details>

<details>
<summary>File map</summary>

- `lib/modules/register/views/profile_preview_screen.dart` — new read-only `ProfilePreviewScreen extends GetView<RegisterController>`; hero card, member-view strip, privacy/stealth card, About Me, three chip sections, safety rows, Edit/Publish action row, footer.
- `lib/modules/register/controller/register_controller.dart` — repointed `onSaveCompleteSetup`/`onSkipIntimateDesires` to `Routes.PROFILE_PREVIEW`; added `int? get previewAge` and `onPublishProfile()` (→ `Routes.PAYMENT`); `onClose` unchanged.
- `lib/routes/routes.dart` — added `PROFILE_PREVIEW`.
- `lib/routes/app_pages.dart` — imported the screen and registered its `GetPage` with `RegisterBinding()` after the Intimate Desires entry.

</details>
