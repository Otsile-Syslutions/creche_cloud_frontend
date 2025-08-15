// lib/features/admin_platform/controllers/admin_home_controller.dart
import 'package:get/get.dart';
import '../../../../utils/app_logger.dart';
import '../../../auth/controllers/auth_controller.dart';

class AdminHomeController extends GetxController {
  // Use lazy getter for safe auth controller access
  AuthController? get _authController =>
      Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isUserDataLoaded = false.obs;
  final RxString selectedMenuItem = 'dashboard'.obs;
  final RxString currentView = 'dashboard'.obs;

  // Stats (will be loaded from API in future)
  final RxInt totalTenants = 0.obs;
  final RxInt activeUsers = 0.obs;
  final RxDouble systemHealth = 0.0.obs;
  final RxInt openTickets = 0.obs;
  final RxInt activeSchools = 0.obs;

  // Safe getters for auth data
  get currentUser => _authController?.currentUser.value;
  get currentTenant => _authController?.currentTenant.value;

  @override
  void onInit() {
    super.onInit();
    AppLogger.i('Admin Home Controller initialized');

    // Ensure AuthController is available
    if (!Get.isRegistered<AuthController>()) {
      AppLogger.w('AuthController not found, attempting to initialize');
      try {
        Get.put(AuthController());
      } catch (e) {
        AppLogger.e('Failed to initialize AuthController', e);
      }
    }

    _initializeAdminDashboard();
  }

  @override
  void onReady() {
    super.onReady();
    AppLogger.d('AdminHomeController ready');
  }

  @override
  void onClose() {
    AppLogger.d('AdminHomeController closed');
    super.onClose();
  }

  Future<void> _initializeAdminDashboard() async {
    try {
      isLoading.value = true;

      // Check if auth controller is available
      if (_authController == null) {
        AppLogger.w('AuthController not available for admin dashboard initialization');
        return;
      }

      // Ensure user data is loaded
      await _ensureUserDataLoaded();

      // Initialize admin-specific data
      final user = currentUser;
      if (user != null) {
        AppLogger.i('Initializing admin dashboard for user: ${user.fullName}');
        AppLogger.d('User roles: ${user.roleNames}');
        AppLogger.d('Is platform admin: ${user.isPlatformAdmin}');

        // Load dashboard stats based on user role
        await _loadDashboardStats();

        isUserDataLoaded.value = true;
      } else {
        AppLogger.w('No user data available for admin dashboard');
      }
    } catch (e) {
      AppLogger.e('Error initializing admin dashboard', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _ensureUserDataLoaded() async {
    try {
      if (_authController == null) {
        AppLogger.w('Cannot load user data - AuthController not available');
        return;
      }

      // Use null-safe operators
      if (_authController?.currentUser.value == null && _authController?.isAuthenticated.value == true) {
        AppLogger.d('AdminHomeController: Loading user data...');
        await _authController?.getCurrentUser();
      }
    } catch (e) {
      AppLogger.e('Failed to load user data in AdminHomeController', e);
      // Don't rethrow - handle gracefully
    }
  }

  Future<void> _loadDashboardStats() async {
    try {
      final user = currentUser;
      if (user == null) return;

      // TODO: Replace with actual API calls
      if (user.isPlatformAdmin == true || isPlatformAdmin) {
        // Load platform admin stats
        totalTenants.value = 24;
        activeUsers.value = 1247;
        systemHealth.value = 98.5;
      } else if (hasSupportRole()) {
        // Load support stats
        openTickets.value = 12;
        systemHealth.value = 98.5;
        activeSchools.value = 22;
      }

      AppLogger.d('Dashboard stats loaded');
    } catch (e) {
      AppLogger.e('Error loading dashboard stats', e);
    }
  }

  void selectMenuItem(String item) {
    selectedMenuItem.value = item;
    AppLogger.d('Admin menu item selected: $item');
  }

  // Navigate to different sections
  void navigateToSection(String section) {
    currentView.value = section;
    AppLogger.d('Navigating to admin section: $section');
  }

  Future<void> refreshDashboard() async {
    AppLogger.d('Refreshing admin dashboard...');
    await _initializeAdminDashboard();
  }

  // Method to refresh data
  void refreshData() {
    AppLogger.d('Refreshing admin home data');
    refreshDashboard();
  }

  // Safe property getters
  bool get isPlatformAdmin {
    if (currentUser?.isPlatformAdmin == true) return true;

    final userRoles = currentUser?.roleNames ?? [];
    const platformAdminRoles = [
      'platform_admin',
      'platform_administrator',
      'super_admin',
      'superadmin',
    ];

    for (final role in userRoles) {
      final normalizedRole = role.toLowerCase().trim();
      if (platformAdminRoles.contains(normalizedRole)) return true;
      if (normalizedRole.contains('platform') && normalizedRole.contains('admin')) return true;
      if (normalizedRole.contains('super') && normalizedRole.contains('admin')) return true;
    }

    return false;
  }

  bool get isPlatformSupport => hasSupportRole();

  String get userName => currentUser?.fullName ?? 'Admin User';

  List<String> get userRoles => currentUser?.roleNames ?? [];

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

  // Method to check if user has support role
  bool hasSupportRole() {
    final roles = userRoles;
    const supportRoles = [
      'platform_support',
      'platform_support_agent',
      'support',
      'support_admin',
    ];

    for (final role in roles) {
      final normalizedRole = role.toLowerCase().trim();
      if (supportRoles.contains(normalizedRole)) return true;
      if (normalizedRole.contains('support')) return true;
    }

    return false;
  }

  // Method to determine access level
  String _determineAccessLevel(List<String> userRoles) {
    if (isPlatformAdmin) {
      return 'Full Access';
    } else if (hasSupportRole()) {
      return 'Support Access';
    } else {
      return 'Limited Access';
    }
  }

  // Get access level for UI display
  String getAccessLevel() {
    return _determineAccessLevel(userRoles);
  }

  // Check if user can access tenants management
  bool canAccessTenants() {
    return isPlatformAdmin;
  }

  // Check if user can access reports
  bool canAccessReports() {
    return isPlatformAdmin || hasSupportRole();
  }

  // Check if user can access settings
  bool canAccessSettings() {
    return isPlatformAdmin;
  }

  // Check if user can access users management
  bool canAccessUsers() {
    return isPlatformAdmin;
  }

  // Check if user can access billing
  bool canAccessBilling() {
    return isPlatformAdmin;
  }

  // Check if user can access analytics
  bool canAccessAnalytics() {
    return isPlatformAdmin || hasSupportRole();
  }

  // Check if user can access support tickets
  bool canAccessSupport() {
    return isPlatformAdmin || hasSupportRole();
  }

  // Check if user can view system health
  bool canViewSystemHealth() {
    return isPlatformAdmin || hasSupportRole();
  }
}