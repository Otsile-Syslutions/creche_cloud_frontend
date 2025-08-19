// lib/middlewares/auth_middleware.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../routes/app_routes.dart';
import '../utils/app_logger.dart';

class AuthMiddleware extends GetMiddleware {
  final bool requireAdmin;
  final bool requireSupport;
  final List<String>? requiredRoles;

  AuthMiddleware({
    int? priority,
    this.requireAdmin = false,
    this.requireSupport = false,
    this.requiredRoles,
  }) : super(priority: priority ?? 0);

  @override
  RouteSettings? redirect(String? route) {
    // Ensure AuthController exists
    if (!Get.isRegistered<AuthController>()) {
      AppLogger.w('AuthMiddleware: AuthController not found, initializing...');
      Get.put(AuthController());
    }

    final authController = Get.find<AuthController>();

    // First check: Is user authenticated?
    if (!authController.isAuthenticated.value) {
      AppLogger.w('AuthMiddleware: User not authenticated, redirecting to login');
      return const RouteSettings(name: AppRoutes.login);
    }

    // If this is an admin route, check admin privileges
    if (requireAdmin || requireSupport || requiredRoles != null) {
      final user = authController.currentUser.value;

      if (user == null) {
        AppLogger.w('AuthMiddleware: No user data, redirecting to login');
        return const RouteSettings(name: AppRoutes.login);
      }

      // Check for admin requirement
      if (requireAdmin) {
        final isAdmin = user.isPlatformAdmin ||
            user.roleNames.contains('platform_admin') ||
            user.roleNames.contains('platform_support');

        if (!isAdmin) {
          AppLogger.w('AuthMiddleware: User lacks admin privileges');
          return _redirectBasedOnRole(user);
        }
      }

      // Check for support requirement
      if (requireSupport) {
        final hasSupport = user.roleNames.any((role) =>
        role.toLowerCase().contains('support') ||
            role.toLowerCase().contains('admin')
        );

        if (!hasSupport) {
          AppLogger.w('AuthMiddleware: User lacks support privileges');
          return _redirectBasedOnRole(user);
        }
      }

      // Check for specific required roles
      if (requiredRoles != null && requiredRoles!.isNotEmpty) {
        final hasRequiredRole = requiredRoles!.any((requiredRole) =>
            user.roleNames.any((userRole) =>
            userRole.toLowerCase() == requiredRole.toLowerCase()
            )
        );

        if (!hasRequiredRole) {
          AppLogger.w('AuthMiddleware: User lacks required roles: ${requiredRoles!.join(", ")}');
          return _redirectBasedOnRole(user);
        }
      }
    }

    // User is authenticated and has required privileges
    return null;
  }

  /// Redirect user based on their role
  RouteSettings _redirectBasedOnRole(dynamic user) {
    if (user.roleNames.contains('parent')) {
      return const RouteSettings(name: AppRoutes.parentHome);
    } else if (user.roleNames.contains('school_admin') ||
        user.roleNames.contains('teacher') ||
        user.roleNames.contains('assistant')) {
      return const RouteSettings(name: AppRoutes.tenantHome);
    } else {
      return const RouteSettings(name: AppRoutes.login);
    }
  }

  @override
  GetPage? onPageCalled(GetPage? page) {
    // Ensure token is loaded before page loads
    _ensureTokenLoaded();
    return page;
  }

  /// Ensure authentication token is loaded - UPDATED FOR FRESH_DIO
  Future<void> _ensureTokenLoaded() async {
    try {
      // Ensure AuthController exists
      if (!Get.isRegistered<AuthController>()) {
        AppLogger.w('AuthMiddleware: AuthController not found in _ensureTokenLoaded, creating...');
        Get.put(AuthController());
      }

      final apiService = Get.find<ApiService>();
      final authController = Get.find<AuthController>();

      // Check if user is authenticated using fresh_dio's async method
      final isAuthenticated = await apiService.isAuthenticatedAsync();

      if (isAuthenticated) {
        AppLogger.d('AuthMiddleware: Token is valid and loaded');

        // Ensure user data is loaded if not already
        if (authController.currentUser.value == null) {
          try {
            await authController.getCurrentUser();
            AppLogger.d('AuthMiddleware: User data loaded successfully');
          } catch (e) {
            AppLogger.w('AuthMiddleware: Failed to load user data', e);
          }
        }

        return;
      }

      AppLogger.w('AuthMiddleware: No valid token found, attempting refresh...');

      // Try to refresh token using AuthController's method
      try {
        final refreshed = await authController.refreshTokenSilently();
        if (refreshed) {
          AppLogger.d('AuthMiddleware: Token refreshed successfully');
        } else {
          AppLogger.e('AuthMiddleware: Token refresh failed');
        }
      } catch (e) {
        AppLogger.e('AuthMiddleware: Token refresh failed', e);
      }

    } catch (e) {
      AppLogger.e('AuthMiddleware: Error ensuring token loaded', e);
    }
  }
}

// Factory methods for creating specific middleware instances
class AuthMiddlewareFactory {
  /// Basic authentication middleware
  static AuthMiddleware basic() {
    return AuthMiddleware(priority: 0);
  }

  /// Admin authentication middleware
  static AuthMiddleware admin() {
    return AuthMiddleware(
      priority: 1,
      requireAdmin: true,
    );
  }

  /// Support authentication middleware
  static AuthMiddleware support() {
    return AuthMiddleware(
      priority: 1,
      requireSupport: true,
    );
  }

  /// Custom role-based middleware
  static AuthMiddleware withRoles(List<String> roles) {
    return AuthMiddleware(
      priority: 1,
      requiredRoles: roles,
    );
  }
}