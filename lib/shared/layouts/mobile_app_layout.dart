// lib/shared/responsive/layouts/mobile_app_layout.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class MobileAppLayout extends StatelessWidget {
  final Widget child;
  final bool showAppBar;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final EdgeInsetsGeometry? padding;
  final bool useSafeArea;

  const MobileAppLayout({
    super.key,
    required this.child,
    this.showAppBar = false,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.padding,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    // Apply padding if specified
    if (padding != null) {
      content = Padding(
        padding: padding!,
        child: content,
      );
    } else if (!showAppBar && bottomNavigationBar == null) {
      // Default padding when no app bar or bottom nav
      content = Padding(
        padding: const EdgeInsets.all(16.0),
        child: content,
      );
    }

    // Apply SafeArea if needed
    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: showAppBar
          ? AppBar(
        title: title != null
            ? Text(
          title!,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        )
            : null,
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: actions,
        centerTitle: true,
      )
          : null,
      body: content,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
    );
  }
}