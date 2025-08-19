// lib/features/admin_platform/home/bindings/admin_home_binding.dart

import 'package:get/get.dart';
import '../controllers/admin_home_controller.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';

class AdminHomeBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure core services are available
    if (!Get.isRegistered<StorageService>()) {
      Get.put<StorageService>(StorageService(), permanent: true);
    }

    if (!Get.isRegistered<ApiService>()) {
      Get.put<ApiService>(ApiService(), permanent: true);
    }

    // CRITICAL: Ensure AuthController is available and kept alive
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: true); // Make it permanent
    }

    // Put AdminHomeController
    Get.lazyPut<AdminHomeController>(
          () => AdminHomeController(),
      fenix: true, // Keep controller alive
    );
  }
}