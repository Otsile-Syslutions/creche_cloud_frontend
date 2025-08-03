// lib/shared/responsive/layouts/mobile_app_layout.dart
import 'package:flutter/material.dart';

class MobileAppLayout extends StatelessWidget {
  final Widget child;

  const MobileAppLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}