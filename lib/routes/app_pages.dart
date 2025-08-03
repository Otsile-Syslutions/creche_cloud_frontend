// lib/routes/app_pages.dart
import 'package:get/get.dart';
import '../features/auth/bindings/auth_binding.dart';
import 'app_routes.dart';
import '../features/auth/views/login/login_view.dart';
import '../features/auth/views/sign_up/sign_up_view.dart';
import '../features/auth/views/forgot_password/forgot_password_view.dart';
import '../features/auth/views/reset_password/reset_password_view.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignUpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordView(),
      binding: AuthBinding(),
    ),
  ];
}