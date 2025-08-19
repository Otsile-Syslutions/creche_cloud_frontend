// lib/features/auth/bindings/login_binding.dart
import 'package:get/get.dart';
import '../views/login/controllers/login_form_controller.dart';
import '../../../utils/app_logger.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    AppLogger.i('LoginBinding: Initializing dependencies');

    // Use lazyPut with fenix: true to ensure controller is recreated when needed
    // This prevents the "used after disposed" error
    Get.lazyPut<LoginFormController>(
          () => LoginFormController(),
      fenix: true,  // IMPORTANT: Recreates controller if it was deleted
    );

    AppLogger.i('LoginBinding: Dependencies initialized');
  }
}