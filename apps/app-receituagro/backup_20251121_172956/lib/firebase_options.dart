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
    apiKey: 'AIzaSyAKo5dxVHE2JJTGJYBcvBzA8u5NOf9XQQk',
    appId: '1:317022121600:web:6756bcf856c110cdba4065',
    messagingSenderId: '317022121600',
    projectId: 'receituagronew',
    authDomain: 'receituagronew.firebaseapp.com',
    databaseURL: 'https://receituagronew-default-rtdb.firebaseio.com',
    storageBucket: 'receituagronew.firebasestorage.app',
    measurementId: 'G-80HVTELSK5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAdheXkyjRAbaLdhbl2cOdSYakBRzCYkRw',
    appId: '1:317022121600:android:952007ab6c04a8d3ba4065',
    messagingSenderId: '317022121600',
    projectId: 'receituagronew',
    databaseURL: 'https://receituagronew-default-rtdb.firebaseio.com',
    storageBucket: 'receituagronew.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDSe-fGLxn320vyDdss7th9glJYMOUc3RU',
    appId: '1:317022121600:ios:f4b7f2b0557b2bb5ba4065',
    messagingSenderId: '317022121600',
    projectId: 'receituagronew',
    databaseURL: 'https://receituagronew-default-rtdb.firebaseio.com',
    storageBucket: 'receituagronew.firebasestorage.app',
    iosBundleId: 'com.example.appReceituagro',
  );
}
