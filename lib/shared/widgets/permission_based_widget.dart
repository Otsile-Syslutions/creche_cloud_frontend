// lib/shared/widgets/permission_based_widget.dart
import 'package:flutter/material.dart';
import 'permission_aware_widget.dart';

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
