// lib/features/admin_platform/home/views/responsive/admin_home_view_desktop.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';
import '../../../../../features/auth/controllers/auth_controller.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../shared/components/sidebar/app_sidebar.dart';
import '../../../../../constants/app_colors.dart';
import '../../../config/sidebar/admin_menu_items.dart';
import '../../../../../utils/app_logger.dart';
import '../../../../../shared/widgets/logout_splash_screen.dart';

class AdminHomeViewDesktop extends GetView<AuthController> {
  const AdminHomeViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final sidebarController = SidebarXController(selectedIndex: 0, extended: true);

    return Scaffold(
      body: Obx(() {
        // Check if auth controller is initialized
        if (!controller.isInitialized.value) {
          return _buildLoadingView('Initializing...');
        }

        // Check if user is authenticated
        if (!controller.isAuthenticated.value) {
          AppLogger.w('Admin view accessed without authentication');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed(AppRoutes.login);
          });
          return _buildLoadingView('Redirecting to login...');
        }

        // Check if user data is loaded
        if (controller.currentUser.value == null) {
          return _buildLoadingView('Loading user data...');
        }

        final user = controller.currentUser.value!;
        final userRoles = user.roleNames;

        // Verify user has admin access
        if (user.platformType != 'admin' && !user.isPlatformAdmin && !userRoles.contains('platform_support')) {
          AppLogger.w('User does not have admin platform access');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed(AppRoutes.getHomeRouteForRoles(userRoles));
          });
          return _buildLoadingView('Access denied. Redirecting...');
        }

        return Row(
          children: [
            // Sidebar
            AppSidebar(
              controller: sidebarController,
              items: AdminMenuItems.getMenuItems(userRoles),
              header: AdminMenuItems.buildHeader(),
              footer: AdminMenuItems.buildFooter(),
            ),
            // Main content
            Expanded(
              child: _buildMainContent(user),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildMainContent(dynamic user) {
    return Scaffold(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      user.fullName ?? 'Platform Admin',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      user.isPlatformAdmin ? 'Platform Admin' : user.primaryRole,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                CircleAvatar(
                  backgroundColor: AppColors.loginButton,
                  radius: 18,
                  child: Text(
                    user.initials ?? 'PA',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Debug button (development only)
          if (const bool.fromEnvironment('dart.vm.product') == false)
            IconButton(
              onPressed: () async {
                await controller.debugUserData();
                _showDebugDialog();
              },
              icon: const Icon(Icons.bug_report, color: AppColors.warning),
              tooltip: 'Debug User Data',
            ),
          // Refresh button
          IconButton(
            onPressed: () async {
              await _refreshData();
            },
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            tooltip: 'Refresh Data',
          ),
          // Logout button
          IconButton(
            onPressed: () async {
              try {
                await controller.logout();
              } catch (e) {
                // Fallback if controller is disposed
                LogoutUtils.refreshToLogin();
              }
            },
            icon: const Icon(
              Icons.logout,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.background,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                  child: Column(
                    children: [
                      Text(
                        'Welcome, ${user.firstName}!',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.isPlatformAdmin
                            ? 'Full Platform Administration Access'
                            : user.roleNames.contains('platform_support')
                            ? 'Platform Support Dashboard'
                            : 'Platform Administration Dashboard',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                // Stats cards
                _buildStatsSection(user),
                const SizedBox(height: 32),
                // Action message
                Text(
                  user.isPlatformAdmin
                      ? 'Use the sidebar to manage tenants, users, and platform settings.'
                      : user.roleNames.contains('platform_support')
                      ? 'Use the sidebar to access reports, analytics, and support tools.'
                      : 'Use the sidebar to navigate through the platform administration features.',
                  style: const TextStyle(
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
    );
  }

  Widget _buildStatsSection(dynamic user) {
    final userRoles = user.roleNames as List<String>;

    if (user.isPlatformAdmin || userRoles.contains('platform_admin')) {
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
      return _buildStatCard(
        title: 'Platform Status',
        value: 'Online',
        icon: Icons.check_circle,
        color: AppColors.success,
      );
    }
  }

  Widget _buildLoadingView(String message) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.loginButton),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
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
          Icon(icon, size: 32, color: color),
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

  Future<void> _refreshData() async {
    try {
      AppLogger.d('Refreshing admin dashboard data...');
      await controller.getCurrentUser();
      Get.snackbar(
        'Refreshed',
        'Dashboard data updated',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.success.withOpacity(0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      AppLogger.e('Failed to refresh data: $e');
      Get.snackbar(
        'Error',
        'Failed to refresh data',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
    }
  }

  void _showDebugDialog() {
    final user = controller.currentUser.value;

    Get.dialog(
      AlertDialog(
        title: const Text('Debug User Data'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('User: ${user?.fullName ?? "null"}'),
              Text('Email: ${user?.email ?? "null"}'),
              Text('ID: ${user?.id ?? "null"}'),
              const Divider(),
              Text('Roles: ${user?.roleNames.join(', ') ?? "none"}'),
              Text('Is Platform Admin: ${user?.isPlatformAdmin ?? false}'),
              Text('Platform Type: ${user?.platformType ?? "unknown"}'),
              Text('Primary Role: ${user?.primaryRole ?? "none"}'),
              const Divider(),
              Text('Tenant ID: ${user?.tenantId ?? "none"}'),
              Text('Is Authenticated: ${controller.isAuthenticated.value}'),
              Text('Is Initialized: ${controller.isInitialized.value}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await controller.debugUserData();
              Get.back();
            },
            child: const Text('Run Full Debug'),
          ),
          TextButton(
            onPressed: () async {
              await _refreshData();
              Get.back();
            },
            child: const Text('Refresh User'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}