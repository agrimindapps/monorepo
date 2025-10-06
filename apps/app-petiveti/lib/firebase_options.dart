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
    apiKey: 'AIzaSyAelydNE5UxgLC0Vr1moK-FRs5tBcusvhk',
    appId: '1:552417998440:web:74eb360b86da8a98d36ddd',
    messagingSenderId: '552417998440',
    projectId: 'calculei-52e71',
    authDomain: 'calculei-52e71.firebaseapp.com',
    storageBucket: 'calculei-52e71.firebasestorage.app',
    measurementId: 'G-FSBN29NSHC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB5YiNGjFwu5r71u6a2jXOQTGsw1jsrHYk',
    appId: '1:552417998440:android:7dec9c69def30940d36ddd',
    messagingSenderId: '552417998440',
    projectId: 'calculei-52e71',
    storageBucket: 'calculei-52e71.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBQsXkFoLVLisS6Ja_8C5ZukLPRi6sEh-g',
    appId: '1:552417998440:ios:66c575640f9d394ed36ddd',
    messagingSenderId: '552417998440',
    projectId: 'calculei-52e71',
    storageBucket: 'calculei-52e71.firebasestorage.app',
    iosBundleId: 'br.com.agrimind.petiveti',
  );
}