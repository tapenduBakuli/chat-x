import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../device_manager/screen_constants.dart';
import '../../../routes/routes.dart';
import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';

enum PaymentMethod { bancontact, sepa, creditCard }

class RegisterController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvcController = TextEditingController();
  final TextEditingController promoController = TextEditingController();

  // Payment details (shared registration flow).
  final TextEditingController accountHolderController = TextEditingController();
  final TextEditingController ibanController = TextEditingController();
  final TextEditingController bicController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  // Profile setup details.
  final TextEditingController profileNameController = TextEditingController();
  final TextEditingController aboutMeController = TextEditingController();

  /// Visibility toggles.
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  // --- Password strength / match state ------------------------------------
  /// Live mirror of the password field (updated via a text listener).
  final RxString password = ''.obs;

  /// Live mirror of the confirm-password field.
  final RxString confirmPassword = ''.obs;

  /// Minimum required password length.
  static const int kMinPasswordLength = 10;

  bool get hasMinLength => password.value.length >= kMinPasswordLength;
  bool get hasUppercase => password.value.contains(RegExp(r'[A-Z]'));
  bool get hasLowercase => password.value.contains(RegExp(r'[a-z]'));
  bool get hasNumber => password.value.contains(RegExp(r'[0-9]'));

  /// Number of satisfied rules (0..4), used for the strength meter.
  int get passwordScore => [
        hasMinLength,
        hasUppercase,
        hasLowercase,
        hasNumber,
      ].where((ok) => ok).length;

  /// Whether every rule is satisfied.
  bool get isPasswordValid => passwordScore == 4;

  /// Human-readable strength label for the current score.
  String get passwordStrengthLabel {
    if (password.value.isEmpty) return '';
    switch (passwordScore) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      default:
        return 'Strong';
    }
  }

  /// First unmet-requirement message shown under the field (empty when valid).
  String get passwordError {
    if (password.value.isEmpty) return '';
    if (!hasMinLength) {
      return 'Password must be at least $kMinPasswordLength characters';
    }
    if (!hasUppercase) return 'Add at least one uppercase letter';
    if (!hasLowercase) return 'Add at least one lowercase letter';
    if (!hasNumber) return 'Add at least one number';
    return '';
  }

  /// Whether confirm-password matches password (only meaningful once the
  /// confirm field has input).
  bool get passwordsMatch =>
      confirmPassword.value.isNotEmpty &&
      confirmPassword.value == password.value;

  /// Error shown under the confirm field, empty when matching or untouched.
  String get confirmPasswordError {
    if (confirmPassword.value.isEmpty) return '';
    return passwordsMatch ? '' : 'Passwords do not match';
  }

  /// Selected payment method/provider.
  final Rx<PaymentMethod> selectedMethod = PaymentMethod.bancontact.obs;

  /// Mandate authorization toggle.
  final RxBool mandateAuthorized = true.obs;

  /// Country selection.
  final List<String> countries = const [
    "Belgium (België / Belgique)",
    "Netherlands (Nederland)",
    "France",
    "Germany (Deutschland)",
    "Luxembourg",
  ];
  late final RxString selectedCountry = countries.first.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void onCountrySelected(String country) {
    selectedCountry.value = country;
  }

  void selectMethod(PaymentMethod method) {
    selectedMethod.value = method;
  }

  void toggleMandate() {
    mandateAuthorized.value = !mandateAuthorized.value;
  }

  void onSaveAndContinue() {
    debugPrint(
      'Save & Continue -> method: ${selectedMethod.value}, '
      'holder: ${accountHolderController.text.trim()}, '
      'iban: ${ibanController.text.trim()}, '
      'mandate: ${mandateAuthorized.value}',
    );
  }

  void onCancel() {
    Get.back();
  }

  /// Policies & Safety Agreement state
  final RxBool agreeTerms = false.obs;
  final RxBool agreePrivacy = false.obs;
  final RxBool agreeCommunity = false.obs;
  final RxBool agreeProhibited = false.obs;
  final RxBool agreeTrial = false.obs;

  final RxList<bool> expandedPolicySections = List.generate(7, (_) => false).obs;

  /// Profile setup state
  final RxString selectedGender = 'Woman'.obs;

  final RxnInt selectedDobDay = RxnInt();
  final RxnInt selectedDobMonth = RxnInt();
  final RxnInt selectedDobYear = RxnInt();

  final RxList<String> selectedOrientations =
      <String>['Straight', 'Open-minded'].obs;

  final List<String> belgianCities = const [
    'Brussels / Bruxelles (1000)',
    'Antwerp / Antwerpen (2000)',
    'Ghent / Gent (9000)',
    'Liège (4000)',
    'Bruges / Brugge (8000)',
    'Namur (5000)',
  ];
  final RxString selectedProfileCity = 'Brussels / Bruxelles (1000)'.obs;

  final RxList<String> selectedLookingFor =
      <String>['Intimate connection', 'Discreet exploration'].obs;

  final RxInt aboutMeLength = 0.obs;

  /// Intimate desires state (per-card expansion, defaulting to expanded).
  final RxBool relationshipExpanded = true.obs;
  final RxBool physicalExpanded = true.obs;
  final RxBool kinkExpanded = true.obs;
  final RxBool interestsExpanded = true.obs;
  final RxBool safetyExpanded = true.obs;

  /// Intimate desires multi-select groups with defaults.
  final RxList<String> relationshipPrefs = <String>['One time'].obs;
  final RxList<String> physicalPrefs =
      <String>['Anal', 'Oral', 'Vaginal'].obs;
  final RxList<String> kinkPrefs = <String>['Roleplay'].obs;
  final RxList<String> interests = <String>['Gaming', 'Music'].obs;
  final RxList<String> ableToAccept =
      <String>['Protected only (Condom required)'].obs;

  /// Intimate desires single-selects.
  final RxString stiStatus = 'No'.obs;
  final RxString visibilityMode = 'Mutual Matches Only'.obs;

  /// The profile photo selected from the camera or gallery (null until picked).
  final Rx<File?> profileImage = Rx<File?>(null);

  /// Personal vault gallery photos (capped at 15).
  final RxList<File> galleryPhotos = <File>[].obs;

  /// Ordered photos shown in the Profile Preview hero carousel: the main
  /// profile photo first (if set), followed by the vault gallery photos.
  List<File> get previewPhotos => <File>[
        if (profileImage.value != null) profileImage.value!,
        ...galleryPhotos,
      ];

  /// Current page of the Profile Preview hero carousel (drives the dashes and
  /// the "x / N" counter).
  final RxInt heroPageIndex = 0.obs;

  /// Controls the Profile Preview hero [PageView].
  final PageController heroPageController = PageController();

  void onHeroPageChanged(int index) => heroPageIndex.value = index;

  final ImagePicker _imagePicker = ImagePicker();

  void selectGender(String gender) {
    selectedGender.value = gender;
  }

  void setDobDay(int? day) {
    selectedDobDay.value = day;
  }

  void setDobMonth(int? month) {
    selectedDobMonth.value = month;
  }

  void setDobYear(int? year) {
    selectedDobYear.value = year;
  }

  void toggleOrientation(String orientation) {
    selectedOrientations.contains(orientation)
        ? selectedOrientations.remove(orientation)
        : selectedOrientations.add(orientation);
  }

  void onProfileCitySelected(String city) {
    selectedProfileCity.value = city;
  }

  void toggleLookingFor(String value) {
    selectedLookingFor.contains(value)
        ? selectedLookingFor.remove(value)
        : selectedLookingFor.add(value);
  }

  void toggleRelationshipExpanded() {
    relationshipExpanded.value = !relationshipExpanded.value;
  }

  void togglePhysicalExpanded() {
    physicalExpanded.value = !physicalExpanded.value;
  }

  void toggleKinkExpanded() {
    kinkExpanded.value = !kinkExpanded.value;
  }

  void toggleInterestsExpanded() {
    interestsExpanded.value = !interestsExpanded.value;
  }

  void toggleSafetyExpanded() {
    safetyExpanded.value = !safetyExpanded.value;
  }

  void toggleRelationshipPref(String value) {
    relationshipPrefs.contains(value)
        ? relationshipPrefs.remove(value)
        : relationshipPrefs.add(value);
  }

  void togglePhysicalPref(String value) {
    physicalPrefs.contains(value)
        ? physicalPrefs.remove(value)
        : physicalPrefs.add(value);
  }

  void toggleKinkPref(String value) {
    kinkPrefs.contains(value)
        ? kinkPrefs.remove(value)
        : kinkPrefs.add(value);
  }

  void toggleInterest(String value) {
    interests.contains(value)
        ? interests.remove(value)
        : interests.add(value);
  }

  void toggleAbleToAccept(String value) {
    ableToAccept.contains(value)
        ? ableToAccept.remove(value)
        : ableToAccept.add(value);
  }

  void setStiStatus(String value) {
    stiStatus.value = value;
  }

  void setVisibilityMode(String value) {
    visibilityMode.value = value;
  }

  bool get isAllConsentAgreed =>
      agreeTerms.value &&
      agreePrivacy.value &&
      agreeCommunity.value &&
      agreeProhibited.value &&
      agreeTrial.value;

  void toggleSelectAll() {
    final target = !isAllConsentAgreed;
    agreeTerms.value = target;
    agreePrivacy.value = target;
    agreeCommunity.value = target;
    agreeProhibited.value = target;
    agreeTrial.value = target;
  }

  void togglePolicySection(int index) {
    expandedPolicySections[index] = !expandedPolicySections[index];
  }

  void onContinueTap() {
    debugPrint(
      'Continue tapped -> email: ${emailController.text.trim()}, '
      'country: ${selectedCountry.value}',
    );
    Get.toNamed(Routes.POLICIES_AGREEMENT);
  }

  void onAgreeAndContinue() {
    if (isAllConsentAgreed) {
      debugPrint('All consents agreed. Navigating to profile setup...');
      Get.toNamed(Routes.PROFILE_SETUP);
    }
  }

  /// Opens a bottom sheet letting the user choose Camera or Gallery, then
  /// stores the picked photo in [profileImage].
  Future<void> onAddPhotoTap() async {
    final source = await _showPhotoSourceSheet();
    if (source == null) return;
    await _pickImage(source);
  }

  Future<ImageSource?> _showPhotoSourceSheet() {
    return Get.bottomSheet<ImageSource>(
      SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: ScreenConstant.defaultHeightTwentyThree,
            horizontal: ScreenConstant.defaultWidthTwenty,
          ),
          decoration: const BoxDecoration(
            color: CustomColor.colorWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 44,
                  margin: EdgeInsets.only(bottom: ScreenConstant.sizeMedium),
                  decoration: BoxDecoration(
                    color: CustomColor.colorE2E8F0,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              Text("Add Profile Photo", style: TextStyles.registerFieldLabel),
              SizedBox(height: ScreenConstant.sizeMedium),
              _photoSourceTile(
                icon: Icons.photo_camera_outlined,
                label: "Take a photo",
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              SizedBox(height: ScreenConstant.sizeSmall),
              _photoSourceTile(
                icon: Icons.photo_library_outlined,
                label: "Choose from gallery",
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
              if (profileImage.value != null) ...[
                SizedBox(height: ScreenConstant.sizeSmall),
                _photoSourceTile(
                  icon: Icons.delete_outline,
                  label: "Remove photo",
                  iconColor: CustomColor.colorE11D48,
                  onTap: () {
                    profileImage.value = null;
                    Get.back();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _photoSourceTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = CustomColor.colorBE185D,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(ScreenConstant.sizeMedium),
        decoration: BoxDecoration(
          color: CustomColor.colorF8FAFC,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: CustomColor.colorE2E8F0, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: ScreenConstant.smallIconSize),
            SizedBox(width: ScreenConstant.sizeMedium),
            Text(label, style: TextStyles.registerFieldLabel),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final File? file = await _pickImageFile(source);
    if (file != null) {
      profileImage.value = file;
    }
  }

  /// Shared picker body: checks permission, picks via [_imagePicker], and
  /// returns the picked [File] (or null if cancelled/denied/failed). Used by
  /// both the main profile photo and the vault gallery.
  Future<File?> _pickImageFile(ImageSource source) async {
    try {
      if (!await _ensurePermission(source)) {
        _showPermissionDeniedSnack(source);
        return null;
      }

      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (picked != null) {
        return File(picked.path);
      }
      return null;
    } catch (e) {
      debugPrint('Image pick failed: $e');
      Get.snackbar(
        'Could not add photo',
        'Something went wrong while selecting the image.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  /// Opens the same Camera/Gallery chooser as [onAddPhotoTap] and appends the
  /// picked photo to [galleryPhotos], up to a cap of 15.
  Future<void> onAddGalleryPhoto() async {
    if (galleryPhotos.length >= 15) {
      Get.snackbar(
        'Limit reached',
        'You can add up to 15 photos.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final source = await _showPhotoSourceSheet();
    if (source == null) return;
    final File? file = await _pickImageFile(source);
    if (file != null) {
      galleryPhotos.add(file);
    }
  }

  void removeGalleryPhoto(int index) {
    if (index >= 0 && index < galleryPhotos.length) {
      galleryPhotos.removeAt(index);
    }
  }

  void onReorderGallery() => debugPrint('Reorder gallery tapped');

  /// Makes the gallery photo at [galleryIndex] the main profile photo. The
  /// current main photo (if any) takes that photo's place in the gallery, so
  /// dragging a gallery image onto the main frame swaps the two.
  void promoteGalleryPhotoToMain(int galleryIndex) {
    if (galleryIndex < 0 || galleryIndex >= galleryPhotos.length) return;

    final File dragged = galleryPhotos[galleryIndex];
    final File? currentMain = profileImage.value;

    profileImage.value = dragged;

    if (currentMain != null) {
      // Swap: the old main photo drops into the dragged image's slot.
      galleryPhotos[galleryIndex] = currentMain;
    } else {
      // No main photo yet: just move the dragged image out of the gallery.
      galleryPhotos.removeAt(galleryIndex);
    }
  }

  /// Reorders the gallery, moving the item at [from] to index [to].
  void reorderGalleryPhoto(int from, int to) {
    if (from == to) return;
    if (from < 0 || from >= galleryPhotos.length) return;
    if (to < 0 || to >= galleryPhotos.length) return;

    final File moved = galleryPhotos.removeAt(from);
    galleryPhotos.insert(to, moved);
  }

  void onMainPhotoMenu() => debugPrint('Main photo menu tapped');

  void onSavePhotosContinue() {
    debugPrint(
      'Save photos -> main: ${profileImage.value != null}, '
      'gallery: ${galleryPhotos.length}',
    );
    Get.toNamed(Routes.INTIMATE_DESIRES);
  }

  void onSkipPhotos() {
    debugPrint('Skip photos');
    Get.toNamed(Routes.INTIMATE_DESIRES);
  }

  Future<bool> _ensurePermission(ImageSource source) async {
    // Camera is a single permission on both platforms.
    if (source == ImageSource.camera) {
      return _isAllowed(await _resolve(Permission.camera));
    }

    // Gallery: photos covers iOS and Android 13+; older Android uses storage.
    // Permissions are already requested at app startup, so in the happy path
    // the status check below returns granted without prompting again.
    if (_isAllowed(await Permission.photos.status) ||
        _isAllowed(await Permission.storage.status)) {
      return true;
    }

    final bool photos = _isAllowed(await _resolve(Permission.photos));
    if (photos) return true;

    if (defaultTargetPlatform == TargetPlatform.android) {
      return _isAllowed(await _resolve(Permission.storage));
    }
    return false;
  }

  /// Returns the current status, requesting it only if not already granted.
  Future<PermissionStatus> _resolve(Permission permission) async {
    final PermissionStatus status = await permission.status;
    if (_isAllowed(status)) return status;
    return permission.request();
  }

  bool _isAllowed(PermissionStatus status) =>
      status.isGranted || status.isLimited;

  void _showPermissionDeniedSnack(ImageSource source) {
    final String what =
        source == ImageSource.camera ? 'camera' : 'photo library';
    Get.snackbar(
      'Permission needed',
      'Please allow $what access in settings to add a profile photo.',
      snackPosition: SnackPosition.BOTTOM,
      mainButton: TextButton(
        onPressed: openAppSettings,
        child: const Text('Settings'),
      ),
    );
  }

  void onCompleteProfile() {
    debugPrint(
      'Complete profile -> name: ${profileNameController.text.trim()}, '
      'gender: ${selectedGender.value}, '
      'dob: ${selectedDobDay.value}/${selectedDobMonth.value}/'
      '${selectedDobYear.value}, '
      'orientations: ${selectedOrientations.toList()}, '
      'city: ${selectedProfileCity.value}, '
      'lookingFor: ${selectedLookingFor.toList()}, '
      'aboutMe length: ${aboutMeLength.value}',
    );
    Get.toNamed(Routes.PROFILE_PHOTOS);
  }

  void onSkipProfileSetup() {
    debugPrint('Skip profile setup');
    Get.toNamed(Routes.PROFILE_PHOTOS);
  }

  void onSaveCompleteSetup() {
    debugPrint(
      'Save & Complete -> relationship: ${relationshipPrefs.toList()}, '
      'physical: ${physicalPrefs.toList()}, '
      'kink: ${kinkPrefs.toList()}, '
      'interests: ${interests.toList()}, '
      'ableToAccept: ${ableToAccept.toList()}, '
      'sti: ${stiStatus.value}, '
      'visibility: ${visibilityMode.value}',
    );
    // Flow now routes through the read-only Profile Preview before payment.
    Get.toNamed(Routes.PROFILE_PREVIEW);
  }

  void onSkipIntimateDesires() {
    debugPrint('Skip intimate desires');
    // Preview is always shown before payment, so skipping still lands on it.
    Get.toNamed(Routes.PROFILE_PREVIEW);
  }

  /// Whole-years age computed from the selected date of birth. Returns null
  /// when the year has not been chosen (callers omit the age in that case).
  int? get previewAge {
    final int? year = selectedDobYear.value;
    if (year == null) return null;
    // Month/day default to 1 so a partially-filled DOB still yields an age.
    final int month = selectedDobMonth.value ?? 1;
    final int day = selectedDobDay.value ?? 1;
    final DateTime now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }

  /// Publishes the previewed profile and continues to payment.
  void onPublishProfile() {
    debugPrint(
      'Publish profile -> name: ${profileNameController.text.trim()}, '
      'age: ${previewAge ?? '-'}, '
      'relationship: ${relationshipPrefs.length}, '
      'intimate: ${physicalPrefs.length + kinkPrefs.length}, '
      'interests: ${interests.length}, '
      'gallery: ${galleryPhotos.length}',
    );
    Get.offAllNamed(Routes.LOGIN);
  }

  void onMoreInfoTap() {
    Get.toNamed(Routes.PAYMENT);
  }

  void onLoginTap() {
    Get.back();
  }

  void onBack() {
    Get.back();
  }

  @override
  void onInit() {
    super.onInit();
    aboutMeController.addListener(() {
      aboutMeLength.value = aboutMeController.text.length;
    });
    // Keep the reactive password mirrors in sync with the text fields so the
    // strength meter, rule checklist, and match indicator update live.
    passwordController.addListener(() {
      password.value = passwordController.text;
    });
    confirmPasswordController.addListener(() {
      confirmPassword.value = confirmPasswordController.text;
    });
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    cardNumberController.dispose();
    expiryController.dispose();
    cvcController.dispose();
    promoController.dispose();
    accountHolderController.dispose();
    ibanController.dispose();
    bicController.dispose();
    streetController.dispose();
    postalCodeController.dispose();
    cityController.dispose();
    profileNameController.dispose();
    aboutMeController.dispose();
    heroPageController.dispose();
    super.onClose();
  }
}
