// lib/shared/responsive/layouts/responsive_app_layout.dart
import 'package:flutter/material.dart';
import '../responsive/responsive_layout.dart';
import 'mobile_app_layout.dart';
import 'tablet_app_layout.dart';
import 'desktop_app_layout.dart';

class ResponsiveAppLayout extends StatelessWidget {
  final Widget child;

  const ResponsiveAppLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: MobileAppLayout(child: child),
      tablet: TabletAppLayout(child: child),
      desktop: DesktopAppLayout(child: child),
    );
  }
}