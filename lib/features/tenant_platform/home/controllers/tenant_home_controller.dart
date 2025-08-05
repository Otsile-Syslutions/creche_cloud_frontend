// lib/features/tenant_platform/controllers/tenant_home_controller.dart
import 'package:get/get.dart';
import '../../../../utils/app_logger.dart';
import '../../../auth/controllers/auth_controller.dart';


class TenantHomeController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxString selectedMenuItem = 'dashboard'.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.i('Tenant Home Controller initialized');
    _initializeTenantDashboard();
  }

  void _initializeTenantDashboard() {
    // Initialize tenant-specific data
    AppLogger.i('Initializing tenant dashboard for user: ${_authController.currentUser.value?.fullName}');
  }

  void selectMenuItem(String item) {
    selectedMenuItem.value = item;
    AppLogger.d('Tenant menu item selected: $item');
  }
}