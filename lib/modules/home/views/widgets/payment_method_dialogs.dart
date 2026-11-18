import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../device_manager/screen_constants.dart';
import '../../../../utils/TextStyles.dart';
import '../../../../utils/card_input_utils.dart';
import '../../../../utils/colors/app_colors.dart';
import '../../../../utils/custom_text_field.dart';
import '../../../../utils/custom_widgets/universal_button.dart';
import '../../controller/account_billing_controller.dart';

/// Confirm dialog for deleting the saved card. Returns true once the DELETE
/// succeeded (the dialog closes itself), otherwise false/null.
Future<bool?> showDeletePaymentMethodDialog(
  BuildContext context,
  AccountBillingController billing,
) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      // Block barrier tap / Back while the DELETE is in flight so the caller
      // always receives the result and can open the mandatory save modal.
      return Obx(() => PopScope(
        canPop: !billing.isDeleting.value,
        child: AlertDialog(
        backgroundColor: CustomColor.colorWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Delete payment method?",
          style: TextStyles.loginWelcome.copyWith(fontSize: FontSize.s18),
        ),
        content: Text(
          "A verified payment method is mandatory for ChatX. You must add a "
          "new one right after deleting this card.",
          style: TextStyles.loginWelcomeSubtitle,
        ),
        actions: [
          Obx(
            () => TextButton(
              onPressed: billing.isDeleting.value
                  ? null
                  : () => Navigator.pop(dialogContext, false),
              child: Text(
                "Cancel",
                style: TextStyles.loginWelcome.copyWith(
                  fontSize: FontSize.s14,
                  color: CustomColor.color64748B,
                ),
              ),
            ),
          ),
          Obx(() {
            final bool busy = billing.isDeleting.value;
            return TextButton(
              onPressed: busy
                  ? null
                  : () async {
                      final bool ok = await billing.deletePaymentMethod();
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext, ok);
                      }
                    },
              child: busy
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          CustomColor.colorE11D48,
                        ),
                      ),
                    )
                  : Text(
                      "Delete",
                      style: TextStyles.loginWelcome.copyWith(
                        fontSize: FontSize.s14,
                        color: CustomColor.colorE11D48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            );
          }),
        ],
      ),
      ));
    },
  );
}

