// lib/shared/responsive/layouts/tablet_app_layout.dart
import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class TabletAppLayout extends StatelessWidget {
  final Widget child;
  final bool showAppBar;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final bool centerContent;
  final double maxContentWidth;
  final EdgeInsetsGeometry? padding;
  final bool useSafeArea;

  const TabletAppLayout({
    super.key,
    required this.child,
    this.showAppBar = false,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.centerContent = true,
    this.maxContentWidth = 600,
    this.padding,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    // Apply padding
    if (padding != null) {
      content = Padding(
        padding: padding!,
        child: content,
      );
    } else {
      // Default padding for tablets
      content = Padding(
        padding: const EdgeInsets.all(24.0),
        child: content,
      );
    }

    // Center and constrain content on tablets for better readability
    if (centerContent) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: content,
        ),
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
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        )
            : null,
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: actions,
      )
          : null,
      body: content,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
    );
  }
}