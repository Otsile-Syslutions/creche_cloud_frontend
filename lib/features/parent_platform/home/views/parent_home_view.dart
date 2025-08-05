// lib/features/parent_platform/home/views/parent_home_view.dart
import 'package:flutter/material.dart';
import '../../../../shared/responsive/responsive_layout.dart';
import 'responsive/parent_home_view_desktop.dart';

class ParentHomeView extends StatelessWidget {
  const ParentHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: ParentHomeViewDesktop(), // Using desktop for all sizes as requested
      tablet: ParentHomeViewDesktop(),
      desktop: ParentHomeViewDesktop(),
    );
  }
}