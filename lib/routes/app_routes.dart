// lib/routes/app_routes.dart
abstract class AppRoutes {
  // Auth routes
  static const String initial = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Platform routes - different home views based on user role (matching backend roles)
  static const String adminHome = '/admin';      // For platform_admin, platform_support
  static const String parentHome = '/parent';    // For parent role
  static const String tenantHome = '/tenant';    // For school_admin, school_manager, teacher, assistant

  // Legacy dashboard route (redirects to appropriate platform)
  static const String dashboard = '/dashboard';

  // Common routes that might be used across platforms
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';

  // Platform-specific routes

  // Admin Platform (Platform Admin/Support)
  static const String adminUsers = '/admin/users';
  static const String adminTenants = '/admin/tenants';
  static const String adminReports = '/admin/reports';
  static const String adminSettings = '/admin/settings';
  static const String adminAnalytics = '/admin/analytics';
  static const String adminBilling = '/admin/billing';
  static const String adminSupport = '/admin/support';
  static const String adminAnnouncements = '/admin/announcements';

  // Schools Management Routes (Under Admin Platform)
  static const String adminActiveCustomers = '/admin/customers/active';
  static const String adminSalesPipeline = '/admin/customers/pipeline';
  static const String adminMarketExplorer = '/admin/customers/market-explorer';
  static const String adminMarketExplorerDetail = '/admin/customers/market-explorer/:id';

  // Parent Platform (Parents)
  static const String parentChildren = '/parent/children';
  static const String parentActivities = '/parent/activities';
  static const String parentReports = '/parent/reports';
  static const String parentMessages = '/parent/messages';
  static const String parentBilling = '/parent/billing';

  // Tenant Platform (School Staff - Admin, Manager, Teacher, Assistant)
  static const String tenantDashboard = '/tenant/dashboard';
  static const String tenantChildren = '/tenant/children';
  static const String tenantStaff = '/tenant/staff';
  static const String tenantUsers = '/tenant/users';
  static const String tenantAttendance = '/tenant/attendance';
  static const String tenantMeals = '/tenant/meals';
  static const String tenantActivities = '/tenant/activities';
  static const String tenantReports = '/tenant/reports';
  static const String tenantBilling = '/tenant/billing';
  static const String tenantSettings = '/tenant/settings';
  static const String tenantMessages = '/tenant/messages';

  /// Get the appropriate home route based on user roles (matching backend role hierarchy)
  static String getHomeRouteForRoles(List<String> roles) {
    // Check for platform admin roles first (highest priority)
    if (roles.contains('platform_admin') || roles.contains('platform_support')) {
      return adminHome;
    }

    // Check for school/tenant admin and management roles
    if (roles.contains('school_admin') ||
        roles.contains('school_manager') ||
        roles.contains('teacher') ||
        roles.contains('assistant')) {
      return tenantHome;
    }

    // Check for parent role
    if (roles.contains('parent')) {
      return parentHome;
    }

    // Check for viewer role (read-only)
    if (roles.contains('viewer')) {
      return tenantHome; // Viewers go to tenant platform with limited access
    }

    // Default fallback - check by role priority
    if (roles.isNotEmpty) {
      final primaryRole = roles.first;
      switch (primaryRole) {
        case 'platform_admin':
        case 'platform_support':
          return adminHome;
        case 'school_admin':
        case 'school_manager':
        case 'teacher':
        case 'assistant':
        case 'viewer':
          return tenantHome;
        case 'parent':
          return parentHome;
        default:
          return tenantHome; // Default to tenant platform
      }
    }

    // Ultimate fallback
    return tenantHome;
  }

  /// Get platform type based on user roles
  static String getPlatformType(List<String> roles) {
    if (roles.contains('platform_admin') || roles.contains('platform_support')) {
      return 'admin';
    }

    if (roles.contains('parent')) {
      return 'parent';
    }

    return 'tenant';
  }

