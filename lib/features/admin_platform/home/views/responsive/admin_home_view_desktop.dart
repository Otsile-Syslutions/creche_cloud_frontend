// lib/features/admin_platform/home/views/responsive/admin_home_view_desktop.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../features/auth/controllers/auth_controller.dart';

import '../../../../../constants/app_colors.dart';
import '../../../../../shared/layouts/desktop_app_layout.dart';
import '../../../config/sidebar/admin_menu_items.dart';

class AdminHomeViewDesktop extends GetView<AuthController> {
  const AdminHomeViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.currentUser.value;
      final userRoles = user?.roleNames ?? [];

      return AdminDesktopLayout(
        sidebarItems: AdminMenuItems.getMenuItems(userRoles),
        sidebarHeader: AdminMenuItems.buildHeader(),
        sidebarFooter: AdminMenuItems.buildFooter(),
        selectedIndex: 0,
        body: _buildBody(context),
      );
    });
  }

  Widget _buildBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final screenWidth = constraints.maxWidth;
        final needsCompactMode = screenHeight < 600 || screenWidth < 1000;

        return Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.background,
          child: needsCompactMode
              ? _buildCompactContent(screenWidth, screenHeight)
              : _buildFullContent(screenWidth, screenHeight),
        );
      },
    );
  }

  Widget _buildFullContent(double screenWidth, double screenHeight) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcome message
            _buildWelcomeCard(),
            const SizedBox(height: 32),

            // Role and platform indicator
            _buildRoleIndicator(),
            const SizedBox(height: 48),

            // Quick actions based on role
            _buildQuickActions(),
            const SizedBox(height: 32),

            // Navigation instruction
            _buildNavigationHint(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactContent(double screenWidth, double screenHeight) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Compact welcome
          Container(
            padding: const EdgeInsets.all(16),
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
            child: const Column(
              children: [
                Text(
                  'Admin Portal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Platform Management',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Compact role indicator
          Obx(() {
            final user = controller.currentUser.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.loginButton.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Role: ${user?.primaryRole ?? 'Administrator'}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.loginButton,
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Compact quick actions grid
          _buildCompactQuickActions(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
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
            'Welcome to Admin Portal',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Platform Management Dashboard',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleIndicator() {
    return Obx(() {
      final user = controller.currentUser.value;
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
              'Role: ${user?.primaryRole ?? 'Platform Administrator'}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.loginButton,
              ),
            ),
          ),
          if (user?.isPlatformAdmin == true) ...[
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
              child: const Text(
                'Full Platform Access',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildQuickActions() {
    return Obx(() {
      final user = controller.currentUser.value;
      final roles = user?.roleNames ?? [];

      return Wrap(
        spacing: 24,
        runSpacing: 24,
        alignment: WrapAlignment.center,
        children: [
          if (user?.isPlatformAdmin == true || roles.contains('platform_admin')) ...[
            _buildQuickActionCard(
              icon: Icons.business,
              title: 'Tenants',
              subtitle: 'Manage Schools',
              color: AppColors.info,
            ),
            _buildQuickActionCard(
              icon: Icons.people,
              title: 'Users',
              subtitle: 'System Users',
              color: AppColors.success,
            ),
            _buildQuickActionCard(
              icon: Icons.settings,
              title: 'Settings',
              subtitle: 'Platform Config',
              color: AppColors.warning,
            ),
          ] else if (roles.contains('platform_support')) ...[
            _buildQuickActionCard(
              icon: Icons.support_agent,
              title: 'Support',
              subtitle: 'Help Tickets',
              color: AppColors.info,
            ),
            _buildQuickActionCard(
              icon: Icons.analytics,
              title: 'Analytics',
              subtitle: 'Reports',
              color: AppColors.success,
            ),
            _buildQuickActionCard(
              icon: Icons.monitor_heart,
              title: 'Health',
              subtitle: 'System Status',
              color: AppColors.warning,
            ),
          ] else ...[
            _buildQuickActionCard(
              icon: Icons.dashboard,
              title: 'Dashboard',
              subtitle: 'Overview',
              color: AppColors.info,
            ),
          ],
        ],
      );
    });
  }

  Widget _buildCompactQuickActions() {
    return Obx(() {
      final user = controller.currentUser.value;

      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
        children: [
          if (user?.isPlatformAdmin == true) ...[
            _buildCompactActionCard(Icons.business, 'Tenants', AppColors.info),
            _buildCompactActionCard(Icons.people, 'Users', AppColors.success),
            _buildCompactActionCard(Icons.settings, 'Settings', AppColors.warning),
            _buildCompactActionCard(Icons.analytics, 'Reports', AppColors.loginButton),
          ] else ...[
            _buildCompactActionCard(Icons.dashboard, 'Dashboard', AppColors.info),
            _buildCompactActionCard(Icons.support_agent, 'Support', AppColors.success),
          ],
        ],
      );
    });
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
          Icon(icon, size: 32, color: color),
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

  Widget _buildCompactActionCard(IconData icon, String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationHint() {
    return const Text(
      'Use the sidebar to navigate through the platform administration features.',
      style: TextStyle(
        fontSize: 16,
        color: AppColors.textSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }
}