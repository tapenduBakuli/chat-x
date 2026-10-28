import 'package:chat_x/device_manager/screen_constants.dart';
import 'package:chat_x/modules/register/controller/register_controller.dart';
import 'package:chat_x/utils/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/TextStyles.dart';
import '../../../utils/colors/app_colors.dart';
import '../../../utils/custom_widgets/universal_button.dart';
import '../../../utils/image_utils/image_utils.dart';

class PaymentDetailsScreen extends GetView<RegisterController> {
  const PaymentDetailsScreen({super.key});

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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock,
              size: ScreenConstant.minimumIconSize,
              color: CustomColor.colorBE123C,
            ),
            SizedBox(width: ScreenConstant.sizeExtraSmall),
            Text("Payment Details", style: TextStyles.registerAppBarTitle),
          ],
        ),
        actions: [
          Icon(
            Icons.shield_outlined,
            size: ScreenConstant.smallIconSize,
            color: CustomColor.color64748B,
          ),
          SizedBox(width: ScreenConstant.sizeSmall),
          Container(
            height: ScreenConstant.defaultHeightThirty,
            width: ScreenConstant.defaultHeightThirty,
            margin: EdgeInsets.only(right: ScreenConstant.sizeMedium),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CustomColor.colorFFF1F2,
              border: Border.all(color: CustomColor.colorFFE4E6, width: 2),
            ),
            child: Icon(
              Icons.person_outline,
              size: ScreenConstant.minimumIconSize,
              color: CustomColor.colorE11D48,
            ),
          ),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildSecurityNotice(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildPaymentMethods(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildTextField(
                label: "Account holder name",
                hint: "Jean Dupont",
                controllerField: controller.accountHolderController,
                prefix: Icons.person_outline,
              ),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              // Method-specific fields: card details for Credit card, IBAN/BIC
              // for Bancontact & SEPA.
              Obx(() => controller.selectedMethod.value ==
                      PaymentMethod.creditCard
                  ? _buildCardFields()
                  : _buildBankFields()),

              SizedBox(height: ScreenConstant.sizeSmall),
              _buildTaxNote(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildMandateCard(),
              SizedBox(height: ScreenConstant.defaultHeightThirty),
              SizedBox(
                height: ScreenConstant.defaultHeightFifty,
                child: Obx(() {
                  if (controller.isSavingPayment.value) {
                    return Container(
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
                      ),
                      alignment: Alignment.center,
                      child: const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            CustomColor.colorWhite,
                          ),
                        ),
                      ),
                    );
                  }
                  return buildLoginButton(
                    "Save & Continue",
                    true,
                    controller.onSaveAndContinue,
                    null,
                  );
                }),
              ),
              SizedBox(height: ScreenConstant.defaultHeightFifteen),
              _buildCancelRow(),
              SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header: bank circle icon + title + subtitle
  // ---------------------------------------------------------------------------
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
            height: ScreenConstant.defaultHeightOneHundred,width: ScreenConstant.defaultWidthOneHundredFifteen,
            child: Image.asset(ImageUtils.bankingPayment,fit: BoxFit.cover,)),
        Text("Banking & Payment", style: TextStyles.paymentTitle),
        SizedBox(height: ScreenConstant.sizeExtraSmall),
        Text(
          "Set up discreet payment to activate your 15-day\ncomplimentary access.",
          textAlign: TextAlign.center,
          style: TextStyles.registerSubtitle,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Security notice card
  // ---------------------------------------------------------------------------
  Widget _buildSecurityNotice() {
    final BorderRadius radius = BorderRadius.circular(16);
    return Container(
      decoration: BoxDecoration(
        color: CustomColor.colorFECDD3.withOpacity(0.1),
        borderRadius: radius,
        border: Border.all(color: CustomColor.colorFCE7F3, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -50,
              child: Container(
                height: 170,
                width: 170,
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
                      CustomColor.colorFECDD3.withOpacity(0.2),
                      CustomColor.colorFECDD3.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
               padding: EdgeInsets.symmetric(horizontal: ScreenConstant.defaultWidthTwenty,vertical: ScreenConstant.defaultWidthTwenty),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                            Container(
                              height: ScreenConstant.defaultHeightThirty,
                              width: ScreenConstant.defaultWidthThirty,
                              decoration: BoxDecoration(shape: BoxShape.circle,border:Border.all(color: CustomColor.colorE11D48.withOpacity(0.1))),
                              child: Icon(
                                Icons.lock_outline,
                                size: ScreenConstant.smallIconSize,
                                color: CustomColor.colorBE123C,
                              ),
                            ),
                  SizedBox(width: ScreenConstant.defaultWidthTwenty,),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text("Security Notice",
                                  style: TextStyles.paymentNoticeTitle),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: ScreenConstant.sizeDefault,
                                vertical: ScreenConstant.sizeExtraSmall / 1.3,
                              ),
                              decoration: BoxDecoration(
                                color: CustomColor.colorFFE4E6,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text("ENCRYPTED",
                                  style: TextStyles.paymentEncryptedBadge),
                            ),
                          ],
                        ),
                              SizedBox(height: ScreenConstant.sizeSmall),
                              Text(
                                "Banking information is securely stored. Payment details "
                                "are required for subscription activation.",
                                style: TextStyles.registerTrialBody,
                              ),
                              SizedBox(height: ScreenConstant.sizeSmall),
                        Container(
                          padding: EdgeInsets.all(ScreenConstant.sizeSmall),
                          decoration: BoxDecoration(
                            color: CustomColor.colorWhite,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: CustomColor.colorFCE7F3,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.visibility_off_outlined,
                                    size: ScreenConstant.minimumIconSize,
                                    color: CustomColor.colorEF4444,
                                  ),
                                  SizedBox(width: ScreenConstant.sizeExtraSmall),
                                  Text("Neutral Statement Descriptor",
                                      style: TextStyles.paymentNoticeTitle.copyWith(
                                        color: CustomColor.colorBE123C,
                                      )),
                                ],
                              ),
                              SizedBox(height: ScreenConstant.sizeExtraSmall),
                              RichText(
                                text: TextSpan(
                                  style: TextStyles.registerVerifyNote
                                      .copyWith(height: 1.3),
                                  children: [
                                    const TextSpan(
                                        text: 'Charges appear neutrally as "CX-'
                                            'NETWORK BV". '),
                                    TextSpan(
                                      text: "€0.00 charged today ",
                                      style: TextStyles.registerVerifyNoteHighlight
                                          .copyWith(height: 1.3),
                                    ),
                                    const TextSpan(text: "during your 15-day trial."),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Payment method / provider selectable cards
  // ---------------------------------------------------------------------------
  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("Payment Method / Provider",
                style: TextStyles.registerFieldLabel),
            Text(" *", style: TextStyles.registerVerifyNoteHighlight),
            const Spacer(),
            Text("Instant activation",
                style: TextStyles.paymentInstantActivation),
          ],
        ),
        SizedBox(height: ScreenConstant.sizeSmall),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _methodCard(
                  method: PaymentMethod.bancontact,
                  icon: Icons.contactless_outlined,
                  title: "Bancontact",
                  subtitle: "Popular (BE)",
                ),
              ),
              SizedBox(width: ScreenConstant.sizeSmall),
              Expanded(
                child: _methodCard(
                  method: PaymentMethod.sepa,
                  icon: Icons.account_balance_outlined,
                  title: "SEPA Transfer",
                  subtitle: "IBAN Direct",
                ),
              ),
              SizedBox(width: ScreenConstant.sizeSmall),
              Expanded(
                child: _methodCard(
                  method: PaymentMethod.creditCard,
                  icon: Icons.credit_card,
                  title: "Credit Card",
                  subtitle: "Visa / MC",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _methodCard({
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final bool selected = controller.selectedMethod.value == method;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => controller.selectMethod(method),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: ScreenConstant.sizeMedium,
          horizontal: ScreenConstant.sizeExtraSmall,
        ),
        decoration: BoxDecoration(
          color: selected ? CustomColor.colorFFF1F2 : CustomColor.colorWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? CustomColor.colorBE123C
                : CustomColor.colorE2E8F0,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: ScreenConstant.smallIconSize,
              color: selected
                  ? CustomColor.colorBE123C
                  : CustomColor.color64748B,
            ),
            SizedBox(height: ScreenConstant.sizeExtraSmall),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyles.paymentMethodTitle,
            ),
            SizedBox(height: ScreenConstant.sizeExtraSmall / 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: selected
                  ? TextStyles.paymentMethodSubtitleSelected
                  : TextStyles.paymentMethodSubtitle,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Generic labelled field
  // ---------------------------------------------------------------------------
  Widget _label(String text, {bool required = true, Widget? trailing}) {
    return Padding(
      padding: EdgeInsets.only(bottom: ScreenConstant.sizeSmall),
      child: Row(
        children: [
          Text(text, style: TextStyles.registerFieldLabel),
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
  // Bancontact / SEPA bank fields (IBAN + BIC).
  // ---------------------------------------------------------------------------
  Widget _buildBankFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIbanField(),
        SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
        _buildBicField(),
        SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
        _buildCountryField(),
        SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
        _buildTextField(
          label: "Billing street address",
          hint: "Avenue Louise 142",
          controllerField: controller.streetController,
          prefix: Icons.home_outlined,
        ),
        SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
        _buildPostalCityRow(),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Credit card fields (card number + expiry / CVV row).
  // ---------------------------------------------------------------------------
  Widget _buildCardFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: "Card number",
          hint: "1234 5678 9012 3456",
          controllerField: controller.cardNumberController,
          prefix: Icons.credit_card,
        ),
        SizedBox(height: ScreenConstant.defaultHeightTwentyThree),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                label: "Expiry date",
                hint: "MM / YY",
                controllerField: controller.expiryController,
                prefix: Icons.calendar_today_outlined,
              ),
            ),
            SizedBox(width: ScreenConstant.sizeMedium),
            Expanded(
              child: _buildTextField(
                label: "CVV",
                hint: "123",
                controllerField: controller.cvcController,
                prefix: Icons.lock_outline,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controllerField,
    IconData? prefix,
    bool required = true,
    Widget? labelTrailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, required: required, trailing: labelTrailing),
        SizedBox(
          height: ScreenConstant.defaultHeightFifty,
          child: CustomTextField(
            borderRadius: 26,
            controller: controllerField,
            hintText: hint,
            hintStyle: TextStyles.loginTopText.copyWith(fontSize: FontSize.s14,color: CustomColor.color94A3B8),
            borderColor: CustomColor.colorE2E8F0,
            prefix: prefix == null
                ? null
                : Icon(
                    prefix,
                    size: ScreenConstant.smallIconSize,
                    color: CustomColor.color94A3B8,
                  ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // IBAN field (valid-format badge + BE suffix + note)
  // ---------------------------------------------------------------------------
  Widget _buildIbanField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(
          "IBAN / Account number",
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: ScreenConstant.minimumIconSize - 2,
                color: CustomColor.color059669,
              ),
              SizedBox(width: ScreenConstant.sizeExtraSmall / 2),
              Text("Valid Format", style: TextStyles.paymentValidFormat),
            ],
          ),
        ),
        SizedBox(
          height: ScreenConstant.defaultHeightFifty,
          child: CustomTextField(
            borderRadius: 26,
            controller: controller.ibanController,
            hintText: "BE76 0012 3456 7890",
            hintStyle: TextStyles.loginTopText.copyWith(fontSize: FontSize.s14,color: CustomColor.color94A3B8),
            borderColor: CustomColor.colorE2E8F0,
            prefix: Image.asset(
              ImageUtils.hash,
              height: ScreenConstant.minimumIconSize,
              color: CustomColor.color94A3B8,
            ),
            suffix: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenConstant.sizeDefault,
                vertical: ScreenConstant.sizeExtraSmall / 1.5,
              ),
              decoration: BoxDecoration(
                color: CustomColor.colorF1F5F9,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text("BE", style: TextStyles.registerPaymentChip),
            ),
          ),
        ),
        SizedBox(height: ScreenConstant.sizeExtraSmall + 2),
        Text(
          "Belgian & European IBAN supported with zero verification fees.",
          style: TextStyles.registerFieldNote,
        ),
      ],
    );
  }

  Widget _buildBicField() {
    return _buildTextField(
      label: "BIC / Swift Code",
      hint: "E.G. GEBABEBB",
      controllerField: controller.bicController,
      prefix: Icons.house,
      required: false,
      labelTrailing: Text("(Optional for BE accounts)",
          style: TextStyles.registerOptional),
    );
  }

  // ---------------------------------------------------------------------------
  // Billing country dropdown
  // ---------------------------------------------------------------------------
  Widget _buildCountryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Billing country"),
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
              Icon(
                Icons.flag_outlined,
                size: ScreenConstant.smallIconSize,
                color: CustomColor.color94A3B8,
              ),
              SizedBox(width: ScreenConstant.sizeSmall),
              Expanded(
                child: Obx(
                  () => DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: controller.countries
                              .contains(controller.selectedCountry.value)
                          ? controller.selectedCountry.value
                          : null,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: CustomColor.color64748B,
                        size: ScreenConstant.smallIconSize,
                      ),
                      style: TextStyles.loginTopText
                          .copyWith(fontSize: FontSize.s14),
                      items: controller.countries
                          .map(
                            (c) => DropdownMenuItem<String>(
                              value: c,
                              child: Text(
                                c,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyles.loginTopText
                                    .copyWith(fontSize: FontSize.s14),
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
              Text("🇧🇪", style: TextStyles.registerCountryText),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Postal code + City row
  // ---------------------------------------------------------------------------
  Widget _buildPostalCityRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildTextField(
            label: "Postal code",
            hint: "1050",
            controllerField: controller.postalCodeController,
          ),
        ),
        SizedBox(width: ScreenConstant.sizeMedium),
        Expanded(
          child: _buildTextField(
            label: "City",
            hint: "Brussels",
            controllerField: controller.cityController,
          ),
        ),
      ],
    );
  }

  Widget _buildTaxNote() {
    return Row(
      children: [
        Icon(
          Icons.shield_outlined,
          size: ScreenConstant.minimumIconSize,
          color: CustomColor.color94A3B8,
        ),
        SizedBox(width: ScreenConstant.sizeExtraSmall),
        Flexible(
          child: Text(
            "Used strictly for tax compliance. Never shared or visible to anyone",
            style: TextStyles.registerFieldNote,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Mandate authorization card (tappable toggle)
  // ---------------------------------------------------------------------------
  Widget _buildMandateCard() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.toggleMandate,
      child: Container(
        padding: EdgeInsets.all(ScreenConstant.sizeMedium),
        decoration: BoxDecoration(
          color: CustomColor.colorF8FAFC,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CustomColor.colorE2E8F0, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: ScreenConstant.smallIconSize,
                width: ScreenConstant.smallIconSize,
                decoration: BoxDecoration(
                  color: controller.mandateAuthorized.value
                      ? CustomColor.colorBE123C
                      : CustomColor.colorWhite,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: controller.mandateAuthorized.value
                        ? CustomColor.colorBE123C
                        : CustomColor.color94A3B8,
                    width: 1.5,
                  ),
                ),
                child: controller.mandateAuthorized.value
                    ? Icon(
                        Icons.check,
                        size: ScreenConstant.minimumIconSize - 2,
                        color: CustomColor.colorWhite,
                      )
                    : null,
              ),
            ),
            SizedBox(width: ScreenConstant.sizeSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Mandate Authorization",
                      style: TextStyles.paymentMandateTitle),
                  SizedBox(height: ScreenConstant.sizeExtraSmall),
                  Text(
                    "Authorize SEPA Direct Debit / Bancontact mandate for "
                    "automatic trial continuation after 15 days. Cancel anytime "
                    "with a single tap in settings.",
                    style: TextStyles.paymentMandateBody,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildCancelRow() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.onCancel,
      child: Text(
        "Cancel and return to account setup",
        textAlign: TextAlign.center,
        style: TextStyles.paymentCancelLink,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(ScreenConstant.sizeMedium),
      decoration: BoxDecoration(
        color: CustomColor.colorF8FAFC,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CustomColor.colorE2E8F0, width: 1),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: ScreenConstant.sizeMedium,
        runSpacing: ScreenConstant.sizeExtraSmall,
        children: [
          _footerBadge(Icons.lock_outline, "256-bit SSL Bank-Grade Encryption",
              CustomColor.colorBE185D,true,ImageUtils.sslTwoFiftySixBit),
          _footerBadge(Icons.visibility_off, "100% Discreet Billing",
              CustomColor.colorDB2777,false,""),
          _footerBadge(Icons.check_circle_outline,
              "Belgian Privacy & GDPR Compliant", CustomColor.colorDB2777,true, ImageUtils.cardVerificationLogo),
        ],
      ),
    );
  }

  Widget _footerBadge(IconData icon, String text, Color color, bool isIcon, String? image) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        isIcon?Image.asset(image!,height: ScreenConstant.minimumIconSize,color: color,):Icon(icon, size: ScreenConstant.minimumIconSize, color: color),
        SizedBox(width: ScreenConstant.sizeExtraSmall),
        Text(text, style: TextStyles.registerFooterStrip),
      ],
    );
  }
}
