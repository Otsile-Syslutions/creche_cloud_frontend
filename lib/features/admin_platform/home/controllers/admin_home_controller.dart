// lib/features/admin_platform/controllers/admin_home_controller.dart
import 'package:get/get.dart';
import '../../../../utils/app_logger.dart';
import '../../../auth/controllers/auth_controller.dart';


class AdminHomeController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isUserDataLoaded = false.obs;
  final RxString selectedMenuItem = 'dashboard'.obs;

  // Stats (will be loaded from API in future)
  final RxInt totalTenants = 0.obs;
  final RxInt activeUsers = 0.obs;
  final RxDouble systemHealth = 0.0.obs;
  final RxInt openTickets = 0.obs;
  final RxInt activeSchools = 0.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.i('Admin Home Controller initialized');
    _initializeAdminDashboard();
  }

  Future<void> _initializeAdminDashboard() async {
    try {
      isLoading.value = true;

      // Ensure user data is loaded
      await _ensureUserDataLoaded();

      // Initialize admin-specific data
      final user = _authController.currentUser.value;
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
      if (_authController.currentUser.value == null && _authController.isAuthenticated.value) {
        AppLogger.d('AdminHomeController: Loading user data...');
        await _authController.getCurrentUser();
      }
    } catch (e) {
      AppLogger.e('Failed to load user data in AdminHomeController', e);
      rethrow;
    }
  }

  Future<void> _loadDashboardStats() async {
    try {
      final user = _authController.currentUser.value;
      if (user == null) return;

      // TODO: Replace with actual API calls
      if (user.isPlatformAdmin) {
        // Load platform admin stats
        totalTenants.value = 24;
        activeUsers.value = 1247;
        systemHealth.value = 98.5;
      } else if (user.hasRole('platform_support')) {
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

  Future<void> refreshDashboard() async {
    AppLogger.d('Refreshing admin dashboard...');
    await _initializeAdminDashboard();
  }

  bool get isPlatformAdmin => _authController.currentUser.value?.isPlatformAdmin ?? false;
  bool get isPlatformSupport => _authController.currentUser.value?.hasRole('platform_support') ?? false;
  String get userName => _authController.currentUser.value?.fullName ?? 'Admin User';
  List<String> get userRoles => _authController.currentUser.value?.roleNames ?? [];
}