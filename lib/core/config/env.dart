// lib/core/config/env.dart
import 'dart:developer' as developer;

class Env {
  // Private constructor
  Env._();

  // Environment detection
  static const bool _kDebugMode = bool.fromEnvironment('dart.vm.product') == false;

  // Environment types
  static const String _environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: _kDebugMode ? 'development' : 'production',
  );

  // Current environment
  static bool get isDevelopment => _environment == 'development';
  static bool get isStaging => _environment == 'staging';
  static bool get isProduction => _environment == 'production';
  static String get environment => _environment;

  // API Configuration - CORRECTLY CONFIGURED FOR PORT 50001
  static String get apiBaseUrl {
    switch (_environment) {
      case 'development':
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://localhost:50001/api',  // Correct port 50001
        );
      case 'staging':
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://api-staging.creche.cloud/api',
        );
      case 'production':
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://api.creche.cloud/api',
        );
      default:
        return 'http://localhost:50001/api';  // Correct fallback to port 50001
    }
  }

  // WebSocket Configuration
  static String get wsBaseUrl {
    final baseUrl = apiBaseUrl.replaceAll('/api', '');
    return baseUrl.replaceAll('http', 'ws').replaceAll('https', 'wss');
  }

  // App Configuration
  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Creche Cloud',
  );

  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0+1',
  );

  static const String bundleId = String.fromEnvironment(
    'BUNDLE_ID',
    defaultValue: 'za.co.crechecloud.app',
  );

  // API Timeouts
  static const Duration connectTimeout = Duration(
    milliseconds: int.fromEnvironment('CONNECT_TIMEOUT', defaultValue: 30000),
  );

  static const Duration receiveTimeout = Duration(
    milliseconds: int.fromEnvironment('RECEIVE_TIMEOUT', defaultValue: 30000),
  );

  static const Duration sendTimeout = Duration(
    milliseconds: int.fromEnvironment('SEND_TIMEOUT', defaultValue: 30000),
  );

  // Security Configuration
  static const bool enableBiometrics = bool.fromEnvironment(
    'ENABLE_BIOMETRICS',
    defaultValue: true,
  );

  static const bool enableHttpLogging = bool.fromEnvironment(
    'ENABLE_HTTP_LOGGING',
    defaultValue: true,
  );

  static const bool enableCertificatePinning = bool.fromEnvironment(
    'ENABLE_CERTIFICATE_PINNING',
    defaultValue: false,  // Disabled in development
  );

  static const String certificateFingerprint = String.fromEnvironment(
    'CERTIFICATE_FINGERPRINT',
    defaultValue: '',
  );

  // Analytics & Crash Reporting
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: false,  // Disabled in development
  );

  static const bool enableCrashReporting = bool.fromEnvironment(
    'ENABLE_CRASH_REPORTING',
    defaultValue: false,  // Disabled in development
  );

  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  // Feature Flags
  static const bool enableDarkMode = bool.fromEnvironment(
    'ENABLE_DARK_MODE',
    defaultValue: true,
  );

  static const bool enableNotifications = bool.fromEnvironment(
    'ENABLE_NOTIFICATIONS',
    defaultValue: true,
  );

  static const bool enableOfflineMode = bool.fromEnvironment(
    'ENABLE_OFFLINE_MODE',
    defaultValue: true,
  );

  // Cache Configuration
  static const Duration cacheTimeout = Duration(
    minutes: int.fromEnvironment('CACHE_TIMEOUT_MINUTES', defaultValue: 60),
  );

  static const int maxCacheSize = int.fromEnvironment(
    'MAX_CACHE_SIZE_MB',
    defaultValue: 100,
  );

  // Performance Configuration
  static const int maxRetryAttempts = int.fromEnvironment(
    'MAX_RETRY_ATTEMPTS',
    defaultValue: 3,
  );

  static const Duration retryDelay = Duration(
    milliseconds: int.fromEnvironment('RETRY_DELAY_MS', defaultValue: 1000),
  );

  // Tenant Configuration
  static const String defaultTenantSlug = String.fromEnvironment(
    'DEFAULT_TENANT_SLUG',
    defaultValue: '',
  );

  static const bool enableTenantSwitching = bool.fromEnvironment(
    'ENABLE_TENANT_SWITCHING',
    defaultValue: false,
  );

  // Media Configuration
  static const int maxImageSize = int.fromEnvironment(
    'MAX_IMAGE_SIZE_MB',
    defaultValue: 10,
  );

  static const int maxVideoSize = int.fromEnvironment(
    'MAX_VIDEO_SIZE_MB',
    defaultValue: 100,
  );

  static const String allowedImageFormats = String.fromEnvironment(
    'ALLOWED_IMAGE_FORMATS',
    defaultValue: 'jpg,jpeg,png,webp',
  );

  static const String allowedVideoFormats = String.fromEnvironment(
    'ALLOWED_VIDEO_FORMATS',
    defaultValue: 'mp4,mov,avi',
  );

  // Third-party Service Keys
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'creche-cloud-$_environment',
  );

  // Social Login Configuration
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );

  static const String appleClientId = String.fromEnvironment(
    'APPLE_CLIENT_ID',
    defaultValue: '',
  );

  // Validation helpers
  static bool get isValidConfiguration {
    // Check required configuration
    if (apiBaseUrl.isEmpty) return false;
    if (appName.isEmpty) return false;
    if (bundleId.isEmpty) return false;

    // Check production-specific requirements
    if (isProduction) {
      if (enableCertificatePinning && certificateFingerprint.isEmpty) {
        return false;
      }
      if (enableCrashReporting && sentryDsn.isEmpty) {
        return false;
      }
    }

    return true;
  }

  // Environment info for debugging
  static Map<String, dynamic> get environmentInfo => {
    'environment': environment,
    'isDevelopment': isDevelopment,
    'isStaging': isStaging,
    'isProduction': isProduction,
    'apiBaseUrl': apiBaseUrl,
    'wsBaseUrl': wsBaseUrl,
    'appName': appName,
    'appVersion': appVersion,
    'bundleId': bundleId,
    'enableHttpLogging': enableHttpLogging,
    'enableCertificatePinning': enableCertificatePinning,
    'enableAnalytics': enableAnalytics,
    'enableCrashReporting': enableCrashReporting,
    'enableOfflineMode': enableOfflineMode,
    'isValidConfiguration': isValidConfiguration,
  };

  // Print environment info (for debugging)
  static void printEnvironmentInfo() {
    if (isDevelopment) {
      developer.log('🌍 Environment Configuration:', name: 'Env');
      environmentInfo.forEach((key, value) {
        developer.log('  $key: $value', name: 'Env');
      });
    }
  }

  // Environment-specific settings
  static T getEnvironmentValue<T>({
    required T development,
    required T staging,
    required T production,
  }) {
    switch (_environment) {
      case 'development':
        return development;
      case 'staging':
        return staging;
      case 'production':
        return production;
      default:
        return development;
    }
  }
}