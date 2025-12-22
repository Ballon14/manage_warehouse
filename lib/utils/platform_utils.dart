import 'package:flutter/foundation.dart';

/// Utility class for platform detection
class PlatformUtils {
  /// Returns true if running on web platform
  static bool get isWeb => kIsWeb;

  /// Returns true if running on mobile platform (Android/iOS)
  static bool get isMobile => !kIsWeb;
}
