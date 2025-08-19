// lib/bindings/global_bindings.dart

import 'package:get/get.dart';
import '../core/services/storage_service.dart';
import '../core/services/api_service.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../utils/app_logger.dart';

/// Global bindings that should be initialized at app startup
/// and remain available throughout the app lifecycle
class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    AppLogger.i('Initializing global bindings...');

    // Core services - permanent throughout app lifecycle
    Get.put<StorageService>(
        StorageService(),
        permanent: true
    );

    Get.put<ApiService>(
        ApiService(),
        permanent: true
    );

    // Auth controller - permanent to maintain auth state
    Get.put<AuthController>(
        AuthController(),
        permanent: true
    );

    AppLogger.i('Global bindings initialized successfully');
  }
}

/// Ensure critical dependencies are always available
class DependencyManager {
  /// Ensure AuthController is available
  static void ensureAuthController() {
    if (!Get.isRegistered<AuthController>()) {
      AppLogger.w('AuthController not found, recreating...');
      Get.put<AuthController>(AuthController(), permanent: true);
    }
  }

  /// Ensure all core services are available
  static void ensureCoreServices() {
    if (!Get.isRegistered<StorageService>()) {
      AppLogger.w('StorageService not found, recreating...');
      Get.put<StorageService>(StorageService(), permanent: true);
    }

    if (!Get.isRegistered<ApiService>()) {
      AppLogger.w('ApiService not found, recreating...');
      Get.put<ApiService>(ApiService(), permanent: true);
    }

    ensureAuthController();
  }

  /// Check if all critical dependencies are available
  static bool checkDependencies() {
    final hasStorage = Get.isRegistered<StorageService>();
    final hasApi = Get.isRegistered<ApiService>();
    final hasAuth = Get.isRegistered<AuthController>();

    if (!hasStorage || !hasApi || !hasAuth) {
      AppLogger.w('Missing dependencies - Storage: $hasStorage, API: $hasApi, Auth: $hasAuth');
      return false;
    }

    return true;
  }

  /// Initialize or reinitialize all dependencies
  static Future<void> initializeDependencies() async {
    AppLogger.i('Initializing dependencies...');

    // Clear any existing instances
    await clearDependencies();

    // Reinitialize
    GlobalBindings().dependencies();

    AppLogger.i('Dependencies initialized');
  }

  /// Clear all dependencies (use with caution)
  static Future<void> clearDependencies() async {
    AppLogger.w('Clearing all dependencies...');

    try {
      if (Get.isRegistered<AuthController>()) {
        await Get.delete<AuthController>(force: true);
      }
    } catch (e) {
      AppLogger.e('Error clearing AuthController', e);
    }

    try {
      if (Get.isRegistered<ApiService>()) {
        await Get.delete<ApiService>(force: true);
      }
    } catch (e) {
      AppLogger.e('Error clearing ApiService', e);
    }

    try {
      if (Get.isRegistered<StorageService>()) {
        await Get.delete<StorageService>(force: true);
      }
    } catch (e) {
      AppLogger.e('Error clearing StorageService', e);
    }

    AppLogger.w('Dependencies cleared');
  }
}