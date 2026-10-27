import 'package:chat_x/device_manager/screen_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors/app_colors.dart';

class TextStyles {
  static TextStyle get landingTitle => TextStyle(
    color: CustomColor.color0D1527,
    fontSize: ScreenConstant.sizeLarge,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold,
  );

  static TextStyle get landingSubTitle => TextStyle(
    color: CustomColor.color717B96,
    fontSize: ScreenConstant.sizeMedium,
    fontFamily: "Liberation",
  );

  static TextStyle get landingSubTitleBadge => TextStyle(
    color: CustomColor.color581C87,
    fontSize: ScreenConstant.sizeSmallHighest,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold
  );

  static TextStyle get loginTopText => TextStyle(
      color: CustomColor.color0F172A,
      fontSize: ScreenConstant.sizeSmallHighest,
      fontFamily: "Liberation",
  );


  static TextStyle get loginPrivateBadge => TextStyle(
    color: CustomColor.colorDB2777,
    fontSize: FontSize.s10,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static TextStyle get loginBrand => TextStyle(
    color: CustomColor.color0F172A,
    fontSize: FontSize.s20,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold,
  );

  static TextStyle get loginWelcome => TextStyle(
    color: CustomColor.color0F172A,
    fontSize: FontSize.s20,
    fontFamily: "Liberation",
  );

  static TextStyle get loginWelcomeSubtitle => TextStyle(
    color: CustomColor.color64748B,
    fontSize: FontSize.s14,
    fontFamily: "Liberation",
  );

  static TextStyle get loginFieldLabel => TextStyle(
    color: CustomColor.color334155,
    fontSize: FontSize.s12,
    fontFamily: "Liberation",
    fontWeight: FontWeight.w600,
  );

  static TextStyle get loginFieldText => TextStyle(
    color: CustomColor.color1E293B,
    fontSize: FontSize.s16,
    fontFamily: "Liberation",
  );

  static TextStyle get loginFieldHint => TextStyle(
    color: CustomColor.color64748B,
    fontSize: FontSize.s16,
    fontFamily: "Liberation",
  );

  static TextStyle get loginRememberMe => TextStyle(
    color: CustomColor.color475569,
    fontSize: FontSize.s12,
    fontFamily: "Liberation",
    fontWeight: FontWeight.w500,
  );

  static TextStyle get loginForgotPassword => TextStyle(
    color: CustomColor.colorBE185D,
    fontSize: FontSize.s12,
    fontFamily: "Liberation",
    fontWeight: FontWeight.w600,
  );

  static TextStyle get loginButtonText => TextStyle(
    color: CustomColor.colorWhite,
    fontSize: FontSize.s16,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold,
  );

  static TextStyle get loginBiometricText => TextStyle(
    color: CustomColor.color334155,
    fontSize: FontSize.s12,
    fontFamily: "Liberation",
    fontWeight: FontWeight.w600,
  );

  static TextStyle get loginFooterText => TextStyle(
    color: CustomColor.color475569,
    fontSize: FontSize.s14,
    fontFamily: "Liberation",
  );

  static TextStyle get loginFooterLink => TextStyle(
    color: CustomColor.colorBE185D,
    fontSize: FontSize.s14,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold,
  );

  // ------------------------- register / create account -------------------------
  static TextStyle get registerAppBarTitle => TextStyle(
    color: CustomColor.color0F172A,
    fontSize: FontSize.s17,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold,
  );

  static TextStyle get registerTitle => TextStyle(
    color: CustomColor.color0F172A,
    fontSize: FontSize.s24,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold,
  );

  static TextStyle get registerSubtitle => TextStyle(
    color: CustomColor.color64748B,
    fontSize: FontSize.s14,
    fontFamily: "Liberation",
  );

  static TextStyle get registerTrialBadge => TextStyle(
    color: CustomColor.colorBE123C,
    fontSize: FontSize.s12,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold,
  );

  static TextStyle get registerZeroRisk => TextStyle(
    color: CustomColor.color059669,
    fontSize: FontSize.s11,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold,
  );

  static TextStyle get registerTrialHeadline => TextStyle(
    color: CustomColor.color0F172A,
    fontSize: FontSize.s15,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold,
  );

  static TextStyle get registerTrialBody => TextStyle(
    height: 1.5,
    color: CustomColor.color475569,
    fontSize: FontSize.s12,
    fontFamily: "Liberation",
  );

  static TextStyle get registerTrialCheck => TextStyle(
    color: CustomColor.color334155,
    fontSize: FontSize.s12,
    fontFamily: "Liberation",
    fontWeight: FontWeight.w500,
  );

  static TextStyle get registerFieldLabel => TextStyle(
    color: CustomColor.color334155,
    fontSize: FontSize.s12,
    fontFamily: "Liberation",
    fontWeight: FontWeight.w600,
  );

  static TextStyle get registerFieldNote => TextStyle(
    color: CustomColor.color94A3B8,
    fontSize: FontSize.s11,
    fontFamily: "Liberation",
  );

  static TextStyle get registerSectionTitle => TextStyle(
    color: CustomColor.color334155,
    fontSize: FontSize.s13,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold,
  );

  static TextStyle get registerSupportedLabel => TextStyle(
    color: CustomColor.color94A3B8,
    fontSize: FontSize.s10,
    fontFamily: "Liberation",
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
  );

  static TextStyle get registerPaymentChip => TextStyle(
    color: CustomColor.color1E293B,
    fontSize: FontSize.s11,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold,
  );

  static TextStyle get registerVerifyNote => TextStyle(
    color: CustomColor.color475569,
    fontSize: FontSize.s11,
    fontFamily: "Liberation",
  );

  static TextStyle get registerVerifyNoteHighlight => TextStyle(
    color: CustomColor.colorEF4444,
    fontSize: FontSize.s12,
    fontFamily: "Liberation",
  );

  static TextStyle get registerCountryText => TextStyle(
    color: CustomColor.color1E293B,
    fontSize: FontSize.s14,
    fontFamily: "Liberation",
  );

  static TextStyle get registerOptional => TextStyle(
    color: CustomColor.color94A3B8,
    fontSize: FontSize.s12,
    fontFamily: "Liberation",
    fontWeight: FontWeight.w500,
  );

  static TextStyle get registerFooterStrip => TextStyle(
    color: CustomColor.color334155,
    fontSize: FontSize.s12,
    fontFamily: "Liberation",
    fontWeight: FontWeight.w600,
  );

  static TextStyle get registerCompliance => TextStyle(
    color: CustomColor.color94A3B8,
    fontSize: FontSize.s11,
    fontFamily: "Liberation",
  );

  // ------------------------- payment details -------------------------
  static TextStyle get paymentTitle => TextStyle(
    color: CustomColor.color0F172A,
    fontSize: FontSize.s24,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold,
  );

  static TextStyle get paymentNoticeTitle => TextStyle(
    color: CustomColor.color0F172A,
    fontSize: FontSize.s13,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold,
  );

  static TextStyle get paymentEncryptedBadge => TextStyle(
    color: CustomColor.colorBE123C,
    fontSize: FontSize.s9,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold,
    letterSpacing: 0.4,
  );

  static TextStyle get paymentInstantActivation => TextStyle(
    color: CustomColor.color059669,
    fontSize: FontSize.s11,
    fontFamily: "Liberation",
    fontWeight: FontWeight.w600,
  );

  static TextStyle get paymentMethodTitle => TextStyle(
    color: CustomColor.color0F172A,
    fontSize: FontSize.s13,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold,
  );

  static TextStyle get paymentMethodSubtitleSelected => TextStyle(
    color: CustomColor.colorBE123C,
    fontSize: FontSize.s10,
    fontFamily: "Liberation",
    fontWeight: FontWeight.w600,
  );

  static TextStyle get paymentMethodSubtitle => TextStyle(
    color: CustomColor.color94A3B8,
    fontSize: FontSize.s10,
    fontFamily: "Liberation",
  );

  static TextStyle get paymentValidFormat => TextStyle(
    color: CustomColor.color059669,
    fontSize: FontSize.s11,
    fontFamily: "Liberation",
    fontWeight: FontWeight.w600,
  );

  static TextStyle get paymentMandateTitle => TextStyle(
    color: CustomColor.color0F172A,
    fontSize: FontSize.s13,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold,
  );

  static TextStyle get paymentMandateBody => TextStyle(
    height: 1.4,
    color: CustomColor.color475569,
    fontSize: FontSize.s11,
    fontFamily: "Liberation",
  );

  static TextStyle get paymentCancelLink => TextStyle(
    color: CustomColor.color64748B,
    fontSize: FontSize.s14,
    fontFamily: "Liberation",
    fontWeight: FontWeight.w500,
  );

  // ------------------------- policies & safety agreement -------------------------
  static TextStyle get policiesBadgeText => TextStyle(
    color: CustomColor.color64748B,
    fontSize: FontSize.s11,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold,
  );

  static TextStyle get policiesHeaderTitle => TextStyle(
    color: CustomColor.color0F172A,
    fontSize: FontSize.s22,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold,
  );

  static TextStyle get policiesHeaderSubtitle => TextStyle(
    color: CustomColor.color64748B,
    fontSize: FontSize.s13,
    fontFamily: "Liberation",
    height: 1.4,
  );

  static TextStyle get policiesPillText => TextStyle(
    color: CustomColor.color334155,
    fontSize: FontSize.s11,
    fontFamily: "Liberation",
    fontWeight: FontWeight.w600,
  );

  static TextStyle get policiesItemTitle => TextStyle(
    color: CustomColor.color0F172A,
    fontSize: FontSize.s15,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold,
  );

  static TextStyle get policiesItemSubtitle => TextStyle(
    color: CustomColor.color64748B,
    fontSize: FontSize.s12,
    fontFamily: "Liberation",
  );

  static TextStyle get policiesItemBody => TextStyle(
    color: CustomColor.color475569,
    fontSize: FontSize.s12,
    fontFamily: "Liberation",
    height: 1.4,
  );

  static TextStyle get policiesConsentHeader => TextStyle(
    color: CustomColor.color64748B,
    fontSize: FontSize.s12,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold,
    letterSpacing: 0.6,
  );

  static TextStyle get policiesSelectAll => TextStyle(
    color: CustomColor.colorBE123C,
    fontSize: FontSize.s12,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold,
  );

  static TextStyle get policiesConsentTitle => TextStyle(
    color: CustomColor.color0F172A,
    fontSize: FontSize.s14,
    fontFamily: "Liberation",
    fontWeight: FontWeight.bold,
  );

  static TextStyle get policiesConsentSubtitle => TextStyle(
    color: CustomColor.color64748B,
    fontSize: FontSize.s12,
    fontFamily: "Liberation",
    height: 1.3,
  );

  static TextStyle get policiesDisclaimer => TextStyle(
    color: CustomColor.color64748B,
    fontSize: FontSize.s11,
    fontFamily: "Liberation",
  );

  // ------------------------- browse members / home -------------------------
  static TextStyle get browseToggleLabel => TextStyle(
    color: CustomColor.color334155,
    fontSize: FontSize.s12,
    fontFamily: "Liberation",
    fontWeight: FontWeight.w600,
  );


}

