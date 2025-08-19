// lib/bindings/global_bindings.dart

import 'package:get/get.dart';
import '../core/services/storage_service.dart';
import '../core/services/api_service.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/auth/views/login/controllers/login_form_controller.dart';
import '../utils/app_logger.dart';

/// Global bindings that should be initialized at app startup
/// and remain available throughout the app lifecycle
class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    AppLogger.i('Initializing global bindings...');

    // Note: Since dependencies() is synchronous, we'll use putAsync
    // for services that need initialization
    _initializeServices();

    AppLogger.i('Global bindings setup complete');
  }

  void _initializeServices() {
    // 1. Storage Service - onInit will be called automatically by GetX
    Get.putAsync<StorageService>(() async {
      AppLogger.d('Initializing StorageService...');
      final service = StorageService();
      // GetX will call onInit() automatically, but we ensure it's ready
      await service.ensureInitialized(); // Use the public method
      AppLogger.d('StorageService initialized successfully');
      return service;
    }, permanent: true);

    // 2. API Service - depends on StorageService
    Get.putAsync<ApiService>(() async {
      AppLogger.d('Initializing ApiService...');

      // Wait for StorageService to be ready
      await Get.find<StorageService>().ensureInitialized();

      final service = ApiService();
      // ApiService's onInit will be called automatically by GetX
      AppLogger.d('ApiService initialized successfully');

      // Debug the initial state
      AppLogger.d('ApiService initial auth state: ${service.isAuthenticated}');

      return service;
    }, permanent: true);

    // 3. Auth Controller - depends on both Storage and API services
    Get.putAsync<AuthController>(() async {
      AppLogger.d('Initializing AuthController...');

      // Wait for dependencies to be ready
      await Get.find<StorageService>().ensureInitialized();
      // Just check that ApiService exists (it initializes itself)
      Get.find<ApiService>();

      final controller = AuthController();
      // Controller's onInit will be called automatically by GetX
      AppLogger.d('AuthController initialized successfully');
      return controller;
    }, permanent: true);

    // 4. Login Form Controller - can be lazy loaded
    Get.lazyPut<LoginFormController>(
          () => LoginFormController(),
      fenix: true, // Recreate if removed
    );
  }

  /// Alternative: Initialize services before app starts (call from main.dart)
  static Future<void> initializeAsync() async {
    AppLogger.i('=== ASYNC INITIALIZATION STARTING ===');

    try {
      // 1. Storage Service
      AppLogger.d('Step 1: Initializing StorageService...');
      final storageService = StorageService();
      // Ensure it's initialized (this will call _initializePrefs internally)
      await storageService.ensureInitialized();
      Get.put<StorageService>(storageService, permanent: true);
      AppLogger.d('✅ StorageService ready');
      AppLogger.d('- Is initialized: ${storageService.isInitialized}');

      // 2. API Service
      AppLogger.d('Step 2: Initializing ApiService...');
      final apiService = ApiService();
      // The ApiService onInit() will be called when we put it
      Get.put<ApiService>(apiService, permanent: true);

      // Wait a moment for onInit to complete
      await Future.delayed(const Duration(milliseconds: 100));

      AppLogger.d('✅ ApiService ready');

      // Verify API service state
      AppLogger.d('API Service check:');
      AppLogger.d('- Base URL: ${apiService.baseUrl}');
      AppLogger.d('- Has access token: ${apiService.accessToken != null}');
      AppLogger.d('- Is authenticated: ${apiService.isAuthenticated}');

      // 3. Auth Controller
      AppLogger.d('Step 3: Initializing AuthController...');
      final authController = AuthController();
      Get.put<AuthController>(authController, permanent: true);

      // Wait for AuthController's onInit to complete
      await Future.delayed(const Duration(milliseconds: 100));

      AppLogger.d('✅ AuthController ready');

      // 4. Login Form Controller (lazy)
      AppLogger.d('Step 4: Setting up LoginFormController (lazy)...');
      Get.lazyPut<LoginFormController>(
            () => LoginFormController(),
        fenix: true,
      );
      AppLogger.d('✅ LoginFormController configured');

      // Verify all services are registered
      AppLogger.d('=== VERIFICATION ===');
      AppLogger.d('StorageService registered: ${Get.isRegistered<StorageService>()}');
      AppLogger.d('ApiService registered: ${Get.isRegistered<ApiService>()}');
      AppLogger.d('AuthController registered: ${Get.isRegistered<AuthController>()}');

      // Test singleton behavior
      final api1 = Get.find<ApiService>();
      final api2 = Get.find<ApiService>();
      AppLogger.d('ApiService is singleton: ${identical(api1, api2)}');

      final storage1 = Get.find<StorageService>();
      final storage2 = Get.find<StorageService>();
      AppLogger.d('StorageService is singleton: ${identical(storage1, storage2)}');

      AppLogger.i('=== INITIALIZATION COMPLETE ===');

    } catch (e, stack) {
      AppLogger.e('Failed to initialize services', e, stack);
      rethrow;
    }
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

  /// Ensure LoginFormController is available
  static void ensureLoginController() {
    if (!Get.isRegistered<LoginFormController>()) {
      AppLogger.w('LoginFormController not found, recreating...');
      Get.put<LoginFormController>(LoginFormController());
    }
  }

  /// Ensure all core services are available and initialized
  static Future<void> ensureCoreServices() async {
    if (!Get.isRegistered<StorageService>()) {
      AppLogger.w('StorageService not found, recreating...');
      final service = StorageService();
      await service.ensureInitialized();
      Get.put<StorageService>(service, permanent: true);
    } else {
      // Ensure existing service is initialized
      final service = Get.find<StorageService>();
      if (!service.isInitialized) {
        await service.ensureInitialized();
      }
    }

    if (!Get.isRegistered<ApiService>()) {
      AppLogger.w('ApiService not found, recreating...');
      final service = ApiService();
      Get.put<ApiService>(service, permanent: true);
      // Wait for onInit to complete
      await Future.delayed(const Duration(milliseconds: 100));
    }

    ensureAuthController();
    ensureLoginController();
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

    // Also check if services are properly initialized
    if (hasStorage) {
      try {
        final storageService = Get.find<StorageService>();
        if (!storageService.isInitialized) {
          AppLogger.w('StorageService found but not properly initialized');
          return false;
        }
      } catch (e) {
        AppLogger.e('Error checking StorageService', e);
        return false;
      }
    }

    if (hasApi) {
      try {
        final apiService = Get.find<ApiService>();
        if (apiService.baseUrl.isEmpty) {
          AppLogger.w('ApiService found but not properly initialized');
          return false;
        }
      } catch (e) {
        AppLogger.e('Error checking ApiService', e);
        return false;
      }
    }

    return true;
  }

  /// Initialize or reinitialize all dependencies
  static Future<void> initializeDependencies() async {
    AppLogger.i('Initializing dependencies...');

    // Clear any existing instances
    await clearDependencies();

    // Reinitialize using async method
    await GlobalBindings.initializeAsync();

    AppLogger.i('Dependencies initialized');
  }

  /// Clear all dependencies (use with caution)
  static Future<void> clearDependencies() async {
    AppLogger.w('Clearing all dependencies...');

    try {
      if (Get.isRegistered<LoginFormController>()) {
        await Get.delete<LoginFormController>(force: true);
      }
    } catch (e) {
      AppLogger.e('Error clearing LoginFormController', e);
    }

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