// lib/features/parent_platform/home/views/parent_home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../shared/responsive/responsive_layout.dart';
import '../../../../features/auth/controllers/auth_controller.dart';
import '../../../../utils/app_logger.dart';
import 'responsive/parent_home_view_desktop.dart';
import '../controllers/parent_home_controller.dart';

class ParentHomeView extends StatelessWidget {
  const ParentHomeView({super.key});

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

    // Initialize ParentHomeController after AuthController
    if (!Get.isRegistered<ParentHomeController>()) {
      AppLogger.d('Initializing ParentHomeController');
      Get.put(ParentHomeController());
    }

    return const ResponsiveLayout(
      mobile: ParentHomeViewDesktop(), // Using desktop for all sizes as requested
      tablet: ParentHomeViewDesktop(),
      desktop: ParentHomeViewDesktop(),
    );
  }
}