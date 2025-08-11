// lib/features/admin_platform/home/views/responsive/admin_home_view_desktop.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';
import '../../../../../features/auth/controllers/auth_controller.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../shared/components/sidebar/app_sidebar.dart';
import '../../../../../constants/app_colors.dart';
import '../../../config/sidebar/admin_menu_items.dart';


class AdminHomeViewDesktop extends GetView<AuthController> {
  const AdminHomeViewDesktop({super.key});

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
              items: AdminMenuItems.getMenuItems(userRoles),
              header: AdminMenuItems.buildHeader(),
              footer: AdminMenuItems.buildFooter(),
            );
          }),
          Expanded(
            child: Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                title: const Text(
                  'Platform Administration',
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
                  // User info
                  Obx(() {
                    final user = controller.currentUser.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Text(
                            user?.fullName ?? 'Platform Admin',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          CircleAvatar(
                            backgroundColor: AppColors.loginButton,
                            radius: 18,
                            child: Text(
                              user?.initials ?? 'PA',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  // Logout button
                  IconButton(
                    onPressed: () async {
                      try {
                        final authController = Get.find<AuthController>();
                        await authController.logout();
                      } catch (e) {
                        Get.offAllNamed(AppRoutes.login);
                      }
                    },
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
                              'Welcome to Admin Platform',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Platform Administration Dashboard',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Quick stats - role-based
                      Obx(() {
                        final user = controller.currentUser.value;
                        final userRoles = user?.roleNames ?? [];

                        if (userRoles.contains('platform_admin')) {
                          // Full admin stats
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStatCard(
                                title: 'Total Tenants',
                                value: '24',
                                icon: Icons.business,
                                color: AppColors.info,
                              ),
                              const SizedBox(width: 24),
                              _buildStatCard(
                                title: 'Active Users',
                                value: '1,247',
                                icon: Icons.people,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 24),
                              _buildStatCard(
                                title: 'System Health',
                                value: '98.5%',
                                icon: Icons.health_and_safety,
                                color: AppColors.warning,
                              ),
                            ],
                          );
                        } else if (userRoles.contains('platform_support')) {
                          // Support-focused stats
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStatCard(
                                title: 'Open Tickets',
                                value: '12',
                                icon: Icons.support_agent,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 24),
                              _buildStatCard(
                                title: 'System Health',
                                value: '98.5%',
                                icon: Icons.health_and_safety,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 24),
                              _buildStatCard(
                                title: 'Active Schools',
                                value: '22',
                                icon: Icons.school,
                                color: AppColors.info,
                              ),
                            ],
                          );
                        } else {
                          // Default minimal stats
                          return _buildStatCard(
                            title: 'Platform Status',
                            value: 'Online',
                            icon: Icons.check_circle,
                            color: AppColors.success,
                          );
                        }
                      }),

                      const SizedBox(height: 32),

                      // Action message - role-based
                      Obx(() {
                        final user = controller.currentUser.value;
                        final userRoles = user?.roleNames ?? [];

                        String message = 'Use the sidebar to navigate through the platform administration features.';

                        if (userRoles.contains('platform_admin')) {
                          message = 'Use the sidebar to manage tenants, users, and platform settings.';
                        } else if (userRoles.contains('platform_support')) {
                          message = 'Use the sidebar to access reports, analytics, and support tools.';
                        }

                        return Text(
                          message,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        );
                      }),
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
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
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
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