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
          label: 'Tenants',
          subItems: [
            AppSidebarItem(
              label: 'All Tenants',
              onTap: () {
                // Get.toNamed(AppRoutes.adminTenants);
              },
            ),
            AppSidebarItem(
              label: 'Add Tenant',
              onTap: () {
                // Get.toNamed(AppRoutes.adminAddTenant);
              },
            ),
            AppSidebarItem(
              label: 'Inactive Tenants',
              onTap: () {
                // Get.toNamed(AppRoutes.adminInactiveTenants);
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
          subItems: [
            AppSidebarItem(
              label: 'All Users',
              onTap: () {
                // Get.toNamed(AppRoutes.adminUsers);
              },
            ),
            AppSidebarItem(
              label: 'Platform Admins',
              onTap: () {
                // Get.toNamed(AppRoutes.adminPlatformAdmins);
              },
            ),
            AppSidebarItem(
              label: 'User Roles',
              onTap: () {
                // Get.toNamed(AppRoutes.adminUserRoles);
              },
            ),
          ],
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
          subItems: [
            AppSidebarItem(
              label: 'Subscriptions',
              onTap: () {
                // Get.toNamed(AppRoutes.adminSubscriptions);
              },
            ),
            AppSidebarItem(
              label: 'Invoices',
              onTap: () {
                // Get.toNamed(AppRoutes.adminInvoices);
              },
            ),
            AppSidebarItem(
              label: 'Payment Methods',
              onTap: () {
                // Get.toNamed(AppRoutes.adminPaymentMethods);
              },
            ),
          ],
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
          subItems: [
            AppSidebarItem(
              label: 'Open Tickets',
              onTap: () {
                // Get.toNamed(AppRoutes.adminOpenTickets);
              },
            ),
            AppSidebarItem(
              label: 'Resolved Tickets',
              onTap: () {
                // Get.toNamed(AppRoutes.adminResolvedTickets);
              },
            ),
            AppSidebarItem(
              label: 'Knowledge Base',
              onTap: () {
                // Get.toNamed(AppRoutes.adminKnowledgeBase);
              },
            ),
          ],
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
        subItems: [
          AppSidebarItem(
            label: 'Platform Settings',
            onTap: () {
              // Get.toNamed(AppRoutes.adminPlatformSettings);
            },
          ),
          AppSidebarItem(
            label: 'Security',
            onTap: () {
              // Get.toNamed(AppRoutes.adminSecurity);
            },
          ),
          AppSidebarItem(
            label: 'API Configuration',
            onTap: () {
              // Get.toNamed(AppRoutes.adminApiConfig);
            },
          ),
          AppSidebarItem(
            label: 'Logs',
            onTap: () {
              // Get.toNamed(AppRoutes.adminLogs);
            },
          ),
        ],
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