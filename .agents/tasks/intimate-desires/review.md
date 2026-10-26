# Intimate Desires screen inserted into the registration flow

A new `IntimateDesiresScreen` is wired between Profile Setup and Payment in the chat_x GetX registration flow (`Policies -> Profile Setup -> Intimate Desires -> Payment`). The screen is a `const GetView<RegisterController>` presenting a step AppBar, eyebrow pill, intro, five collapsible preference cards (four data-driven, one bespoke Safety card), a visibility-mode radio card, a gradient Save button, a skip link, and footer badges. All new reactive state (per-card expansion flags, multi-select chip groups, two single-selects) lives on `RegisterController`, each reactive subtree is wrapped in `Obx`, and navigation was re-pointed so Profile Setup's complete/skip now land on this screen while this screen's save/skip continue to Payment. The implementation reuses existing `CustomColor`/`ScreenConstant`/`TextStyles` members and clones the sibling screen's chip/button/footer idioms verbatim.

Watch for: the two intentional spec-mandated inconsistencies — AppBar reads "STEP 4 OF 4" / "Profile Photos" while the body eyebrow reads "PROFILE SETUP - STEP 5 OF 5" and the heading reads "Set Your Intimate Desires" (confirmed; copied from the two stitched screenshots per the plan's Known gaps). No blocking issues found.

**Verdict**: APPROVED

## High-level view

The screen matches the spec section by section. The AppBar carries the back-to-`controller.onBack` leading arrow, the STEP/title Column, and an actions row with a lock icon preceding the circular person-outline avatar. The first four preference cards are rendered from a `_PrefCardData` list through a single `_preferenceCard` helper, giving each the correct chips, default selections, "N selected" pill, and working chevron; the Exploration & Kink card gets its purple accent through per-card color fields rather than branching. The Safety card is a separate helper sharing the same card chrome, with the Able-to-accept chip Wrap, the full-width equal STI row defaulting to "No", and the GDPR note. The visibility card presents two single-select radio rows with "Mutual Matches Only" defaulted and tagged with a green "Recommended" pill.

State and routing are correct. The controller gained five expansion `RxBool`s (all default true), five multi-select `RxList`s with the specified defaults, two `RxString` single-selects (`stiStatus` default 'No', `visibilityMode` default 'Mutual Matches Only'), toggle/setter methods following the existing `toggleOrientation`/`selectGender` idioms, and the two new handlers routing to `Routes.PAYMENT`. `onCompleteProfile()` and `onSkipProfileSetup()` were re-pointed to `Routes.INTIMATE_DESIRES`; `onMoreInfoTap` and all login/payment/photo-picker code are untouched.

Constants discipline holds. Every color (`color9333EA`, `colorAF5FF`, `colorECFDF5`, `color059669`, `colorFECDD3`, etc.) and size referenced by the screen exists in `app_colors.dart` / `screen_constants.dart` (verified). The remaining raw literals (badge 44/22/12, radius 10/16/100, 2px/4px spacers) are the sibling screen's established pattern, not newly introduced magic numbers, consistent with the plan's verbatim-clone decision.

Verification evidence is present and trusted: `flutter analyze` over the four files reported 9 info-level lints, zero errors/warnings, all pre-existing patterns (the `withOpacity` deprecation cloned from the sibling, and the SCREAMING_CASE route-name convention). This review did not re-run analysis per instructions.

<details>
<summary>Issues (0)</summary>

No blocking or non-blocking actionable findings. The two step-label/heading inconsistencies are intentional and documented in the plan's Known gaps, reproduced from the source screenshots.

</details>

<details>
<summary>Details</summary>

### AppBar: back, step title, lock + avatar

`build` renders the AppBar exactly as specced: a `GestureDetector` leading arrow calling `controller.onBack`, a centered `Column` with "STEP 4 OF 4" (`policiesBadgeText`) over "Profile Photos" (`registerTitle`), and an `actions` list placing `Icons.lock_outline` (colorBE123C, `minimumIconSize`) before the circular person-outline avatar container (colorFFF1F2 fill, colorFFE4E6 border, colorE11D48 icon) copied from the sibling. The step label "4 OF 4" and title "Profile Photos" diverge from the body's "STEP 5 OF 5" / "Set Your Intimate Desires"; this is the spec's documented stitched-screenshot artifact and is reproduced verbatim rather than reconciled (confirmed against plan Known gaps).

### Five cards via one reusable helper + bespoke Safety body

Cards a–d are a `List<_PrefCardData>` mapped through `_preferenceCard`, matching the spec's data-driven requirement and the sibling's `_PolicyItemData` idiom. Each card's `Obx` reads `d.expanded().value` and `d.selected().length`, so the "N selected" pill and the up/down chevron (`keyboard_arrow_up`/`keyboard_arrow_down`) react live, and the chip `Wrap` only mounts when expanded. The Exploration & Kink card's purple treatment (`accent` color9333EA, `accentBg`/`pillBg` colorAF5FF, `pillTextColor` color9333EA) is driven by per-card fields, so the one helper handles both rose and purple without conditional logic — the clean approach the plan called for. Chip lists and default selections match the spec: relationship `['One time']`, physical `['Anal','Oral','Vaginal']`, kink `['Roleplay']`, interests `['Gaming','Music']`.

The Safety card (`_buildSafetyCard`) reuses the same white-card chrome (radius 16, colorE2E8F0 1.5 border, 44x44 badge) with a shield icon and rose accent, then diverges into the bespoke body: the Able-to-accept `_label` + chip `Wrap` bound to `ableToAccept`/`toggleAbleToAccept` (default `['Protected only (Condom required)']`), the STI `_equalWidthChipRow` over `['No','Yes','Prefer not to say']` with `stiStatus` defaulting to 'No' and laid out full-width with equal `Expanded` chips, and the GDPR lock-icon note. All three sub-sections render inside the single `Obx` so STI selection and accept-chip toggles update correctly.

### Visibility card: two single-select radios

`_buildVisibilityCard` renders the `Icons.visibility_outlined` header and two `_visibilityOption` rows, each wrapped in its own `Obx` reading `controller.visibilityMode.value == value`. "Mutual Matches Only" carries the green "Recommended" pill (colorECFDF5 bg / color059669 text) and is the default selection; "Visible to ID-Verified Belgian Profiles" is the alternative. The radio uses the adapted consent-card idiom: circular border colorBE185D when selected (else color94A3B8), filled inner colorBE185D dot when selected, selected card border colorFECDD3 (else colorE2E8F0). Tapping sets `visibilityMode`. The trailing shield GDPR note closes the card.

### Save button, skip link, footer

`_buildSaveButton` is a faithful clone of the sibling's `_buildCompleteButton` — the colorBE185D->color581C87 gradient, radius 100, colorDB2777 0.35 shadow, `defaultHeightFifty` height, `loginButtonText` white label, and `arrow_forward` icon — relabeled "Save & Complete Setup" and wired to `controller.onSaveCompleteSetup`. `_buildSkipLink` ("Skip for now (configure later in Settings)", `paymentCancelLink`) calls `onSkipIntimateDesires`. The footer renders the three specified badges (Zero Search Indexing / Belgian GDPR / Vault Encrypted) via `_footerBadge` using `registerFooterStrip`.

### Controller state and routing

The new state follows the existing idioms precisely: multi-select toggles mirror `toggleOrientation` (`contains ? remove : add` on `RxList<String>`), single-selects mirror `selectGender`/`onCountrySelected` (`RxString` + plain setter), and expansion flags are individual `RxBool`s defaulting to true. `onSaveCompleteSetup()` debug-prints the full selection set and routes to `Routes.PAYMENT`; `onSkipIntimateDesires()` routes to `Routes.PAYMENT`. `onCompleteProfile()` and `onSkipProfileSetup()` now route to `Routes.INTIMATE_DESIRES`. `onMoreInfoTap` still routes to PAYMENT (untouched), and no new `TextEditingController`s were added so `onInit`/`onClose` are correctly left alone. Login/biometric, splash permission logic, payment, and the add-photo/image-picker code are all unchanged.

### Routes and page registration

`routes.dart` adds `INTIMATE_DESIRES = '/intimate_desires'` below `PROFILE_SETUP`, following the class's SCREAMING_CASE convention. `app_pages.dart` imports `intimate_desires_screen.dart` and registers `GetPage(name: Routes.INTIMATE_DESIRES, page: () => const IntimateDesiresScreen(), binding: RegisterBinding())` immediately after the PROFILE_SETUP page. Note the PAYMENT page sits earlier in the list than PROFILE_SETUP, so "between PROFILE_SETUP and PAYMENT" by list position is not literally possible; the new page is placed right after PROFILE_SETUP, which is the readable and functionally correct placement the plan anticipated. Registration order does not affect routing behavior.

### Constants and const-correctness

The `const IntimateDesiresScreen({super.key})` constructor is present and the class extends `GetView<RegisterController>`. Every color and size the screen references was confirmed to exist in `app_colors.dart` and `screen_constants.dart`. The raw numeric literals that remain (badge 44x44 / icon 22, radii 10/16/100, 2px and 4px micro-spacers, 6px eyebrow dot) are identical to the patterns already used in `profile_setup_screen.dart` and `policies_agreement_screen.dart`; introducing new ScreenConstant entries for them would deviate from the sibling and was explicitly ruled out by the plan.

### Verification

The coder's `verification.md` records `flutter analyze` over the four files: 9 info-level issues, zero errors, zero warnings — the `withOpacity` deprecation (cloned verbatim from the sibling's save button) and eight `constant_identifier_names` lints on the established route-name convention. No new errors introduced. Per instructions this review trusts that evidence and did not re-run analysis or build.

### File map

- `lib/modules/register/views/intimate_desires_screen.dart` (new) — the full screen plus `_PrefCardData` struct and cloned `_label`/`_selectableChip`/`_equalWidthChipRow` helpers.
- `lib/modules/register/controller/register_controller.dart` — new Rx state, toggles/setters, `onSaveCompleteSetup`/`onSkipIntimateDesires`; re-pointed `onCompleteProfile`/`onSkipProfileSetup` to INTIMATE_DESIRES.
- `lib/routes/routes.dart` — added `INTIMATE_DESIRES` constant.
- `lib/routes/app_pages.dart` — import + `GetPage` registration after PROFILE_SETUP.

No git repository is present in the workspace, so no machine diff was available; the review was conducted by reading the four target files in full against the plan spec.

</details>
