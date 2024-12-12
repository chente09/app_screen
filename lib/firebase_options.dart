// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyB5vUKhquum97F1Prx0v5TXkHODLd6JdAA',
    appId: '1:10832189466:web:e070515aff3f4a3db8d9a3',
    messagingSenderId: '10832189466',
    projectId: 'aplasta-insectos',
    authDomain: 'aplasta-insectos.firebaseapp.com',
    databaseURL: 'https://aplasta-insectos-default-rtdb.firebaseio.com',
    storageBucket: 'aplasta-insectos.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBgtfbh1XxPK_I9p1i8qw7P4ATEY9hcYfo',
    appId: '1:10832189466:android:311a30d85b23ecc3b8d9a3',
    messagingSenderId: '10832189466',
    projectId: 'aplasta-insectos',
    databaseURL: 'https://aplasta-insectos-default-rtdb.firebaseio.com',
    storageBucket: 'aplasta-insectos.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB5vUKhquum97F1Prx0v5TXkHODLd6JdAA',
    appId: '1:10832189466:web:13d9593ebc17e307b8d9a3',
    messagingSenderId: '10832189466',
    projectId: 'aplasta-insectos',
    authDomain: 'aplasta-insectos.firebaseapp.com',
    databaseURL: 'https://aplasta-insectos-default-rtdb.firebaseio.com',
    storageBucket: 'aplasta-insectos.appspot.com',
  );
}
