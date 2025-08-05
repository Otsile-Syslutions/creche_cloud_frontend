// lib/features/tenant_platform/bindings/tenant_binding.dart
import 'package:get/get.dart';
import '../controllers/tenant_home_controller.dart';

class TenantBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TenantHomeController>(() => TenantHomeController());
  }
}