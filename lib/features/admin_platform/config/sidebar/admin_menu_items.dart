// lib/features/admin_platform/config/sidebar/admin_menu_items.dart
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart' hide SidebarXItem; // Hide SidebarXItem to avoid conflicts
import 'package:hugeicons/hugeicons.dart';
import '../../../../shared/components/sidebar/app_sidebar.dart';

class AdminMenuItems {
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
          // Navigate to admin dashboard
          // Get.toNamed(AppRoutes.adminDashboard);
        },
      ),
    ];

    // Add platform admin items
    if (userRoles.any((role) =>
    role.toLowerCase() == 'platform_admin' ||
        role.toLowerCase() == 'admin')) {
      items.addAll([
        AppSidebarItem(
          iconBuilder: (selected, hovered) => HugeIcon(
            icon: HugeIcons.strokeRoundedBuilding01,
            color: selected ? Colors.white : const Color(0xFF6B7280),
            size: 22,
          ),
          label: 'Schools',
          subItems: [
            AppSidebarItem(
              label: 'Active Schools',
              onTap: () {
                // Get.toNamed(AppRoutes.adminActiveSchools);
              },
            ),
            AppSidebarItem(
              label: 'Sales Pipeline',
              onTap: () {
                // Get.toNamed(AppRoutes.adminSalesPipeline);
              },
            ),
            AppSidebarItem(
              label: 'Market Explorer',
              onTap: () {
                // Get.toNamed(AppRoutes.adminMarketExplorer);
              },
            ),
          ],
        ),
        AppSidebarItem(
          iconBuilder: (selected, hovered) => HugeIcon(
            icon: HugeIcons.strokeRoundedUserMultiple,
            color: selected ? Colors.white : const Color(0xFF6B7280),
            size: 22,
          ),
          label: 'Users',
          onTap: () {
            // Navigate to users
            // Get.toNamed(AppRoutes.adminUsers);
          },
        ),
        AppSidebarItem(
          iconBuilder: (selected, hovered) => HugeIcon(
            icon: HugeIcons.strokeRoundedChartLineData01,
            color: selected ? Colors.white : const Color(0xFF6B7280),
            size: 22,
          ),
          label: 'Analytics',
          onTap: () {
            // Navigate to analytics
            // Get.toNamed(AppRoutes.adminAnalytics);
          },
        ),
        AppSidebarItem(
          iconBuilder: (selected, hovered) => HugeIcon(
            icon: HugeIcons.strokeRoundedCreditCard,
            color: selected ? Colors.white : const Color(0xFF6B7280),
            size: 22,
          ),
          label: 'Billing',
          onTap: () {
            // Navigate to billing
            // Get.toNamed(AppRoutes.adminBilling);
          },
        ),
      ]);
    }

    // Add support items
    if (userRoles.any((role) =>
    role.toLowerCase() == 'platform_support' ||
        role.toLowerCase() == 'support')) {
      items.addAll([
        AppSidebarItem(
          iconBuilder: (selected, hovered) => HugeIcon(
            icon: HugeIcons.strokeRoundedCustomerSupport,
            color: selected ? Colors.white : const Color(0xFF6B7280),
            size: 22,
          ),
          label: 'Support',
          onTap: () {
            // Navigate to support
            // Get.toNamed(AppRoutes.adminSupport);
          },
        ),
        AppSidebarItem(
          iconBuilder: (selected, hovered) => HugeIcon(
            icon: HugeIcons.strokeRoundedNotification02,
            color: selected ? Colors.white : const Color(0xFF6B7280),
            size: 22,
          ),
          label: 'Announcements',
          onTap: () {
            // Navigate to announcements
            // Get.toNamed(AppRoutes.adminAnnouncements);
          },
        ),
      ]);
    }

    // Add settings for all admin users
    items.add(
      AppSidebarItem(
        iconBuilder: (selected, hovered) => HugeIcon(
          icon: HugeIcons.strokeRoundedSettings01,
          color: selected ? Colors.white : const Color(0xFF6B7280),
          size: 22,
        ),
        label: 'Settings',
        onTap: () {
          // Navigate to settings
          // Get.toNamed(AppRoutes.adminSettings);
        },
      ),
    );

    return items;
  }

  static Widget buildHeader({SidebarXController? controller}) {
    return AppSidebarHeader(
      controller: controller,
      // You can add a custom admin logo here
      // customLogo: Image.asset('assets/images/admin_logo.png'),
    );
  }

  static Widget buildFooter() {
    return const AppSidebarFooter(
      statusText: 'Platform Admin',
      isActive: true,
      statusIcon: Icons.admin_panel_settings,
    );
  }

  // Dynamic footer with platform status
  static Widget buildDynamicFooter({required bool isSystemOnline}) {
    return AppSidebarFooter(
      statusText: isSystemOnline ? 'System Online' : 'System Maintenance',
      isActive: isSystemOnline,
      statusIcon: isSystemOnline ? Icons.check_circle : Icons.warning,
    );
  }
}