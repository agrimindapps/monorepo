// Package imports:
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
        return android;
      case TargetPlatform.iOS:
        return ios;
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
    projectId: 'gasometer-12c83',
    authDomain: 'gasometer-12c83.firebaseapp.com',
    storageBucket: 'gasometer-12c83.firebasestorage.app',
    measurementId: 'G-H8DCELX91Q',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAdBqBkEc-zU9S5eoyESmHn6_-YnBx_BeE',
    appId: '1:68399647443:android:b9ab1951c1ac0552916226',
    messagingSenderId: '68399647443',
    projectId: 'gasometer-12c83',
    storageBucket: 'gasometer-12c83.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCLCC_pxo734IMr8E2EonctkdO4yc98vUc',
    appId: '1:68399647443:ios:20959311a7140d18916226',
    messagingSenderId: '68399647443',
    projectId: 'gasometer-12c83',
    storageBucket: 'gasometer-12c83.firebasestorage.app',
    iosBundleId: 'br.com.agrimind.winfinancas',
  );
}
