// lib/core/config/api_endpoints.dart
class ApiEndpoints {
  // Private constructor to prevent instantiation
  ApiEndpoints._();

  // Base paths matching backend structure
  static const String _auth = '/auth';
  static const String _users = '/users';
  static const String _tenants = '/tenants';
  static const String _children = '/children';
  static const String _attendance = '/attendance';
  static const String _meals = '/meals';
  static const String _activities = '/activities';
  static const String _media = '/media';
  static const String _communication = '/communication';
  static const String _reports = '/reports';
  static const String _billing = '/billing';
  static const String _settings = '/settings';
  static const String _marketExplorer = '/market-explorer';

  // =============================================================================
  // AUTHENTICATION ENDPOINTS (matching backend)
  // =============================================================================

  /// POST /auth/login - User login
  static const String login = '$_auth/login';

  /// POST /auth/register - User registration
  static const String register = '$_auth/register';

  /// POST /auth/refresh - Refresh access token
  static const String refreshToken = '$_auth/refresh';

  /// POST /auth/logout - User logout
  static const String logout = '$_auth/logout';

  /// GET /auth/me - Get current user profile
  static const String getMe = '$_auth/me';

  /// POST /auth/forgot-password - Request password reset
  static const String forgotPassword = '$_auth/forgot-password';

  /// POST /auth/reset-password/:token - Reset password
  static String resetPassword(String token) => '$_auth/reset-password/$token';

  /// GET /auth/verify-email/:token - Verify email address
  static String verifyEmail(String token) => '$_auth/verify-email/$token';

  /// POST /auth/resend-verification - Resend verification email
  static const String resendVerification = '$_auth/resend-verification';

  /// GET /auth/check-auth - Check authentication status
  static const String checkAuth = '$_auth/check-auth';

  /// GET /auth/validate-token - Validate current token
  static const String validateToken = '$_auth/validate-token';

  /// GET /auth/debug-user - Debug user data and roles (development only)
  static const String debugUser = '$_auth/debug-user';

  // =============================================================================
  // USER MANAGEMENT ENDPOINTS (matching backend)
  // =============================================================================

  /// GET /users - Get all users in tenant
  static const String getUsers = _users;

  /// GET /users/me - Get current user profile
  static const String getCurrentUser = '$_users/me';

  /// GET /users/:id - Get user by ID
  static String getUserById(String userId) => '$_users/$userId';

  /// POST /users - Create new user
  static const String createUser = _users;

  /// PUT /users/:id - Update user
  static String updateUser(String userId) => '$_users/$userId';

  /// DELETE /users/:id - Delete/deactivate user
  static String deleteUser(String userId) => '$_users/$userId';

  /// POST /users/:id/activate - Activate user account
  static String activateUser(String userId) => '$_users/$userId/activate';

  /// POST /users/:id/deactivate - Deactivate user account
  static String deactivateUser(String userId) => '$_users/$userId/deactivate';

  /// POST /users/:id/reset-password - Force password reset
  static String forcePasswordReset(String userId) => '$_users/$userId/reset-password';

  /// GET /users/roles/:roleName - Get users by role
  static String getUsersByRole(String roleName) => '$_users/roles/$roleName';

  /// POST /users/invite - Invite new user via email
  static const String inviteUser = '$_users/invite';

  /// GET /users/search - Search users
  static const String searchUsers = '$_users/search';

  /// GET /users/me/dashboard - Get user dashboard data
  static const String getUserDashboard = '$_users/me/dashboard';

  // =============================================================================
  // TENANT MANAGEMENT ENDPOINTS (matching backend)
  // =============================================================================

  /// GET /tenants - Get all tenants (Platform admin only)
  static const String getTenants = _tenants;

  /// GET /tenants/me - Get current user's tenant
  static const String getCurrentTenant = '$_tenants/me';

  /// GET /tenants/:id - Get tenant by ID
  static String getTenantById(String tenantId) => '$_tenants/$tenantId';

  /// POST /tenants - Create new tenant
  static const String createTenant = _tenants;

  /// PUT /tenants/:id - Update tenant
  static String updateTenant(String tenantId) => '$_tenants/$tenantId';

  /// DELETE /tenants/:id - Delete tenant
  static String deleteTenant(String tenantId) => '$_tenants/$tenantId';

  /// POST /tenants/:id/activate - Activate tenant
  static String activateTenant(String tenantId) => '$_tenants/$tenantId/activate';

