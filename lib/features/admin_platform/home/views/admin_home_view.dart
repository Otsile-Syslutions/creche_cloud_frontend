// lib/features/admin_platform/home/views/admin_home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../shared/responsive/responsive_layout.dart';
import '../../../../features/auth/controllers/auth_controller.dart';
import '../../../../utils/app_logger.dart';
import 'responsive/admin_home_view_desktop.dart';
import '../controllers/admin_home_controller.dart';

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure AuthController is available first
    if (!Get.isRegistered<AuthController>()) {
      AppLogger.w('AuthController not registered, initializing...');
      try {
        Get.put(AuthController());
        AppLogger.i('AuthController initialized successfully');
      } catch (e) {
        AppLogger.e('Failed to initialize AuthController', e);
      }
    }

    // Initialize AdminHomeController after AuthController
    if (!Get.isRegistered<AdminHomeController>()) {
      AppLogger.d('Initializing AdminHomeController');
      Get.put(AdminHomeController());
    }

    return const ResponsiveLayout(
      mobile: AdminHomeViewDesktop(),
      tablet: AdminHomeViewDesktop(),
      desktop: AdminHomeViewDesktop(),
    );
  }
}