import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../device_manager/urls.dart';
import '../../../routes/routes.dart';
import '../../../utils/Store/HiveStore.dart';
import '../../register/model/update_profile_response_model.dart';
import '../../register/services/profile_services.dart';

/// Logged-in "Profile Preview" screen. Shows Hive-cached name/avatar
/// instantly, then overwrites everything with GET /users/me.
class ProfileController extends GetxController {
  // --- Loading / error state ----------------------------------------------
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // --- Identity -------------------------------------------------------------
  final RxString displayName = ''.obs;

  /// Whole years from date_of_birth; 0 = unknown.
  final RxInt age = 0.obs;
  final RxString city = ''.obs;
  final RxString gender = ''.obs;
  final RxString orientation = ''.obs;
  final RxString bio = ''.obs;

  final RxList<String> photoUrls = <String>[].obs;
  final RxInt currentPhotoIndex = 0.obs;

  // --- Preferences ----------------------------------------------------------
  final RxList<String> interests = <String>[].obs;
  final RxList<String> lookingFor = <String>[].obs;
  final RxList<String> relationshipTypes = <String>[].obs;

  /// Combined list (profile.sexual_preferences = core + exploration).
  final RxList<String> sexualPreferences = <String>[].obs;
  final RxList<String> coreIntimate = <String>[].obs;
  final RxList<String> explorationKink = <String>[].obs;

  // --- Other details / account ---------------------------------------------
  final RxString hasSoa = ''.obs;
  final RxString personalSafetyInfo = ''.obs;
  final RxString visibilityMode = ''.obs;
  final RxString email = ''.obs;
  final RxString country = ''.obs;
  final RxString memberSince = ''.obs;
  final RxString accountStatus = 'Active'.obs;
  final RxBool isInvisible = false.obs;
  final RxBool hasPaymentMethod = false.obs;
  final RxString trialEndsAt = ''.obs;

  /// True once a successful API response has been applied.
  final RxBool hasLoaded = false.obs;

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
    fetchProfile();
  }

  /// Instant fallback from Hive so the hero card isn't empty while loading.
  void loadProfileData() {
    final String? name = HiveStore().getString(Keys.SAVEDPROFILENAME) ??
        HiveStore().getString(Keys.SAVEDNAME) ??
        HiveStore().getString(Keys.SESSIONDISPLAYNAME);
    if (name != null && name.isNotEmpty) {
      displayName.value = name;
    }

    final String? avatar = HiveStore().getString(Keys.SAVEDAVATAR);
    if (avatar != null && avatar.isNotEmpty) {
      photoUrls.assignAll([avatar]);
    }
  }

  /// GET /users/me → maps the response onto the Rx fields. Used on init and
  /// for pull-to-refresh / retry. On failure the current values are kept.
  Future<void> fetchProfile() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await ProfileService.instance.getMyProfile();
      final data = res.data;
      if (res.success && data != null) {
        _apply(data);
        hasLoaded.value = true;
      } else {
        _fail(res.message.isNotEmpty
            ? res.message
            : 'Could not load profile. Please try again.');
      }
    } catch (e) {
      debugPrint('ProfileController.fetchProfile error: $e');
      _fail('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void _fail(String message) {
    errorMessage.value = message;
    Get.snackbar('Could not load profile', message);
  }

  void _apply(UpdateProfileUser data) {
    final p = data.profile;

    displayName.value = data.displayName;
    final computedAge = _ageFrom(data.dateOfBirth);
    if (computedAge != null) age.value = computedAge;

    email.value = data.email;
    country.value = data.country;
    isInvisible.value = data.isInvisible;
    hasPaymentMethod.value = data.hasPaymentMethod;
    trialEndsAt.value = data.trialEndsAt;
    memberSince.value = _monthYear(data.createdAt);
    // Rule: invisible accounts show "Invisible", otherwise "Active".
    accountStatus.value = data.isInvisible ? 'Invisible' : 'Active';

    final loc = p?.location;
    if (loc == null || (loc.city.isEmpty && loc.region.isEmpty)) {
      city.value = '';
    } else if (loc.region.isEmpty) {
      city.value = loc.city;
    } else if (loc.city.isEmpty) {
      city.value = loc.region;
    } else {
      city.value = '${loc.city}, ${loc.region}';
    }

    gender.value = p?.gender ?? '';
    orientation.value = (p?.orientation ?? const <String>[]).join(', ');
    bio.value = p?.aboutMe ?? '';

    interests.assignAll(p?.interestAndPassion ?? const <String>[]);
    lookingFor.assignAll(p?.lookingFor ?? const <String>[]);
    relationshipTypes.assignAll(p?.relationshipPreferences ?? const <String>[]);
    sexualPreferences.assignAll(p?.sexualPreferences ?? const <String>[]);
    coreIntimate.assignAll(p?.corePhysicalIntimate ?? const <String>[]);
    explorationKink.assignAll(p?.explorationKink ?? const <String>[]);

    hasSoa.value = p?.hasStdOrSti ?? '';
    personalSafetyInfo.value = p?.personalSafetyInfo ?? '';
    visibilityMode.value = p?.preferenceVisibilityMode ?? '';

    photoUrls.assignAll(_photoUrlsFrom(data));
    if (currentPhotoIndex.value >= photoUrls.length) {
      currentPhotoIndex.value = 0;
    }
  }

  /// Photos sorted by position; falls back to the avatar when there are none.
  List<String> _photoUrlsFrom(UpdateProfileUser data) {
    final photos = [...?data.profile?.photos]
      ..sort((a, b) => a.position.compareTo(b.position));
    var urls = photos.map((e) => e.url).where((u) => u.isNotEmpty).toList();
    if (urls.isEmpty) {
      final profileAvatar = data.profile?.avatarUrl ?? '';
      final avatar = profileAvatar.isNotEmpty ? profileAvatar : data.avatarUrl;
      if (avatar.isNotEmpty) urls = [avatar];
    }
    return urls.map(_absoluteUrl).toList();
  }

  String _absoluteUrl(String url) =>
      url.startsWith('/') ? '${Urls.baseUrl}$url' : url;

  /// Whole years since [dob] (yyyy-MM-dd); null when unparseable.
  int? _ageFrom(String dob) {
    final birth = DateTime.tryParse(dob);
    if (birth == null) return null;
    final now = DateTime.now();
    var years = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      years--;
    }
    return years < 0 ? null : years;
  }

  /// "MMM yyyy" (e.g. "Oct 2026"); '' when unparseable.
  String _monthYear(String iso) {
    final d = DateTime.tryParse(iso)?.toLocal();
    if (d == null) return '';
    return '${_months[d.month - 1]} ${d.year}';
  }

  void setPhotoIndex(int index) {
    currentPhotoIndex.value = index;
  }

  void onEditProfile() {
    Get.toNamed(Routes.EDIT_PROFILE);
  }

  void onBack() {
    Get.back();
  }
}
