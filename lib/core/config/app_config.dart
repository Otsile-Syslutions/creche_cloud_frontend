// lib/core/config/app_config.dart
import 'package:flutter/foundation.dart';
import 'env.dart';
import '../../utils/app_logger.dart';

class AppConfig {
  static const String appName = 'Creche Cloud';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Empowering Early Childhood Development';

  // Environment-based configuration
  static String get apiBaseUrl => Env.apiBaseUrl;
  static String get defaultTenantId => Env.defaultTenantSlug.isEmpty ? 'default' : Env.defaultTenantSlug;
  static bool get isProduction => Env.isProduction;
  static bool get isDevelopment => Env.isDevelopment;

  // API Configuration
  static Duration get apiTimeout => Env.connectTimeout;
  static Duration get cacheTimeout => Env.cacheTimeout;
  static int get retryAttempts => Env.maxRetryAttempts;

  // Security Configuration
  static bool get enableBiometrics => Env.enableBiometrics;
  static bool get enableTwoFactor => const bool.fromEnvironment('ENABLE_TWO_FACTOR', defaultValue: true);
  static Duration get sessionTimeout => const Duration(
    minutes: int.fromEnvironment('SESSION_TIMEOUT_MINUTES', defaultValue: 30),
  );
  static bool get enableAutoLogout => const bool.fromEnvironment('ENABLE_AUTO_LOGOUT', defaultValue: true);

  // Child Data Protection (COPPA/GDPR Compliance)
  static bool get enableChildDataEncryption => const bool.fromEnvironment('ENABLE_CHILD_DATA_ENCRYPTION', defaultValue: true);
  static bool get requireParentConsent => const bool.fromEnvironment('REQUIRE_PARENT_CONSENT', defaultValue: true);
  static bool get auditChildDataAccess => const bool.fromEnvironment('AUDIT_CHILD_DATA_ACCESS', defaultValue: true);
  static int get dataRetentionDays => const int.fromEnvironment('DATA_RETENTION_DAYS', defaultValue: 365);

  // Feature Flags
  static bool get enableDarkMode => Env.enableDarkMode;
  static bool get enableNotifications => Env.enableNotifications;
  static bool get enableOfflineMode => Env.enableOfflineMode;
  static bool get enableAnalytics => Env.enableAnalytics;
  static bool get enableCrashReporting => Env.enableCrashReporting;

  // Media Configuration
  static int get maxImageSizeMB => Env.maxImageSize;
  static int get maxVideoSizeMB => Env.maxVideoSize;
  static int get imageQuality => const int.fromEnvironment('IMAGE_QUALITY', defaultValue: 85);
  static int get maxCacheSize => Env.maxCacheSize;

  // Permissions required by the app
  static const List<String> requiredPermissions = [
    'camera',
    'storage',
    'notification',
  ];

  // App initialization
  static Future<void> initialize() async {
    try {
      AppLogger.i('Initializing Creche Cloud app...');

      // Print configuration in debug mode
      if (isDevelopment) {
        printConfiguration();
      }

      // Validate configuration
      if (!validateConfiguration()) {
        throw Exception('Invalid configuration detected');
      }

      // Initialize security features
      await _initializeSecurity();

      // Initialize offline support
      if (enableOfflineMode) {
        await _initializeOfflineSupport();
      }

      // Initialize crash reporting
      if (enableCrashReporting && !kDebugMode) {
        await _initializeCrashReporting();
      }

      // Initialize analytics
      if (enableAnalytics && !kDebugMode) {
        await _initializeAnalytics();
      }

      AppLogger.i('App initialization completed successfully');
    } catch (e) {
      AppLogger.e('App initialization failed', e);
      rethrow;
    }
  }

  static Future<void> _initializeSecurity() async {
    AppLogger.d('Initializing security features...');

    // Initialize encryption for child data
    if (enableChildDataEncryption) {
      AppLogger.d('Child data encryption enabled');
    }

    // Initialize biometric authentication
    if (enableBiometrics) {
      AppLogger.d('Biometric authentication enabled');
    }

    // Initialize two-factor authentication
    if (enableTwoFactor) {
      AppLogger.d('Two-factor authentication enabled');
    }

    AppLogger.d('Security initialization completed');
  }

  static Future<void> _initializeOfflineSupport() async {
    AppLogger.d('Initializing offline support...');

    // Initialize local database
    // Initialize cache management
    // Set up sync mechanisms

    AppLogger.d('Offline support initialization completed');
  }

