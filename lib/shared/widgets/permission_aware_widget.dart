// lib/shared/widgets/permission_aware_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../core/config/env.dart';
import '../../utils/app_logger.dart';

/// A comprehensive permission-aware widget that handles role-based and permission-based access control
/// Aligned with the backend RBAC system including roles, permissions, child access, and audit logging
class PermissionAwareWidget extends StatelessWidget {
  final List<String> requiredRoles;
  final List<String> requiredPermissions;
  final Widget child;
  final Widget? fallback;
  final bool requireAllRoles;
  final bool requireAllPermissions;
  final String? childId; // For child-specific access control
  final String? classroomId; // For classroom-specific access control
  final bool auditAccess; // Whether to audit access attempts
  final String? resourceType; // Type of resource being accessed (for auditing)
  final VoidCallback? onAccessDenied; // Callback when access is denied

  const PermissionAwareWidget({
    super.key,
    this.requiredRoles = const [],
    this.requiredPermissions = const [],
    required this.child,
    this.fallback,
    this.requireAllRoles = false,
    this.requireAllPermissions = false,
    this.childId,
    this.classroomId,
    this.auditAccess = false,
    this.resourceType,
    this.onAccessDenied,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (authController) {
        // Check if user is authenticated
        if (!authController.isAuthenticated.value) {
          _logAccessDenied(authController, 'User not authenticated');
          _handleAccessDenied();
          return fallback ?? const SizedBox.shrink();
        }

        final user = authController.currentUser.value;
        if (user == null) {
          _logAccessDenied(authController, 'User data not available');
          _handleAccessDenied();
          return fallback ?? const SizedBox.shrink();
        }

        // Check roles
        if (requiredRoles.isNotEmpty) {
          bool hasRoleAccess;
          if (requireAllRoles) {
            hasRoleAccess = requiredRoles.every((role) => user.hasRole(role));
          } else {
            hasRoleAccess = user.hasAnyRole(requiredRoles);
          }

          if (!hasRoleAccess) {
            _logAccessDenied(authController, 'Insufficient roles: required $requiredRoles, user has ${user.roleNames}');
            _handleAccessDenied();
            return fallback ?? const SizedBox.shrink();
          }
        }

        // Check permissions
        if (requiredPermissions.isNotEmpty) {
          bool hasPermissionAccess;
          if (requireAllPermissions) {
            hasPermissionAccess = requiredPermissions.every((permission) => user.hasPermission(permission));
          } else {
            hasPermissionAccess = user.hasAnyPermission(requiredPermissions);
          }

          if (!hasPermissionAccess) {
            _logAccessDenied(authController, 'Insufficient permissions: required $requiredPermissions');
            _handleAccessDenied();
            return fallback ?? const SizedBox.shrink();
          }
        }

        // Check child-specific access
        if (childId != null) {
          if (!user.canAccessChild(childId!)) {
            _logAccessDenied(authController, 'Cannot access child: $childId');
            _handleAccessDenied();
            return fallback ?? const SizedBox.shrink();
          }
        }

        // Check classroom-specific access
        if (classroomId != null) {
          if (!user.canAccessClassroom(classroomId!)) {
            _logAccessDenied(authController, 'Cannot access classroom: $classroomId');
            _handleAccessDenied();
            return fallback ?? const SizedBox.shrink();
          }
        }

        // Log successful access if auditing is enabled
        if (auditAccess && Env.enableAnalytics) {
          _logAccessGranted(authController);
        }

        return child;
      },
    );
  }

  void _handleAccessDenied() {
    if (onAccessDenied != null) {
      onAccessDenied!();
    }
  }

  void _logAccessDenied(AuthController authController, String reason) {
    if (!auditAccess && !Env.enableAnalytics) return;

    AppLogger.w('Access denied: $reason');

    // Log to audit system
    _logAuditEvent(authController, 'access_denied', {
      'reason': reason,
      'required_roles': requiredRoles,
      'required_permissions': requiredPermissions,
      'child_id': childId,
      'classroom_id': classroomId,
      'resource_type': resourceType,
    });
  }

