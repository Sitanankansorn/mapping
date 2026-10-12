import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] configured for Thailand Mapping App.
/// Associated Firebase Account: s6707012660077@email.kmutnb.ac.th
class DefaultFirebaseOptions {
  static const String ownerEmail = 's6707012660077@email.kmutnb.ac.th';

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        return web;
    }
  }

  /// Indicates if real Firebase project credentials are configured
  static bool get isConfigured =>
      !web.apiKey.contains('DEMO_KEY');

  // ── Web Configuration ──────────────────────────────────────────────────────

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAf-3y6B6TSIIh3bR5FdZujYm8-uUCst0k',
    appId: '1:116413326341:web:5656755f226b2f8e1b286c',
    messagingSenderId: '116413326341',
    projectId: 'mapping-ae4b8',
    authDomain: 'mapping-ae4b8.firebaseapp.com',
    storageBucket: 'mapping-ae4b8.firebasestorage.app',
    measurementId: 'G-83NT1807S9',
  );
  // ── Android Configuration ──────────────────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_KMUTNB_MAPPING_FIREBASE_2026',
    appId: '1:670701266007:android:8f9a2b3c4d5e6f7a8b9c',
    messagingSenderId: '670701266007',
    projectId: 'thailand-mapping-kmutnb',
    storageBucket: 'thailand-mapping-kmutnb.appspot.com',
  );

  // ── iOS Configuration ──────────────────────────────────────────────────────
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA_KMUTNB_MAPPING_FIREBASE_2026',
    appId: '1:670701266007:ios:8f9a2b3c4d5e6f7a8b9c',
    messagingSenderId: '670701266007',
    projectId: 'thailand-mapping-kmutnb',
    storageBucket: 'thailand-mapping-kmutnb.appspot.com',
    iosBundleId: 'com.kmutnb.mappingV1',
  );

  // ── Windows Desktop Configuration ──────────────────────────────────────────

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAf-3y6B6TSIIh3bR5FdZujYm8-uUCst0k',
    appId: '1:116413326341:web:a5cc5b6397752dd71b286c',
    messagingSenderId: '116413326341',
    projectId: 'mapping-ae4b8',
    authDomain: 'mapping-ae4b8.firebaseapp.com',
    storageBucket: 'mapping-ae4b8.firebasestorage.app',
    measurementId: 'G-F7S6C6Q42F',
  );
}
