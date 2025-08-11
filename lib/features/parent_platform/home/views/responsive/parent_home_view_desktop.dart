// lib/features/parent_platform/home/views/responsive/parent_home_view_desktop.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';
import '../../../../../features/auth/controllers/auth_controller.dart';
import '../../../../../shared/components/sidebar/app_sidebar.dart';
import '../../../../../constants/app_colors.dart';
import '../../../config/sidebar/parent_menu_items.dart';

class ParentHomeViewDesktop extends GetView<AuthController> {
  const ParentHomeViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final sidebarController = SidebarXController(selectedIndex: 0, extended: true);

    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            controller: sidebarController,
            items: ParentMenuItems.getMenuItems(),
            header: ParentMenuItems.buildHeader(),
            footer: ParentMenuItems.buildFooter(),
          ),
          Expanded(
            child: Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                title: const Text(
                  'Parent Portal',
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
                            user?.fullName ?? 'Parent',
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
                              user?.initials ?? 'P',
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
                              'Welcome to Parent Portal',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Your Child\'s Journey Dashboard',
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

                      // Role indicator
                      Obx(() {
                        final user = controller.currentUser.value;
                        return Container(
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
                            'Role: ${user?.primaryRole ?? 'Parent'}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppColors.loginButton,
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 48),

                      // Feature indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildFeatureCard(
                            icon: Icons.child_care,
                            title: 'My Children',
                            subtitle: 'View Progress',
                            color: AppColors.info,
                          ),
                          const SizedBox(width: 24),
                          _buildFeatureCard(
                            icon: Icons.photo_library,
                            title: 'Daily Photos',
                            subtitle: 'Memories',
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 24),
                          _buildFeatureCard(
                            icon: Icons.message,
                            title: 'Messages',
                            subtitle: 'School Updates',
                            color: AppColors.warning,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Welcome message with child info
                      Obx(() {
                        final user = controller.currentUser.value;
                        final childCount = user?.children.length ?? 0;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.textHint,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Welcome, ${user?.firstName ?? 'Parent'}!',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                childCount > 0
                                    ? 'You have $childCount ${childCount == 1 ? 'child' : 'children'} enrolled'
                                    : 'No children enrolled yet',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 32),

                      // Navigation instruction
                      const Text(
                        'Use the sidebar to navigate through the parent portal features.',
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

  Widget _buildFeatureCard({
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