  void _logAccessGranted(AuthController authController) {
    if (!auditAccess && !Env.enableAnalytics) return;

    AppLogger.d('Access granted for resource: ${resourceType ?? 'unknown'}');

    // Log to audit system
    _logAuditEvent(authController, 'access_granted', {
      'resource_type': resourceType,
      'child_id': childId,
      'classroom_id': classroomId,
    });
  }

  void _logAuditEvent(AuthController authController, String action, Map<String, dynamic> metadata) {
    // This would typically send to a centralized audit logging service
    // For now, we'll log locally and match backend audit structure
    final auditData = {
      'timestamp': DateTime.now().toIso8601String(),
      'action': action,
      'user_id': authController.currentUser.value?.id,
      'tenant_id': authController.currentTenantId.value,
      'metadata': metadata,
    };

    AppLogger.i('Audit event: $auditData');
  }
}

// =============================================================================
// SPECIALIZED WIDGETS FOR COMMON USE CASES (Aligned with Backend Permissions)
// =============================================================================

class ChildDataWidget extends PermissionAwareWidget {
  const ChildDataWidget({
    super.key,
    required super.child,
    required super.childId,
    super.fallback,
    super.onAccessDenied,
  }) : super(
    requiredPermissions: const ['child:read'],
    auditAccess: true,
    resourceType: 'child_data',
  );
}

class ChildEditWidget extends PermissionAwareWidget {
  const ChildEditWidget({
    super.key,
    required super.child,
    required super.childId,
    super.fallback,
    super.onAccessDenied,
  }) : super(
    requiredPermissions: const ['child:update'],
    auditAccess: true,
    resourceType: 'child_edit',
  );
}

class ChildPhotosWidget extends PermissionAwareWidget {
  const ChildPhotosWidget({
    super.key,
    required super.child,
    required super.childId,
    super.fallback,
    super.onAccessDenied,
  }) : super(
    requiredPermissions: const ['child:read'],
    auditAccess: true,
    resourceType: 'child_photos',
  );
}

class ChildMedicalWidget extends PermissionAwareWidget {
  const ChildMedicalWidget({
    super.key,
    required super.child,
    required super.childId,
    super.fallback,
    super.onAccessDenied,
  }) : super(
    requiredPermissions: const ['child:read'],
    auditAccess: true,
    resourceType: 'child_medical',
  );
}

class AdminOnlyWidget extends PermissionAwareWidget {
  const AdminOnlyWidget({
    super.key,
    required super.child,
    super.fallback,
    super.onAccessDenied,
  }) : super(
    requiredRoles: const ['school_admin', 'platform_admin'],
    requireAllRoles: false,
    auditAccess: true,
    resourceType: 'admin_function',
  );
}

class TeacherOnlyWidget extends PermissionAwareWidget {
  const TeacherOnlyWidget({
    super.key,
    required super.child,
    super.fallback,
    super.onAccessDenied,
  }) : super(
    requiredRoles: const ['teacher', 'school_admin', 'platform_admin'],
    requireAllRoles: false,
    auditAccess: true,
    resourceType: 'teacher_function',
  );
}

class ParentOnlyWidget extends PermissionAwareWidget {
  const ParentOnlyWidget({
    super.key,
    required super.child,
    super.childId, // Removed type annotation
    super.fallback,
    super.onAccessDenied,
  }) : super(
    requiredRoles: const ['parent'],
    auditAccess: true,
    resourceType: 'parent_function',
  );
}

class ClassroomWidget extends PermissionAwareWidget {
  const ClassroomWidget({
    super.key,
    required super.child,
    required super.classroomId, // Removed type annotation
    super.fallback,
    super.onAccessDenied,
  }) : super(
    requiredPermissions: const ['child:read_assigned'],
    auditAccess: true,
    resourceType: 'classroom_data',
  );
}

