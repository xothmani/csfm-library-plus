// File generated based on GoogleService-Info.plist
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAgKC3-oIXssK4vwB0bJZxisUUfKCmqgpA',
    appId: '1:919803545201:ios:612c16ab3e2fa740ea7dd0',
    messagingSenderId: '919803545201',
    projectId: 'csfm-library-plus',
    storageBucket: 'csfm-library-plus.firebasestorage.app',
    iosBundleId: 'com.rayen.libraryapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAgKC3-oIXssK4vwB0bJZxisUUfKCmqgpA',
    appId: '1:919803545201:ios:612c16ab3e2fa740ea7dd0',
    messagingSenderId: '919803545201',
    projectId: 'csfm-library-plus',
    storageBucket: 'csfm-library-plus.firebasestorage.app',
    iosBundleId: 'com.rayen.libraryapp',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAgKC3-oIXssK4vwB0bJZxisUUfKCmqgpA',
    appId: '1:919803545201:ios:612c16ab3e2fa740ea7dd0',
    messagingSenderId: '919803545201',
    projectId: 'csfm-library-plus',
    storageBucket: 'csfm-library-plus.firebasestorage.app',
  );
}
