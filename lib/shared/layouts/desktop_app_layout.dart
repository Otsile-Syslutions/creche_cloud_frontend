// lib/shared/responsive/layouts/desktop_app_layout.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';
import '../../../constants/app_colors.dart';
import '../components/sidebar/app_sidebar.dart';
import '../components/topbar/app_topbar.dart';

class DesktopAppLayout extends StatefulWidget {
  final Widget body;
  final List<SidebarXItem> sidebarItems;
  final Widget? sidebarHeader;
  final Widget? sidebarFooter;
  final String appBarTitle;
  final List<Widget>? appBarActions;
  final int? selectedSidebarIndex;
  final bool showSidebar;
  final bool showTopbar;
  final Color? backgroundColor;
  final double? sidebarExpandedWidth;
  final double? sidebarCollapsedWidth;
  final bool startSidebarExpanded;
  final PreferredSizeWidget? customTopbar;
  final String? appBarSubtitle;
  final VoidCallback? onSidebarToggle;
  final bool enableResponsiveSidebar;

  const DesktopAppLayout({
    super.key,
    required this.body,
    required this.sidebarItems,
    this.sidebarHeader,
    this.sidebarFooter,
    this.appBarTitle = 'Dashboard',
    this.appBarActions,
    this.selectedSidebarIndex,
    this.showSidebar = true,
    this.showTopbar = true,
    this.backgroundColor,
    this.sidebarExpandedWidth,
    this.sidebarCollapsedWidth,
    this.startSidebarExpanded = true,
    this.customTopbar,
    this.appBarSubtitle,
    this.onSidebarToggle,
    this.enableResponsiveSidebar = true,
  });

  @override
  State<DesktopAppLayout> createState() => _DesktopAppLayoutState();
}

class _DesktopAppLayoutState extends State<DesktopAppLayout> {
  late bool _isSidebarExpanded;
  late double _currentSidebarWidth;

  @override
  void initState() {
    super.initState();
    _isSidebarExpanded = widget.startSidebarExpanded;
  }

