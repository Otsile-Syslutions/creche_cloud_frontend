// lib/features/admin_platform/schools_management/market_explorer/bindings/market_explorer_binding.dart

import 'package:get/get.dart';
import '../controllers/market_explorer_controller.dart';

class MarketExplorerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MarketExplorerController>(
          () => MarketExplorerController(),
    );
  }
}