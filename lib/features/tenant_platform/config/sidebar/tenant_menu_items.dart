// lib/features/tenant_platform/config/sidebar/tenant_menu_items.dart
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart' hide SidebarXItem;

import 'package:hugeicons/hugeicons.dart';
import '../../../../shared/components/sidebar/app_sidebar.dart';

class TenantMenuItems {
  static List<AppSidebarItem> getMenuItems(List<String> userRoles) {
    final items = <AppSidebarItem>[
      AppSidebarItem(
        iconBuilder: (selected, hovered) => HugeIcon(
          icon: HugeIcons.strokeRoundedDashboardSquare01,
          color: selected ? Colors.white : const Color(0xFF6B7280),
          size: 22,
        ),
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
        AppSidebarItem(
          iconBuilder: (selected, hovered) => HugeIcon(
            icon: HugeIcons.strokeRoundedBaby01,
            color: selected ? Colors.white : const Color(0xFF6B7280),
            size: 22,
          ),
          label: 'Children',
          onTap: () {
            // Navigate to children management
            // Get.toNamed(AppRoutes.tenantChildren);
          },
        ),
        AppSidebarItem(
          iconBuilder: (selected, hovered) => HugeIcon(
            icon: HugeIcons.strokeRoundedUserCheck01,
            color: selected ? Colors.white : const Color(0xFF6B7280),
            size: 22,
          ),
          label: 'Attendance',
          onTap: () {
            // Navigate to attendance
            // Get.toNamed(AppRoutes.tenantAttendance);
          },
        ),
        AppSidebarItem(
          iconBuilder: (selected, hovered) => HugeIcon(
            icon: HugeIcons.strokeRoundedDish01,
            color: selected ? Colors.white : const Color(0xFF6B7280),
            size: 22,
          ),
          label: 'Meals',
          onTap: () {
            // Navigate to meals
            // Get.toNamed(AppRoutes.tenantMeals);
          },
        ),
        AppSidebarItem(
          iconBuilder: (selected, hovered) => HugeIcon(
            icon: HugeIcons.strokeRoundedBasketball01,
            color: selected ? Colors.white : const Color(0xFF6B7280),
            size: 22,
          ),
          label: 'Activities',
          onTap: () {
            // Navigate to activities
            // Get.toNamed(AppRoutes.tenantActivities);
          },
        ),
        AppSidebarItem(
          iconBuilder: (selected, hovered) => HugeIcon(
            icon: HugeIcons.strokeRoundedMessage01,
            color: selected ? Colors.white : const Color(0xFF6B7280),
            size: 22,
          ),
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
        AppSidebarItem(
          iconBuilder: (selected, hovered) => HugeIcon(
            icon: HugeIcons.strokeRoundedUserMultiple,
            color: selected ? Colors.white : const Color(0xFF6B7280),
            size: 22,
          ),
          label: 'Staff',
          onTap: () {
            // Navigate to staff management
            // Get.toNamed(AppRoutes.tenantStaff);
          },
        ),
        AppSidebarItem(
          iconBuilder: (selected, hovered) => HugeIcon(
            icon: HugeIcons.strokeRoundedChartLineData01,
            color: selected ? Colors.white : const Color(0xFF6B7280),
            size: 22,
          ),
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
        AppSidebarItem(
          iconBuilder: (selected, hovered) => HugeIcon(
            icon: HugeIcons.strokeRoundedUserSettings01,
            color: selected ? Colors.white : const Color(0xFF6B7280),
            size: 22,
          ),
          label: 'Users',
          onTap: () {
            // Navigate to user management
            // Get.toNamed(AppRoutes.tenantUsers);
          },
        ),
        AppSidebarItem(
          iconBuilder: (selected, hovered) => HugeIcon(
            icon: HugeIcons.strokeRoundedInvoice,
            color: selected ? Colors.white : const Color(0xFF6B7280),
            size: 22,
          ),
          label: 'Billing',
          onTap: () {
            // Navigate to billing
            // Get.toNamed(AppRoutes.tenantBilling);
          },
        ),
        AppSidebarItem(
          iconBuilder: (selected, hovered) => HugeIcon(
            icon: HugeIcons.strokeRoundedSettings01,
            color: selected ? Colors.white : const Color(0xFF6B7280),
            size: 22,
          ),
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

  static Widget buildHeader({SidebarXController? controller}) {
    return AppSidebarHeader(
      controller: controller,
    );
  }

  static Widget buildFooter() {
    // Simple static footer without GetBuilder
    return const AppSidebarFooter(
      statusText: 'School Active',
      isActive: true,
      statusIcon: Icons.check_circle,
    );
  }

  // New method to build dynamic footer (to be called from parent widget that has access to AuthController)
  static Widget buildDynamicFooter({required bool isActive, String? tenantName}) {
    return AppSidebarFooter(
      statusText: isActive ? 'School Active' : 'Check Status',
      isActive: isActive,
      statusIcon: isActive ? Icons.check_circle : Icons.warning,
    );
  }
}