// lib/features/auth/bindings/auth_binding.dart
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/login_form_controller.dart';
import '../controllers/signup_form_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Put form controllers FIRST to ensure they're available before AuthController
    Get.put<LoginFormController>(LoginFormController(), permanent: false);
    Get.put<SignUpFormController>(SignUpFormController(), permanent: false);

    // Put AuthController LAST so it can safely access form controllers
    Get.put<AuthController>(AuthController(), permanent: false);
  }
}