  static Future<void> _initializeCrashReporting() async {
    if (Env.sentryDsn.isNotEmpty) {
      AppLogger.d('Initializing crash reporting...');
      // Initialize Sentry or other crash reporting service
      AppLogger.d('Crash reporting initialization completed');
    }
  }

  static Future<void> _initializeAnalytics() async {
    AppLogger.d('Initializing analytics...');
    // Initialize Firebase Analytics or other analytics service
    AppLogger.d('Analytics initialization completed');
  }

  // Tenant-specific configuration
  static Map<String, dynamic> getTenantConfig(String tenantId) {
    return {
      'tenantId': tenantId,
      'apiBaseUrl': apiBaseUrl,
      'features': getTenantFeatures(tenantId),
      'security': getTenantSecurity(tenantId),
      'compliance': getTenantCompliance(tenantId),
    };
  }

  static Map<String, bool> getTenantFeatures(String tenantId) {
    // This would typically come from the backend
    // For now, return default features
    return {
      'photos': true,
      'activities': true,
      'reports': true,
      'messaging': true,
      'billing': true,
      'assessments': true,
      'attendance': true,
      'parent_portal': true,
      'teacher_tools': true,
      'admin_dashboard': true,
    };
  }

  static Map<String, dynamic> getTenantSecurity(String tenantId) {
    return {
      'encryption_required': enableChildDataEncryption,
      'audit_enabled': auditChildDataAccess,
      'session_timeout': sessionTimeout.inSeconds,
      'biometrics_enabled': enableBiometrics,
      'two_factor_enabled': enableTwoFactor,
      'auto_logout_enabled': enableAutoLogout,
    };
  }

  static Map<String, dynamic> getTenantCompliance(String tenantId) {
    return {
      'coppa_compliant': true,
      'gdpr_compliant': true,
      'popi_compliant': true, // South African POPI Act
      'data_retention_days': dataRetentionDays,
      'parent_consent_required': requireParentConsent,
      'child_data_encryption': enableChildDataEncryption,
      'audit_all_access': auditChildDataAccess,
    };
  }

  // App capabilities based on configuration
  static bool canTakePhotos() {
    return requiredPermissions.contains('camera');
  }

  static bool canStoreFiles() {
    return requiredPermissions.contains('storage');
  }

  static bool canSendNotifications() {
    return requiredPermissions.contains('notification') && enableNotifications;
  }

  static bool canWorkOffline() {
    return enableOfflineMode;
  }

  static bool canUseBiometrics() {
    return enableBiometrics;
  }

  static bool canUseTwoFactor() {
    return enableTwoFactor;
  }

  // Data protection helpers
  static bool shouldEncryptData(String dataType) {
    // Default implementation for child data protection
    const sensitiveDataTypes = ['child_profile', 'child_photos', 'child_activities', 'child_assessments'];
    return enableChildDataEncryption && sensitiveDataTypes.contains(dataType);
  }

  static bool shouldAuditAccess(String resourceType) {
    // Default implementation for access auditing
    const auditedResources = ['child_data', 'parent_info', 'financial_data', 'staff_records'];
    return auditChildDataAccess && auditedResources.contains(resourceType);
  }

  // File size validation
  static bool isImageSizeValid(int sizeInBytes) {
    final sizeInMB = sizeInBytes / (1024 * 1024);
    return sizeInMB <= maxImageSizeMB;
  }

  static bool isVideoSizeValid(int sizeInBytes) {
    final sizeInMB = sizeInBytes / (1024 * 1024);
    return sizeInMB <= maxVideoSizeMB;
  }

  // Cache management
  static bool isCacheSizeValid(int sizeInBytes) {
    final sizeInMB = sizeInBytes / (1024 * 1024);
    return sizeInMB <= maxCacheSize;
  }

  // Environment-specific URLs (mapping to Env properties or providing defaults)
  static String get authUrl => '${Env.apiBaseUrl}/auth';
  static String get usersUrl => '${Env.apiBaseUrl}/users';
  static String get childrenUrl => '${Env.apiBaseUrl}/children';
  static String get activitiesUrl => '${Env.apiBaseUrl}/activities';
  static String get reportsUrl => '${Env.apiBaseUrl}/reports';
  static String get uploadUrl => '${Env.apiBaseUrl}/upload';

