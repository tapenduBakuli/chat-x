# Profile Setup screen and policies-to-profile navigation rewire

Adds a new STEP 3 OF 4 Profile Setup screen to the register flow and repoints the policies "Agree & Continue" button at it instead of jumping straight to payment. The screen is a `GetView<RegisterController>` with a const constructor rendering all 13 mock sections (step header, discreet badge, add-photo control, profile name, gender, DOB, orientation, Belgian location card, looking-for, about-me, complete button, skip link, footer strip). All selection state lives on `RegisterController` as Rx fields with toggle/select methods, the view wraps every reactive region in `Obx`, and the completed profile hands off to `Routes.PAYMENT`. New route constant and `GetPage` registration are in place.

Watch for: nothing blocking. The implementation follows the plan and existing register-screen conventions precisely, reuses the shared `CustomColor` / `ScreenConstant` / `TextStyles` / `CustomTextField` helpers throughout, and adds no inline hex or magic sizes. The only observations are informational (confirmed): the project is not a git repository so the review is diff-reconstructed from file state against the plan, and the coder's analyzer note reports 9 pre-existing `info`-level lints (deprecated `withOpacity`, UPPER_CASE route names) that mirror sibling screens.

**Verdict**: APPROVED

## High-level view

The policies screen now feeds Profile Setup rather than Payment: `onAgreeAndContinue()` keeps its `isAllConsentAgreed` guard and only changes the target route and its debug text. Profile Setup then forwards to `Routes.PAYMENT` from both `onCompleteProfile()` and `onSkipProfileSetup()`, so the Banking & Payment screen the user reported seeing prematurely now sits one step later in the flow, which is the behavior the original request asked for.

State and view are cleanly separated. The controller owns `profileNameController`, `aboutMeController`, single-select gender, nullable DOB day/month/year, multi-select orientation and looking-for lists, selected city, and an `aboutMeLength` counter driven by a listener attached in `onInit()`. The view holds only the static option lists and `Obx`-wrapped widgets reading that state. Both new text controllers are disposed in `onClose()` alongside the existing thirteen.

The About Me field is the one spot that deviates from the shared `CustomTextField`, by design: that widget exposes no `maxLength` or counter, so a plain `TextField` with `maxLength: 500`, a suppressed default counter, and the matching fill/border styling enforces the 500-char cap while the visible "n / 500" readout is driven from `aboutMeLength`.

The API surface added is small and internal: one route constant `PROFILE_SETUP = '/profile_setup'`, one `GetPage` bound to `RegisterBinding`, and the controller handlers. No new colors or text styles were introduced — every referenced `CustomColor`, `ScreenConstant`, and `TextStyles` member already exists in the palette files, which I verified directly.

<details>
<summary>Issues (0)</summary>

No blocking or non-blocking action items. The two informational observations (non-git workspace limiting diff reconstruction, pre-existing info-level lints noted by the coder) require no change.

</details>

<details>
<summary>Details</summary>

### Policies navigation now gates on consent then routes to Profile Setup

`onAgreeAndContinue()` reads (confirmed):

```dart
void onAgreeAndContinue() {
  if (isAllConsentAgreed) {
    debugPrint('All consents agreed. Navigating to profile setup...');
    Get.toNamed(Routes.PROFILE_SETUP);
  }
}
```

The `isAllConsentAgreed` guard (all five consent toggles true) is intact, so the button still does nothing until every consent is checked — only the destination and debug text changed. This is the exact fix for the reported symptom where agreeing opened Banking & Payment directly. `onCompleteProfile()` and `onSkipProfileSetup()` both call `Get.toNamed(Routes.PAYMENT)` (confirmed), so Payment is reachable from the end of Profile Setup rather than from Policies.

### Controller state, counter wiring, and disposal

The profile Rx state matches the plan field-for-field (confirmed): `selectedGender` defaults to `'Woman'`, DOB is three `RxnInt`s so the dropdowns can start empty, `selectedOrientations` and `selectedLookingFor` are seeded multi-select `RxList<String>`s with the toggle pattern (`contains ? remove : add`), and `selectedProfileCity` defaults to Brussels over the static `belgianCities` list. The about-me counter is wired in `onInit()`:

