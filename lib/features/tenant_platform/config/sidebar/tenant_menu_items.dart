// lib/features/tenant_platform/config/sidebar/tenant_menu_items.dart
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../shared/components/sidebar/app_sidebar.dart';
import '../../../auth/controllers/auth_controller.dart';

class TenantMenuItems {
  static List<SidebarXItem> getMenuItems(List<String> userRoles) {
    final items = <SidebarXItem>[
      SidebarXItem(
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
        SidebarXItem(
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
        SidebarXItem(
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
        SidebarXItem(
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
        SidebarXItem(
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
        SidebarXItem(
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
        SidebarXItem(
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
        SidebarXItem(
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
        SidebarXItem(
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
        SidebarXItem(
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
        SidebarXItem(
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