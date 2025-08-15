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

// Complete responsive layout with sidebar and topbar for main app screens
class ResponsiveMainLayout extends StatelessWidget {
  final Widget body;
  final List<SidebarXItem> sidebarItems;
  final Widget? sidebarHeader;
  final Widget? sidebarFooter;
  final String appBarTitle;
  final List<Widget>? appBarActions;
  final int? selectedSidebarIndex;
  final PreferredSizeWidget? customTopbar;
  final String? appBarSubtitle;

  const ResponsiveMainLayout({
    super.key,
    required this.body,
    required this.sidebarItems,
    this.sidebarHeader,
    this.sidebarFooter,
    this.appBarTitle = 'Dashboard',
    this.appBarActions,
    this.selectedSidebarIndex,
    this.customTopbar,
    this.appBarSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _MobileMainLayout(
        body: body,
        title: appBarTitle,
        subtitle: appBarSubtitle,
      ),
      tablet: _TabletMainLayout(
        body: body,
        sidebarItems: sidebarItems,
        sidebarHeader: sidebarHeader,
        sidebarFooter: sidebarFooter,
        title: appBarTitle,
        subtitle: appBarSubtitle,
      ),
      desktop: DesktopAppLayout(
        body: body,
        sidebarItems: sidebarItems,
        sidebarHeader: sidebarHeader,
        sidebarFooter: sidebarFooter,
        appBarTitle: appBarTitle,
        appBarActions: appBarActions,
        selectedSidebarIndex: selectedSidebarIndex,
        customTopbar: customTopbar,
        appBarSubtitle: appBarSubtitle,
      ),
    );
  }
}

// Mobile layout with bottom navigation instead of sidebar
class _MobileMainLayout extends StatelessWidget {
  final Widget body;
  final String title;
  final String? subtitle;

  const _MobileMainLayout({
    required this.body,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: body,
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    // This would be connected to navigation logic
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}

// Tablet layout with collapsible sidebar
class _TabletMainLayout extends StatelessWidget {
  final Widget body;
  final List<SidebarXItem> sidebarItems;
  final Widget? sidebarHeader;
  final Widget? sidebarFooter;
  final String title;
  final String? subtitle;

  const _TabletMainLayout({
    required this.body,
    required this.sidebarItems,
    this.sidebarHeader,
    this.sidebarFooter,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
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
  final String? title;
  final int? selectedIndex;

  const AdminResponsiveLayout({
    super.key,
    required this.body,
    required this.getSidebarItems,
    this.buildSidebarHeader,
    this.buildSidebarFooter,
    this.title,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveMainLayout(
      body: body,
      sidebarItems: getSidebarItems(),
      sidebarHeader: buildSidebarHeader?.call(),
      sidebarFooter: buildSidebarFooter?.call(),
      appBarTitle: title ?? 'Platform Administration',
      selectedSidebarIndex: selectedIndex ?? 0,
    );
  }
}

class TenantResponsiveLayout extends StatelessWidget {
  final Widget body;
  final List<SidebarXItem> Function() getSidebarItems;
  final Widget Function()? buildSidebarHeader;
  final Widget Function()? buildSidebarFooter;
  final String? title;
  final int? selectedIndex;

  const TenantResponsiveLayout({
    super.key,
    required this.body,
    required this.getSidebarItems,
    this.buildSidebarHeader,
    this.buildSidebarFooter,
    this.title,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveMainLayout(
      body: body,
      sidebarItems: getSidebarItems(),
      sidebarHeader: buildSidebarHeader?.call(),
      sidebarFooter: buildSidebarFooter?.call(),
      appBarTitle: title ?? 'School Management',
      selectedSidebarIndex: selectedIndex ?? 0,
    );
  }
}

class ParentResponsiveLayout extends StatelessWidget {
  final Widget body;
  final List<SidebarXItem> Function() getSidebarItems;
  final Widget Function()? buildSidebarHeader;
  final Widget Function()? buildSidebarFooter;
  final String? title;
  final int? selectedIndex;

  const ParentResponsiveLayout({
    super.key,
    required this.body,
    required this.getSidebarItems,
    this.buildSidebarHeader,
    this.buildSidebarFooter,
    this.title,
    this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveMainLayout(
      body: body,
      sidebarItems: getSidebarItems(),
      sidebarHeader: buildSidebarHeader?.call(),
      sidebarFooter: buildSidebarFooter?.call(),
      appBarTitle: title ?? 'Parent Portal',
      selectedSidebarIndex: selectedIndex ?? 0,
    );
  }
}