/// "Payment Method Required" save modal. When [mandatory] the barrier and the
/// back button are blocked until the card is saved.
Future<void> showSavePaymentMethodDialog(
  BuildContext context,
  AccountBillingController billing, {
  required bool mandatory,
}) {
  billing.resetSaveForm();
  return showDialog<void>(
    context: context,
    barrierDismissible: !mandatory,
    builder: (dialogContext) {
      return PopScope(
        canPop: !mandatory,
        child: Dialog(
          backgroundColor: CustomColor.colorWhite,
          insetPadding: EdgeInsets.symmetric(
            horizontal: ScreenConstant.defaultWidthTwenty,
            vertical: ScreenConstant.defaultHeightTen,
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ScreenConstant.sizeMedium),
              child: _SavePaymentForm(
                billing: billing,
                mandatory: mandatory,
                onSaved: () {
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                },
                onClose: () => Navigator.of(dialogContext).pop(),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _SavePaymentForm extends StatelessWidget {
  const _SavePaymentForm({
    required this.billing,
    required this.mandatory,
    required this.onSaved,
    required this.onClose,
  });

  final AccountBillingController billing;
  final bool mandatory;
  final VoidCallback onSaved;
  final VoidCallback onClose;

  Widget _label(String text) => Padding(
        padding: EdgeInsets.only(bottom: ScreenConstant.sizeExtraSmall),
        child: Text(
          text,
          style: TextStyles.registerFieldNote.copyWith(
            color: CustomColor.color334155,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget _field({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? formatters,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        SizedBox(
          height: ScreenConstant.defaultHeightFifty,
          child: CustomTextField(
            borderRadius: 26,
            controller: controller,
            hintText: hint,
            keyboardType: keyboardType,
            inputFormatters: formatters,
            obscureText: obscure,
            hintStyle: TextStyles.loginTopText.copyWith(
              fontSize: FontSize.s14,
              color: CustomColor.color94A3B8,
            ),
            borderColor: CustomColor.colorE2E8F0,
          ),
        ),
      ],
    );
  }

  InputDecoration _dropDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyles.loginTopText.copyWith(
          fontSize: FontSize.s14,
          color: CustomColor.color94A3B8,
        ),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: ScreenConstant.sizeSmallHighest,
          vertical: ScreenConstant.sizeSmallHighest,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: const BorderSide(color: CustomColor.colorE2E8F0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: const BorderSide(color: CustomColor.colorE2E8F0),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final TextStyle dropStyle = TextStyles.loginTopText.copyWith(
      fontSize: FontSize.s14,
      color: CustomColor.color0F172A,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(ScreenConstant.sizeSmall),
              decoration: const BoxDecoration(
                color: CustomColor.colorFFF1F2,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.credit_card,
                size: ScreenConstant.smallIconSize,
                color: CustomColor.colorBE185D,
              ),
            ),
            SizedBox(width: ScreenConstant.sizeSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Payment Method Required",
                    style: TextStyles.registerSectionTitle
                        .copyWith(fontSize: FontSize.s16),
                  ),
                  Text(
                    "Mandatory verification to use ChatX",
                    style: TextStyles.registerFieldNote
                        .copyWith(color: CustomColor.color64748B),
                  ),
                ],
              ),
            ),
            if (!mandatory)
              Semantics(
                button: true,
                label: "Close",
                child: IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, color: CustomColor.color64748B),
                ),
              ),
          ],
        ),
        SizedBox(height: ScreenConstant.sizeMedium),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(ScreenConstant.sizeSmallHighest),
          decoration: BoxDecoration(
            color: CustomColor.colorFFF1F2,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: CustomColor.colorFECDD3),
          ),
          child: RichText(
            text: TextSpan(
              style: TextStyles.registerFieldNote
                  .copyWith(color: CustomColor.colorBE123C),
              children: const [
                TextSpan(
                  text: "Action Required: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: "A verified payment method is mandatory for all "
                      "active ChatX members under Belgian anti-bot and 18+ "
                      "identity regulations. You must provide a valid payment "
                      "method before continuing or leaving this page.",
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: ScreenConstant.sizeMedium),
        _field(
          label: "Cardholder Name*",
          hint: "Jean Dupont",
          controller: billing.cardholderCtrl,
        ),
        SizedBox(height: ScreenConstant.sizeSmallHighest),
        _field(
          label: "Card Number*",
          hint: "1234 5678 9012 3456",
          controller: billing.cardNumberCtrl,
          keyboardType: TextInputType.number,
          formatters: [CardNumberInputFormatter()],
        ),
        SizedBox(height: ScreenConstant.sizeSmallHighest),
        _label("Expiry*"),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: billing.expiryMonth.value,
                  decoration: _dropDecoration("MM"),
                  style: dropStyle,
                  items: List<DropdownMenuItem<int>>.generate(
                    12,
                    (i) => DropdownMenuItem<int>(
                      value: i + 1,
                      child: Text((i + 1).toString().padLeft(2, '0')),
                    ),
                  ),
                  onChanged: (v) => billing.expiryMonth.value = v,
                ),
              ),
            ),
            SizedBox(width: ScreenConstant.sizeSmall),
            Expanded(
              child: Obx(
                () => DropdownButtonFormField<int>(
                  isExpanded: true,
                  initialValue: billing.expiryYear.value,
                  decoration: _dropDecoration("YYYY"),
                  style: dropStyle,
                  items: expiryYearOptions()
                      .map((y) => DropdownMenuItem<int>(
                            value: y,
                            child: Text('$y'),
                          ))
                      .toList(),
                  onChanged: (v) => billing.expiryYear.value = v,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenConstant.sizeSmallHighest),
        _field(
          label: "CVV/CVC*",
          hint: "123",
          controller: billing.cvvCtrl,
          keyboardType: TextInputType.number,
          obscure: true,
          formatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
        ),
        Obx(() {
          final String? err = billing.saveError.value;
          if (err == null || err.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.only(top: ScreenConstant.sizeSmall),
            child: Semantics(
              liveRegion: true,
              child: Text(
                err,
                style: TextStyles.registerFieldNote.copyWith(
                  color: CustomColor.colorE11D48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
        SizedBox(height: ScreenConstant.sizeSmallHighest),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lock_outline,
              size: ScreenConstant.minimumIconSize,
              color: CustomColor.color94A3B8,
            ),
            SizedBox(width: ScreenConstant.sizeExtraSmall),
            Expanded(
              child: Text(
                "256-bit TLS encrypted under Belgian banking standards. No "
                "unauthorized debits.",
                style: TextStyles.registerFieldNote,
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenConstant.sizeMedium),
        SizedBox(
          height: ScreenConstant.defaultHeightFifty,
          child: Obx(() {
            if (billing.isSaving.value) {
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
            return Semantics(
              button: true,
              label: "Verify and save payment method",
              child: buildLoginButton(
                "Verify & Save Payment Method",
                false,
                () async {
                  if (await billing.savePaymentMethod()) onSaved();
                },
                null,
                height: ScreenConstant.defaultHeightFifty,
                fontSize: FontSize.s12,
              ),
            );
          }),
        ),
      ],
    );
  }
}
