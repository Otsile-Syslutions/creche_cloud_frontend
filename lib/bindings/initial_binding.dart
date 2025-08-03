// lib/bindings/initial_binding.dart
import 'package:get/get.dart';
import '../core/services/storage_service.dart';
import '../core/services/api_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Only load core services at app startup
    // AuthController and form controllers will be loaded by AuthBinding when needed
    Get.put<StorageService>(StorageService(), permanent: true);
    Get.put<ApiService>(ApiService(), permanent: true);
  }
}