  /// POST /tenants/:id/suspend - Suspend tenant
  static String suspendTenant(String tenantId) => '$_tenants/$tenantId/suspend';

  /// POST /tenants/:id/reactivate - Reactivate tenant
  static String reactivateTenant(String tenantId) => '$_tenants/$tenantId/reactivate';

  /// GET /tenants/:id/stats - Get tenant statistics
  static String getTenantStats(String tenantId) => '$_tenants/$tenantId/stats';

  /// PUT /tenants/:id/subscription - Update tenant subscription
  static String updateTenantSubscription(String tenantId) => '$_tenants/$tenantId/subscription';

  /// GET /tenants/me/dashboard - Get tenant dashboard data
  static const String getTenantDashboard = '$_tenants/me/dashboard';

  /// GET /tenants/me/settings - Get tenant settings
  static const String getTenantSettings = '$_tenants/me/settings';

  /// PUT /tenants/me/settings - Update tenant settings
  static const String updateTenantSettings = '$_tenants/me/settings';

  /// GET /tenants/search - Search tenants
  static const String searchTenants = '$_tenants/search';

  /// GET /tenants/expiring-trials - Get tenants with expiring trials
  static const String getExpiringTrials = '$_tenants/expiring-trials';

  /// POST /tenants/:id/extend-trial - Extend tenant trial
  static String extendTrial(String tenantId) => '$_tenants/$tenantId/extend-trial';

  /// GET /tenants/:id/audit-log - Get tenant audit log
  static String getTenantAuditLog(String tenantId) => '$_tenants/$tenantId/audit-log';

  /// POST /tenants/:id/regenerate-api-key - Regenerate tenant API key
  static String regenerateApiKey(String tenantId) => '$_tenants/$tenantId/regenerate-api-key';

  // =============================================================================
  // MARKET EXPLORER ENDPOINTS (NEW)
  // =============================================================================

  /// GET /market-explorer - Get all ECD Centers with filtering
  static const String getECDCenters = _marketExplorer;

  /// GET /market-explorer/analytics - Get market analytics
  static const String getMarketAnalytics = '$_marketExplorer/analytics';

  /// GET /market-explorer/export - Export ECD Centers data
  static const String exportECDCenters = '$_marketExplorer/export';

  /// GET /market-explorer/:id - Get single ECD Center
  static String getECDCenterById(String centerId) => '$_marketExplorer/$centerId';

  /// PUT /market-explorer/:id - Update ECD Center
  static String updateECDCenter(String centerId) => '$_marketExplorer/$centerId';

  /// POST /market-explorer/:id/notes - Add note to ECD Center
  static String addNoteToCenter(String centerId) => '$_marketExplorer/$centerId/notes';

  /// PUT /market-explorer/:id/status - Update lead status
  static String updateCenterLeadStatus(String centerId) => '$_marketExplorer/$centerId/status';

  /// POST /market-explorer/:id/convert - Convert ECD Center to Tenant
  static String convertCenterToTenant(String centerId) => '$_marketExplorer/$centerId/convert';

  /// POST /market-explorer/assign - Assign sales rep to ECD Centers
  static const String assignSalesRep = '$_marketExplorer/assign';

  /// PUT /market-explorer/bulk - Bulk update ECD Centers
  static const String bulkUpdateCenters = '$_marketExplorer/bulk';

  /// POST /market-explorer/:id/tasks - Add task to ECD Center
  static String addTaskToCenter(String centerId) => '$_marketExplorer/$centerId/tasks';

  /// PUT /market-explorer/:id/tasks/:taskId - Update task
  static String updateCenterTask(String centerId, String taskId) => '$_marketExplorer/$centerId/tasks/$taskId';

  /// POST /market-explorer/:id/schedule-demo - Schedule demo for center
  static String scheduleDemoForCenter(String centerId) => '$_marketExplorer/$centerId/schedule-demo';

  /// GET /market-explorer/territories - Get sales territories
  static const String getSalesTerritories = '$_marketExplorer/territories';

  /// POST /market-explorer/territories - Create sales territory
  static const String createSalesTerritory = '$_marketExplorer/territories';

  /// PUT /market-explorer/territories/:id - Update territory
  static String updateSalesTerritory(String territoryId) => '$_marketExplorer/territories/$territoryId';

