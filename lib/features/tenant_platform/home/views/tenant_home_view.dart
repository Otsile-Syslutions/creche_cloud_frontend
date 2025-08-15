// lib/features/tenant_platform/home/views/tenant_home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../shared/responsive/responsive_layout.dart';
import '../../../../features/auth/controllers/auth_controller.dart';
import '../../../../utils/app_logger.dart';
import 'responsive/tenant_home_view_desktop.dart';
import '../controllers/tenant_home_controller.dart';

class TenantHomeView extends StatelessWidget {
  const TenantHomeView({super.key});

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

    // Initialize TenantHomeController after AuthController
    if (!Get.isRegistered<TenantHomeController>()) {
      AppLogger.d('Initializing TenantHomeController');
      Get.put(TenantHomeController());
    }

    return const ResponsiveLayout(
      mobile: TenantHomeViewDesktop(), // Using desktop for all sizes as requested
      tablet: TenantHomeViewDesktop(),
      desktop: TenantHomeViewDesktop(),
    );
  }
}