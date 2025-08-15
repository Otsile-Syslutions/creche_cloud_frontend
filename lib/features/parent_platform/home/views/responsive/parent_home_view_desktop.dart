// lib/features/parent_platform/home/views/responsive/parent_home_view_desktop.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../features/auth/controllers/auth_controller.dart';
import '../../../../../shared/layouts/desktop_app_layout.dart';
import '../../../../../constants/app_colors.dart';
import '../../../config/sidebar/parent_menu_items.dart';

class ParentHomeViewDesktop extends GetView<AuthController> {
  const ParentHomeViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return ParentDesktopLayout(
      sidebarItems: ParentMenuItems.getMenuItems(),
      sidebarHeader: ParentMenuItems.buildHeader(),
      sidebarFooter: ParentMenuItems.buildFooter(),
      selectedIndex: 0,
      body: _buildBody(context),
    );
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

            // Role indicator
            _buildRoleIndicator(),
            const SizedBox(height: 48),

            // Feature cards
            _buildFeatureCards(),
            const SizedBox(height: 32),

            // Welcome message with child info
            _buildChildInfoCard(),
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
                  'Parent Portal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your Child\'s Journey',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Compact child info
          Obx(() {
            final user = controller.currentUser.value;
            final childCount = user?.children.length ?? 0;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.loginButton.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                childCount > 0
                    ? '$childCount ${childCount == 1 ? 'Child' : 'Children'} Enrolled'
                    : 'No Children Enrolled',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.loginButton,
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Compact feature grid
          _buildCompactFeatures(),
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
    );
  }

  Widget _buildRoleIndicator() {
    return Obx(() {
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
    });
  }

  Widget _buildFeatureCards() {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: [
        _buildFeatureCard(
          icon: Icons.child_care,
          title: 'My Children',
          subtitle: 'View Progress',
          color: AppColors.info,
        ),
        _buildFeatureCard(
          icon: Icons.photo_library,
          title: 'Daily Photos',
          subtitle: 'Memories',
          color: AppColors.success,
        ),
        _buildFeatureCard(
          icon: Icons.message,
          title: 'Messages',
          subtitle: 'School Updates',
          color: AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildChildInfoCard() {
    return Obx(() {
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
            if (childCount > 0) ...[
              const SizedBox(height: 16),
              // Quick stats
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatChip(Icons.photo, '${childCount * 5} Photos'),
                  const SizedBox(width: 12),
                  _buildStatChip(Icons.message, '3 Messages'),
                  const SizedBox(width: 12),
                  _buildStatChip(Icons.calendar_today, 'Updated Today'),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.loginButton.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.loginButton.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.loginButton,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.loginButton,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFeatures() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildCompactFeatureCard(Icons.child_care, 'My Children', AppColors.info),
        _buildCompactFeatureCard(Icons.photo_library, 'Photos', AppColors.success),
        _buildCompactFeatureCard(Icons.message, 'Messages', AppColors.warning),
        _buildCompactFeatureCard(Icons.report, 'Reports', AppColors.loginButton),
      ],
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

  Widget _buildCompactFeatureCard(IconData icon, String title, Color color) {
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
      'Use the sidebar to navigate through the parent portal features.',
      style: TextStyle(
        fontSize: 16,
        color: AppColors.textSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }
}