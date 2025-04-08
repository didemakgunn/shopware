import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBJMSQ5csMFH1V5zNRwda1TT0MkdVTar9Q',
    appId: '1:1046381078438:web:1f73c5e0ea549b34d0d167',
    messagingSenderId: '1046381078438',
    projectId: 'shopware-47761',
    authDomain: 'shopware-47761.firebaseapp.com',
    storageBucket: 'shopware-47761.firebasestorage.app',
    measurementId: 'G-JC6FJYDSVM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyChsFC_k1S_kX6OpQZFmW1bAh0WJFjzK_U',
    appId: '1:1046381078438:android:6295cbadbab15cf1d0d167',
    messagingSenderId: '1046381078438',
    projectId: 'shopware-47761',
    storageBucket: 'shopware-47761.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDhdllK1tRnrgr-m2NcaiZMfZK67VvvGMs',
    appId: '1:1046381078438:ios:5fbe77d2bc95e245d0d167',
    messagingSenderId: '1046381078438',
    projectId: 'shopware-47761',
    storageBucket: 'shopware-47761.firebasestorage.app',
    iosBundleId: 'com.example.shopware',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDhdllK1tRnrgr-m2NcaiZMfZK67VvvGMs',
    appId: '1:1046381078438:ios:5fbe77d2bc95e245d0d167',
    messagingSenderId: '1046381078438',
    projectId: 'shopware-47761',
    storageBucket: 'shopware-47761.firebasestorage.app',
    iosBundleId: 'com.example.shopware',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBJMSQ5csMFH1V5zNRwda1TT0MkdVTar9Q',
    appId: '1:1046381078438:web:16afdf6fe3525bc1d0d167',
    messagingSenderId: '1046381078438',
    projectId: 'shopware-47761',
    authDomain: 'shopware-47761.firebaseapp.com',
    storageBucket: 'shopware-47761.firebasestorage.app',
    measurementId: 'G-N3G2LHJHHY',
  );
}
