// lib/bindings/permission_binding.dart
import 'package:get/get.dart';
import '../shared/services/permission_service.dart';

class PermissionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PermissionService>(() => PermissionService());
  }
}
