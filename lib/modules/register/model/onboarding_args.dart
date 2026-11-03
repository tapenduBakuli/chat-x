import '../../../routes/routes.dart';
import '../../login/model/login_response_model.dart';
import 'update_profile_response_model.dart';

/// Where the Payment → Profile Setup → … → Publish onboarding was entered
/// from. [register] is the default (fresh sign-up, also Edit Profile, which
/// shares RegisterController but never publishes). [login] means a registered
/// user who never saved a payment method is resuming onboarding.
enum OnboardingSource { register, login }

/// Passed as `Get.arguments` to [Routes.PAYMENT] to resume onboarding after
/// login / app relaunch. Carries the registration values so Profile Setup and
/// Profile Preview show the real name/age/avatar and PUT /users/me never sends
/// an empty display_name.
class OnboardingArgs {
  final OnboardingSource source;
  final String displayName;

  /// Raw `date_of_birth` from the server (YYYY-MM-DD, may carry a time part).
  final String dateOfBirth;
  final String country;

  /// Raw avatar URL (relative "/uploads/..." or absolute).
  final String avatarUrl;

  const OnboardingArgs({
    this.source = OnboardingSource.register,
    this.displayName = '',
    this.dateOfBirth = '',
    this.country = '',
    this.avatarUrl = '',
  });

  /// From the login response: avatar is `user.profile.avatar_url` →
  /// `user.avatar_url` → `data.avatar_url` (first non-empty).
  factory OnboardingArgs.fromLoginData(LoginData data) {
    final LoginUser? user = data.user;
    return OnboardingArgs(
      source: OnboardingSource.login,
      displayName: (user?.displayName ?? '').trim(),
      dateOfBirth: (user?.dateOfBirth ?? '').trim(),
      country: (user?.country ?? '').trim(),
      avatarUrl: _firstNonEmpty(<String?>[
        user?.profileAvatarUrl,
        user?.avatar_url,
        data.avatarUrl,
      ]),
    );
  }

  /// From GET /users/me: avatar is `profile.avatar_url` → `avatar_url`.
  factory OnboardingArgs.fromProfileUser(UpdateProfileUser u) {
    return OnboardingArgs(
      source: OnboardingSource.login,
      displayName: u.displayName.trim(),
      dateOfBirth: u.dateOfBirth.trim(),
      country: u.country.trim(),
      avatarUrl: _firstNonEmpty(<String?>[u.profile?.avatarUrl, u.avatarUrl]),
    );
  }

  /// Parses "YYYY-MM-DD" (optionally followed by a time part). Returns null
  /// when malformed.
  static ({int year, int month, int day})? parseDob(String raw) {
    final String s = raw.trim();
    if (s.length < 10) return null;
    final List<String> parts = s.substring(0, 10).split('-');
    if (parts.length != 3) return null;
    final int? year = int.tryParse(parts[0]);
    final int? month = int.tryParse(parts[1]);
    final int? day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    return (year: year, month: month, day: day);
  }

  static String _firstNonEmpty(List<String?> values) {
    for (final v in values) {
      final String t = (v ?? '').trim();
      if (t.isNotEmpty) return t;
    }
    return '';
  }
}

/// Only an explicit `false` gates the user to Payment; null/missing = paid.
bool requiresPaymentGate(bool? hasPaymentMethod) => hasPaymentMethod == false;

/// Route after login / splash session check.
String routeForPaymentState(bool? hasPaymentMethod) =>
    requiresPaymentGate(hasPaymentMethod) ? Routes.PAYMENT : Routes.HOME;

/// Route after a successful Publish on Profile Preview.
String routeAfterPublish(OnboardingSource source) =>
    source == OnboardingSource.login ? Routes.HOME : Routes.LOGIN;
