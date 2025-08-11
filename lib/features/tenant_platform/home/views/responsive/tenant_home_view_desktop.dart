// lib/features/tenant_platform/home/views/responsive/tenant_home_view_desktop.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';
import '../../../../../features/auth/controllers/auth_controller.dart';
import '../../../../../shared/components/sidebar/app_sidebar.dart';
import '../../../../../constants/app_colors.dart';
import '../../../config/sidebar/tenant_menu_items.dart';


class TenantHomeViewDesktop extends GetView<AuthController> {
  const TenantHomeViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final sidebarController = SidebarXController(selectedIndex: 0, extended: true);

    return Scaffold(
      body: Row(
        children: [
          Obx(() {
            final user = controller.currentUser.value;
            final userRoles = user?.roleNames ?? [];

            return AppSidebar(
              controller: sidebarController,
              items: TenantMenuItems.getMenuItems(userRoles),
              header: TenantMenuItems.buildHeader(),
              footer: TenantMenuItems.buildFooter(),
            );
          }),
          Expanded(
            child: Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                title: const Text(
                  'School Management',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: AppColors.surface,
                elevation: 0,
                automaticallyImplyLeading: false,
                actions: [
                  // School info
                  Obx(() {
                    final user = controller.currentUser.value;
                    final tenant = controller.currentTenant.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            tenant?.name ?? 'School',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            user?.fullName ?? 'Staff Member',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(width: 8),
                  // User avatar
                  Obx(() {
                    final user = controller.currentUser.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: CircleAvatar(
                        backgroundColor: AppColors.loginButton,
                        radius: 18,
                        child: Text(
                          user?.initials ?? 'T',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                  // Logout button
                  IconButton(
                    onPressed: () => controller.logout(),
                    icon: const Icon(
                      Icons.logout,
                      color: AppColors.textSecondary,
                    ),
                    tooltip: 'Logout',
                  ),
                ],
              ),
              body: Container(
                width: double.infinity,
                height: double.infinity,
                color: AppColors.background,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Welcome message
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Column(
                          children: [
                            Text(
                              'Welcome to School Portal',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'School Management Dashboard',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Role and school indicator
                      Obx(() {
                        final user = controller.currentUser.value;
                        final tenant = controller.currentTenant.value;
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.loginButton.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: AppColors.loginButton.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Role: ${user?.primaryRole ?? 'Staff Member'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.loginButton,
                                ),
                              ),
                            ),
                            if (tenant != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.textHint,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'School: ${tenant.displayName}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      }),

                      const SizedBox(height: 48),

                      // Quick actions based on role
                      Obx(() {
                        final user = controller.currentUser.value;
                        final roles = user?.roleNames ?? [];

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (roles.any((role) => ['school_admin', 'school_manager', 'teacher', 'assistant'].contains(role))) ...[
                              _buildQuickActionCard(
                                icon: Icons.child_care,
                                title: 'Children',
                                subtitle: 'Manage Classes',
                                color: AppColors.info,
                              ),
                              const SizedBox(width: 24),
                              _buildQuickActionCard(
                                icon: Icons.how_to_reg,
                                title: 'Attendance',
                                subtitle: 'Today\'s Check-in',
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 24),
                              _buildQuickActionCard(
                                icon: Icons.restaurant,
                                title: 'Meals',
                                subtitle: 'Track Nutrition',
                                color: AppColors.warning,
                              ),
                            ] else ...[
                              _buildQuickActionCard(
                                icon: Icons.visibility,
                                title: 'View Access',
                                subtitle: 'Limited View',
                                color: AppColors.info,
                              ),
                            ],
                          ],
                        );
                      }),

                      const SizedBox(height: 32),

                      // Navigation instruction
                      const Text(
                        'Use the sidebar to navigate through the school management features.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}