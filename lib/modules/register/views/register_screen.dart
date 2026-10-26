import 'dart:io';

import 'package:chat_x/device_manager/screen_constants.dart';
import 'package:chat_x/modules/register/controller/register_controller.dart';
import 'package:chat_x/utils/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';
import '../../../utils/custom_widgets/universal_button.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: CustomColor.colorWhite,
        leading:  GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.onBack,
          child: Icon(
            Icons.arrow_back_ios_new,
            size: ScreenConstant.smallIconSize,
            color: CustomColor.color0F172A,
          ),
        ),
        title: Text(
          "Create Account",
          textAlign: TextAlign.center,
          style: TextStyles.registerAppBarTitle,
        ),
        actions: [
          Container(
            height: ScreenConstant.defaultHeightForty,
            width: ScreenConstant.defaultWidthForty,
            margin: EdgeInsets.only(right: ScreenConstant.sizeMedium),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CustomColor.colorFFF1F2,
              border: Border.all(color: CustomColor.colorFFE4E6, width: 2),
            ),
            child: Icon(
              Icons.person_outline,
              color: CustomColor.colorE11D48,
              size: ScreenConstant.smallIconSize - 2,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenConstant.defaultWidthTwenty,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                    _buildTrialCard(),
                    SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                    _buildProfileName(),
                    SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                    _buildEmailField(),
                    SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                    _buildDob(),
                    SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                    _buildPasswordField(),
                    SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                    _buildConfirmPasswordField(),
                    SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                    _buildBankingCard(),
                    SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                    _buildCountryField(),
                    SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                    _buildPromoField(),
                    SizedBox(height: ScreenConstant.defaultHeightThirty),
                    SizedBox(
                      height: ScreenConstant.defaultHeightFifty,
                      child: buildLoginButton(
                        "Continue",
                        true,
                        controller.onContinueTap,
                        null,
                      ),
                    ),
                    SizedBox(height: ScreenConstant.defaultHeightFifteen),
                    _buildLoginRow(),
                    SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
                    _buildFooter(),
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
  // (2) Discreet & protected badge
  // ---------------------------------------------------------------------------
  Widget _buildDiscreetBadge() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenConstant.sizeMedium,
          vertical: ScreenConstant.sizeExtraSmall,
        ),
        decoration: BoxDecoration(
          color: CustomColor.colorFFF1F2,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: CustomColor.colorFECDD3, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/images/100percent_discreet.png",
              height: ScreenConstant.minimumIconSize,
              color: CustomColor.colorBE123C,
            ),
            SizedBox(width: ScreenConstant.sizeExtraSmall),
            Text(
              "100% DISCREET & PROTECTED",
              style: TextStyles.policiesBadgeText,
            ),
          ],
        ),
      ),
    );
  }


  // ---------------------------------------------------------------------------
  // (3) Add photo control
  // ---------------------------------------------------------------------------
  Widget _buildAddPhoto() {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.onAddPhotoTap,
          child: SizedBox(
            height: ScreenConstant.defaultSizeOneTen,
            width: ScreenConstant.defaultSizeOneTen,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: ScreenConstant.defaultSizeOneTwenty,
                  width: ScreenConstant.defaultSizeOneTwenty,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        CustomColor.colorEC4899,
                        CustomColor.colorF43F5E,
                        CustomColor.color9333EA,
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Obx(() {
                      final File? photo = controller.profileImage.value;
                      return Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: CustomColor.colorWhite,
                        ),
                        child: photo != null
                            ? Image.file(
                          photo,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                            : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/add_photo.png",
                              height: ScreenConstant.texIconSize,
                              color: CustomColor.color475569,
                            ),
                            SizedBox(height: ScreenConstant.sizeSmall),
                            Text(
                              "ADD PHOTO",
                              style: TextStyles.policiesBadgeText.copyWith(
                                color: CustomColor.color334155,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: ScreenConstant.defaultHeightThirty,
                    width: ScreenConstant.defaultWidthThirty,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CustomColor.color0F172A,
                      border: Border.all(
                        color: CustomColor.colorWhite,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.photo_camera,
                      size: ScreenConstant.minimumIconSize,
                      color: CustomColor.colorWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: ScreenConstant.sizeSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/photos_can_be_blurred.png",
              height: ScreenConstant.minimumIconSize,
              color: CustomColor.colorF43F5E,
            ),
            SizedBox(width: ScreenConstant.defaultWidthTen,),
            Text(
              "Photos can be blurred or hidden anytime.",
              textAlign: TextAlign.center,
              style: TextStyles.registerFieldNote,
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Header: circle icon + "Create your account" + subtitle
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    return Column(
      children: [
        SizedBox(height: ScreenConstant.defaultHeightTen,),
        _buildDiscreetBadge(),
        SizedBox(height: ScreenConstant.defaultHeightTen,),
        _buildAddPhoto(),
        // Container(
        //     height: ScreenConstant.defaultHeightOneHundred,width: ScreenConstant.defaultWidthOneHundredFifteen,
        //     child: Image.asset("assets/images/register_top_logo.png",fit: BoxFit.cover,)),
        Text("Create your account", style: TextStyles.registerTitle),
        Text(
          "Join Belgium's discreet adult connection\n network",
          textAlign: TextAlign.center,
          style: TextStyles.registerSubtitle,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Trial card
  // ---------------------------------------------------------------------------
  Widget _buildTrialCard() {
    final BorderRadius radius = BorderRadius.circular(16);
    return Container(
      decoration: BoxDecoration(
        color: CustomColor.colorWhite,
        borderRadius: radius,
        border: Border.all(color: CustomColor.colorFCE7F3, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            // Soft pink glow bloom in the top-right corner (FECDD3 @ ~40%)
            Positioned(
              top: -60,
              right: -50,
              child: Container(
                height: 180,
                width: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      CustomColor.colorFECDD3.withOpacity(0.55),
                      CustomColor.colorFECDD3.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // A faint second bloom in the bottom-left for depth
            Positioned(
              top: -60,
              left: -50,
              child: Container(
                height: 170,
                width: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      CustomColor.colorFFE4E6.withOpacity(0.5),
                      CustomColor.colorFFE4E6.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(ScreenConstant.sizeMedium),
              child: _buildTrialCardContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrialCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Row(
            children: [
              _pill(
                color: CustomColor.colorBE123C.withOpacity(0.1),
                borderColor: Colors.transparent,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      "assets/images/free_trial_logo.png",
                      height: ScreenConstant.defaultHeightFifteen,
                      color: CustomColor.colorBE123C,
                    ),
                    SizedBox(width: ScreenConstant.sizeExtraSmall / 1.5),
                    Text("15-Day Free Trial",
                        style: TextStyles.registerTrialBadge),
                  ],
                ),
              ),
              const Spacer(),
              _pill(
                color: CustomColor.colorECFDF5,
                borderColor: CustomColor.color059669.withOpacity(0.4),
                child: Text("ZERO RISK", style: TextStyles.registerZeroRisk),
              ),
            ],
          ),
          SizedBox(height: ScreenConstant.sizeSmall),
          Text(
            "You will not be charged during your free trial.",
            style: TextStyles.registerTrialHeadline,
          ),
          SizedBox(height: ScreenConstant.sizeDefault),
          Text(
            "Enjoy full uncapped VIP access for 15 days. Cancel anytime "
            "before your trial ends with one tap. If you decide to stay, "
            "membership renews at €19.99/mo with 100% discreet billing.",
            style: TextStyles.registerTrialBody,
          ),
          SizedBox(height: ScreenConstant.sizeSmall),
          Divider(color: CustomColor.colorFCE7F3, thickness: 1),
          SizedBox(height: ScreenConstant.sizeSmall),
          Row(
            children: [
              _checkItem("assets/images/instant.png","Instant cancellation"),
              SizedBox(width: ScreenConstant.sizeMedium),
              _checkItem("assets/images/nutral.png","Neutral descriptor"),
            ],
          ),
        ],
      );
  }

  Widget _checkItem(String image,String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(image,height: ScreenConstant.minimumIconSize,),
        SizedBox(width: ScreenConstant.sizeExtraSmall),
        Text(text, style: TextStyles.registerTrialCheck),
      ],
    );
  }

  Widget _pill({required Color color, required Widget child,required Color borderColor}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeSmall,
        vertical: ScreenConstant.sizeExtraSmall / 1.3,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        color: color,
        borderRadius: BorderRadius.circular(100),
      ),
      child: child,
    );
  }

  // ---------------------------------------------------------------------------
  // Field helpers
  // ---------------------------------------------------------------------------
  Widget _label(String text, {bool required = true, Widget? trailing}) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenConstant.sizeSmall),
      child: Row(
        children: [
          Text(text, style: TextStyles.loginFieldLabel),
          if (required)
            Text(" *", style: TextStyles.registerVerifyNoteHighlight),
          if (trailing != null) ...[
            const Spacer(),
            trailing,
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // (4) Profile name
  // ---------------------------------------------------------------------------
  Widget _buildProfileName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Profile Name", trailing: _greenPill("Pseudonym OK")),
        SizedBox(
          height: ScreenConstant.defaultHeightFifty,
          child: CustomTextField(
            borderRadius: 26,
            controller: controller.profileNameController,
            hintText: "e.g. Alex_BXL or VelvetMystique",
            hintStyle: TextStyles.loginTopText.copyWith(fontSize: FontSize.s14,color: CustomColor.color94A3B8),
            borderColor: CustomColor.colorE2E8F0,
          ),
        ),
        SizedBox(height: ScreenConstant.sizeExtraSmall + 2),
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: ScreenConstant.minimumIconSize - 2,
              color: CustomColor.color94A3B8,
            ),
            SizedBox(width: ScreenConstant.sizeExtraSmall + 2),
            Expanded(
              child: Text(
                "This is your public display name. Never use your real legal name.",
                style: TextStyles.registerFieldNote,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _greenPill(String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeSmall,
        vertical: ScreenConstant.sizeExtraSmall / 1.5,
      ),
      decoration: BoxDecoration(
        color: CustomColor.colorECFDF5,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: CustomColor.color10B981.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lock_open_outlined,
            size: ScreenConstant.minimumIconSize - 2,
            color: CustomColor.color059669,
          ),
          SizedBox(width: ScreenConstant.sizeExtraSmall / 2),
          Text(text, style: TextStyles.paymentValidFormat),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Email address"),
        SizedBox(
          height: ScreenConstant.defaultHeightFifty,
          child: CustomTextField(
            borderRadius: 26,
            controller: controller.emailController,
            hintStyle: TextStyles.loginTopText.copyWith(fontSize: FontSize.s14,color: CustomColor.color94A3B8),
            hintText: "name@example.com",
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            borderColor: CustomColor.colorE2E8F0,
            prefix: Icon(
              Icons.mail_outline,
              size: ScreenConstant.smallIconSize,
              color: CustomColor.color94A3B8,
            ),
          ),
        ),
        SizedBox(height: ScreenConstant.sizeExtraSmall + 2),
        Row(
          children: [
            Icon(
              Icons.visibility_off_outlined,
              size: ScreenConstant.minimumIconSize - 2,
              color: CustomColor.color94A3B8,
            ),
            SizedBox(width: ScreenConstant.sizeExtraSmall),
            Flexible(
              child: Text(
                "Your email remains completely hidden from all members.",
                style: TextStyles.registerFieldNote,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // (6) Date of birth / age verification
  // ---------------------------------------------------------------------------
  Widget _buildDob() {
    final int currentYear = DateTime.now().year;
    final List<int> days = List.generate(31, (i) => i + 1);
    final List<int> months = List.generate(12, (i) => i + 1);
    final List<int> years =
    List.generate(currentYear - 18 - 1950 + 1, (i) => currentYear - 18 - i);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Date of Birth / Age Verification"),
        Row(
          children: [
            Expanded(
              child: Obx(
                    () => _dropdown<int>(
                  value: controller.selectedDobDay.value,
                  hint: "Day",
                  items: days
                      .map(
                        (d) => DropdownMenuItem<int>(
                      value: d,
                      child: Text(
                        "$d",
                        style: TextStyles.loginTopText
                            .copyWith(fontSize: FontSize.s14),
                      ),
                    ),
                  )
                      .toList(),
                  onChanged: controller.setDobDay,
                ),
              ),
            ),
            SizedBox(width: ScreenConstant.sizeSmall),
            Expanded(
              child: Obx(
                    () => _dropdown<int>(
                  value: controller.selectedDobMonth.value,
                  hint: "Month",
                  items: months
                      .map(
                        (m) => DropdownMenuItem<int>(
                      value: m,
                      child: Text(
                        "$m",
                        style: TextStyles.loginTopText
                            .copyWith(fontSize: FontSize.s14),
                      ),
                    ),
                  )
                      .toList(),
                  onChanged: controller.setDobMonth,
                ),
              ),
            ),
            SizedBox(width: ScreenConstant.sizeSmall),
            Expanded(
              child: Obx(
                    () => _dropdown<int>(
                  value: controller.selectedDobYear.value,
                  hint: "Year",
                  items: years
                      .map(
                        (y) => DropdownMenuItem<int>(
                      value: y,
                      child: Text(
                        "$y",
                        style: TextStyles.loginTopText
                            .copyWith(fontSize: FontSize.s14),
                      ),
                    ),
                  )
                      .toList(),
                  onChanged: controller.setDobYear,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenConstant.sizeExtraSmall + 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              "assets/images/dateofbirth.png",
              height: ScreenConstant.minimumIconSize,
            ),
            SizedBox(width: ScreenConstant.defaultWidthTen,),
            Expanded(
              child: Text(
                "Only your calculated age (e.g. 28) will be displayed. Your exact "
                    "birth date remains completely hidden.",
                style: TextStyles.registerFieldNote,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? hint,
  }) {
    return Container(
      height: ScreenConstant.defaultHeightFifty,
      padding: EdgeInsets.symmetric(horizontal: ScreenConstant.sizeMedium),
      decoration: BoxDecoration(
        color: CustomColor.colorF8FAFC,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: CustomColor.colorE2E8F0, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: hint == null
              ? null
              : Text(
            hint,
            overflow: TextOverflow.ellipsis,
            style: TextStyles.loginTopText.copyWith(
              fontSize: FontSize.s14,
              color: CustomColor.color94A3B8,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: CustomColor.color64748B,
            size: ScreenConstant.smallIconSize,
          ),
          style: TextStyles.loginTopText.copyWith(fontSize: FontSize.s14),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Password"),
        Obx(
          () => SizedBox(
            height: ScreenConstant.defaultHeightFifty,
            child: CustomTextField(
              borderRadius: 26,
              controller: controller.passwordController,
              hintText: "Create password",
              hintStyle: TextStyles.loginTopText.copyWith(fontSize: FontSize.s14,color: CustomColor.color94A3B8),
              obscureText: controller.obscurePassword.value,
              textInputAction: TextInputAction.next,
              borderColor: CustomColor.colorE2E8F0,
              prefix: Icon(
                Icons.lock_outline,
                size: ScreenConstant.smallIconSize,
                color: CustomColor.color94A3B8,
              ),
              suffix: GestureDetector(
                onTap: controller.togglePasswordVisibility,
                child: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: ScreenConstant.smallIconSize,
                  color: CustomColor.color94A3B8,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Confirm password"),
        Obx(
          () => SizedBox(
            height: ScreenConstant.defaultHeightFifty,
            child: CustomTextField(
              hintStyle: TextStyles.loginTopText.copyWith(fontSize: FontSize.s14,color: CustomColor.color94A3B8),
              borderRadius: 26,
              controller: controller.confirmPasswordController,
              hintText: "Confirm password",
              obscureText: controller.obscureConfirmPassword.value,
              textInputAction: TextInputAction.next,
              borderColor: CustomColor.colorE2E8F0,
              prefix: Icon(
                Icons.lock_outline,
                size: ScreenConstant.smallIconSize,
                color: CustomColor.color94A3B8,
              ),
              suffix: GestureDetector(
                onTap: controller.toggleConfirmPasswordVisibility,
                child: Icon(
                  controller.obscureConfirmPassword.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: ScreenConstant.smallIconSize,
                  color: CustomColor.color94A3B8,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Banking / payment details card
  // ---------------------------------------------------------------------------
  Widget _buildBankingCard() {
    return Container(
      padding: EdgeInsets.all(ScreenConstant.sizeMedium),
      decoration: BoxDecoration(
        color: CustomColor.colorWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CustomColor.colorE2E8F0, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Banking / payment details",
                  style: TextStyles.registerSectionTitle),
              Text(" *", style: TextStyles.registerVerifyNoteHighlight),
            ],
          ),
          SizedBox(height: ScreenConstant.sizeSmall),
          Row(
            children: [
              Text("SUPPORTED IN BE", style: TextStyles.registerSupportedLabel),
              const Spacer(),
              _paymentChip("Bancontact"),
              SizedBox(width: ScreenConstant.sizeExtraSmall),
              _paymentChip("VISA"),
              SizedBox(width: ScreenConstant.sizeExtraSmall),
              _paymentChip("MC"),
            ],
          ),
          SizedBox(height: ScreenConstant.sizeSmall),
          SizedBox(
            height: ScreenConstant.defaultHeightFifty,
            child: CustomTextField(
              hintStyle: TextStyles.loginTopText.copyWith(fontSize: FontSize.s14,color: CustomColor.color94A3B8),
              borderRadius: 26,
              controller: controller.cardNumberController,
              hintText: "Card number",
              keyboardType: TextInputType.number,
              borderColor: CustomColor.colorE2E8F0,
              prefix: Icon(
                Icons.credit_card,
                size: ScreenConstant.smallIconSize,
                color: CustomColor.color94A3B8,
              ),
            ),
          ),
          SizedBox(height: ScreenConstant.sizeSmall),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: ScreenConstant.defaultHeightFifty,
                  child: CustomTextField(
                    hintStyle: TextStyles.loginTopText.copyWith(fontSize: FontSize.s14,color: CustomColor.color94A3B8),
                    borderRadius: 26,
                    textAlign: TextAlign.center,
                    controller: controller.expiryController,
                    hintText: "MM / YY",
                    keyboardType: TextInputType.number,
                    borderColor: CustomColor.colorE2E8F0,
                  ),
                ),
              ),
              SizedBox(width: ScreenConstant.sizeSmall),
              Expanded(
                child: SizedBox(
                  height: ScreenConstant.defaultHeightFifty,
                  child: CustomTextField(
                    hintStyle: TextStyles.loginTopText.copyWith(fontSize: FontSize.s14,color: CustomColor.color94A3B8),
                    borderRadius: 26,
                    textAlign: TextAlign.center,
                    controller: controller.cvcController,
                    hintText: "CVC",
                    keyboardType: TextInputType.number,
                    borderColor: CustomColor.colorE2E8F0,
                    suffix: Icon(
                      Icons.help_outline,
                      size: ScreenConstant.minimumIconSize,
                      color: CustomColor.color94A3B8,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ScreenConstant.sizeSmall),
          Container(
            padding: EdgeInsets.all(ScreenConstant.sizeSmall),
            decoration: BoxDecoration(
              color: CustomColor.colorWhite,
              border: Border.all(color: CustomColor.color475569.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  "assets/images/card_verification_logo.png",
                  height: ScreenConstant.minimumIconSize,
                  color: CustomColor.colorEF4444,
                ),
                SizedBox(width: ScreenConstant.sizeExtraSmall),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyles.registerVerifyNote,
                      children: [
                        TextSpan(
                          text:
                              "Card verification required to verify authenticity "
                              "& age.",
                          style: TextStyles.registerVerifyNoteHighlight.copyWith(color: CustomColor.color475569,height: 1.3),
                        ),
                        TextSpan(
                          text:
                          "€0.00 charged today. ",
                          style: TextStyles.registerVerifyNoteHighlight.copyWith(color: CustomColor.color0F172A,height: 1.3),
                        ),
                        TextSpan(
                          text:
                          "Appears as neutral ",
                          style: TextStyles.registerVerifyNoteHighlight.copyWith(color: CustomColor.color475569,height: 1.3),
                        ),
                        TextSpan(
                          text: '"EX-NETWORK BV"',
                          style: TextStyles.registerVerifyNoteHighlight.copyWith(height: 1.3),
                        ),
                         TextSpan(text: " on statements.",style: TextStyles.registerVerifyNoteHighlight.copyWith(color: CustomColor.color475569,height: 1.3),),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ScreenConstant.defaultHeightTen),
          SizedBox(
            height: ScreenConstant.defaultHeightFifty,
            child: buildLoginButton(
              "More info",
              true,
              controller.onMoreInfoTap,
              null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeDefault,
        vertical: ScreenConstant.sizeExtraSmall / 1.3,
      ),
      decoration: BoxDecoration(
        color: CustomColor.colorWhite,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: CustomColor.colorF1F5F9, width: 1)
      ),
      child: Text(text, style: TextStyles.registerPaymentChip),
    );
  }

  // ---------------------------------------------------------------------------
  // Country dropdown
  // ---------------------------------------------------------------------------
  Widget _buildCountryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Country"),
        Container(
          height: ScreenConstant.defaultHeightFifty,
          padding: EdgeInsets.symmetric(horizontal: ScreenConstant.sizeMedium),
          decoration: BoxDecoration(
            color: CustomColor.colorF8FAFC,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: CustomColor.colorE2E8F0, width: 1),
          ),
          child: Row(
            children: [
              Text("🇧🇪  ", style: TextStyles.registerCountryText),
              Expanded(
                child: Obx(
                  () => DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: controller.selectedCountry.value,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: CustomColor.color64748B,
                        size: ScreenConstant.smallIconSize,
                      ),
                      style: TextStyles.loginTopText.copyWith(fontSize: FontSize.s14),
                      items: controller.countries
                          .map(
                            (c) => DropdownMenuItem<String>(
                              value: c,
                              child: Text(
                                c,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyles.loginTopText.copyWith(fontSize: FontSize.s14),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) controller.onCountrySelected(value);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Referral / promo code (optional)
  // ---------------------------------------------------------------------------
  Widget _buildPromoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(
          "Referral / promo code",
          required: false,
          trailing: Text("Optional", style: TextStyles.registerOptional),
        ),
        SizedBox(
          height: ScreenConstant.defaultHeightFifty,
          child: CustomTextField(
            borderRadius: 26,
            hintStyle: TextStyles.loginTopText.copyWith(fontSize: FontSize.s14,color: CustomColor.color94A3B8),
            controller: controller.promoController,
            hintText: "ENTER PROMO CODE",
            borderColor: CustomColor.colorE2E8F0,
            textInputAction: TextInputAction.done,
            prefix: Icon(
              Icons.local_offer_outlined,
              size: ScreenConstant.smallIconSize,
              color: CustomColor.color94A3B8,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Already have an account? Login
  // ---------------------------------------------------------------------------
  Widget _buildLoginRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Already have an account? ", style: TextStyles.loginFooterText),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.onLoginTap,
          child: Text("Login", style: TextStyles.loginFooterLink),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Footer strip + compliance text
  // ---------------------------------------------------------------------------
  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(ScreenConstant.sizeMedium),
      decoration: BoxDecoration(
        color: CustomColor.colorF8FAFC,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CustomColor.colorE2E8F0, width: 1),
      ),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: ScreenConstant.sizeMedium,
            runSpacing: ScreenConstant.sizeExtraSmall,
            children: [
              _footerBadge(Icons.lock_outline, "End-to-End Encrypted",
                  CustomColor.colorBE185D,false,""),
              _footerBadge(Icons.verified_user_outlined,
                  "100% Discreet Billing", CustomColor.colorBE123C,true,"assets/images/discount.png",),
              _footerBadge(Icons.check_circle_outline, "18+ Only",
                  CustomColor.colorDB2777,true,"assets/images/card_verification_logo.png"),
            ],
          ),
          SizedBox(height: ScreenConstant.sizeSmall),
          Text(
            "Strictly compliant with Belgian privacy regulations & "
            "European GDPR standards.",
            textAlign: TextAlign.center,
            style: TextStyles.registerCompliance.copyWith(color: CustomColor.color64748B),
          ),
        ],
      ),
    );
  }

  Widget _footerBadge(IconData icon, String text, Color color, bool isIcon, String? image) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        isIcon?Image.asset(image!,height: ScreenConstant.minimumIconSize - 2,color: color,):Icon(icon, size: ScreenConstant.minimumIconSize - 2, color: color),
        SizedBox(width: ScreenConstant.sizeExtraSmall),
        Text(text, style: TextStyles.registerFooterStrip),
      ],
    );
  }
}