  void _handleSidebarToggle() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
    });
    widget.onSidebarToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Determine responsive widths
        final expandedWidth = widget.sidebarExpandedWidth ?? (screenWidth < 1400 ? 220 : 250);
        final collapsedWidth = widget.sidebarCollapsedWidth ?? (screenWidth < 1200 ? 60 : 70);

        // Determine if we need responsive adjustments
        final shouldAutoCollapseSidebar = widget.enableResponsiveSidebar && screenWidth < 1200;

        // Calculate current sidebar width
        _currentSidebarWidth = (_isSidebarExpanded && !shouldAutoCollapseSidebar)
            ? expandedWidth
            : collapsedWidth;

        return Scaffold(
          backgroundColor: widget.backgroundColor ?? AppColors.background,
          body: Stack(
            clipBehavior: Clip.none, // Critical for allowing tooltip overflow
            children: [
              // Main content area - positioned to account for sidebar width
              Positioned(
                left: widget.showSidebar ? _currentSidebarWidth : 0,
                top: 0,
                right: 0,
                bottom: 0,
                child: Scaffold(
                  backgroundColor: widget.backgroundColor ?? AppColors.background,
                  appBar: widget.showTopbar
                      ? (widget.customTopbar ??
                      AppTopbar(
                        title: widget.appBarTitle,
                        subtitle: widget.appBarSubtitle,
                        additionalActions: widget.appBarActions,
                      ))
                      : null,
                  body: widget.body,
                ),
              ),

              // Sidebar - positioned absolutely to allow overflow
              if (widget.showSidebar)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Stack(
                    clipBehavior: Clip.none, // Allow sidebar content to overflow
                    children: [
                      widget.enableResponsiveSidebar
                          ? ResponsiveAppSidebar(
                        items: widget.sidebarItems,
                        header: widget.sidebarHeader,
                        footer: widget.sidebarFooter,
                        selectedIndex: widget.selectedSidebarIndex,
                        breakpoint: 1200,
                        isExpanded: _isSidebarExpanded && !shouldAutoCollapseSidebar,
                        onToggle: _handleSidebarToggle,
                      )
                          : AppSidebar(
                        items: widget.sidebarItems,
                        header: widget.sidebarHeader,
                        footer: widget.sidebarFooter,
                        selectedIndex: widget.selectedSidebarIndex,
                        startExpanded: _isSidebarExpanded && !shouldAutoCollapseSidebar,
                        expandedWidth: expandedWidth,
                        collapsedWidth: collapsedWidth,
                        onToggle: _handleSidebarToggle,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Simplified layout for specific platforms
class PlatformDesktopLayout extends StatelessWidget {
  final Widget body;
  final List<SidebarXItem> Function() getSidebarItems;
  final Widget Function()? buildSidebarHeader;
  final Widget Function()? buildSidebarFooter;
  final PreferredSizeWidget? topbar;
  final String platformType;
  final int? selectedIndex;

  const PlatformDesktopLayout({
    super.key,
    required this.body,
    required this.getSidebarItems,
    this.buildSidebarHeader,
    this.buildSidebarFooter,
    this.topbar,
    required this.platformType,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return DesktopAppLayout(
      body: body,
      sidebarItems: getSidebarItems(),
      sidebarHeader: buildSidebarHeader?.call(),
      sidebarFooter: buildSidebarFooter?.call(),
      appBarTitle: _getDefaultTitle(),
      customTopbar: topbar,
      selectedSidebarIndex: selectedIndex ?? 0,
      enableResponsiveSidebar: true,
    );
  }

  String _getDefaultTitle() {
    switch (platformType) {
      case 'admin':
        return 'Platform Administration';
      case 'tenant':
        return 'School Management';
      case 'parent':
        return 'Parent Portal';
      default:
        return 'Dashboard';
    }
  }
}

// Admin-specific desktop layout
class AdminDesktopLayout extends StatelessWidget {
  final Widget body;
  final List<SidebarXItem> sidebarItems;
  final Widget? sidebarHeader;
  final Widget? sidebarFooter;
  final String? appBarTitle;
  final List<Widget>? appBarActions;
  final int? selectedIndex;

  const AdminDesktopLayout({
    super.key,
    required this.body,
    required this.sidebarItems,
    this.sidebarHeader,
    this.sidebarFooter,
    this.appBarTitle,
    this.appBarActions,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return DesktopAppLayout(
      body: body,
      sidebarItems: sidebarItems,
      sidebarHeader: sidebarHeader,
      sidebarFooter: sidebarFooter,
      customTopbar: AdminTopbar(
        customTitle: appBarTitle,
        additionalActions: appBarActions,
      ),
      selectedSidebarIndex: selectedIndex ?? 0,
      enableResponsiveSidebar: true,
    );
  }
}

// Tenant-specific desktop layout
class TenantDesktopLayout extends StatelessWidget {
  final Widget body;
  final List<SidebarXItem> sidebarItems;
  final Widget? sidebarHeader;
  final Widget? sidebarFooter;
  final String? appBarTitle;
  final List<Widget>? appBarActions;
  final int? selectedIndex;

  const TenantDesktopLayout({
    super.key,
    required this.body,
    required this.sidebarItems,
    this.sidebarHeader,
    this.sidebarFooter,
    this.appBarTitle,
    this.appBarActions,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return DesktopAppLayout(
      body: body,
      sidebarItems: sidebarItems,
      sidebarHeader: sidebarHeader,
      sidebarFooter: sidebarFooter,
      customTopbar: TenantTopbar(
        customTitle: appBarTitle,
        additionalActions: appBarActions,
      ),
      selectedSidebarIndex: selectedIndex ?? 0,
      enableResponsiveSidebar: true,
    );
  }
}

// Parent-specific desktop layout
class ParentDesktopLayout extends StatelessWidget {
  final Widget body;
  final List<SidebarXItem> sidebarItems;
  final Widget? sidebarHeader;
  final Widget? sidebarFooter;
  final String? appBarTitle;
  final List<Widget>? appBarActions;
  final int? selectedIndex;

  const ParentDesktopLayout({
    super.key,
    required this.body,
    required this.sidebarItems,
    this.sidebarHeader,
    this.sidebarFooter,
    this.appBarTitle,
    this.appBarActions,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return DesktopAppLayout(
      body: body,
      sidebarItems: sidebarItems,
      sidebarHeader: sidebarHeader,
      sidebarFooter: sidebarFooter,
      customTopbar: ParentTopbar(
        customTitle: appBarTitle,
        additionalActions: appBarActions,
      ),
      selectedSidebarIndex: selectedIndex ?? 0,
      enableResponsiveSidebar: true,
    );
  }
}