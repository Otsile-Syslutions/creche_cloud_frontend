// lib/shared/responsive/layouts/desktop_app_layout.dart
import 'package:flutter/material.dart';

class DesktopAppLayout extends StatelessWidget {
  final Widget child;

  const DesktopAppLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
