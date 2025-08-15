// lib/features/admin_platform/config/sidebar/admin_menu_items.dart
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../shared/components/sidebar/app_sidebar.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../../utils/app_logger.dart';

class AdminMenuItems {
  static List<SidebarXItem> getMenuItems(List<String> userRoles) {
    // Enhanced debug logging
    AppLogger.d('=== ADMIN MENU GENERATION ===');
    AppLogger.d('Received roles: $userRoles');
    AppLogger.d('Roles count: ${userRoles.length}');

    final items = <SidebarXItem>[
      // Dashboard - Available to all admin roles
      SidebarXItem(
        iconBuilder: (selected, hovered) => HugeIcon(
          icon: HugeIcons.strokeRoundedDashboardSquare01,
          color: selected ? Colors.white : const Color(0xFF6B7280),
          size: 22,
        ),
        label: 'Dashboard',
        onTap: () {
          AppLogger.d('Admin Dashboard tapped');
          // Navigate to admin home
          // Get.toNamed(AppRoutes.adminHome);
        },
      ),
    ];

    // More flexible role checking
    final isPlatformAdmin = _isPlatformAdmin(userRoles);
    AppLogger.d('Is platform admin result: $isPlatformAdmin');

    // Platform Admin only features
    if (isPlatformAdmin) {
      AppLogger.d('✅ Adding platform admin menu items');
      items.addAll([
        SidebarXItem(
          iconBuilder: (selected, hovered) => HugeIcon(
            icon: HugeIcons.strokeRoundedBuilding01,
            color: selected ? Colors.white : const Color(0xFF6B7280),
            size: 22,
          ),
          label: 'Tenants',
          onTap: () {
            AppLogger.d('Tenants menu tapped');
            // Navigate to tenants management
            // Get.toNamed(AppRoutes.adminTenants);
          },
        ),
        SidebarXItem(
          iconBuilder: (selected, hovered) => HugeIcon(
            icon: HugeIcons.strokeRoundedUserMultiple,
            color: selected ? Colors.white : const Color(0xFF6B7280),
            size: 22,
          ),
          label: 'Users',
          onTap: () {
            AppLogger.d('Users menu tapped');
            // Navigate to user management
            // Get.toNamed(AppRoutes.adminUsers);
          },
        ),
      ]);
    } else {
      AppLogger.d('❌ Not adding platform admin items - user is not platform admin');
    }

    // Reports and Analytics
    final hasReportsAccess = _hasReportsAccess(userRoles);
    AppLogger.d('Has reports access result: $hasReportsAccess');

    if (hasReportsAccess) {
      AppLogger.d('✅ Adding reports and analytics menu items');
      items.addAll([
        SidebarXItem(
          iconBuilder: (selected, hovered) => HugeIcon(
            icon: HugeIcons.strokeRoundedFile02,
            color: selected ? Colors.white : const Color(0xFF6B7280),
            size: 22,
          ),
          label: 'Reports',
          onTap: () {
            AppLogger.d('Reports menu tapped');
            // Navigate to reports
            // Get.toNamed(AppRoutes.adminReports);
          },
        ),
        SidebarXItem(
          iconBuilder: (selected, hovered) => HugeIcon(
            icon: HugeIcons.strokeRoundedChartLineData01,
            color: selected ? Colors.white : const Color(0xFF6B7280),
            size: 22,
          ),
          label: 'Analytics',
          onTap: () {
            AppLogger.d('Analytics menu tapped');
            // Navigate to analytics
            // Get.toNamed(AppRoutes.adminAnalytics);
          },
        ),
      ]);
    } else {
      AppLogger.d('❌ Not adding reports items - user does not have reports access');
    }

    // Platform Admin only - Settings
    if (isPlatformAdmin) {
      AppLogger.d('✅ Adding settings menu item');
      items.add(
        SidebarXItem(
          iconBuilder: (selected, hovered) => HugeIcon(
            icon: HugeIcons.strokeRoundedSettings01,
            color: selected ? Colors.white : const Color(0xFF6B7280),
            size: 22,
          ),
          label: 'Settings',
          onTap: () {
            AppLogger.d('Settings menu tapped');
            // Navigate to settings
            // Get.toNamed(AppRoutes.adminSettings);
          },
        ),
      );
    }

    AppLogger.d('Total admin menu items generated: ${items.length}');
    AppLogger.d('Menu items: ${items.map((e) => e.label).toList()}');
    AppLogger.d('=============================');

    return items;
  }

