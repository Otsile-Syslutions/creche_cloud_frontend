// lib/middlewares/role_middleware.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../routes/app_routes.dart';

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
    final authController = Get.find<AuthController>();

    if (!authController.isAuthenticated.value) {
      return const RouteSettings(name: AppRoutes.login);
    }

    // Check roles
    if (requiredRoles.isNotEmpty) {
      bool hasRole = authController.hasAnyRole(requiredRoles);
      if (!hasRole) {
        Get.snackbar(
          'Access Denied',
          'You do not have permission to access this page.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return const RouteSettings(name: AppRoutes.dashboard);
      }
    }

    // Check permissions
    if (requiredPermissions.isNotEmpty) {
      bool hasPermission = authController.hasAnyPermission(requiredPermissions);
      if (!hasPermission) {
        Get.snackbar(
          'Access Denied',
          'You do not have permission to perform this action.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return const RouteSettings(name: AppRoutes.dashboard);
      }
    }

    return null;
  }
}