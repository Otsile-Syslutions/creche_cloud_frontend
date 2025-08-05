// lib/features/parent_platform/bindings/parent_binding.dart
import 'package:get/get.dart';
import '../controllers/parent_home_controller.dart';

class ParentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentHomeController>(() => ParentHomeController());
  }
}