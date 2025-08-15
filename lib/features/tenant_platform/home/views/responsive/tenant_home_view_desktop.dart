// lib/features/tenant_platform/home/views/responsive/tenant_home_view_desktop.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../features/auth/controllers/auth_controller.dart';
import '../../../../../constants/app_colors.dart';
import '../../../../../shared/layouts/desktop_app_layout.dart';
import '../../../config/sidebar/tenant_menu_items.dart';

class TenantHomeViewDesktop extends GetView<AuthController> {
  const TenantHomeViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.currentUser.value;
      final userRoles = user?.roleNames ?? [];

      return TenantDesktopLayout(
        sidebarItems: TenantMenuItems.getMenuItems(userRoles),
        sidebarHeader: TenantMenuItems.buildHeader(),
        sidebarFooter: TenantMenuItems.buildFooter(),
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

            // Role and school indicator
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
                  'School Portal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Management Dashboard',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Compact role and school indicator
          Obx(() {
            final user = controller.currentUser.value;
            final tenant = controller.currentTenant.value;
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.loginButton.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Role: ${user?.primaryRole ?? 'Staff'}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.loginButton,
                    ),
                  ),
                ),
                if (tenant != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    tenant.displayName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
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
    );
  }

  Widget _buildRoleIndicator() {
    return Obx(() {
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
          if (roles.any((role) => ['school_admin', 'school_manager', 'teacher', 'assistant'].contains(role))) ...[
            _buildQuickActionCard(
              icon: Icons.child_care,
              title: 'Children',
              subtitle: 'Manage Classes',
              color: AppColors.info,
            ),
            _buildQuickActionCard(
              icon: Icons.how_to_reg,
              title: 'Attendance',
              subtitle: 'Today\'s Check-in',
              color: AppColors.success,
            ),
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
    });
  }

  Widget _buildCompactQuickActions() {
    return Obx(() {
      final user = controller.currentUser.value;
      final roles = user?.roleNames ?? [];

      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
        children: [
          if (roles.any((role) => ['school_admin', 'school_manager', 'teacher', 'assistant'].contains(role))) ...[
            _buildCompactActionCard(Icons.child_care, 'Children', AppColors.info),
            _buildCompactActionCard(Icons.how_to_reg, 'Attendance', AppColors.success),
            _buildCompactActionCard(Icons.restaurant, 'Meals', AppColors.warning),
            _buildCompactActionCard(Icons.photo_library, 'Activities', AppColors.loginButton),
          ] else ...[
            _buildCompactActionCard(Icons.visibility, 'View', AppColors.info),
            _buildCompactActionCard(Icons.dashboard, 'Dashboard', AppColors.success),
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
      'Use the sidebar to navigate through the school management features.',
      style: TextStyle(
        fontSize: 16,
        color: AppColors.textSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }
}