class ReportsWidget extends PermissionAwareWidget {
  const ReportsWidget({
    super.key,
    required super.child,
    super.childId, // Removed type annotation
    super.fallback,
    super.onAccessDenied,
  }) : super(
    requiredPermissions: const ['report:read'],
    auditAccess: true,
    resourceType: 'reports',
  );
}

class ActivitiesWidget extends PermissionAwareWidget {
  const ActivitiesWidget({
    super.key,
    required super.child,
    super.childId, // Removed type annotation
    super.fallback,
    super.onAccessDenied,
  }) : super(
    requiredPermissions: const ['activity:read'],
    auditAccess: true,
    resourceType: 'activities',
  );
}

class CreateActivityWidget extends PermissionAwareWidget {
  const CreateActivityWidget({
    super.key,
    required super.child,
    super.fallback,
    super.onAccessDenied,
  }) : super(
    requiredPermissions: const ['activity:create'],
    auditAccess: true,
    resourceType: 'create_activity',
  );
}

class BillingWidget extends PermissionAwareWidget {
  const BillingWidget({
    super.key,
    required super.child,
    super.fallback,
    super.onAccessDenied,
  }) : super(
    requiredPermissions: const ['billing:read'],
    auditAccess: true,
    resourceType: 'billing',
  );
}

class AttendanceWidget extends PermissionAwareWidget {
  const AttendanceWidget({
    super.key,
    required super.child,
    super.childId, // Removed type annotation
    super.fallback,
    super.onAccessDenied,
  }) : super(
    requiredPermissions: const ['attendance:read'],
    auditAccess: true,
    resourceType: 'attendance',
  );
}

class CommunicationWidget extends PermissionAwareWidget {
  const CommunicationWidget({
    super.key,
    required super.child,
    super.fallback,
    super.onAccessDenied,
  }) : super(
    requiredPermissions: const ['communication:read'],
    auditAccess: true,
    resourceType: 'communication',
  );
}

class UserManagementWidget extends PermissionAwareWidget {
  const UserManagementWidget({
    super.key,
    required super.child,
    super.fallback,
    super.onAccessDenied,
  }) : super(
    requiredPermissions: const ['user:read'],
    auditAccess: true,
    resourceType: 'user_management',
  );
}

// =============================================================================
// PERMISSION CHECKER UTILITY CLASS (Aligned with Backend)
// =============================================================================

/// Helper class to check permissions programmatically
/// Matches the backend permission structure and role hierarchy
class PermissionChecker {
  static bool canAccessChild(String childId) {
    try {
      final authController = Get.find<AuthController>();
      return authController.canAccessChild(childId);
    } catch (e) {
      AppLogger.w('Error checking child access permission', e);
      return false;
    }
  }

  static bool canAccessClassroom(String classroomId) {
    try {
      final authController = Get.find<AuthController>();
      return authController.currentUser.value?.canAccessClassroom(classroomId) ?? false;
    } catch (e) {
      AppLogger.w('Error checking classroom access permission', e);
      return false;
    }
  }

  static bool hasRole(String role) {
    try {
      final authController = Get.find<AuthController>();
      return authController.hasRole(role);
    } catch (e) {
      AppLogger.w('Error checking role permission', e);
      return false;
    }
  }

  static bool hasPermission(String permission) {
    try {
      final authController = Get.find<AuthController>();
      return authController.hasPermission(permission);
    } catch (e) {
      AppLogger.w('Error checking permission', e);
      return false;
    }
  }

  static bool isAdmin() {
    try {
      final authController = Get.find<AuthController>();
      return authController.currentUser.value?.hasAnyRole([
        'platform_admin',
        'school_admin'
      ]) ?? false;
    } catch (e) {
      AppLogger.w('Error checking admin status', e);
      return false;
    }
  }

