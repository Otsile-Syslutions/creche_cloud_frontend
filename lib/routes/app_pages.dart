// lib/routes/app_pages.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../bindings/global_bindings.dart';
import '../features/admin_platform/home/bindings/admin_home_binding.dart';
import '../features/auth/bindings/auth_binding.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../middlewares/auth_middleware.dart';
import 'app_routes.dart';

// Auth views
import '../features/auth/views/login/login_view.dart';
import '../features/auth/views/sign_up/sign_up_view.dart';
import '../features/auth/views/forgot_password/forgot_password_view.dart';
import '../features/auth/views/reset_password/reset_password_view.dart';

// Platform views
import '../features/admin_platform/home/views/admin_home_view.dart';
import '../features/parent_platform/home/views/parent_home_view.dart';
import '../features/tenant_platform/home/views/tenant_home_view.dart';

// Schools Management views
import '../features/admin_platform/schools_management/market_explorer/views/market_explorer_view.dart';
import '../features/admin_platform/schools_management/market_explorer/bindings/market_explorer_binding.dart';
// import '../features/admin_platform/schools_management/active_schools/views/active_schools_view.dart';
// import '../features/admin_platform/schools_management/active_schools/bindings/active_schools_binding.dart';
// import '../features/admin_platform/schools_management/sales_pipeline/views/sales_pipeline_view.dart';
// import '../features/admin_platform/schools_management/sales_pipeline/bindings/sales_pipeline_binding.dart';

class AppPages {
  static final List<GetPage> pages = [
    // =========================================================================
    // AUTH ROUTES (No middleware needed - public routes)
    // =========================================================================
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignUpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordView(),
      binding: AuthBinding(),
    ),

    // =========================================================================
    // PLATFORM HOME ROUTES
    // =========================================================================

    // Admin Platform Home (Platform Admin/Support only)
    GetPage(
      name: AppRoutes.adminHome,
      page: () => const AdminHomeView(),
      binding: AdminHomeBinding(),
      middlewares: [AuthMiddlewareFactory.admin()],
    ),

    // Parent Platform Home (Parents only)
    GetPage(
      name: AppRoutes.parentHome,
      page: () => const ParentHomeView(),
      binding: AuthBinding(), // TODO: Create ParentBinding when needed
      middlewares: [AuthMiddlewareFactory.withRoles(['parent'])],
    ),

    // Tenant Platform Home (School Staff)
    GetPage(
      name: AppRoutes.tenantHome,
      page: () => const TenantHomeView(),
      binding: AuthBinding(), // TODO: Create TenantBinding when needed
      middlewares: [
        AuthMiddlewareFactory.withRoles([
          'school_admin',
          'school_manager',
          'teacher',
          'assistant',
          'viewer'
        ])
      ],
    ),

    // =========================================================================
    // ADMIN PLATFORM - SCHOOLS MANAGEMENT ROUTES
    // =========================================================================

    // Active Schools (Admin/Support)
    GetPage(
      name: AppRoutes.adminActiveSchools,
      page: () => const ActiveSchoolsPlaceholderView(),
      binding: AuthBinding(), // TODO: Replace with ActiveSchoolsBinding
      middlewares: [AuthMiddlewareFactory.admin()],
    ),

    // Sales Pipeline (Admin/Support)
    GetPage(
      name: AppRoutes.adminSalesPipeline,
      page: () => const SalesPipelinePlaceholderView(),
      binding: AuthBinding(), // TODO: Replace with SalesPipelineBinding
      middlewares: [AuthMiddlewareFactory.admin()],
    ),

    // Market Explorer (Admin/Support)
    GetPage(
      name: AppRoutes.adminMarketExplorer,
      page: () => const MarketExplorerPage(),
      binding: MarketExplorerBinding(),
      middlewares: [AuthMiddlewareFactory.admin()],
    ),

    // Market Explorer Detail (Admin/Support)
    GetPage(
      name: AppRoutes.adminMarketExplorerDetail,
      page: () => const MarketExplorerDetailPlaceholderView(),
      binding: MarketExplorerBinding(),
      middlewares: [AuthMiddlewareFactory.admin()],
    ),

    // =========================================================================
    // ADMIN PLATFORM - OTHER MANAGEMENT ROUTES
    // =========================================================================

    // Users Management (Platform Admin only)
    GetPage(
      name: AppRoutes.adminUsers,
      page: () => const AdminPlaceholderView(title: 'Users Management'),
      binding: AuthBinding(),
      middlewares: [AuthMiddlewareFactory.withRoles(['platform_admin'])],
    ),

    // Tenants Management (Platform Admin only)
    GetPage(
      name: AppRoutes.adminTenants,
      page: () => const AdminPlaceholderView(title: 'Tenants Management'),
      binding: AuthBinding(),
      middlewares: [AuthMiddlewareFactory.withRoles(['platform_admin'])],
    ),

    // Reports (Admin/Support)
    GetPage(
      name: AppRoutes.adminReports,
      page: () => const AdminPlaceholderView(title: 'Reports'),
      binding: AuthBinding(),
      middlewares: [AuthMiddlewareFactory.support()],
    ),

