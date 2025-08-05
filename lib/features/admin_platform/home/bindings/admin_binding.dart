// lib/features/admin_platform/bindings/admin_binding.dart
import 'package:get/get.dart';
import '../controllers/admin_home_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminHomeController>(() => AdminHomeController());
  }
}