import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Default Firebase configuration generated from `google-services.json`.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'FirebaseOptions have not been configured for web. '
        'Run flutterfire configure or update firebase_options.dart.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'FirebaseOptions have not been configured for this platform.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDH-fL8NLuockkoTEW_W4Fnk476KoU-Puw',
    appId: '1:82639873656:android:85bb2b6e707688e28e6f8d',
    messagingSenderId: '82639873656',
    projectId: 'manage-your-stock-f684a',
    storageBucket: 'manage-your-stock-f684a.firebasestorage.app',
    databaseURL:
        'https://manage-your-stock-f684a-default-rtdb.asia-southeast1.firebasedatabase.app',
  );
}
