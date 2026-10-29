import 'package:chat_x/modules/home/binding/home_binding.dart';
import 'package:chat_x/modules/home/views/browse_members_screen.dart';
import 'package:chat_x/modules/home/views/member_detail_screen.dart';
import 'package:chat_x/modules/login/binding/login_binding.dart';
import 'package:chat_x/modules/login/views/login_screen.dart';
import 'package:chat_x/modules/login/views/forgot_password_screen.dart';
import 'package:chat_x/modules/login/views/otp_screen.dart';
import 'package:chat_x/modules/login/views/reset_password_screen.dart';
import 'package:chat_x/modules/register/binding/register_binding.dart';
import 'package:chat_x/modules/register/views/register_screen.dart';
import 'package:chat_x/modules/register/views/payment_details_screen.dart';
import 'package:chat_x/modules/register/views/policies_agreement_screen.dart';
import 'package:chat_x/modules/register/views/profile_setup_screen.dart';
import 'package:chat_x/modules/register/views/profile_photos_screen.dart';
import 'package:chat_x/modules/register/views/intimate_desires_screen.dart';
import 'package:chat_x/modules/register/views/profile_preview_screen.dart';
import 'package:chat_x/modules/profile/binding/profile_binding.dart';
import 'package:chat_x/modules/profile/views/profile_screen.dart';
import 'package:chat_x/routes/routes.dart';
import 'package:get/get.dart';
import '../modules/splash/binding/splash_binding.dart';
import '../modules/splash/views/splash_screen.dart';


class Theme1AppPages {
  static const INITIAL = Routes.ROOT;
  static final routes = [
    GetPage(
      name: Routes.ROOT,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => const ForgotPasswordScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.OTP,
      page: () => const OtpScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.RESET_PASSWORD,
      page: () => const ResetPasswordScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.PAYMENT,
      page: () => const PaymentDetailsScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.POLICIES_AGREEMENT,
      page: () => const PoliciesAgreementScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.PROFILE_SETUP,
      page: () => const ProfileSetupScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.PROFILE_PHOTOS,
      page: () => const ProfilePhotosScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.INTIMATE_DESIRES,
      page: () => const IntimateDesiresScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.PROFILE_PREVIEW,
      page: () => const ProfilePreviewScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const BrowseMembersScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.MEMBER_DETAIL,
      page: () => const MemberDetailScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
  ];
}