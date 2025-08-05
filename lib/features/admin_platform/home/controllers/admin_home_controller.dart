// lib/features/admin_platform/controllers/admin_home_controller.dart
import 'package:get/get.dart';
import '../../../../utils/app_logger.dart';
import '../../../auth/controllers/auth_controller.dart';


class AdminHomeController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxString selectedMenuItem = 'dashboard'.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.i('Admin Home Controller initialized');
    _initializeAdminDashboard();
  }

  void _initializeAdminDashboard() {
    // Initialize admin-specific data
    AppLogger.i('Initializing admin dashboard for user: ${_authController.currentUser.value?.fullName}');
  }

  void selectMenuItem(String item) {
    selectedMenuItem.value = item;
    AppLogger.d('Admin menu item selected: $item');
  }
}