import 'package:chat_x/device_manager/screen_constants.dart';
import 'package:chat_x/modules/register/controller/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';
import '../../../utils/image_utils/image_utils.dart';

class PoliciesAgreementScreen extends GetView<RegisterController> {
  const PoliciesAgreementScreen({super.key});

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
        title: Row(
          children: [
            Image.asset(
              ImageUtils.policiesSafetyAgreement,
              height: ScreenConstant.minimumIconSize,
              color: CustomColor.colorBE123C,
            ),
            SizedBox(width: ScreenConstant.sizeExtraSmall),
            Expanded(
              child: Text(
                "Policies & Safety Agreement",
                style: TextStyles.registerAppBarTitle,
              ),
            ),
          ],
        ),
        actions: [
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
          padding: EdgeInsets.symmetric(
            horizontal: ScreenConstant.defaultWidthTwenty,
            vertical: ScreenConstant.sizeMedium,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderCard(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildPolicySectionsList(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildConsentRequirementsHeader(),
              SizedBox(height: ScreenConstant.sizeSmall),
              _buildConsentCheckboxes(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildSubmitButton(),
              SizedBox(height: ScreenConstant.sizeMedium),
              _buildFooterSecurityStrip(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Header Banner Card
  // ---------------------------------------------------------------------------
  Widget _buildHeaderCard() {
    final BorderRadius radius = BorderRadius.circular(24);
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
            // Soft top-right pink gradient bloom
            Positioned(
              top: -50,
              right: -40,
              child: Container(
                height: 180,
                width: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      CustomColor.colorFECDD3.withOpacity(0.5),
                      CustomColor.colorFECDD3.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(ScreenConstant.sizeLarge),
              child: Column(
                children: [
                  // Icon emblem
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CustomColor.colorFFF1F2,
                      border: Border.all(
                        color: CustomColor.colorFFE4E6,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.edit_note,
                      size: 28,
                      color: CustomColor.colorBE123C,
                    ),
                  ),
                  SizedBox(height: ScreenConstant.sizeSmall),
                  // Mandatory Verification Pill
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenConstant.sizeMedium,
                      vertical: ScreenConstant.sizeExtraSmall / 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: CustomColor.colorFFF1F2,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: CustomColor.colorFECDD3,
                        width: 1,
                      ),
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
                          "MANDATORY VERIFICATION",
                          style: TextStyles.policiesBadgeText,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: ScreenConstant.sizeMedium),
                  Text(
                    "Policies & Safety Agreement",
                    textAlign: TextAlign.center,
                    style: TextStyles.policiesHeaderTitle,
                  ),
                  SizedBox(height: ScreenConstant.sizeSmall),
                  Text(
                    "Please review and accept our platform standards, privacy commitments, and legal agreements before entering.",
                    textAlign: TextAlign.center,
                    style: TextStyles.policiesHeaderSubtitle,
                  ),
                  SizedBox(height: ScreenConstant.sizeMedium),
                  // Feature pills
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: ScreenConstant.sizeSmall,
                    runSpacing: ScreenConstant.sizeExtraSmall,
                    children: [
                      _headerPill(
                        Icons.verified_user_outlined,
                        "Belgian Law Compliant",
                        CustomColor.colorF8FAFC,
                        CustomColor.colorE2E8F0,
                        CustomColor.colorBE123C,
                      ),
                      _headerPill(
                        Icons.lock_outline,
                        "100% Confidential",
                        CustomColor.colorFFF1F2,
                        CustomColor.colorFFE4E6,
                        CustomColor.colorBE123C,
                      ),
                      _headerPill(
                        Icons.block_outlined,
                        "Zero Tolerance",
                        CustomColor.colorFEF2F2,
                        CustomColor.colorFECDD3,
                        CustomColor.colorEF4444,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerPill(
    IconData icon,
    String label,
    Color bg,
    Color border,
    Color iconColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenConstant.sizeSmall,
        vertical: ScreenConstant.sizeExtraSmall / 1.5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: ScreenConstant.minimumIconSize - 2, color: iconColor),
          SizedBox(width: ScreenConstant.sizeExtraSmall),
          Text(label, style: TextStyles.policiesPillText),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Expandable Policy Section Items (1 to 7)
  // ---------------------------------------------------------------------------
  Widget _buildPolicySectionsList() {
    final List<_PolicyItemData> items = [
      _PolicyItemData(
        title: "1. Terms & Conditions",
        subtitle: "Governance, verified identity, member rights",
        icon: Icons.description_outlined,
        iconBg: CustomColor.colorFFF1F2,
        iconColor: CustomColor.colorBE123C,
        body:
            "Sets out core membership rules, identity verification guidelines, terms of account usage, and user rights under Belgian digital service regulations.",
      ),
      _PolicyItemData(
        title: "2. Privacy & Data Shield",
        subtitle: "GDPR-first, zero public web indexing",
        icon: Icons.shield_outlined,
        iconBg: CustomColor.colorFFF1F2,
        iconColor: CustomColor.colorBE123C,
        body:
            "Ensures complete data masking, strict GDPR compliance, encrypted personal records, and guarantees that member profiles remain unindexed by web search engines.",
      ),
      _PolicyItemData(
        title: "3. Community Standards",
        subtitle: "Mutual respect, active consent, safety",
        icon: Icons.favorite_outline,
        iconBg: CustomColor.colorFFF1F2,
        iconColor: CustomColor.colorBE123C,
        body:
            "Mandates explicit consent, respectful interactions, zero harassment policies, and robust reporting mechanisms to maintain a safe environment.",
      ),
      _PolicyItemData(
        title: "4. 15-Day Trial Terms",
        subtitle: "Zero initial charges, 1-tap cancellation",
        badge: "Free",
        icon: Icons.card_giftcard_outlined,
        iconBg: CustomColor.colorFFF1F2,
        iconColor: CustomColor.colorBE123C,
        body:
            "Provides 15 days of full VIP access with zero upfront fees. Members can cancel instantly at any time prior to trial expiry with a single tap.",
      ),
      _PolicyItemData(
        title: "5. Warning: Prohibited Conduct",
        subtitle: "Anti-fraud, anti-exploitation, bans",
        icon: Icons.warning_amber_rounded,
        iconBg: CustomColor.colorFEF3C7,
        iconColor: CustomColor.colorD97706,
        body:
            "Strictly forbids commercial solicitation, non-consensual media distribution, fraud, and illegal behavior. Violations result in instant, permanent expulsion.",
      ),
      _PolicyItemData(
        title: "6. Legal Consequences",
        subtitle: "Belgian & EU penal prosecution",
        icon: Icons.gavel_outlined,
        iconBg: CustomColor.colorFFF1F2,
        iconColor: CustomColor.colorBE123C,
        body:
            "Outlines civil and criminal penalties under Belgian and European law for harassment, identity theft, unauthorized disclosure, or fraudulent activity.",
      ),
      _PolicyItemData(
        title: "7. Our Mutual Pledge",
        subtitle: "Discretion, integrity, responsible usage",
        icon: Icons.favorite_border,
        iconBg: CustomColor.colorFFF1F2,
        iconColor: CustomColor.colorBE123C,
        body:
            "Our shared commitment to uphold discretion, safeguard member privacy, and foster an honorable community built on mutual respect and integrity.",
      ),
    ];

    return Column(
      children: List.generate(items.length, (index) {
        return _buildSinglePolicyCard(items[index], index);
      }),
    );
  }

  Widget _buildSinglePolicyCard(_PolicyItemData data, int index) {
    return Obx(() {
      final bool isExpanded = controller.expandedPolicySections[index];
      return Container(
        margin: EdgeInsets.only(bottom: ScreenConstant.sizeSmall),
        decoration: BoxDecoration(
          color: CustomColor.colorWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CustomColor.colorE2E8F0, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => controller.togglePolicySection(index),
          child: Padding(
            padding: EdgeInsets.all(ScreenConstant.sizeMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: data.iconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(data.icon, color: data.iconColor, size: 22),
                    ),
                    SizedBox(width: ScreenConstant.sizeMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  data.title,
                                  style: TextStyles.policiesItemTitle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (data.badge != null) ...[
                                SizedBox(width: ScreenConstant.sizeExtraSmall),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: ScreenConstant.sizeExtraSmall + 2,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: CustomColor.colorFFF1F2,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    data.badge!,
                                    style: TextStyles.registerTrialBadge.copyWith(
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 2),
                          Text(
                            data.subtitle,
                            style: TextStyles.policiesItemSubtitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: CustomColor.color64748B,
                      size: ScreenConstant.smallIconSize,
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  SizedBox(height: ScreenConstant.sizeSmall),
                  Divider(color: CustomColor.colorE2E8F0, thickness: 1),
                  SizedBox(height: ScreenConstant.sizeExtraSmall),
                  Text(
                    data.body,
                    style: TextStyles.policiesItemBody,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Consent Requirements Header
  // ---------------------------------------------------------------------------
  Widget _buildConsentRequirementsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "CONSENT REQUIREMENTS",
          style: TextStyles.policiesConsentHeader,
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: controller.toggleSelectAll,
          child: Obx(
            () => Text(
              controller.isAllConsentAgreed ? "Deselect All" : "Select All",
              style: TextStyles.policiesSelectAll,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 5 Consent Checkboxes
  // ---------------------------------------------------------------------------
  Widget _buildConsentCheckboxes() {
    return Column(
      children: [
        _consentCheckboxCard(
          title: "I agree to the Terms & Conditions",
          subtitle: "Governing eligibility and membership rights in Belgium.",
          valueRx: controller.agreeTerms,
        ),
        _consentCheckboxCard(
          title: "I agree to the Privacy Policy",
          subtitle:
              "Including masked identity protection and strict GDPR compliance.",
          valueRx: controller.agreePrivacy,
        ),
        _consentCheckboxCard(
          title: "I understand the community rules",
          subtitle:
              "Active mutual consent and zero harassment standards.",
          valueRx: controller.agreeCommunity,
        ),
        _consentCheckboxCard(
          title: "I understand the warning regarding prohibited behavior",
          subtitle:
              "Including legal consequences under Belgian and EU penal codes.",
          valueRx: controller.agreeProhibited,
        ),
        _consentCheckboxCard(
          title: "I understand the 15-day free trial & subscription terms",
          subtitle:
              "No initial charge, no commitment, 1-tap instant cancellation.",
          valueRx: controller.agreeTrial,
        ),
      ],
    );
  }

  Widget _consentCheckboxCard({
    required String title,
    required String subtitle,
    required RxBool valueRx,
  }) {
    return Obx(() {
      final bool isChecked = valueRx.value;
      return Container(
        margin: EdgeInsets.only(bottom: ScreenConstant.sizeSmall),
        decoration: BoxDecoration(
          color: CustomColor.colorWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isChecked
                ? CustomColor.colorFECDD3
                : CustomColor.colorE2E8F0,
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => valueRx.value = !valueRx.value,
          child: Padding(
            padding: EdgeInsets.all(ScreenConstant.sizeMedium),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 24,
                  width: 24,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: isChecked
                        ? CustomColor.colorBE185D
                        : CustomColor.colorWhite,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isChecked
                          ? CustomColor.colorBE185D
                          : CustomColor.color94A3B8,
                      width: 1.5,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: CustomColor.colorWhite,
                        )
                      : null,
                ),
                SizedBox(width: ScreenConstant.sizeMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyles.policiesConsentTitle,
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyles.policiesConsentSubtitle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Action Button & Disclaimer
  // ---------------------------------------------------------------------------
  Widget _buildSubmitButton() {
    return Column(
      children: [
        Obx(() {
          final bool isEnabled = controller.isAllConsentAgreed;
          return GestureDetector(
            onTap: isEnabled ? controller.onAgreeAndContinue : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: ScreenConstant.defaultHeightFifty,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: isEnabled
                    ? const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          CustomColor.colorBE185D,
                          CustomColor.color581C87,
                        ],
                      )
                    : null,
                color: isEnabled ? null : CustomColor.colorF1F5F9,
                border: isEnabled
                    ? null
                    : Border.all(color: CustomColor.colorE2E8F0, width: 1),
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: CustomColor.colorDB2777.withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Agree & Continue",
                    style: TextStyles.loginButtonText.copyWith(
                      color: isEnabled
                          ? CustomColor.colorWhite
                          : CustomColor.color94A3B8,
                    ),
                  ),
                  SizedBox(width: ScreenConstant.sizeSmall),
                  Icon(
                    Icons.arrow_forward,
                    color: isEnabled
                        ? CustomColor.colorWhite
                        : CustomColor.color94A3B8,
                    size: ScreenConstant.smallIconSize,
                  ),
                ],
              ),
            ),
          );
        }),
        SizedBox(height: ScreenConstant.sizeSmall),
        Text(
          "By clicking Agree & Continue, you confirm you are 18+\nand bound by our legal agreements.",
          textAlign: TextAlign.center,
          style: TextStyles.policiesDisclaimer,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Footer Security Strip
  // ---------------------------------------------------------------------------
  Widget _buildFooterSecurityStrip() {
    return Container(
      padding: EdgeInsets.all(ScreenConstant.sizeMedium),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: ScreenConstant.sizeMedium,
        runSpacing: ScreenConstant.sizeExtraSmall,
        children: [
          _footerSecurityBadge(
            Icons.lock_outline,
            "End-to-End Encrypted",
            CustomColor.colorBE185D,
          ),
          _footerSecurityBadge(
            Icons.gavel_outlined,
            "GDPR & Belgian Penal Code",
            CustomColor.colorBE123C,
          ),
          _footerSecurityBadge(
            Icons.block_outlined,
            "Zero Charge Trial",
            CustomColor.colorE11D48,
          ),
        ],
      ),
    );
  }

  Widget _footerSecurityBadge(IconData icon, String text, Color color) {
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

class _PolicyItemData {
  final String title;
  final String subtitle;
  final String body;
  final String? badge;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  _PolicyItemData({
    required this.title,
    required this.subtitle,
    required this.body,
    this.badge,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });
}
