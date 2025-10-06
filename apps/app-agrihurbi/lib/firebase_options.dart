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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAbxefXQBElRF84GWnTqOroKKhQpDWaj_c',
    appId: '1:68399647443:web:6228c3a94f180e60916226',
    messagingSenderId: '68399647443',
    projectId: 'agrihurbi-firebase',
    authDomain: 'agrihurbi-firebase.firebaseapp.com',
    storageBucket: 'agrihurbi-firebase.firebasestorage.app',
    measurementId: 'G-H8DCELX91Q',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAdBqBkEc-zU9S5eoyESmHn6_-YnBx_BeE',
    appId: '1:68399647443:android:e8d019f4262dbc89916226',
    messagingSenderId: '68399647443',
    projectId: 'agrihurbi-firebase',
    storageBucket: 'agrihurbi-firebase.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCLCC_pxo734IMr8E2EonctkdO4yc98vUc',
    appId: '1:68399647443:ios:d08b01dbe452f2b3916226',
    messagingSenderId: '68399647443',
    projectId: 'agrihurbi-firebase',
    storageBucket: 'agrihurbi-firebase.firebasestorage.app',
    iosBundleId: 'br.com.agrimind.agrihurbi',
  );
}