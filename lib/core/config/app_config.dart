// lib/core/config/app_config.dart
class AppConfig {
  static const String appName = 'Creche Cloud';
  static const String appVersion = '1.0.0';
  static const String apiBaseUrl = 'https://api.crechecloud.co.za';

  // Environment
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');
  static bool get isDevelopment => !isProduction;

  // API Configuration
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration cacheTimeout = Duration(hours: 1);

  // Permissions
  static const List<String> requiredPermissions = [
    'camera',
    'storage',
    'notification',
  ];

  static Future<void> initialize() async {
    // Initialize any required services here
    // Firebase, local storage, etc.
  }
}