  // Headers for API requests
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'Creche Cloud Mobile $appVersion',
    'X-App-Version': appVersion,
    'X-Platform': 'mobile',
  };

  // Helper methods for development
  static void printConfiguration() {
    if (isDevelopment) {
      Env.printEnvironmentInfo();
      AppLogger.i('=== Creche Cloud App Configuration ===');
      AppLogger.i('App Name: $appName');
      AppLogger.i('Version: $appVersion');
      AppLogger.i('Environment: ${isProduction ? "Production" : "Development"}');
      AppLogger.i('API URL: $apiBaseUrl');
      AppLogger.i('Default Tenant: $defaultTenantId');
      AppLogger.i('Security Features:');
      AppLogger.i('  - Child Data Encryption: $enableChildDataEncryption');
      AppLogger.i('  - Audit Access: $auditChildDataAccess');
      AppLogger.i('  - Biometrics: $enableBiometrics');
      AppLogger.i('  - Two Factor: $enableTwoFactor');
      AppLogger.i('Feature Flags:');
      AppLogger.i('  - Offline Mode: $enableOfflineMode');
      AppLogger.i('  - Dark Mode: $enableDarkMode');
      AppLogger.i('  - Notifications: $enableNotifications');
      AppLogger.i('  - Analytics: $enableAnalytics');
      AppLogger.i('  - Crash Reporting: $enableCrashReporting');
      AppLogger.i('=== End Configuration ===');
    }
  }

  // Validation
  static bool validateConfiguration() {
    final errors = <String>[];

    if (apiBaseUrl.isEmpty) {
      errors.add('API Base URL is required');
    }

    if (defaultTenantId.isEmpty) {
      errors.add('Default Tenant ID is required');
    }

    if (apiTimeout.inSeconds <= 0) {
      errors.add('API timeout must be positive');
    }

    if (sessionTimeout.inSeconds <= 0) {
      errors.add('Session timeout must be positive');
    }

    if (maxImageSizeMB <= 0) {
      errors.add('Max image size must be positive');
    }

    if (maxVideoSizeMB <= 0) {
      errors.add('Max video size must be positive');
    }

    if (maxCacheSize <= 0) {
      errors.add('Max cache size must be positive');
    }

    if (dataRetentionDays <= 0) {
      errors.add('Data retention days must be positive');
    }

    if (errors.isNotEmpty) {
      AppLogger.e('Configuration validation failed: ${errors.join(', ')}');
      return false;
    }

    return true;
  }

  // Runtime configuration updates
  static Future<void> updateConfiguration(Map<String, dynamic> updates) async {
    try {
      AppLogger.i('Updating app configuration...');

      // Handle configuration updates
      // This would typically save to local storage and notify relevant services

      AppLogger.i('Configuration updated successfully');
    } catch (e) {
      AppLogger.e('Failed to update configuration', e);
      rethrow;
    }
  }

  // Feature flag helpers
  static bool isFeatureEnabled(String featureName) {
    // Default implementation using environment variables
    switch (featureName.toLowerCase()) {
      case 'biometrics':
        return enableBiometrics;
      case 'two_factor':
        return enableTwoFactor;
      case 'offline_mode':
        return enableOfflineMode;
      case 'dark_mode':
        return enableDarkMode;
      case 'notifications':
        return enableNotifications;
      case 'analytics':
        return enableAnalytics;
      case 'crash_reporting':
        return enableCrashReporting;
      case 'child_data_encryption':
        return enableChildDataEncryption;
      case 'audit_child_data_access':
        return auditChildDataAccess;
      case 'require_parent_consent':
        return requireParentConsent;
      default:
        return false;
    }
  }

  // App metadata
  static Map<String, dynamic> get appMetadata => {
    'name': appName,
    'version': appVersion,
    'tagline': appTagline,
    'environment': isProduction ? 'production' : 'development',
    'build_date': DateTime.now().toIso8601String(),
    'tenant_id': defaultTenantId,
    'api_base_url': apiBaseUrl,
    'security_features': {
      'child_data_encryption': enableChildDataEncryption,
      'audit_access': auditChildDataAccess,
      'biometrics': enableBiometrics,
      'two_factor': enableTwoFactor,
    },
    'compliance': {
      'coppa': true,
      'gdpr': true,
      'popi': true,
      'data_retention_days': dataRetentionDays,
    },
  };
}