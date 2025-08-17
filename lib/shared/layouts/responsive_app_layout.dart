// lib/shared/responsive/layouts/responsive_app_layout.dart
import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import '../responsive/responsive_layout.dart';
import 'mobile_app_layout.dart';
import 'tablet_app_layout.dart';
import 'desktop_app_layout.dart';

// Simple responsive layout for basic screens without sidebar
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
      desktop: _SimpleDesktopWrapper(child: child),
    );
  }
}

// Wrapper for desktop without sidebar (like login, signup, etc.)
class _SimpleDesktopWrapper extends StatelessWidget {
  final Widget child;

  const _SimpleDesktopWrapper({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: child,
        ),
      ),
    );
  }
}

// Complete responsive layout with sidebar for main app screens
class ResponsiveMainLayout extends StatelessWidget {
  final Widget body;
  final List<SidebarXItem> sidebarItems;
  final Widget? sidebarHeader;
  final Widget? sidebarFooter;
  final int? selectedSidebarIndex;

  const ResponsiveMainLayout({
    super.key,
    required this.body,
    required this.sidebarItems,
    this.sidebarHeader,
    this.sidebarFooter,
    this.selectedSidebarIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _MobileMainLayout(
        body: body,
        sidebarItems: sidebarItems,
      ),
      tablet: _TabletMainLayout(
        body: body,
        sidebarItems: sidebarItems,
        sidebarHeader: sidebarHeader,
        sidebarFooter: sidebarFooter,
      ),
      desktop: DesktopAppLayout(
        body: body,
        sidebarItems: sidebarItems,
        sidebarHeader: sidebarHeader,
        sidebarFooter: sidebarFooter,
        selectedSidebarIndex: selectedSidebarIndex,
      ),
    );
  }
}

// Mobile layout with bottom navigation instead of sidebar
class _MobileMainLayout extends StatefulWidget {
  final Widget body;
  final List<SidebarXItem> sidebarItems;

  const _MobileMainLayout({
    required this.body,
    required this.sidebarItems,
  });

  @override
  State<_MobileMainLayout> createState() => _MobileMainLayoutState();
}

class _MobileMainLayoutState extends State<_MobileMainLayout> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Convert sidebar items to bottom nav items (max 5 items)
    final navItems = widget.sidebarItems.take(5).toList();

    return Scaffold(
      body: widget.body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Call the onTap function of the corresponding sidebar item
          if (index < navItems.length) {
            navItems[index].onTap?.call();
          }
        },
        items: navItems.map((item) {
          return BottomNavigationBarItem(
            icon: item.icon != null
                ? Icon(item.icon)
                : item.iconBuilder?.call(false, false) ?? const Icon(Icons.circle),
            label: item.label ?? '',
          );
        }).toList(),
      ),
    );
  }
}

// Tablet layout with collapsible sidebar
class _TabletMainLayout extends StatelessWidget {
  final Widget body;
  final List<SidebarXItem> sidebarItems;
  final Widget? sidebarHeader;
  final Widget? sidebarFooter;

  const _TabletMainLayout({
    required this.body,
    required this.sidebarItems,
    this.sidebarHeader,
    this.sidebarFooter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: SizedBox(
        width: 250,
        child: Drawer(
          child: Column(
            children: [
              if (sidebarHeader != null) sidebarHeader!,
              Expanded(
                child: ListView.builder(
                  itemCount: sidebarItems.length,
                  itemBuilder: (context, index) {
                    final item = sidebarItems[index];
                    return ListTile(
                      leading: item.icon != null
                          ? Icon(item.icon)
                          : item.iconBuilder?.call(false, false),
                      title: Text(item.label ?? ''),
                      onTap: () {
                        Navigator.pop(context);
                        item.onTap?.call();
                      },
                    );
                  },
                ),
              ),
              if (sidebarFooter != null) sidebarFooter!,
            ],
          ),
        ),
      ),
      body: body,
    );
  }
}

// Platform-specific responsive layouts
class AdminResponsiveLayout extends StatelessWidget {
  final Widget body;
  final List<SidebarXItem> Function() getSidebarItems;
  final Widget Function()? buildSidebarHeader;
  final Widget Function()? buildSidebarFooter;
  final int? selectedIndex;

  const AdminResponsiveLayout({
    super.key,
    required this.body,
    required this.getSidebarItems,
    this.buildSidebarHeader,
    this.buildSidebarFooter,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveMainLayout(
      body: body,
      sidebarItems: getSidebarItems(),
      sidebarHeader: buildSidebarHeader?.call(),
      sidebarFooter: buildSidebarFooter?.call(),
      selectedSidebarIndex: selectedIndex ?? 0,
    );
  }
}

class TenantResponsiveLayout extends StatelessWidget {
  final Widget body;
  final List<SidebarXItem> Function() getSidebarItems;
  final Widget Function()? buildSidebarHeader;
  final Widget Function()? buildSidebarFooter;
  final int? selectedIndex;

  const TenantResponsiveLayout({
    super.key,
    required this.body,
    required this.getSidebarItems,
    this.buildSidebarHeader,
    this.buildSidebarFooter,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveMainLayout(
      body: body,
      sidebarItems: getSidebarItems(),
      sidebarHeader: buildSidebarHeader?.call(),
      sidebarFooter: buildSidebarFooter?.call(),
      selectedSidebarIndex: selectedIndex ?? 0,
    );
  }
}

class ParentResponsiveLayout extends StatelessWidget {
  final Widget body;
  final List<SidebarXItem> Function() getSidebarItems;
  final Widget Function()? buildSidebarHeader;
  final Widget Function()? buildSidebarFooter;
  final int? selectedIndex;

  const ParentResponsiveLayout({
    super.key,
    required this.body,
    required this.getSidebarItems,
    this.buildSidebarHeader,
    this.buildSidebarFooter,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveMainLayout(
      body: body,
      sidebarItems: getSidebarItems(),
      sidebarHeader: buildSidebarHeader?.call(),
      sidebarFooter: buildSidebarFooter?.call(),
      selectedSidebarIndex: selectedIndex ?? 0,
    );
  }
}