    // Settings (Platform Admin only)
    GetPage(
      name: AppRoutes.adminSettings,
      page: () => const AdminPlaceholderView(title: 'Settings'),
      binding: AuthBinding(),
      middlewares: [AuthMiddlewareFactory.withRoles(['platform_admin'])],
    ),

    // Analytics (Admin/Support)
    GetPage(
      name: AppRoutes.adminAnalytics,
      page: () => const AdminPlaceholderView(title: 'Analytics'),
      binding: AuthBinding(),
      middlewares: [AuthMiddlewareFactory.support()],
    ),

    // Billing (Platform Admin only)
    GetPage(
      name: AppRoutes.adminBilling,
      page: () => const AdminPlaceholderView(title: 'Billing'),
      binding: AuthBinding(),
      middlewares: [AuthMiddlewareFactory.withRoles(['platform_admin'])],
    ),

    // Support Tickets (Admin/Support)
    GetPage(
      name: AppRoutes.adminSupport,
      page: () => const AdminPlaceholderView(title: 'Support Tickets'),
      binding: AuthBinding(),
      middlewares: [AuthMiddlewareFactory.support()],
    ),

    // =========================================================================
    // COMMON ROUTES (All authenticated users)
    // =========================================================================

    // User Profile
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePlaceholderView(),
      binding: AuthBinding(),
      middlewares: [AuthMiddlewareFactory.basic()],
    ),

    // Settings
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsPlaceholderView(),
      binding: AuthBinding(),
      middlewares: [AuthMiddlewareFactory.basic()],
    ),

    // Notifications
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsPlaceholderView(),
      binding: AuthBinding(),
      middlewares: [AuthMiddlewareFactory.basic()],
    ),

    // =========================================================================
    // SPECIAL ROUTES
    // =========================================================================

    // Legacy dashboard route - redirects to appropriate platform
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardRedirectView(),
      binding: AuthBinding(),
      middlewares: [AuthMiddlewareFactory.basic()],
    ),

    // Initial route - redirects to login or dashboard based on auth state
    GetPage(
      name: AppRoutes.initial,
      page: () => const InitialRedirectView(),
      binding: AuthBinding(),
    ),
  ];
}

// =============================================================================
// PLACEHOLDER VIEWS FOR UNIMPLEMENTED ROUTES
// =============================================================================

// Generic admin placeholder view
class AdminPlaceholderView extends StatelessWidget {
  final String title;
  final IconData icon;

  const AdminPlaceholderView({
    super.key,
    required this.title,
    this.icon = Icons.construction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'This feature is coming soon',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Active Schools placeholder
class ActiveSchoolsPlaceholderView extends StatelessWidget {
  const ActiveSchoolsPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Schools'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Active Schools',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This feature is coming soon',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Sales Pipeline placeholder
class SalesPipelinePlaceholderView extends StatelessWidget {
  const SalesPipelinePlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Pipeline'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Sales Pipeline',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This feature is coming soon',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Market Explorer Detail placeholder
class MarketExplorerDetailPlaceholderView extends StatelessWidget {
  const MarketExplorerDetailPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    final String centerId = Get.parameters['id'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Explorer Detail'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.explore, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Market Explorer Detail',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Center ID: $centerId',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'This feature is coming soon',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Profile placeholder
class ProfilePlaceholderView extends StatelessWidget {
  const ProfilePlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'User Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This feature is coming soon',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Settings placeholder
class SettingsPlaceholderView extends StatelessWidget {
  const SettingsPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This feature is coming soon',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Notifications placeholder
class NotificationsPlaceholderView extends StatelessWidget {
  const NotificationsPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Notifications',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'This feature is coming soon',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// REDIRECT VIEWS
// =============================================================================

// Initial redirect view that checks auth state and redirects appropriately
class InitialRedirectView extends StatelessWidget {
  const InitialRedirectView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure AuthController exists
    DependencyManager.ensureAuthController();

    return GetBuilder<AuthController>(
      init: Get.find<AuthController>(), // Use Get.find since we ensured it exists
      builder: (authController) {
        // Wait for auth initialization
        if (!authController.isInitialized.value) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check if user is authenticated
        if (authController.isAuthenticated.value && authController.currentUser.value != null) {
          final user = authController.currentUser.value!;
          final homeRoute = AppRoutes.getHomeRouteForRoles(user.roleNames);

          // Schedule navigation for next frame to avoid navigation during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed(homeRoute);
          });
        } else {
          // No user, redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed(AppRoutes.login);
          });
        }

        // Show loading while redirecting
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading Creche Cloud...'),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Dashboard redirect view that determines which platform to navigate to
class DashboardRedirectView extends StatelessWidget {
  const DashboardRedirectView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure AuthController exists
    DependencyManager.ensureAuthController();

    // Get auth controller and redirect based on user roles
    final authController = Get.find<AuthController>();
    final user = authController.currentUser.value;

    if (user != null) {
      final homeRoute = AppRoutes.getHomeRouteForRoles(user.roleNames);

      // Schedule navigation for next frame to avoid navigation during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(homeRoute);
      });
    } else {
      // No user, redirect to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoutes.login);
      });
    }

    // Show loading while redirecting
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Redirecting...'),
          ],
        ),
      ),
    );
  }
}