```dart
aboutMeController.addListener(() {
  aboutMeLength.value = aboutMeController.text.length;
});
```

Because the `TextField` enforces `maxLength: 500`, `aboutMeLength` stays within `0..500`, so the "n / 500" display can never contradict the cap. Both `profileNameController` and `aboutMeController` are disposed in `onClose()` before `super.onClose()` (confirmed), closing the leak that would otherwise follow from adding controllers without disposal.

### Reactive view and symbol-resolution check

The gradient Complete button copies the policies `_buildSubmitButton` pattern but, per spec, carries no enablement guard — unlike policies' Agree button it is always tappable regardless of field state.

I verified that each referenced symbol resolves against the source: all `TextStyles` getters used (`registerAppBarTitle`, `registerTitle`, `registerFieldLabel`, `registerFieldNote`, `registerSectionTitle`, `registerVerifyNoteHighlight`, `registerOptional`, `registerFooterStrip`, `policiesBadgeText`, `paymentValidFormat`, `paymentCancelLink`, `loginTopText`, `loginFieldText`, `loginFieldHint`, `loginButtonText`) exist in `TextStyles.dart`; every `ScreenConstant` size referenced exists in `screen_constants.dart`; every `CustomColor` referenced exists in `app_colors.dart`; and the `CustomTextField` named params used (`controller`, `hintText`, `hintStyle`, `borderColor`, `borderRadius`) match its constructor. No new color or style was added, consistent with the plan's assessment that the existing palette covered the design (the green pill reuses `colorECFDF5` + `color059669` + `color10B981`).

### Route and page registration

`Routes.PROFILE_SETUP = '/profile_setup'` is defined directly after `POLICIES_AGREEMENT` (confirmed). `app_pages.dart` imports `profile_setup_screen.dart` with the other register views and registers `GetPage(name: Routes.PROFILE_SETUP, page: () => const ProfileSetupScreen(), binding: RegisterBinding())`. The entry sits at the end of the list rather than literally between the policies and payment entries, but list order is cosmetic for GetX named routes and the plan explicitly treated "between" as positional-not-literal; shared `RegisterBinding` means the same controller instance carries the register, policies, profile, and payment state across the flow.

### Scope

The change touches only the five intended files: `routes.dart`, `app_pages.dart`, `register_controller.dart`, the new `profile_setup_screen.dart`, and (per spec) nothing else. The controller references no biometric or login symbols, so the biometric button and login modules mentioned in the broader feature request are untouched by this change — correct, since that work is out of this task's scope.

### Verification evidence

The plan tail carries the coder's verification note: `flutter analyze` was run against the four touched Dart files (the fifth, the new screen, is included) and reported 9 `info`-level issues, zero errors or warnings. The lints are `deprecated_member_use` for `withOpacity` (two in the new screen, matching the identical pattern already shipped in `policies_agreement_screen.dart` and `payment_details_screen.dart`) and `constant_identifier_names` for the UPPER_CASE route constants (every route in `Routes` already uses this style). These are pre-existing project conventions, not new regressions. Per the task's verification policy I did not re-run analyze; the static cross-checks above (symbol resolution against the three helper files and the `CustomTextField` signature) found no articulable doubt that would warrant a spot-check.

</details>

<details>
<summary>File map</summary>

- `lib/routes/routes.dart` — adds `PROFILE_SETUP = '/profile_setup'` after `POLICIES_AGREEMENT`.
- `lib/routes/app_pages.dart` — imports the new screen and registers its `GetPage` with `RegisterBinding`.
- `lib/modules/register/controller/register_controller.dart` — adds profile name/about-me controllers, gender/DOB/orientation/city/looking-for Rx state and their mutators, the about-me length listener in `onInit()`, the `onAddPhotoTap`/`onCompleteProfile`/`onSkipProfileSetup` handlers, repoints `onAgreeAndContinue()` to `PROFILE_SETUP`, and disposes both new controllers in `onClose()`.
- `lib/modules/register/views/profile_setup_screen.dart` — new `ProfileSetupScreen extends GetView<RegisterController>` rendering all 13 sections with shared helpers and `Obx` reactive state.

Workspace is not a git repository, so no diff hash is available; this review was reconstructed from current file state against the plan.

</details>