  /// GET /market-explorer/opportunities - Get top opportunities
  static const String getTopOpportunities = '$_marketExplorer/opportunities';

  /// GET /market-explorer/pipeline - Get pipeline funnel data
  static const String getPipelineFunnel = '$_marketExplorer/pipeline';

  // =============================================================================
  // FUTURE ENDPOINTS (Placeholders for upcoming features)
  // =============================================================================

  /// GET /children - Get children
  static const String getChildren = _children;

  /// POST /children - Create child
  static const String createChild = _children;

  /// GET /attendance - Get attendance records
  static const String getAttendance = _attendance;

  /// POST /attendance/check-in - Check in child
  static const String checkIn = '$_attendance/check-in';

  /// POST /attendance/check-out - Check out child
  static const String checkOut = '$_attendance/check-out';

  /// GET /meals - Get meal records
  static const String getMeals = _meals;

  /// POST /meals - Record meal
  static const String recordMeal = _meals;

  /// GET /activities - Get activities
  static const String getActivities = _activities;

  /// POST /activities - Create activity
  static const String createActivity = _activities;

  /// GET /media - Get media files
  static const String getMedia = _media;

  /// POST /media - Upload media
  static const String uploadMedia = _media;

  /// GET /communication/messages - Get messages
  static const String getMessages = '$_communication/messages';

  /// POST /communication/messages - Send message
  static const String sendMessage = '$_communication/messages';

  /// GET /reports - Get reports
  static const String getReports = _reports;

  /// GET /billing/invoices - Get invoices
  static const String getInvoices = '$_billing/invoices';

  /// GET /settings - Get settings
  static const String getSettings = _settings;

  // =============================================================================
  // UTILITY METHODS
  // =============================================================================

  /// Build URL with query parameters
  static String buildUrlWithQuery(String endpoint, Map<String, dynamic>? queryParams) {
    if (queryParams == null || queryParams.isEmpty) {
      return endpoint;
    }

    final uri = Uri.parse(endpoint);
    final newUri = uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...queryParams.map((key, value) => MapEntry(key, value.toString())),
    });

    return newUri.toString();
  }

  /// Build URL with path parameters
  static String buildUrlWithParams(String template, Map<String, String> params) {
    String url = template;
    params.forEach((key, value) {
      url = url.replaceAll(':$key', value);
    });
    return url;
  }

  /// Get all endpoint definitions for debugging
  static Map<String, String> get allEndpoints => {
    // Auth endpoints
    'login': login,
    'register': register,
    'refreshToken': refreshToken,
    'logout': logout,
    'getMe': getMe,
    'forgotPassword': forgotPassword,
    'resendVerification': resendVerification,
    'checkAuth': checkAuth,
    'validateToken': validateToken,
    'debugUser': debugUser,

    // User endpoints
    'getUsers': getUsers,
    'getCurrentUser': getCurrentUser,
    'createUser': createUser,
    'inviteUser': inviteUser,
    'searchUsers': searchUsers,
    'getUserDashboard': getUserDashboard,

    // Tenant endpoints
    'getTenants': getTenants,
    'getCurrentTenant': getCurrentTenant,
    'createTenant': createTenant,
    'searchTenants': searchTenants,
    'getExpiringTrials': getExpiringTrials,
    'getTenantDashboard': getTenantDashboard,
    'getTenantSettings': getTenantSettings,

    // Market Explorer endpoints
    'getECDCenters': getECDCenters,
    'getMarketAnalytics': getMarketAnalytics,
    'exportECDCenters': exportECDCenters,
    'assignSalesRep': assignSalesRep,
    'bulkUpdateCenters': bulkUpdateCenters,
    'getSalesTerritories': getSalesTerritories,
    'createSalesTerritory': createSalesTerritory,
    'getTopOpportunities': getTopOpportunities,
    'getPipelineFunnel': getPipelineFunnel,

    // Future endpoints
    'getChildren': getChildren,
    'createChild': createChild,
    'getAttendance': getAttendance,
    'checkIn': checkIn,
    'checkOut': checkOut,
    'getMeals': getMeals,
    'recordMeal': recordMeal,
    'getActivities': getActivities,
    'createActivity': createActivity,
    'getMedia': getMedia,
    'uploadMedia': uploadMedia,
    'getMessages': getMessages,
    'sendMessage': sendMessage,
    'getReports': getReports,
    'getInvoices': getInvoices,
    'getSettings': getSettings,
  };
}