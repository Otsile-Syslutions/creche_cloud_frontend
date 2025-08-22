// lib/features/admin_platform/customer_management/market_explorer/bindings/market_explorer_binding.dart

import 'package:get/get.dart';
import '../controllers/market_explorer_controller.dart';
import '../../../../auth/controllers/auth_controller.dart';
import '../../../../../core/services/api_service.dart';
import '../../../../../core/services/storage_service.dart';

class MarketExplorerBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure core services are available
    if (!Get.isRegistered<StorageService>()) {
      Get.put<StorageService>(StorageService(), permanent: true);
    }

    if (!Get.isRegistered<ApiService>()) {
      Get.put<ApiService>(ApiService(), permanent: true);
    }

    // Ensure AuthController is available (critical for authentication)
    if (!Get.isRegistered<AuthController>()) {
      // Create AuthController if it doesn't exist
      Get.put<AuthController>(AuthController(), permanent: false);
    }

    // Put MarketExplorerController with dependencies ensured
    Get.lazyPut<MarketExplorerController>(
          () => MarketExplorerController(),
      fenix: true, // Keep controller alive even after route disposal
    );
  }
}