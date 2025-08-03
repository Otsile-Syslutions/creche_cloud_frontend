// lib/utils/app_logger.dart
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

class AppLogger {
  static Logger? _instance;

  static Logger get instance {
    _instance ??= _createLogger();
    return _instance!;
  }

  static Logger _createLogger() {
    return Logger(
      filter: kDebugMode ? DevelopmentFilter() : ProductionFilter(),
      printer: kDebugMode
          ? PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      )
          : SimplePrinter(),
      output: kDebugMode
          ? ConsoleOutput()
          : MultiOutput([
        ConsoleOutput(),
        // Add FileOutput here for production logging if needed
      ]),
    );
  }

  // Convenience methods
  static void d(String message, [Object? error, StackTrace? stackTrace]) {
    instance.d(message, error: error, stackTrace: stackTrace);
  }

  static void i(String message, [Object? error, StackTrace? stackTrace]) {
    instance.i(message, error: error, stackTrace: stackTrace);
  }

  static void w(String message, [Object? error, StackTrace? stackTrace]) {
    instance.w(message, error: error, stackTrace: stackTrace);
  }

  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    instance.e(message, error: error, stackTrace: stackTrace);
  }

  static void t(String message, [Object? error, StackTrace? stackTrace]) {
    instance.t(message, error: error, stackTrace: stackTrace);
  }

  static void f(String message, [Object? error, StackTrace? stackTrace]) {
    instance.f(message, error: error, stackTrace: stackTrace);
  }
}

// Custom filter for production
class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // In production, only log warnings and above
    return event.level.index >= Level.warning.index;
  }
}

// Example usage:
// AppLogger.i('User logged in successfully');
// AppLogger.e('Login failed', error: exception);
// AppLogger.d('Debug info: ${someVariable}');