  /// Check if route requires authentication
  static bool requiresAuth(String route) {
    const publicRoutes = [
      login,
      signup,
      forgotPassword,
      resetPassword,
    ];
    return !publicRoutes.contains(route);
  }

  /// Check if route is a platform home route
  static bool isPlatformHome(String route) {
    return [adminHome, parentHome, tenantHome].contains(route);
  }

  /// Check if user can access route based on roles
  static bool canAccessRoute(String route, List<String> userRoles) {
    // Public routes are always accessible
    if (!requiresAuth(route)) {
      return true;
    }

    // Define route access rules based on backend permissions
    final routePermissions = {
      // Admin platform routes
      adminHome: ['platform_admin', 'platform_support'],
      adminUsers: ['platform_admin'],
      adminTenants: ['platform_admin'],
      adminReports: ['platform_admin', 'platform_support'],
      adminSettings: ['platform_admin'],
      adminAnalytics: ['platform_admin', 'platform_support'],
      adminBilling: ['platform_admin'],
      adminSupport: ['platform_admin', 'platform_support'],
      adminAnnouncements: ['platform_admin', 'platform_support'],

      // Schools Management routes
      adminActiveCustomers: ['platform_admin', 'platform_support'],
      adminSalesPipeline: ['platform_admin', 'platform_support'],
      adminMarketExplorer: ['platform_admin', 'platform_support'],
      adminMarketExplorerDetail: ['platform_admin', 'platform_support'],

      // Parent platform routes
      parentHome: ['parent'],
      parentChildren: ['parent'],
      parentActivities: ['parent'],
      parentReports: ['parent'],
      parentMessages: ['parent'],
      parentBilling: ['parent'],

      // Tenant platform routes (school staff)
      tenantHome: ['school_admin', 'school_manager', 'teacher', 'assistant', 'viewer'],
      tenantDashboard: ['school_admin', 'school_manager', 'teacher', 'assistant', 'viewer'],
      tenantChildren: ['school_admin', 'school_manager', 'teacher', 'assistant'],
      tenantStaff: ['school_admin', 'school_manager'],
      tenantUsers: ['school_admin'],
      tenantAttendance: ['school_admin', 'school_manager', 'teacher', 'assistant'],
      tenantMeals: ['school_admin', 'school_manager', 'teacher', 'assistant'],
      tenantActivities: ['school_admin', 'school_manager', 'teacher', 'assistant'],
      tenantReports: ['school_admin', 'school_manager', 'teacher'],
      tenantBilling: ['school_admin'],
      tenantSettings: ['school_admin', 'school_manager'],
      tenantMessages: ['school_admin', 'school_manager', 'teacher', 'assistant'],

      // Common routes
      profile: ['platform_admin', 'platform_support', 'school_admin', 'school_manager', 'teacher', 'assistant', 'parent', 'viewer'],
      settings: ['platform_admin', 'platform_support', 'school_admin', 'school_manager', 'teacher', 'assistant', 'parent'],
      notifications: ['platform_admin', 'platform_support', 'school_admin', 'school_manager', 'teacher', 'assistant', 'parent'],
    };

    final requiredRoles = routePermissions[route];
    if (requiredRoles == null) {
      // If route is not defined, allow access to authenticated users
      return true;
    }

    // Check if user has any of the required roles
    return userRoles.any((role) => requiredRoles.contains(role));
  }

  /// Get allowed routes for user roles
  static List<String> getAllowedRoutes(List<String> userRoles) {
    return [
      login,
      signup,
      forgotPassword,
      resetPassword,
      profile,
      settings,
      notifications,
      ...getHomeRouteForRoles(userRoles) == adminHome ? [
        adminHome,
        adminUsers,
        adminTenants,
        adminReports,
        adminSettings,
        adminAnalytics,
        adminBilling,
        adminSupport,
        adminAnnouncements,
        adminActiveCustomers,
        adminSalesPipeline,
        adminMarketExplorer,
        adminMarketExplorerDetail,
      ] : [],
      ...getHomeRouteForRoles(userRoles) == parentHome ? [
        parentHome,
        parentChildren,
        parentActivities,
        parentReports,
        parentMessages,
        parentBilling,
      ] : [],
      ...getHomeRouteForRoles(userRoles) == tenantHome ? [
        tenantHome,
        tenantDashboard,
        tenantChildren,
        tenantStaff,
        tenantUsers,
        tenantAttendance,
        tenantMeals,
        tenantActivities,
        tenantReports,
        tenantBilling,
        tenantSettings,
        tenantMessages,
      ] : [],
    ];
  }

