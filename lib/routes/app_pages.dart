// lib/routes/app_pages.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../features/admin_platform/home/bindings/admin_home_binding.dart';
import '../features/auth/bindings/auth_binding.dart';
import '../features/auth/controllers/auth_controller.dart';
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
    // Auth routes
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

    // Platform home routes
    GetPage(
      name: AppRoutes.adminHome,
      page: () => const AdminHomeView(),
      binding: AdminBinding(),
      middlewares: [
        AuthMiddleware(priority: 1),
        RoleMiddleware(
          requiredRoles: ['platform_admin', 'platform_support'],
          priority: 2,
        ),
      ],
    ),
    GetPage(
      name: AppRoutes.parentHome,
      page: () => const ParentHomeView(),
      binding: AuthBinding(), // Create ParentBinding later if needed
      middlewares: [
        AuthMiddleware(priority: 1),
        RoleMiddleware(
          requiredRoles: ['parent'],
          priority: 2,
        ),
      ],
    ),
    GetPage(
      name: AppRoutes.tenantHome,
      page: () => const TenantHomeView(),
      binding: AuthBinding(), // Create TenantBinding later if needed
      middlewares: [
        AuthMiddleware(priority: 1),
        RoleMiddleware(
          requiredRoles: ['school_admin', 'school_manager', 'teacher', 'assistant', 'viewer'],
          priority: 2,
        ),
      ],
    ),

    // Schools Management routes (Admin Platform)
    GetPage(
      name: AppRoutes.adminActiveSchools,
      page: () => const ActiveSchoolsPlaceholderView(), // TODO: Replace with actual view
      binding: AuthBinding(), // TODO: Replace with ActiveSchoolsBinding
      middlewares: [
        AuthMiddleware(priority: 1),
        RoleMiddleware(
          requiredRoles: ['platform_admin', 'platform_support'],
          priority: 2,
        ),
      ],
    ),
    GetPage(
      name: AppRoutes.adminSalesPipeline,
      page: () => const SalesPipelinePlaceholderView(), // TODO: Replace with actual view
      binding: AuthBinding(), // TODO: Replace with SalesPipelineBinding
      middlewares: [
        AuthMiddleware(priority: 1),
        RoleMiddleware(
          requiredRoles: ['platform_admin', 'platform_support'],
          priority: 2,
        ),
      ],
    ),
    GetPage(
      name: AppRoutes.adminMarketExplorer,
      page: () => const MarketExplorerPage(),
      binding: MarketExplorerBinding(),
      middlewares: [
        AuthMiddleware(priority: 1),
        RoleMiddleware(
          requiredRoles: ['platform_admin', 'platform_support'],
          priority: 2,
        ),
      ],
    ),
    GetPage(
      name: AppRoutes.adminMarketExplorerDetail,
      page: () => MarketExplorerDetailPlaceholderView(), // TODO: Create detail view
      binding: MarketExplorerBinding(),
      middlewares: [
        AuthMiddleware(priority: 1),
        RoleMiddleware(
          requiredRoles: ['platform_admin', 'platform_support'],
          priority: 2,
        ),
      ],
    ),

    // Legacy dashboard route - redirects to appropriate platform
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardRedirectView(),
      binding: AuthBinding(),
      middlewares: [
        AuthMiddleware(priority: 1),
      ],
    ),

    // Initial route - redirects to login or dashboard based on auth state
    GetPage(
      name: AppRoutes.initial,
      page: () => const InitialRedirectView(),
      binding: AuthBinding(),
    ),
  ];
}

// Placeholder views for routes that aren't implemented yet
// TODO: Replace these with actual implementations

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

// Initial redirect view that checks auth state and redirects appropriately
class InitialRedirectView extends StatelessWidget {
  const InitialRedirectView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      init: AuthController(),
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

// Redirect view that determines which platform to navigate to
class DashboardRedirectView extends StatelessWidget {
  const DashboardRedirectView({super.key});

