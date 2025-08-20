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
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCbW8MMuDEBuesAQ2-OvqqMm9quMKB0a4Y',
    appId: '1:587531440612:web:81dc341ebfefacfec5b7f1',
    messagingSenderId: '587531440612',
    projectId: 'nutrituti',
    authDomain: 'nutrituti.firebaseapp.com',
    storageBucket: 'nutrituti.appspot.com',
    measurementId: 'G-RF53YPFDQ5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDUU1oh_Ee81dArOR12JBp7tj8B6D-cyPU',
    appId: '1:587531440612:android:9f5b3d6ea9510984c5b7f1',
    messagingSenderId: '587531440612',
    projectId: 'nutrituti',
    storageBucket: 'nutrituti.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC2aBYbsYILPbYqcm38vAlYRQQUMdWpZcY',
    appId: '1:587531440612:ios:609814a7da9b74f8c5b7f1',
    messagingSenderId: '587531440612',
    projectId: 'nutrituti',
    storageBucket: 'nutrituti.appspot.com',
    iosClientId:
        '587531440612-r4hj93gq9hp9k7saib5b57kijcng1gir.apps.googleusercontent.com',
    iosBundleId: 'br.com.agrimind.tabelanutricional',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC2aBYbsYILPbYqcm38vAlYRQQUMdWpZcY',
    appId: '1:587531440612:ios:609814a7da9b74f8c5b7f1',
    messagingSenderId: '587531440612',
    projectId: 'nutrituti',
    storageBucket: 'nutrituti.appspot.com',
    iosClientId:
        '587531440612-r4hj93gq9hp9k7saib5b57kijcng1gir.apps.googleusercontent.com',
    iosBundleId: 'br.com.agrimind.tabelanutricional',
  );
}