  /// Enhanced platform admin checking
  static bool _isPlatformAdmin(List<String> userRoles) {
    if (userRoles.isEmpty) {
      AppLogger.w('No user roles provided to _isPlatformAdmin');
      return false;
    }

    // Check for exact matches first
    const platformAdminRoles = [
      'platform_admin',
      'platform_administrator',
      'super_admin',
      'superadmin',
    ];

    for (final role in userRoles) {
      final normalizedRole = role.toLowerCase().trim();

      // Debug each role check
      AppLogger.d('Checking role: "$role" (normalized: "$normalizedRole")');

      // Exact match check
      if (platformAdminRoles.contains(normalizedRole)) {
        AppLogger.d('✅ Found exact platform admin role: $role');
        return true;
      }

      // Partial match check for variations
      if (normalizedRole.contains('platform') && normalizedRole.contains('admin')) {
        AppLogger.d('✅ Found platform admin role by pattern: $role');
        return true;
      }

      if (normalizedRole.contains('super') && normalizedRole.contains('admin')) {
        AppLogger.d('✅ Found super admin role by pattern: $role');
        return true;
      }
    }

    AppLogger.d('❌ No platform admin role found in: $userRoles');
    return false;
  }

  /// Enhanced reports access checking
  static bool _hasReportsAccess(List<String> userRoles) {
    if (userRoles.isEmpty) {
      AppLogger.w('No user roles provided to _hasReportsAccess');
      return false;
    }

    // If user is platform admin, they automatically have reports access
    if (_isPlatformAdmin(userRoles)) {
      AppLogger.d('✅ Has reports access via platform admin role');
      return true;
    }

    // Check for support roles
    const supportRoles = [
      'platform_support',
      'platform_support_agent',
      'support',
      'support_admin',
    ];

    for (final role in userRoles) {
      final normalizedRole = role.toLowerCase().trim();

      // Exact match check
      if (supportRoles.contains(normalizedRole)) {
        AppLogger.d('✅ Found support role: $role');
        return true;
      }

      // Pattern matching for support roles
      if (normalizedRole.contains('support') &&
          (normalizedRole.contains('platform') || normalizedRole.contains('admin'))) {
        AppLogger.d('✅ Found support role by pattern: $role');
        return true;
      }
    }

    AppLogger.d('❌ No reports access role found in: $userRoles');
    return false;
  }

  static Widget buildHeader({SidebarXController? controller}) {
    return AppSidebarHeader(
      controller: controller,
    );
  }

  static Widget buildFooter() {
    // Use GetBuilder instead of Obx to avoid the controller not found issue
    return GetBuilder<AuthController>(
      init: Get.isRegistered<AuthController>() ? null : AuthController(),
      builder: (authController) {
        final user = authController.currentUser.value;

        // Enhanced debugging
        AppLogger.d('=== ADMIN FOOTER BUILD ===');
        AppLogger.d('User exists: ${user != null}');
        AppLogger.d('User name: ${user?.fullName}');
        AppLogger.d('User roles: ${user?.roleNames}');
        AppLogger.d('Is platform admin: ${user?.isPlatformAdmin}');

        final userRoles = user?.roleNames ?? [];

        // Show different status based on role
        String statusText = 'Platform Online';
        bool isActive = true;
        IconData statusIcon = Icons.check_circle;

        // Use both roleNames and isPlatformAdmin flag for determination
        if (user?.isPlatformAdmin == true || _isPlatformAdmin(userRoles)) {
          statusText = 'Full Access';
          statusIcon = Icons.admin_panel_settings;
          AppLogger.d('✅ Footer: Full Access');
        } else if (_hasReportsAccess(userRoles)) {
          statusText = 'Support Access';
          statusIcon = Icons.support_agent;
          AppLogger.d('✅ Footer: Support Access');
        } else {
          statusText = 'Limited Access';
          statusIcon = Icons.info;
          isActive = false;
          AppLogger.d('✅ Footer: Limited Access');
        }

        AppLogger.d('Admin footer status: $statusText');
        AppLogger.d('=========================');

        return AppSidebarFooter(
          statusText: statusText,
          isActive: isActive,
          statusIcon: statusIcon,
        );
      },
    );
  }
}