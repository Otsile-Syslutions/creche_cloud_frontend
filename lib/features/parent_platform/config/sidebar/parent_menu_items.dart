// lib/features/parent_platform/config/sidebar/parent_menu_items.dart
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:get/get.dart';
import '../../../../shared/components/sidebar/app_sidebar.dart';
import '../../../auth/controllers/auth_controller.dart';

class ParentMenuItems {
  static List<SidebarXItem> getMenuItems() {
    return [
      SidebarXItem(
        icon: Icons.home,
        label: 'Home',
        onTap: () {
          // Navigate to parent home
          // Get.toNamed(AppRoutes.parentHome);
        },
      ),
      SidebarXItem(
        icon: Icons.child_care,
        label: 'My Children',
        onTap: () {
          // Navigate to children
          // Get.toNamed(AppRoutes.parentChildren);
        },
      ),
      SidebarXItem(
        icon: Icons.photo_library,
        label: 'Daily Photos',
        onTap: () {
          // Navigate to photos/activities
          // Get.toNamed(AppRoutes.parentActivities);
        },
      ),
      SidebarXItem(
        icon: Icons.message,
        label: 'Messages',
        onTap: () {
          // Navigate to messages
          // Get.toNamed(AppRoutes.parentMessages);
        },
      ),
      SidebarXItem(
        icon: Icons.assessment,
        label: 'Reports',
        onTap: () {
          // Navigate to reports
          // Get.toNamed(AppRoutes.parentReports);
        },
      ),
      SidebarXItem(
        icon: Icons.payment,
        label: 'Billing',
        onTap: () {
          // Navigate to billing
          // Get.toNamed(AppRoutes.parentBilling);
        },
      ),
    ];
  }

  static Widget buildHeader() {
    return const AppSidebarHeader(
      title: 'Creche Cloud',
      subtitle: 'Parent Portal',
      icon: Icons.family_restroom,
    );
  }

  static Widget buildFooter() {
    return GetBuilder<AuthController>(
      builder: (authController) {
        final user = authController.currentUser.value;
        final childCount = user?.children.length ?? 0;

        return AppSidebarFooter(
          statusText: childCount > 0
              ? '$childCount ${childCount == 1 ? 'Child' : 'Children'}'
              : 'No Children',
          isActive: childCount > 0,
          statusIcon: Icons.child_care,
        );
      },
    );
  }
}