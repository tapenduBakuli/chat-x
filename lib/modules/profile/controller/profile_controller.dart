import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/routes.dart';
import '../../../utils/Store/HiveStore.dart';

class ProfileController extends GetxController {
  final RxString displayName = 'JerryTwo'.obs;
  final RxInt age = 30.obs;
  final RxString city = 'Brussels, Belgium'.obs;
  final RxString gender = 'Woman'.obs;
  final RxString orientation = 'Straight'.obs;
  final RxString bio =
      'Passionate about meaningful conversations, exploring cozy cafes, art galleries, and authentic connections.'
          .obs;

  final RxList<String> photoUrls = <String>[].obs;
  final RxInt currentPhotoIndex = 0.obs;

  final RxList<String> interests = <String>[
    'Sports',
    'Gaming',
    'Movies',
    'Music',
    'Drawing / Art',
    'Travel',
  ].obs;

  final RxList<String> lookingFor = <String>[
    'Multiple times',
    'In-life friendship',
  ].obs;

  final RxList<String> relationshipTypes = <String>[
    'One Time',
    'Multiple Times',
  ].obs;

  final RxString sexualPreference = 'Straight'.obs;
  final RxString hasSoa = 'Yes'.obs;
  final RxString memberSince = 'Jan 2024'.obs;
  final RxString accountStatus = 'Active'.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }

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
