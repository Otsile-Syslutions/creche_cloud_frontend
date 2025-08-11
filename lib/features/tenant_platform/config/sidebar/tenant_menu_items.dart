// lib/features/tenant_platform/config/sidebar/tenant_menu_items.dart
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:get/get.dart';
import '../../../../shared/components/sidebar/app_sidebar.dart';
import '../../../auth/controllers/auth_controller.dart';

class TenantMenuItems {
  static List<SidebarXItem> getMenuItems(List<String> userRoles) {
    final items = <SidebarXItem>[
      SidebarXItem(
        icon: Icons.dashboard,
        label: 'Dashboard',
        onTap: () {
          // Navigate to tenant home
          // Get.toNamed(AppRoutes.tenantHome);
        },
      ),
    ];

    // Add items based on user roles - staff roles (teachers, assistants, etc.)
    if (userRoles.any((role) => [
      'school_admin',
      'school_manager',
      'teacher',
      'assistant'
    ].contains(role.toLowerCase()))) {
      items.addAll([
        SidebarXItem(
          icon: Icons.child_care,
          label: 'Children',
          onTap: () {
            // Navigate to children management
            // Get.toNamed(AppRoutes.tenantChildren);
          },
        ),
        SidebarXItem(
          icon: Icons.how_to_reg,
          label: 'Attendance',
          onTap: () {
            // Navigate to attendance
            // Get.toNamed(AppRoutes.tenantAttendance);
          },
        ),
        SidebarXItem(
          icon: Icons.restaurant,
          label: 'Meals',
          onTap: () {
            // Navigate to meals
            // Get.toNamed(AppRoutes.tenantMeals);
          },
        ),
        SidebarXItem(
          icon: Icons.sports,
          label: 'Activities',
          onTap: () {
            // Navigate to activities
            // Get.toNamed(AppRoutes.tenantActivities);
          },
        ),
        SidebarXItem(
          icon: Icons.message,
          label: 'Messages',
          onTap: () {
            // Navigate to messages
            // Get.toNamed(AppRoutes.tenantMessages);
          },
        ),
      ]);
    }

    // Add management items for admin and managers
    if (userRoles.any((role) => [
      'school_admin',
      'school_manager'
    ].contains(role.toLowerCase()))) {
      items.addAll([
        SidebarXItem(
          icon: Icons.people,
          label: 'Staff',
          onTap: () {
            // Navigate to staff management
            // Get.toNamed(AppRoutes.tenantStaff);
          },
        ),
        SidebarXItem(
          icon: Icons.analytics,
          label: 'Reports',
          onTap: () {
            // Navigate to reports
            // Get.toNamed(AppRoutes.tenantReports);
          },
        ),
      ]);
    }

    // Add admin-only items
    if (userRoles.any((role) => role.toLowerCase() == 'school_admin')) {
      items.addAll([
        SidebarXItem(
          icon: Icons.manage_accounts,
          label: 'Users',
          onTap: () {
            // Navigate to user management
            // Get.toNamed(AppRoutes.tenantUsers);
          },
        ),
        SidebarXItem(
          icon: Icons.payment,
          label: 'Billing',
          onTap: () {
            // Navigate to billing
            // Get.toNamed(AppRoutes.tenantBilling);
          },
        ),
        SidebarXItem(
          icon: Icons.settings,
          label: 'Settings',
          onTap: () {
            // Navigate to settings
            // Get.toNamed(AppRoutes.tenantSettings);
          },
        ),
      ]);
    }

    return items;
  }

  static Widget buildHeader() {
    return GetBuilder<AuthController>(
      builder: (authController) {
        final tenant = authController.currentTenant.value;
        return AppSidebarHeader(
          title: 'Creche Cloud',
          subtitle: tenant?.name ?? 'School Management',
          icon: Icons.school,
        );
      },
    );
  }

  static Widget buildFooter() {
    return GetBuilder<AuthController>(
      builder: (authController) {
        final tenant = authController.currentTenant.value;
        final isActive = tenant?.checkSubscriptionStatus() ?? false;

        return AppSidebarFooter(
          statusText: isActive ? 'School Active' : 'Check Status',
          isActive: isActive,
          statusIcon: isActive ? Icons.check_circle : Icons.warning,
        );
      },
    );
  }
}