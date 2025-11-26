import 'package:core/core.dart' show FirebaseOptions;
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
    apiKey: 'AIzaSyAbImRXfyz39ThgSCBe9rVI8iq4acyTTaU',
    appId: '1:378904707318:web:69498a7e6613b714a4ecd7',
    messagingSenderId: '378904707318',
    projectId: 'calcagro-2d6d8',
    authDomain: 'calcagro-2d6d8.firebaseapp.com',
    storageBucket: 'calcagro-2d6d8.appspot.com',
    measurementId: 'G-Y07M3TSD0X',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAcLZGM_eWlbam_L6T9ZcsUFFvgC-HU-XI',
    appId: '1:378904707318:android:db4078485bc933aaa4ecd7',
    messagingSenderId: '378904707318',
    projectId: 'calcagro-2d6d8',
    storageBucket: 'calcagro-2d6d8.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAXyCF4XZ32F9SA7rkX3pz9VAbp09Ct4zU',
    appId: '1:378904707318:ios:2ed8a511e4b99525a4ecd7',
    messagingSenderId: '378904707318',
    projectId: 'calcagro-2d6d8',
    storageBucket: 'calcagro-2d6d8.appspot.com',
    iosBundleId: 'br.com.agrimind.calculadoraagronomica',
  );

}