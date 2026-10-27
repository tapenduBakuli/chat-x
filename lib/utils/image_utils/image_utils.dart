import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';

/// Central registry of all image asset paths used across the app.
///
/// Prefer referencing assets through these constants instead of hardcoding
/// `"assets/images/..."` strings inside widgets, so a renamed/moved asset only
/// has to change in one place.
class ImageUtils {
  /// Base directory for bundled image assets.
  static const String _dir = "assets/images/";

  // --- Login ---------------------------------------------------------------
  static const String chatxEncryptedLogo = "${_dir}chatx_encrypted_logo.png";
  static const String loginChatxTopLogo = "${_dir}login_chatx_top_logo.png";
  static const String waveHandLogo = "${_dir}wave_hand_logo.png";
  static const String loginEmail = "${_dir}login_email.png";
  static const String loginPassPrefixLogo =
      "${_dir}login_pass_prefix_logo.png";
  static const String loginPassSuffixLogo =
      "${_dir}login_pass_suffix_logo.png";

  // --- Branding / shared ---------------------------------------------------
  static const String chatxLogo = "${_dir}chatxlogo.png";
  static const String registerTopLogo = "${_dir}register_top_logo.png";
  static const String userRegister = "${_dir}user_register.png";

  // --- Register / profile setup --------------------------------------------
  static const String hundredPercentDiscreet =
      "${_dir}100percent_discreet.png";
  static const String addPhoto = "${_dir}add_photo.png";
  static const String photosCanBeBlurred = "${_dir}photos_can_be_blurred.png";
  static const String profileName = "${_dir}profile_name.png";
  static const String dateOfBirth = "${_dir}dateofbirth.png";
  static const String cardVerificationLogo =
      "${_dir}card_verification_logo.png";
  static const String freeTrialLogo = "${_dir}free_trial_logo.png";
  static const String instant = "${_dir}instant.png";
  static const String neutral = "${_dir}nutral.png";
  static const String policiesSafetyAgreement =
      "${_dir}policies_safety_agreement.png";

  // --- Payment -------------------------------------------------------------
  static const String bankingPayment = "${_dir}banking_payment.png";
  static const String hash = "${_dir}hash.png";
  static const String bic = "${_dir}bic.png";
  static const String sslTwoFiftySixBit = "${_dir}256bit.png";
  static const String discount = "${_dir}discount.png";
  static const String remainsHidden = "${_dir}remains_hidden.png";

  // --- Profile preview section icons ---------------------------------------
  static const String privacy = "${_dir}privacy.png";
  static const String aboutMe = "${_dir}aboutme.png";
  static const String seeking = "${_dir}seeking.png";

  // --- Intimate desires chip glyphs ----------------------------------------
  static const String selectedCheck = "${_dir}selected.png";
  static const String multipleTime = "${_dir}multipletime.png";
  static const String inLife = "${_dir}inlife.png";
  static const String serious = "${_dir}serious.png";
  static const String other = "${_dir}other.png";
  static const String outdoor = "${_dir}outdoor.png";
  static const String sensual = "${_dir}sensual.png";
  static const String threesome = "${_dir}3some.png";
  static const String feet = "${_dir}feet.png";
  static const String bdsm = "${_dir}bdsm.png";
  static const String sensory = "${_dir}sensory.png";
  static const String exhibitionism = "${_dir}exhibi.png";
  static const String sport = "${_dir}sport.png";
  static const String movies = "${_dir}movies.png";
  static const String genre = "${_dir}genre.png";
  static const String drawing = "${_dir}drawing.png";
  static const String container4 = "${_dir}Container-4.png";
}