  @override
  Widget build(BuildContext context) {
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

// Auth middleware to check if user is authenticated
class AuthMiddleware extends GetMiddleware {
  AuthMiddleware({required int priority}) : super(priority: priority);

  @override
  RouteSettings? redirect(String? route) {
    try {
      final authController = Get.find<AuthController>();

      // Check if auth is initialized
      if (!authController.isInitialized.value) {
        // Wait for initialization - let the route load and handle redirect in widget
        return null;
      }

      if (!authController.isAuthenticated.value) {
        return const RouteSettings(name: AppRoutes.login);
      }

      return null;
    } catch (e) {
      // AuthController not found, redirect to login
      return const RouteSettings(name: AppRoutes.login);
    }
  }
}

// Role middleware to check user roles (matching backend role structure)
class RoleMiddleware extends GetMiddleware {
  final List<String> requiredRoles;
  final List<String> requiredPermissions;

  RoleMiddleware({
    required this.requiredRoles,
    this.requiredPermissions = const [],
    required int priority,
  }) : super(priority: priority);

  @override
  RouteSettings? redirect(String? route) {
    try {
      final authController = Get.find<AuthController>();

      if (!authController.isAuthenticated.value) {
        return const RouteSettings(name: AppRoutes.login);
      }

      final user = authController.currentUser.value;
      if (user == null) {
        return const RouteSettings(name: AppRoutes.login);
      }

      // Check roles if specified
      if (requiredRoles.isNotEmpty) {
        bool hasRole = user.hasAnyRole(requiredRoles);
        if (!hasRole) {
          // Show access denied message
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.snackbar(
              'Access Denied',
              'You do not have permission to access this page.',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
            );
          });

          // Redirect to appropriate home based on their actual roles
          final homeRoute = AppRoutes.getHomeRouteForRoles(user.roleNames);
          return RouteSettings(name: homeRoute);
        }
      }

      // Check permissions if specified
      if (requiredPermissions.isNotEmpty) {
        bool hasPermission = user.hasAnyPermission(requiredPermissions);
        if (!hasPermission) {
          // Show access denied message
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.snackbar(
              'Access Denied',
              'You do not have permission to perform this action.',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 4),
            );
          });

          // Redirect to appropriate home based on their actual roles
          final homeRoute = AppRoutes.getHomeRouteForRoles(user.roleNames);
          return RouteSettings(name: homeRoute);
        }
      }

      return null;
    } catch (e) {
      // Error occurred, redirect to login
      return const RouteSettings(name: AppRoutes.login);
    }
  }
}

// Tenant middleware to check tenant access (updated for new tenant structure)
class TenantMiddleware extends GetMiddleware {
  TenantMiddleware({required int priority}) : super(priority: priority);

  @override
  RouteSettings? redirect(String? route) {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.currentUser.value;
      final tenant = authController.currentTenant.value;

      if (user == null) {
        return const RouteSettings(name: AppRoutes.login);
      }

      // Check if user's tenant is active
      if (tenant != null && !tenant.checkSubscriptionStatus()) {
        // Show tenant inactive message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          String message = 'Your school account is inactive. Please contact support.';

          if (tenant.isExpired) {
            message = 'Your subscription has expired. Please renew to continue.';
          } else if (tenant.isSuspended) {
            message = 'Your account has been suspended. Please contact support.';
          } else if (tenant.isInTrial && tenant.trialEndsAt != null) {
            final daysLeft = tenant.daysUntilExpiry;
            if (daysLeft <= 0) {
              message = 'Your trial has expired. Please upgrade to continue.';
            } else {
              message = 'Your trial expires in $daysLeft days. Please upgrade soon.';
            }
          }

          Get.snackbar(
            'Account Status',
            message,
            snackPosition: SnackPosition.TOP,
            backgroundColor: tenant.isExpired || tenant.isSuspended ? Colors.red : Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 6),
          );
        });

        // For now, still allow access but show warning
        // In production, you might want to redirect to a "subscription required" page
        // return const RouteSettings(name: AppRoutes.subscriptionRequired);
      }

      return null;
    } catch (e) {
      return const RouteSettings(name: AppRoutes.login);
    }
  }
}