import 'package:chat_x/device_manager/screen_constants.dart';
import 'package:chat_x/modules/register/controller/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';
import 'widgets/intimate_desires_form.dart';

class IntimateDesiresScreen extends GetView<RegisterController> {
  const IntimateDesiresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: CustomColor.colorWhite,
        elevation: 0,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.onBack,
          child: Icon(
            Icons.arrow_back_ios_new,
            size: ScreenConstant.smallIconSize,
            color: CustomColor.color0F172A,
          ),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              "STEP 5 OF 5",
              textAlign: TextAlign.center,
              style: TextStyles.policiesBadgeText,
            ),
            Text(
              "Profile Photos",
              textAlign: TextAlign.center,
              style: TextStyles.registerTitle,
            ),
          ],
        ),
        actions: [
          // Icon(
          //   Icons.lock_outline,
          //   size: ScreenConstant.smallIconSize,
          //   color: CustomColor.color94A3B8,
          // ),
          // SizedBox(width: ScreenConstant.defaultWidthTen,),
          // Container(
          //   height: ScreenConstant.defaultHeightForty,
          //   width: ScreenConstant.defaultWidthForty,
          //   margin: EdgeInsets.only(right: ScreenConstant.sizeMedium),
          //   decoration: BoxDecoration(
          //     shape: BoxShape.circle,
          //     color: CustomColor.colorFFF1F2,
          //     border: Border.all(color: CustomColor.colorFFE4E6, width: 2),
          //   ),
          //   child: Icon(
          //     Icons.person_outline,
          //     color: CustomColor.colorE11D48,
          //     size: ScreenConstant.smallIconSize - 2,
          //   ),
          // ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            ScreenConstant.defaultWidthTwenty,
            ScreenConstant.defaultHeightTen,
            ScreenConstant.defaultWidthTwenty,
            ScreenConstant.defaultHeightThirty,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopEyebrow(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildIntro(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              const IntimateDesiresForm(),
              SizedBox(height: ScreenConstant.defaultHeightThirty),
              _buildSaveButton(),
              SizedBox(height: ScreenConstant.defaultHeightFifteen),
              Center(child: _buildSkipLink()),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              Center(child: _buildFooter()),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // (1) Top eyebrow pill
  // ---------------------------------------------------------------------------
  Widget _buildTopEyebrow() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeMedium,
        vertical: ScreenConstant.sizeSmall,
      ),
      decoration: BoxDecoration(
        color: CustomColor.colorFFF1F2,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: CustomColor.colorFECDD3, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: CustomColor.colorBE123C,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: ScreenConstant.sizeExtraSmall),
          Text(
            "PROFILE SETUP ",
            style: TextStyles.policiesBadgeText.copyWith(
              color: CustomColor.colorBE123C,
            ),
          ),
          SizedBox(width: ScreenConstant.sizeExtraSmall),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: CustomColor.colorBE123C,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: ScreenConstant.sizeExtraSmall),
          Text(
            "STEP 5 OF 5",
            style: TextStyles.policiesBadgeText.copyWith(
              color: CustomColor.colorBE123C,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // (2) Intro heading + paragraph
  // ---------------------------------------------------------------------------
  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Set Your Intimate Desires",
          style: TextStyles.registerTitle.copyWith(fontSize: FontSize.s16),
        ),
        SizedBox(height: ScreenConstant.sizeSmall),
        Text(
          "Choose what you're open to exploring. Preferences power smart "
          "Belgian matchmaking while remaining completely confidential.",
          style: TextStyles.registerFieldNote.copyWith(
            color: CustomColor.color64748B,
              fontSize: FontSize.s16
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // (6) Save & Complete Setup button
  // ---------------------------------------------------------------------------
  Widget _buildSaveButton() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.onSaveCompleteSetup,
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
              color: CustomColor.colorDB2777.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Save & Complete Setup",
              style: TextStyles.loginButtonText.copyWith(
                color: CustomColor.colorWhite,
              ),
            ),
            SizedBox(width: ScreenConstant.sizeSmall),
            Icon(
              Icons.arrow_forward,
              color: CustomColor.colorWhite,
              size: ScreenConstant.smallIconSize,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // (7) Skip link
  // ---------------------------------------------------------------------------
  Widget _buildSkipLink() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.onSkipIntimateDesires,
      child: Text(
        "Skip for now (configure later in Settings)",
        textAlign: TextAlign.center,
        style: TextStyles.paymentCancelLink,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // (8) Footer security strip
  // ---------------------------------------------------------------------------
  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(ScreenConstant.sizeMedium),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: ScreenConstant.sizeMedium,
        runSpacing: ScreenConstant.sizeExtraSmall,
        children: [
          _footerBadge(
            Icons.visibility_off,
            "Zero Search Indexing",
            CustomColor.colorBE185D,
          ),
          _footerBadge(
            Icons.gavel_outlined,
            "Belgian GDPR",
            CustomColor.colorBE123C,
          ),
          _footerBadge(
            Icons.lock_outline,
            "Vault Encrypted",
            CustomColor.colorBE185D,
          ),
        ],
      ),
    );
  }

  Widget _footerBadge(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: ScreenConstant.minimumIconSize - 2, color: color),
        SizedBox(width: ScreenConstant.sizeExtraSmall),
        Text(text, style: TextStyles.registerFooterStrip),
      ],
    );
  }
}
