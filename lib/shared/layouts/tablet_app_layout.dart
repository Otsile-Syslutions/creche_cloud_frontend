// lib/shared/responsive/layouts/tablet_app_layout.dart
import 'package:flutter/material.dart';

class TabletAppLayout extends StatelessWidget {
  final Widget child;

  const TabletAppLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}