  /// Get navigation items based on user roles
  static List<NavigationItem> getNavigationItems(List<String> userRoles) {
    final platform = getPlatformType(userRoles);

    switch (platform) {
      case 'admin':
        return [
          NavigationItem('Dashboard', adminHome, 'dashboard'),
          NavigationItem('Customers', adminActiveCustomers, 'business', [
            NavigationItem('Active Customers', adminActiveCustomers, 'business'),
            NavigationItem('Sales Pipeline', adminSalesPipeline, 'trending_up'),
            NavigationItem('Market Explorer', adminMarketExplorer, 'explore'),
          ]),
          NavigationItem('Users', adminUsers, 'people'),
          NavigationItem('Reports', adminReports, 'analytics'),
          NavigationItem('Settings', adminSettings, 'settings'),
        ];

      case 'parent':
        return [
          NavigationItem('Home', parentHome, 'home'),
          NavigationItem('My Children', parentChildren, 'child_care'),
          NavigationItem('Activities', parentActivities, 'sports'),
          NavigationItem('Messages', parentMessages, 'message'),
          NavigationItem('Reports', parentReports, 'assessment'),
        ];

      case 'tenant':
      default:
        final items = <NavigationItem>[
          NavigationItem('Dashboard', tenantHome, 'dashboard'),
        ];

        // Add items based on specific roles
        if (userRoles.any((role) => ['school_admin', 'school_manager', 'teacher', 'assistant'].contains(role))) {
          items.add(NavigationItem('Children', tenantChildren, 'child_care'));
          items.add(NavigationItem('Attendance', tenantAttendance, 'how_to_reg'));
          items.add(NavigationItem('Meals', tenantMeals, 'restaurant'));
          items.add(NavigationItem('Activities', tenantActivities, 'sports'));
        }

        if (userRoles.any((role) => ['school_admin', 'school_manager'].contains(role))) {
          items.add(NavigationItem('Staff', tenantStaff, 'people'));
          items.add(NavigationItem('Reports', tenantReports, 'analytics'));
        }

        if (userRoles.contains('school_admin')) {
          items.add(NavigationItem('Users', tenantUsers, 'manage_accounts'));
          items.add(NavigationItem('Billing', tenantBilling, 'payment'));
          items.add(NavigationItem('Settings', tenantSettings, 'settings'));
        }

        return items;
    }
  }

  /// Route names for easier reference
  static const Map<String, String> routeNames = {
    initial: 'Initial',
    login: 'Login',
    signup: 'Sign Up',
    forgotPassword: 'Forgot Password',
    resetPassword: 'Reset Password',
    adminHome: 'Admin Dashboard',
    parentHome: 'Parent Dashboard',
    tenantHome: 'School Dashboard',
    dashboard: 'Dashboard',
    profile: 'Profile',
    settings: 'Settings',
    notifications: 'Notifications',
    adminActiveCustomers: 'Active Customers',
    adminSalesPipeline: 'Sales Pipeline',
    adminMarketExplorer: 'Market Explorer',
    adminMarketExplorerDetail: 'Market Explorer Detail',
  };

  /// Get route name
  static String getRouteName(String route) {
    return routeNames[route] ?? route;
  }
}

/// Navigation item model for menu generation
class NavigationItem {
  final String title;
  final String route;
  final String icon;
  final List<NavigationItem>? children;

  NavigationItem(this.title, this.route, this.icon, [this.children]);
}