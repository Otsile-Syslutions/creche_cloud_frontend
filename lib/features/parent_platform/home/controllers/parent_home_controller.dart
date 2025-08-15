// lib/features/parent_platform/controllers/parent_home_controller.dart
import 'package:get/get.dart';
import '../../../../utils/app_logger.dart';
import '../../../auth/controllers/auth_controller.dart';

class ParentHomeController extends GetxController {
  // Use lazy getter for safe auth controller access
  AuthController? get _authController =>
      Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxString selectedMenuItem = 'children'.obs;

  // Safe getters for auth data
  get currentUser => _authController?.currentUser.value;
  get currentTenant => _authController?.currentTenant.value;

  @override
  void onInit() {
    super.onInit();
    AppLogger.i('Parent Home Controller initialized');

    // Ensure AuthController is available
    if (!Get.isRegistered<AuthController>()) {
      AppLogger.w('AuthController not found, attempting to initialize');
      try {
        Get.put(AuthController());
      } catch (e) {
        AppLogger.e('Failed to initialize AuthController', e);
      }
    }

    _initializeParentDashboard();
  }

  @override
  void onReady() {
    super.onReady();
    AppLogger.d('ParentHomeController ready');
  }

  @override
  void onClose() {
    AppLogger.d('ParentHomeController closed');
    super.onClose();
  }

  void _initializeParentDashboard() {
    try {
      isLoading.value = true;

      // Initialize parent-specific data
      if (_authController != null) {
        AppLogger.i('Initializing parent dashboard for user: ${currentUser?.fullName ?? 'Unknown'}');

        // Log children information if available
        final childCount = currentUser?.children?.length ?? 0;
        AppLogger.d('Parent has $childCount children enrolled');
      } else {
        AppLogger.w('AuthController not available for parent dashboard initialization');
      }

    } catch (e) {
      AppLogger.e('Error initializing parent dashboard', e);
    } finally {
      isLoading.value = false;
    }
  }

  void selectMenuItem(String item) {
    selectedMenuItem.value = item;
    AppLogger.d('Parent menu item selected: $item');
  }

  // Method to refresh data
  void refreshData() {
    AppLogger.d('Refreshing parent home data');
    _initializeParentDashboard();
  }

  // Method to get child count safely
  int getChildCount() {
    return currentUser?.children?.length ?? 0;
  }

  // Method to check if parent has children
  bool hasChildren() {
    return getChildCount() > 0;
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
}