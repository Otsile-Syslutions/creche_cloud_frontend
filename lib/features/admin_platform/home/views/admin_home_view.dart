// lib/features/admin_platform/home/views/admin_home_view.dart
import 'package:flutter/material.dart';
import '../../../../shared/responsive/responsive_layout.dart';
import 'responsive/admin_home_view_desktop.dart';

class AdminHomeView extends StatelessWidget {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: AdminHomeViewDesktop(), // Using desktop for all sizes as requested
      tablet: AdminHomeViewDesktop(),
      desktop: AdminHomeViewDesktop(),
    );
  }
}