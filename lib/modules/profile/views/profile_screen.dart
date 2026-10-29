import 'package:chat_x/device_manager/screen_constants.dart';
import 'package:chat_x/modules/home/views/widgets/member_network_image.dart';
import 'package:chat_x/modules/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.colorAF5FF,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: CustomColor.colorWhite,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.onBack,
          child: Icon(
            Icons.arrow_back,
            size: ScreenConstant.smallIconSize,
            color: CustomColor.color0F172A,
          ),
        ),
        title: Text(
          "Profile Preview",
          style: TextStyles.registerAppBarTitle,
        ),
        actions: [

        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenConstant.defaultWidthTwenty,
                  vertical: ScreenConstant.defaultHeightFifteen,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenConstant.sizeSmall,
                              vertical: ScreenConstant.sizeExtraSmall / 1.5,
                            ),
                            margin: EdgeInsets.only(right: ScreenConstant.sizeMedium),
                            decoration: BoxDecoration(
                              color: CustomColor.colorFFF1F2,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: CustomColor.colorFECDD3, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 12,
                                  color: CustomColor.colorBE123C,
                                ),
                                SizedBox(width: ScreenConstant.sizeExtraSmall),
                                Text(
                                  "This profile is visible to other members",
                                  style: TextStyle(
                                    color: CustomColor.colorBE123C,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Liberation",
                                  ),
                                ),
                                SizedBox(width: ScreenConstant.sizeExtraSmall),
                                Icon(
                                  Icons.visibility_outlined,
                                  size: 12,
                                  color: CustomColor.colorBE123C,
                                ),
                              ],
                            ),
                          ),
                    ),
                    SizedBox(height: ScreenConstant.defaultHeightTen),
                    _buildHeroPhotoCard(),
                    SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                    _buildAboutMeCard(),
                    SizedBox(height: ScreenConstant.sizeMedium),
                    _buildInterestsCard(),
                    SizedBox(height: ScreenConstant.sizeMedium),
                    _buildLocationCard(),
                    SizedBox(height: ScreenConstant.sizeMedium),
                    _buildLookingForCard(),
                    SizedBox(height: ScreenConstant.sizeMedium),
                    _buildSexualPreferencesCard(),
                    SizedBox(height: ScreenConstant.sizeMedium),
                    _buildRelationshipTypeCard(),
                    SizedBox(height: ScreenConstant.sizeMedium),
                    _buildOtherDetailsCard(),
                    SizedBox(height: ScreenConstant.sizeMedium),
                    _buildAccountInfoCard(),
                    SizedBox(height: ScreenConstant.sizeMedium),
                    _buildPrivacyNoticeCard(),
                    SizedBox(height: ScreenConstant.defaultHeightThirty),
                    Container(
                      padding: EdgeInsets.all(ScreenConstant.sizeMedium),
                      decoration: BoxDecoration(
                        color: CustomColor.colorWhite,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: CustomColor.color0F172A.withOpacity(0.06),
                            blurRadius: 16,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Security disclaimer
                          Row(
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                size: 16,
                                color: CustomColor.colorBE123C,
                              ),
                              SizedBox(width: ScreenConstant.sizeExtraSmall),
                              Expanded(
                                child: Text(
                                  "Your privacy is our priority. All data is encrypted and securely stored.",
                                  style: TextStyles.policiesDisclaimer.copyWith(
                                    fontSize: 11,
                                    color: CustomColor.color64748B,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ScreenConstant.sizeSmall),
                          // Action Buttons
                          Row(
                            children: [
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: controller.onBack,
                                child: Container(
                                  height: ScreenConstant.defaultHeightFifty,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ScreenConstant.sizeLarge,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                      color: CustomColor.colorE2E8F0,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_back,
                                        size: ScreenConstant.smallIconSize,
                                        color: CustomColor.color0F172A,
                                      ),
                                      SizedBox(width: ScreenConstant.sizeExtraSmall),
                                      Text(
                                        "Back",
                                        style: TextStyles.browseToggleLabel.copyWith(
                                          color: CustomColor.color0F172A,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: ScreenConstant.sizeMedium),
                              Expanded(
                                child: GestureDetector(
                                  onTap: controller.onEditProfile,
                                  child: Container(
                                    height: ScreenConstant.defaultHeightFifty,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      gradient: const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          CustomColor.colorBE185D,
                                          CustomColor.color581C87,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: CustomColor.colorBE185D.withOpacity(0.3),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.edit,
                                          color: CustomColor.colorWhite,
                                          size: 18,
                                        ),
                                        SizedBox(width: ScreenConstant.sizeSmall),
                                        Text(
                                          "Edit Profile",
                                          style: TextStyles.loginButtonText,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ScreenConstant.defaultHeightThirty),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Hero Photo Carousel Card
  // ---------------------------------------------------------------------------
  Widget _buildHeroPhotoCard() {
    return Container(
      height: 380,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CustomColor.color0F172A.withOpacity(0.12),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Swipeable Photo Carousel
            Obx(() {
              final photos = controller.photoUrls;
              if (photos.isEmpty) {
                return const MemberNetworkImage(url: '');
              }
              return PageView.builder(
                onPageChanged: controller.setPhotoIndex,
                itemCount: photos.length,
                itemBuilder: (context, index) =>
                    MemberNetworkImage(url: photos[index]),
              );
            }),
            // Bottom Scrim Gradient
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        CustomColor.color0F172A,
                      ],
                      stops: [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            // Top Left Badge: Online Now
            Positioned(
              top: ScreenConstant.sizeMedium,
              left: ScreenConstant.sizeMedium,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenConstant.sizeSmall,
                  vertical: ScreenConstant.sizeExtraSmall / 1.2,
                ),
                decoration: BoxDecoration(
                  color: CustomColor.color0D1527.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: CustomColor.color10B981,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: ScreenConstant.sizeExtraSmall),
                    Text(
                      "Online Now",
                      style: TextStyles.policiesBadgeText.copyWith(
                        color: CustomColor.colorWhite,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Top Right Badge: Photo Counter (e.g. 1/15)
            Positioned(
              top: ScreenConstant.sizeMedium,
              right: ScreenConstant.sizeMedium,
              child: Obx(() {
                final total = controller.photoUrls.isEmpty
                    ? 1
                    : controller.photoUrls.length;
                final current = controller.currentPhotoIndex.value + 1;
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenConstant.sizeSmall,
                    vertical: ScreenConstant.sizeExtraSmall / 1.2,
                  ),
                  decoration: BoxDecoration(
                    color: CustomColor.color0D1527.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_camera_outlined,
                        size: ScreenConstant.minimumIconSize,
                        color: CustomColor.colorWhite,
                      ),
                      SizedBox(width: ScreenConstant.sizeExtraSmall),
                      Text(
                        "$current/$total",
                        style: TextStyles.policiesBadgeText.copyWith(
                          color: CustomColor.colorWhite,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
            // Bottom Info & Action Buttons Overlay
            Positioned(
              left: ScreenConstant.sizeMedium,
              right: ScreenConstant.sizeMedium,
              bottom: ScreenConstant.sizeExtraSmall,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name + Verified Badge
                  Row(
                    children: [
                      Obx(
                        () => Text(
                          "${controller.displayName.value}, ${controller.age.value}",
                          style: TextStyle(
                            color: CustomColor.colorWhite,
                            fontSize: FontSize.s22,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Liberation",
                          ),
                        ),
                      ),
                      SizedBox(width: ScreenConstant.sizeExtraSmall),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: CustomColor.colorE11D48,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 12,
                          color: CustomColor.colorWhite,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenConstant.sizeExtraSmall),
                  // Identity Pills Wrap
                  Obx(
                    () => Wrap(
                      spacing: ScreenConstant.sizeExtraSmall,
                      runSpacing: ScreenConstant.sizeExtraSmall,
                      children: [
                        _identityOverlayPill(
                          Icons.female,
                          controller.gender.value,
                        ),
                        _identityOverlayPill(
                          Icons.location_on_outlined,
                          controller.city.value,
                        ),
                        _identityOverlayPill(
                          Icons.favorite_border,
                          controller.orientation.value,
                        ),
                        _identityOverlayPill(
                          Icons.check,
                          "Multiple times",
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: ScreenConstant.sizeSmall),
                  // Hero Action Buttons (Chat, View, Add, Block)
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: _heroActionButton(
                  //         Icons.chat_bubble_outline,
                  //         "Chat",
                  //       ),
                  //     ),
                  //     SizedBox(width: ScreenConstant.sizeExtraSmall),
                  //     Expanded(
                  //       child: _heroActionButton(
                  //         Icons.visibility_outlined,
                  //         "View",
                  //       ),
                  //     ),
                  //     SizedBox(width: ScreenConstant.sizeExtraSmall),
                  //     Expanded(
                  //       child: _heroActionButton(
                  //         Icons.person_add_outlined,
                  //         "Add",
                  //       ),
                  //     ),
                  //     SizedBox(width: ScreenConstant.sizeExtraSmall),
                  //     Expanded(
                  //       child: _heroActionButton(
                  //         Icons.block_outlined,
                  //         "Block",
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _identityOverlayPill(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeSmall,
        vertical: ScreenConstant.sizeExtraSmall / 1.5,
      ),
      decoration: BoxDecoration(
        color: CustomColor.colorWhite.withOpacity(0.2),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: ScreenConstant.minimumIconSize,
            color: CustomColor.colorWhite,
          ),
          SizedBox(width: ScreenConstant.sizeExtraSmall),
          Text(
            label,
            style: const TextStyle(
              color: CustomColor.colorWhite,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: "Liberation",
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroActionButton(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ScreenConstant.sizeExtraSmall + 1,
      ),
      decoration: BoxDecoration(
        color: CustomColor.colorWhite.withOpacity(0.15),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: CustomColor.colorWhite.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 14,
            color: CustomColor.colorWhite,
          ),
          SizedBox(width: ScreenConstant.sizeExtraSmall / 1.5),
          Text(
            label,
            style: const TextStyle(
              color: CustomColor.colorWhite,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: "Liberation",
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Profile Cards
  // ---------------------------------------------------------------------------
  Widget _buildAboutMeCard() {
    return _profileCard(
      icon: Icons.person_outline,
      title: "About Me",
      child: Obx(
        () => Text(
          controller.bio.value,
          style: TextStyles.registerFieldNote.copyWith(
            fontSize: FontSize.s13,
            color: CustomColor.color64748B,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildInterestsCard() {
    return _profileCard(
      icon: Icons.star_outline,
      title: "Interests & Hobbies",
      child: Obx(
        () => _chipWrap(
          controller.interests,
          rose: false,
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return _profileCard(
      icon: Icons.location_on_outlined,
      title: "Location",
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(
            () => Text(
              controller.city.value,
              style: TextStyles.policiesConsentTitle.copyWith(
                fontSize: 14,
                color: CustomColor.color0F172A,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenConstant.sizeSmall,
              vertical: ScreenConstant.sizeExtraSmall / 1.5,
            ),
            decoration: BoxDecoration(
              color: CustomColor.colorF1F5F9,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              "Remains Hidden",
              style: TextStyles.policiesPillText.copyWith(
                fontSize: 11,
                color: CustomColor.color64748B,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLookingForCard() {
    return _profileCard(
      icon: Icons.favorite_outline,
      title: "Looking For",
      child: Obx(
        () => _chipWrap(
          controller.lookingFor,
          rose: true,
        ),
      ),
    );
  }

  Widget _buildSexualPreferencesCard() {
    return _profileCard(
      icon: Icons.shield_outlined,
      title: "Sexual Preferences",
      child: Obx(
        () => Text(
          controller.sexualPreference.value,
          style: TextStyles.policiesConsentTitle.copyWith(
            fontSize: 14,
            color: CustomColor.color64748B,
          ),
        ),
      ),
    );
  }

  Widget _buildRelationshipTypeCard() {
    return _profileCard(
      icon: Icons.favorite_outline,
      title: "Relationship Type",
      child: Obx(
        () => _chipWrap(
          controller.relationshipTypes.map((e) => "♦ $e").toList(),
          rose: true,
        ),
      ),
    );
  }

  Widget _buildOtherDetailsCard() {
    return _profileCard(
      icon: Icons.star_outline,
      title: "Other Details",
      child: Obx(
        () => Column(
          children: [
            _detailRow("Has SOA's:", controller.hasSoa.value),
            SizedBox(height: ScreenConstant.sizeExtraSmall),
            _detailRow("Orientation:", controller.orientation.value),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfoCard() {
    return _profileCard(
      icon: Icons.calendar_today_outlined,
      title: "Account Info",
      child: Obx(
        () => Column(
          children: [
            _detailRow("Member since:", controller.memberSince.value),
            SizedBox(height: ScreenConstant.sizeExtraSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Account status:",
                  style: TextStyles.registerFieldNote.copyWith(
                    fontSize: 13,
                    color: CustomColor.color64748B,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenConstant.sizeSmall,
                    vertical: ScreenConstant.sizeExtraSmall / 1.5,
                  ),
                  decoration: BoxDecoration(
                    color: CustomColor.colorECFDF5,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    controller.accountStatus.value,
                    style: TextStyles.policiesBadgeText.copyWith(
                      fontSize: 11,
                      color: CustomColor.color059669,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyNoticeCard() {
    return _profileCard(
      icon: Icons.lock_outline,
      title: "Privacy Notice",
      child: Text(
        "Your personal information is kept secure and will not be shared without your consent.",
        style: TextStyles.registerFieldNote.copyWith(
          fontSize: 12,
          color: CustomColor.color64748B,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _profileCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ScreenConstant.sizeMedium),
      decoration: BoxDecoration(
        color: CustomColor.colorWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CustomColor.color0F172A.withOpacity(0.06),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: CustomColor.colorBE123C,
              ),
              SizedBox(width: ScreenConstant.sizeExtraSmall + 2),
              Text(
                title,
                style: TextStyles.registerSectionTitle.copyWith(
                  fontSize: 15,
                  color: CustomColor.color0F172A,
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenConstant.sizeSmall),
          child,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyles.registerFieldNote.copyWith(
            fontSize: 13,
            color: CustomColor.color64748B,
          ),
        ),
        Text(
          value,
          style: TextStyles.policiesConsentTitle.copyWith(
            fontSize: 13,
            color: CustomColor.color0F172A,
          ),
        ),
      ],
    );
  }

  Widget _chipWrap(List<String> items, {required bool rose}) {
    if (items.isEmpty) {
      return Text(
        "None selected",
        style: TextStyles.registerFieldNote,
      );
    }
    return Wrap(
      spacing: ScreenConstant.sizeSmall,
      runSpacing: ScreenConstant.sizeSmall,
      children: items.map((e) => _chip(e, rose: rose)).toList(),
    );
  }

  Widget _chip(String label, {required bool rose}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeMedium,
        vertical: ScreenConstant.sizeExtraSmall + 1,
      ),
      decoration: BoxDecoration(
        color: rose ? CustomColor.colorFFF1F2 : CustomColor.colorF1F5F9,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: rose ? CustomColor.colorFECDD3 : CustomColor.colorE2E8F0,
        ),
      ),
      child: Text(
        label,
        style: TextStyles.policiesPillText.copyWith(
          color: rose ? CustomColor.colorBE123C : CustomColor.color334155,
        ),
      ),
    );
  }
}
