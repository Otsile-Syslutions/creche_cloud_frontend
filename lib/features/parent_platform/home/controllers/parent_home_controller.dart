// lib/features/parent_platform/controllers/parent_home_controller.dart
import 'package:get/get.dart';
import '../../../../utils/app_logger.dart';
import '../../../auth/controllers/auth_controller.dart';


class ParentHomeController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  // Observable variables
  final RxBool isLoading = false.obs;
  final RxString selectedMenuItem = 'children'.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.i('Parent Home Controller initialized');
    _initializeParentDashboard();
  }

  void _initializeParentDashboard() {
    // Initialize parent-specific data
    AppLogger.i('Initializing parent dashboard for user: ${_authController.currentUser.value?.fullName}');
  }

  void selectMenuItem(String item) {
    selectedMenuItem.value = item;
    AppLogger.d('Parent menu item selected: $item');
  }
}