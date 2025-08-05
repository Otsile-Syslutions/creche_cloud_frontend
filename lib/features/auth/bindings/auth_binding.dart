// lib/features/auth/bindings/auth_binding.dart
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/login_form_controller.dart';
import '../controllers/signup_form_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Create form controllers fresh each time - let GetX handle existing ones
    Get.lazyPut<LoginFormController>(() => LoginFormController(), fenix: true);
    Get.lazyPut<SignUpFormController>(() => SignUpFormController(), fenix: true);

    // Put AuthController
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: false);
    }
  }
}