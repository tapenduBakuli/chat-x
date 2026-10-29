import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../device_manager/screen_constants.dart';
import 'TextStyles.dart';
import 'colors/app_colors.dart';

/// A clean, reusable text field for the ChatX project.
///
/// This is intentionally lightweight (unlike the legacy
/// `common_text_form_field.dart`) so it can be dropped into any screen with
/// just the properties that are needed.
class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;

  /// Optional widget shown before the text (e.g. an icon/image).
  final Widget? prefix;

  /// Optional widget shown after the text (e.g. a password visibility toggle).
  final Widget? suffix;

  final bool obscureText;
  final TextInputType keyboardType;

  /// Optional input formatters (e.g. digits-only, expiry MM/YY auto-slash).
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool readOnly;
  final bool enabled;
  final VoidCallback? onTap;
  final int maxLines;
  final FocusNode? focusNode;

  /// Horizontal alignment of the text and hint (defaults to left).
  final TextAlign textAlign;

  /// Visual customization (sensible defaults match the Figma login design).
  final Color? fillColor;
  final Color? borderColor;
  final double borderRadius;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.textInputAction,
    this.onChanged,
    this.validator,
    this.readOnly = false,
    this.enabled = true,
    this.onTap,
    this.maxLines = 1,
    this.focusNode,
    this.textAlign = TextAlign.start,
    this.fillColor,
    this.borderColor,
    this.borderRadius = 16,
    this.textStyle,
    this.hintStyle,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(
        color: borderColor ?? CustomColor.colorF8FAFC,
        width: 1,
      ),
    );

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      onChanged: onChanged,
      validator: validator,
      readOnly: readOnly,
      enabled: enabled,
      onTap: onTap,
      maxLines: obscureText ? 1 : maxLines,
      textAlign: textAlign,
      style: textStyle ?? TextStyles.loginFieldText,
      cursorColor: CustomColor.colorDB2777,
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor ?? CustomColor.colorF8FAFC,
        hintText: hintText,
        hintStyle: hintStyle ?? TextStyles.loginFieldHint,
        prefixIcon: prefix == null
            ? null
            : Padding(
                padding: EdgeInsets.only(
                  left: ScreenConstant.sizeMedium,
                  right: ScreenConstant.sizeSmall,
                ),
                child: prefix,
              ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffix == null
            ? null
            : Padding(
                padding: EdgeInsets.only(right: ScreenConstant.sizeMedium),
                child: suffix,
              ),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        contentPadding: contentPadding ??
            EdgeInsets.symmetric(
              horizontal: ScreenConstant.sizeMedium,
              vertical: ScreenConstant.sizeMedium + 2,
            ),
        border: baseBorder,
        enabledBorder: baseBorder,
        disabledBorder: baseBorder,
        focusedBorder: baseBorder.copyWith(
          borderSide: const BorderSide(
            color: CustomColor.colorDB2777,
            width: 1.4,
          ),
        ),
        errorBorder: baseBorder.copyWith(
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: baseBorder.copyWith(
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
        ),
      ),
    );
  }
}
