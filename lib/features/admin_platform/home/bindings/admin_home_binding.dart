// lib/features/admin_platform/bindings/admin_binding.dart
import 'package:get/get.dart';
import '../../../../utils/app_logger.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../controllers/admin_home_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    AppLogger.d('AdminBinding: Initializing dependencies');

    // Ensure AuthController exists and user data is loaded
    final authController = Get.find<AuthController>();

    // Load user data if not already loaded
    if (authController.currentUser.value == null && authController.isAuthenticated.value) {
      AppLogger.d('AdminBinding: User is authenticated but data not loaded, fetching...');
      authController.getCurrentUser().then((_) {
        AppLogger.d('AdminBinding: User data loaded successfully');
        AppLogger.d('User: ${authController.currentUser.value?.fullName}');
        AppLogger.d('Roles: ${authController.currentUser.value?.roleNames}');
        AppLogger.d('Is Platform Admin: ${authController.currentUser.value?.isPlatformAdmin}');
      }).catchError((error) {
        AppLogger.e('AdminBinding: Failed to load user data', error);
      });
    } else if (authController.currentUser.value != null) {
      AppLogger.d('AdminBinding: User data already available');
      AppLogger.d('User: ${authController.currentUser.value?.fullName}');
      AppLogger.d('Roles: ${authController.currentUser.value?.roleNames}');
    } else {
      AppLogger.w('AdminBinding: User not authenticated');
    }

    // Initialize AdminHomeController
    Get.lazyPut<AdminHomeController>(() => AdminHomeController());
  }
}