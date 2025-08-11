// lib/features/admin_platform/home/views/admin_home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../shared/responsive/responsive_layout.dart';
import 'responsive/admin_home_view_desktop.dart';
import '../controllers/admin_home_controller.dart';

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller here as a failsafe
    if (!Get.isRegistered<AdminHomeController>()) {
      Get.put(AdminHomeController());
    }

    return const ResponsiveLayout(
      mobile: AdminHomeViewDesktop(),
      tablet: AdminHomeViewDesktop(),
      desktop: AdminHomeViewDesktop(),
    );
  }
}