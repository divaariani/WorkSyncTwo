// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyC2xvEtA7qOmkptlzQlWfhXZ_D4NpRv6ck',
    appId: '1:867819750191:android:9f912d528a3bf6bc7ad7da',
    messagingSenderId: '867819750191',
    projectId: 'sisap-ptski',
    authDomain: 'sisap-ptski.appspot.com',
    storageBucket: 'sisap-ptski.appspot.com',
    measurementId: 'G-8CGVFBC4GV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDSMCfO05VAAALzhiKOJIK6lbw74pIgF4o',
    appId: '1:58992226470:android:1ffb7858ad4ea387f80467',
    messagingSenderId: '58992226470',
    projectId: 'sisap-ski',
    storageBucket: 'sisap-ski.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA87XmEvRD-Uf20z65alMhdz1YaFrhAQ8E',
    appId: '1:58992226470:ios:bf3064aa82c9d21ef80467',
    messagingSenderId: '58992226470',
    projectId: 'sisap-ski',
    storageBucket: 'sisap-ski.appspot.com',
    iosBundleId: 'com.ski.sisap',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA87XmEvRD-Uf20z65alMhdz1YaFrhAQ8E',
    appId: '1:58992226470:ios:bf3064aa82c9d21ef80467',
    messagingSenderId: '58992226470',
    projectId: 'sisap-ski',
    storageBucket: 'sisap-ski.appspot.com',
    iosBundleId: 'com.ski.sisap.RunnerTests',
  );
}