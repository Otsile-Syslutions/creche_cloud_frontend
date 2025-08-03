// lib/shared/widgets/permission_aware_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/auth/controllers/auth_controller.dart';

class PermissionAwareWidget extends StatelessWidget {
  final List<String> requiredRoles;
  final List<String> requiredPermissions;
  final Widget child;
  final Widget? fallback;
  final bool requireAllRoles;
  final bool requireAllPermissions;

  const PermissionAwareWidget({
    super.key,
    this.requiredRoles = const [],
    this.requiredPermissions = const [],
    required this.child,
    this.fallback,
    this.requireAllRoles = false,
    this.requireAllPermissions = false,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        // Check if user is authenticated
        if (!authController.isAuthenticated.value) {
          return fallback ?? const SizedBox.shrink();
        }

        // Check roles
        if (requiredRoles.isNotEmpty) {
          bool hasRoleAccess;
          if (requireAllRoles) {
            hasRoleAccess = requiredRoles.every(
                  (role) => authController.hasRole(role),
            );
          } else {
            hasRoleAccess = authController.hasAnyRole(requiredRoles);
          }

          if (!hasRoleAccess) {
            return fallback ?? const SizedBox.shrink();
          }
        }

        // Check permissions
        if (requiredPermissions.isNotEmpty) {
          bool hasPermissionAccess;
          if (requireAllPermissions) {
            hasPermissionAccess = requiredPermissions.every(
                  (permission) => authController.hasPermission(permission),
            );
          } else {
            hasPermissionAccess = authController.hasAnyPermission(requiredPermissions);
          }

          if (!hasPermissionAccess) {
            return fallback ?? const SizedBox.shrink();
          }
        }

        return child;
      },
    );
  }
}