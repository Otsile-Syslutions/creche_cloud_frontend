// lib/features/admin_platform/customer_management/sales_pipeline/bindings/sales_pipeline_binding.dart

import 'package:get/get.dart';
import '../controllers/sales_pipeline_controller.dart';
import '../../market_explorer/controllers/market_explorer_controller.dart';

class SalesPipelineBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure Market Explorer controller is available for integration
    if (!Get.isRegistered<MarketExplorerController>()) {
      Get.lazyPut<MarketExplorerController>(
            () => MarketExplorerController(),
      );
    }

    // Create Sales Pipeline controller
    Get.lazyPut<SalesPipelineController>(
          () => SalesPipelineController(),
    );
  }
}