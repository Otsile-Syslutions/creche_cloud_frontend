// lib/features/auth/bindings/auth_binding.dart
import 'package:get/get.dart';
import '../../../bindings/global_bindings.dart';
import '../controllers/auth_controller.dart';
import '../views/login/controllers/login_form_controller.dart';
import '../views/sign_up/controllers/signup_form_controller.dart';


class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure core dependencies are available
    DependencyManager.ensureCoreServices();

    // Put form controllers FIRST to ensure they're available before AuthController
    Get.put<LoginFormController>(LoginFormController(), permanent: false);
    Get.put<SignUpFormController>(SignUpFormController(), permanent: false);

    // AuthController should already be available from GlobalBindings
    // But ensure it exists just in case
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: true);
    }
  }
}