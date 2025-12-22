// Conditional export for platform-specific barcode scanner implementations
// On web: exports scanner_screen_web.dart with manual input option
// On mobile (Android/iOS): exports scanner_screen_mobile.dart with camera-only

export 'scanner_screen_mobile.dart'
    if (dart.library.html) 'scanner_screen_web.dart';
