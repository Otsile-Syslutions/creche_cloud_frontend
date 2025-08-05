// lib/features/tenant_platform/home/views/responsive/tenant_home_view_desktop.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../features/auth/controllers/auth_controller.dart';

class TenantHomeViewDesktop extends GetView<AuthController> {
  const TenantHomeViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF059669), // Deep green background
      appBar: AppBar(
        title: const Text(
          'Creche Cloud - School Management',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF10B981), // Slightly lighter green
        elevation: 0,
        actions: [
          // School info
          Obx(() {
            final user = controller.currentUser.value;
            final tenant = controller.currentTenant.value; // Fixed: use currentTenant from controller
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    tenant?.name ?? 'School',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    user?.fullName ?? 'Staff Member',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
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
                backgroundColor: Colors.white,
                radius: 18,
                child: Text(
                  user?.initials ?? 'T',
                  style: const TextStyle(
                    color: Color(0xFF059669),
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
              color: Colors.white,
            ),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF059669), // Deep green
              const Color(0xFF10B981), // Medium green
              const Color(0xFF34D399), // Lighter green
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main title
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Text(
                  'Tenant Platform',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Subtitle
              Text(
                'School Management Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 16),

              // Role and school indicator
              Obx(() {
                final user = controller.currentUser.value;
                final tenant = controller.currentTenant.value; // Fixed: use currentTenant from controller
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Role: ${user?.primaryRole ?? 'Staff Member'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (tenant != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'School: ${tenant.displayName}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }),

              const SizedBox(height: 48),

              // Feature indicators based on role
              Obx(() {
                final user = controller.currentUser.value;
                final roles = user?.roleNames ?? [];

                List<Widget> features = [];

                if (roles.any((role) => ['school_admin', 'school_manager'].contains(role))) {
                  features.addAll([
                    _buildFeatureCard(
                      icon: Icons.dashboard,
                      title: 'Dashboard',
                      subtitle: 'Overview',
                    ),
                    const SizedBox(width: 32),
                    _buildFeatureCard(
                      icon: Icons.people,
                      title: 'Staff Management',
                      subtitle: 'Manage Team',
                    ),
                    const SizedBox(width: 32),
                    _buildFeatureCard(
                      icon: Icons.analytics,
                      title: 'Reports',
                      subtitle: 'School Insights',
                    ),
                  ]);
                } else if (roles.any((role) => ['teacher', 'assistant'].contains(role))) {
                  features.addAll([
                    _buildFeatureCard(
                      icon: Icons.child_care,
                      title: 'Children',
                      subtitle: 'My Classes',
                    ),
                    const SizedBox(width: 32),
                    _buildFeatureCard(
                      icon: Icons.how_to_reg,
                      title: 'Attendance',
                      subtitle: 'Daily Check-in',
                    ),
                    const SizedBox(width: 32),
                    _buildFeatureCard(
                      icon: Icons.restaurant,
                      title: 'Meals',
                      subtitle: 'Track Nutrition',
                    ),
                  ]);
                } else {
                  features.addAll([
                    _buildFeatureCard(
                      icon: Icons.school,
                      title: 'School Portal',
                      subtitle: 'Access Platform',
                    ),
                    const SizedBox(width: 32),
                    _buildFeatureCard(
                      icon: Icons.visibility,
                      title: 'View Access',
                      subtitle: 'Limited View',
                    ),
                  ]);
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: features,
                );
              }),

              const SizedBox(height: 48),

              // School status indicator
              Obx(() {
                final tenant = controller.currentTenant.value; // Fixed: use currentTenant from controller
                final isActive = tenant?.checkSubscriptionStatus() ?? false; // Fixed: use correct method name

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? Colors.green.withOpacity(0.5)
                          : Colors.orange.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? Icons.check_circle : Icons.warning,
                        color: isActive ? Colors.green[300] : Colors.orange[300],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isActive ? 'School Active' : 'Check Subscription',
                        style: TextStyle(
                          color: isActive ? Colors.green[300] : Colors.orange[300],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}