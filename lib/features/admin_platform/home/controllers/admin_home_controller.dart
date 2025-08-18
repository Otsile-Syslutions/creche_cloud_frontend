// lib/features/admin_platform/controllers/admin_home_controller.dart
import 'package:get/get.dart';
import '../../../../utils/app_logger.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../auth/controllers/auth_controller.dart';

class AdminHomeController extends GetxController {
  // Services
  final ApiService _apiService = ApiService.to;
  final StorageService _storageService = StorageService.to;

  // Use lazy getter for safe auth controller access
  AuthController? get _authController =>
      Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isUserDataLoaded = false.obs;
  final RxString selectedMenuItem = 'dashboard'.obs;
  final RxString currentView = 'dashboard'.obs;
  final RxBool isInitialized = false.obs;

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

    // Additional initialization after view is ready
    if (!isInitialized.value) {
      _ensureAuthenticationAndLoadData();
    }
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

      // Ensure authentication is valid
      await _ensureAuthentication();

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
        isInitialized.value = true;
      } else {
        AppLogger.w('No user data available for admin dashboard');
      }
    } catch (e) {
      AppLogger.e('Error initializing admin dashboard', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Ensure authentication and load data (called from onReady)
  Future<void> _ensureAuthenticationAndLoadData() async {
    try {
      // Skip if already initialized
      if (isInitialized.value) return;

      AppLogger.d('Ensuring authentication and loading admin data...');

      // Ensure authentication is valid
      await _ensureAuthentication();

      // Load dashboard data if not already loaded
      if (!isUserDataLoaded.value) {
        await _loadDashboardStats();
        isUserDataLoaded.value = true;
      }

      isInitialized.value = true;

    } catch (e) {
      AppLogger.e('Failed to ensure authentication and load data', e);
    }
  }

  /// CRITICAL: Ensure user is authenticated before loading admin content
  Future<void> _ensureAuthentication() async {
    try {
      // Check if user is authenticated
      if (_authController == null || !_authController!.isAuthenticated.value) {
        AppLogger.w('User not authenticated in AdminHomeController');
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      // Verify the user has admin privileges
      final user = currentUser;
      if (user == null) {
        AppLogger.w('No user data available');
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      // Check if user is platform admin or has admin roles
      final isAdmin = isPlatformAdmin || hasSupportRole();

      if (!isAdmin) {
        AppLogger.w('User does not have admin privileges');
        // Redirect to appropriate platform based on user role
        _redirectBasedOnRole();
        return;
      }

      // Ensure token is set in API service
      await _ensureTokenInApiService();

      AppLogger.d('Authentication verified for admin user');

    } catch (e) {
      AppLogger.e('Authentication check failed', e);
      await _authController?.clearSession();
      Get.offAllNamed(AppRoutes.login);
      throw e;
    }
  }

  /// Ensure token is properly set in API service
  Future<void> _ensureTokenInApiService() async {
    try {
      final token = await _storageService.getString('access_token');

      if (token == null || token.isEmpty) {
        AppLogger.w('No access token found, attempting refresh...');

        // Try to refresh token
        final refreshToken = await _storageService.getString('refresh_token');
        if (refreshToken != null && refreshToken.isNotEmpty) {
          try {
            await _apiService.refreshTokenRequest();
            AppLogger.d('Token refreshed successfully');
          } catch (e) {
            AppLogger.e('Token refresh failed', e);
            await _authController?.clearSession();
            Get.offAllNamed(AppRoutes.login);
            return;
          }
        } else {
          await _authController?.clearSession();
          Get.offAllNamed(AppRoutes.login);
          return;
        }
      } else {
        // Ensure token is set in API service
        if (_apiService.accessToken != token) {
          await _apiService.setAccessToken(token);
          AppLogger.d('Token set in API service');
        }
      }
    } catch (e) {
      AppLogger.e('Error ensuring token in API service', e);
      throw e;
    }
  }

  /// Redirect user based on their role
  void _redirectBasedOnRole() {
    final user = currentUser;
    if (user == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    if (user.roleNames.contains('parent')) {
      Get.offAllNamed(AppRoutes.parentHome);
    } else if (user.roleNames.contains('school_admin') ||
        user.roleNames.contains('teacher') ||
        user.roleNames.contains('assistant')) {
      Get.offAllNamed(AppRoutes.tenantHome);
    } else {
      Get.offAllNamed(AppRoutes.login);
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

      // Ensure authentication before making API calls
      await _ensureTokenInApiService();

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

  // Navigate to different sections with authentication check
  Future<void> navigateToSection(String section) async {
    try {
      // Ensure authentication before navigation
      await _ensureAuthentication();

      currentView.value = section;
      AppLogger.d('Navigating to admin section: $section');

      // Navigate to the route if it's different from current
      final routeMap = {
        'market-explorer': AppRoutes.adminMarketExplorer,
        'active-schools': AppRoutes.adminActiveSchools,
        'sales-pipeline': AppRoutes.adminSalesPipeline,
        'users': AppRoutes.adminUsers,
        'tenants': AppRoutes.adminTenants,
        'reports': AppRoutes.adminReports,
        'settings': AppRoutes.adminSettings,
        'analytics': AppRoutes.adminAnalytics,
        'support': AppRoutes.adminSupport,
      };

      final route = routeMap[section];
      if (route != null) {
        Get.toNamed(route);
      }

    } catch (e) {
      AppLogger.e('Navigation failed', e);
    }
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

  // Logout user
  Future<void> logout() async {
    try {
      await _authController?.logout();
    } catch (e) {
      AppLogger.e('Logout failed', e);
    }
  }
}