// lib/features/tenant_platform/controllers/tenant_home_controller.dart
import 'package:get/get.dart';
import '../../../../utils/app_logger.dart';
import '../../../auth/controllers/auth_controller.dart';

class TenantHomeController extends GetxController {
  // Use lazy getter for safe auth controller access
  AuthController? get _authController =>
      Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxString selectedMenuItem = 'dashboard'.obs;
  final RxString currentView = 'dashboard'.obs;

  // Safe getters for auth data
  get currentUser => _authController?.currentUser.value;
  get currentTenant => _authController?.currentTenant.value;

  @override
  void onInit() {
    super.onInit();
    AppLogger.i('Tenant Home Controller initialized');

    // Ensure AuthController is available
    if (!Get.isRegistered<AuthController>()) {
      AppLogger.w('AuthController not found, attempting to initialize');
      try {
        Get.put(AuthController());
      } catch (e) {
        AppLogger.e('Failed to initialize AuthController', e);
      }
    }

    _initializeTenantDashboard();
  }

  @override
  void onReady() {
    super.onReady();
    AppLogger.d('TenantHomeController ready');
  }

  @override
  void onClose() {
    AppLogger.d('TenantHomeController closed');
    super.onClose();
  }

  void _initializeTenantDashboard() {
    try {
      isLoading.value = true;

      // Initialize tenant-specific data
      if (_authController != null) {
        AppLogger.i('Initializing tenant dashboard for user: ${currentUser?.fullName ?? 'Unknown'}');

        // Log tenant information if available
        if (currentTenant != null) {
          AppLogger.d('Tenant: ${currentTenant.displayName}');
          AppLogger.d('Tenant ID: ${currentTenant.id}');
          AppLogger.d('Subscription status: ${currentTenant.checkSubscriptionStatus() ? 'Active' : 'Inactive'}');
        }

        // Log user roles
        final userRoles = currentUser?.roleNames ?? [];
        AppLogger.d('User roles: $userRoles');

      } else {
        AppLogger.w('AuthController not available for tenant dashboard initialization');
      }

    } catch (e) {
      AppLogger.e('Error initializing tenant dashboard', e);
    } finally {
      isLoading.value = false;
    }
  }

  void selectMenuItem(String item) {
    selectedMenuItem.value = item;
    AppLogger.d('Tenant menu item selected: $item');
  }

  // Navigate to different sections
  void navigateToSection(String section) {
    currentView.value = section;
    AppLogger.d('Navigating to section: $section');
  }

  // Method to refresh data
  void refreshData() {
    AppLogger.d('Refreshing tenant home data');
    _initializeTenantDashboard();
  }

  // Method to check if user has specific role using safe access
  bool hasRole(String role) {
    // Use null-safe access to currentUser
    final user = currentUser;
    if (user == null) return false;

    try {
      // Check if user has the hasRole method and use it
      return user.hasRole(role);
    } catch (e) {
      // Fallback to manual check if hasRole method doesn't exist
      final roles = user.roleNames ?? [];
      return roles.any((r) => r.toLowerCase() == role.toLowerCase());
    }
  }

  // Method to check if user is school admin
  bool isSchoolAdmin() {
    return hasRole('school_admin');
  }

  // Method to check if user is teacher
  bool isTeacher() {
    return hasRole('teacher');
  }

  // Method to check if tenant subscription is active
  bool isTenantActive() {
    return currentTenant?.checkSubscriptionStatus() ?? false;
  }
}