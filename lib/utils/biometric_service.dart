import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

/// Result of a biometric authentication attempt.
class BiometricResult {
  const BiometricResult({required this.success, this.message});

  /// Whether the user authenticated successfully.
  final bool success;

  /// A human-readable message when [success] is false (null on success).
  final String? message;

  const BiometricResult.ok() : this(success: true);

  const BiometricResult.fail(String message)
      : this(success: false, message: message);
}

/// Thin wrapper around [local_auth] that performs device biometric
/// authentication (Face ID / Touch ID on iOS, fingerprint / face on Android).
class BiometricService {
  BiometricService._();

  static final LocalAuthentication _auth = LocalAuthentication();

  /// Whether the device has biometric hardware AND the OS reports it is
  /// available (e.g. supports biometric or device-credential auth).
  static Future<bool> isAvailable() async {
    try {
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } on PlatformException {
      return false;
    }
  }

  /// Returns the list of biometric types enrolled on the device
  /// (e.g. face, fingerprint, iris).
  static Future<List<BiometricType>> enrolledBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return const <BiometricType>[];
    }
  }

  /// Prompts the user to authenticate with their device biometrics.
  ///
  /// [reason] is shown in the system prompt. [biometricOnly] forces biometric
  /// auth (no PIN/pattern/passcode fallback) when true.
  static Future<BiometricResult> authenticate({
    String reason = 'Authenticate to log in to ChatX',
    bool biometricOnly = false,
  }) async {
    try {
      if (!await isAvailable()) {
        return const BiometricResult.fail(
          'Biometric authentication is not available on this device.',
        );
      }

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      return didAuthenticate
          ? const BiometricResult.ok()
          : const BiometricResult.fail('Authentication cancelled.');
    } on PlatformException catch (e) {
      return BiometricResult.fail(_messageForError(e));
    }
  }

  static String _messageForError(PlatformException e) {
    switch (e.code) {
      case auth_error.notAvailable:
        return 'Biometric authentication is not available on this device.';
      case auth_error.notEnrolled:
        return 'No biometrics enrolled. Add Face ID / fingerprint in your '
            'device settings first.';
      case auth_error.lockedOut:
        return 'Too many attempts. Try again later.';
      case auth_error.permanentlyLockedOut:
        return 'Biometrics locked. Unlock your device with your '
            'passcode/PIN first.';
      case auth_error.passcodeNotSet:
        return 'Set a device passcode/PIN to use biometric login.';
      default:
        return e.message ?? 'Biometric authentication failed.';
    }
  }
}
