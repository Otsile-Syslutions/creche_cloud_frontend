// lib/features/admin_platform/config/sidebar/admin_menu_items.dart
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:get/get.dart';
import '../../../../shared/components/sidebar/app_sidebar.dart';
import '../../../auth/controllers/auth_controller.dart';

class AdminMenuItems {
  static List<SidebarXItem> getMenuItems(List<String> userRoles) {
    final items = <SidebarXItem>[
      // Dashboard - Available to all admin roles
      SidebarXItem(
        icon: Icons.dashboard,
        label: 'Dashboard',
        onTap: () {
          // Navigate to admin home
          // Get.toNamed(AppRoutes.adminHome);
        },
      ),
    ];

    // Check for platform admin role (flexible matching)
    final isPlatformAdmin = userRoles.any((role) =>
    role == 'platform_admin' ||
        role == 'platform_administrator' ||
        role.toLowerCase() == 'platform_admin' ||
        (role.toLowerCase().contains('platform') && role.toLowerCase().contains('admin'))
    );

    // Platform Admin only features
    if (isPlatformAdmin) {
      items.addAll([
        SidebarXItem(
          icon: Icons.business,
          label: 'Tenants',
          onTap: () {
            // Navigate to tenants management
            // Get.toNamed(AppRoutes.adminTenants);
          },
        ),
        SidebarXItem(
          icon: Icons.people,
          label: 'Users',
          onTap: () {
            // Navigate to user management
            // Get.toNamed(AppRoutes.adminUsers);
          },
        ),
      ]);
    }

    // Check for support/admin roles (flexible matching)
    final hasReportsAccess = userRoles.any((role) =>
    role == 'platform_admin' ||
        role == 'platform_support' ||
        role.toLowerCase().contains('admin') ||
        role.toLowerCase().contains('support')
    );

    // Reports and Analytics - Available to both platform_admin and platform_support
    if (hasReportsAccess) {
      items.addAll([
        SidebarXItem(
          icon: Icons.analytics,
          label: 'Reports',
          onTap: () {
            // Navigate to reports
            // Get.toNamed(AppRoutes.adminReports);
          },
        ),
        SidebarXItem(
          icon: Icons.bar_chart,
          label: 'Analytics',
          onTap: () {
            // Navigate to analytics
            // Get.toNamed(AppRoutes.adminAnalytics);
          },
        ),
      ]);
    }

    // Platform Admin only - Settings
    if (isPlatformAdmin) {
      items.add(
        SidebarXItem(
          icon: Icons.settings,
          label: 'Settings',
          onTap: () {
            // Navigate to settings
            // Get.toNamed(AppRoutes.adminSettings);
          },
        ),
      );
    }

    return items;
  }

  static Widget buildHeader() {
    return GetBuilder<AuthController>(
      builder: (authController) {
        final user = authController.currentUser.value;
        final userRoles = user?.roleNames ?? [];

        // Determine the subtitle based on role
        String subtitle = 'Platform Admin';
        if (userRoles.any((role) => role.toLowerCase().contains('platform') && role.toLowerCase().contains('admin'))) {
          subtitle = 'Platform Administrator';
        } else if (userRoles.any((role) => role.toLowerCase().contains('support'))) {
          subtitle = 'Platform Support';
        }

        return AppSidebarHeader(
          title: 'Creche Cloud',
          subtitle: subtitle,
          icon: Icons.admin_panel_settings,
        );
      },
    );
  }

  static Widget buildFooter() {
    return GetBuilder<AuthController>(
      builder: (authController) {
        final user = authController.currentUser.value;
        final userRoles = user?.roleNames ?? [];

        // Show different status based on role
        String statusText = 'Platform Online';
        bool isActive = true;
        IconData statusIcon = Icons.check_circle;

        if (userRoles.any((role) => role.toLowerCase().contains('platform') && role.toLowerCase().contains('admin'))) {
          statusText = 'Full Access';
        } else if (userRoles.any((role) => role.toLowerCase().contains('support'))) {
          statusText = 'Support Access';
          statusIcon = Icons.support_agent;
        }

        return AppSidebarFooter(
          statusText: statusText,
          isActive: isActive,
          statusIcon: statusIcon,
        );
      },
    );
  }
}