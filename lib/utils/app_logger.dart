import 'package:flutter/foundation.dart';

/// App-wide logging utility that only logs in debug mode
class AppLogger {
  static const bool _enabled = kDebugMode;

  /// Log debug message
  static void debug(String message, [String? tag]) {
    if (_enabled) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('🔍 $prefix$message');
    }
  }

  /// Log info message
  static void info(String message, [String? tag]) {
    if (_enabled) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('ℹ️  $prefix$message');
    }
  }

  /// Log success message
  static void success(String message, [String? tag]) {
    if (_enabled) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('✅ $prefix$message');
    }
  }

  /// Log warning message
  static void warning(String message, [String? tag]) {
    if (_enabled) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('⚠️  $prefix$message');
    }
  }

  /// Log error message
  static void error(String message, [String? tag, Object? error]) {
    if (_enabled) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('❌ $prefix$message');
      if (error != null) {
        debugPrint('   Error details: $error');
      }
    }
  }

  /// Log network request
  static void network(String message, [String? endpoint]) {
    if (_enabled) {
      final prefix = endpoint != null ? '[$endpoint] ' : '';
      debugPrint('🌐 $prefix$message');
    }
  }

  /// Log authentication event
  static void auth(String message) {
    if (_enabled) {
      debugPrint('🔑 [Auth] $message');
    }
  }

  /// Log database operation
  static void database(String message) {
    if (_enabled) {
      debugPrint('📚 [Database] $message');
    }
  }

  /// Log navigation event
  static void navigation(String message) {
    if (_enabled) {
      debugPrint('🚀 [Navigation] $message');
    }
  }
}