  static bool isTeacher() {
    try {
      final authController = Get.find<AuthController>();
      return authController.currentUser.value?.hasAnyRole([
        'teacher',
        'school_admin',
        'platform_admin'
      ]) ?? false;
    } catch (e) {
      AppLogger.w('Error checking teacher status', e);
      return false;
    }
  }

  static bool isParent() {
    try {
      final authController = Get.find<AuthController>();
      return authController.currentUser.value?.hasRole('parent') ?? false;
    } catch (e) {
      AppLogger.w('Error checking parent status', e);
      return false;
    }
  }

  static bool isPlatformAdmin() {
    try {
      final authController = Get.find<AuthController>();
      return authController.currentUser.value?.hasRole('platform_admin') ?? false;
    } catch (e) {
      AppLogger.w('Error checking platform admin status', e);
      return false;
    }
  }

  static List<String> getUserRoles() {
    try {
      final authController = Get.find<AuthController>();
      return authController.currentUser.value?.roleNames ?? [];
    } catch (e) {
      AppLogger.w('Error getting user roles', e);
      return [];
    }
  }

  static String getPrimaryRole() {
    try {
      final authController = Get.find<AuthController>();
      final roles = authController.currentUser.value?.roleNames ?? [];

      // Return highest priority role based on backend hierarchy
      const roleHierarchy = [
        'platform_admin',
        'platform_support',
        'school_admin',
        'school_manager',
        'teacher',
        'assistant',
        'parent',
        'viewer'
      ];

      for (String role in roleHierarchy) {
        if (roles.contains(role)) {
          return role;
        }
      }

      return 'viewer'; // Default fallback
    } catch (e) {
      AppLogger.w('Error getting primary role', e);
      return 'viewer';
    }
  }

  /// Check if user can perform action on specific resource
  static bool canPerformAction({
    required String action,
    required String resource,
    String? childId,
    String? classroomId,
  }) {
    final permission = '$resource:$action';

    if (!hasPermission(permission)) {
      return false;
    }

    // Additional checks for child-specific resources
    if (childId != null && !canAccessChild(childId)) {
      return false;
    }

    // Additional checks for classroom-specific resources
    if (classroomId != null && !canAccessClassroom(classroomId)) {
      return false;
    }

    return true;
  }
}

// =============================================================================
// SIMPLIFIED PERMISSION-BASED WIDGET
// =============================================================================

/// Simplified widget for basic permission checking
class PermissionBasedWidget extends StatelessWidget {
  final List<String> requiredPermissions;
  final Widget child;
  final Widget? fallback;
  final bool requireAll;

  const PermissionBasedWidget({
    super.key,
    required this.requiredPermissions,
    required this.child,
    this.fallback,
    this.requireAll = false,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionAwareWidget(
      requiredPermissions: requiredPermissions,
      requireAllPermissions: requireAll,
      fallback: fallback,
      child: child,
    );
  }
}

// =============================================================================
// USAGE EXAMPLES
// =============================================================================

/// Example usage of the permission aware widgets:
///
/// ```dart
/// // Basic permission check
/// PermissionAwareWidget(
///   requiredPermissions: ['child:read'],
///   child: ChildDataDisplay(),
///   fallback: AccessDeniedMessage(),
/// )
///
/// // Role-based access with child-specific check
/// ChildDataWidget(
///   childId: selectedChildId,
///   child: ChildProfile(),
///   fallback: UnauthorizedWidget(),
/// )
///
/// // Admin-only functionality
/// AdminOnlyWidget(
///   child: UserManagementPanel(),
///   fallback: Text('Admin access required'),
/// )
///
/// // Multiple permissions required
/// PermissionAwareWidget(
///   requiredPermissions: ['report:read', 'report:export'],
///   requireAllPermissions: true,
///   auditAccess: true,
///   resourceType: 'financial_reports',
///   child: FinancialReportsView(),
/// )
///
/// // Teacher access with classroom restriction
/// ClassroomWidget(
///   classroomId: currentClassroomId,
///   child: ClassroomManagement(),
/// )
/// ```