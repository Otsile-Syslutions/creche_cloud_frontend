// lib/features/tenant_platform/home/views/tenant_home_view.dart
import 'package:flutter/material.dart';
import '../../../../shared/responsive/responsive_layout.dart';
import 'responsive/tenant_home_view_desktop.dart';

class TenantHomeView extends StatelessWidget {
  const TenantHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: TenantHomeViewDesktop(), // Using desktop for all sizes as requested
      tablet: TenantHomeViewDesktop(),
      desktop: TenantHomeViewDesktop(),
    );
  }
}