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
    apiKey: 'AIzaSyAKo5dxVHE2JJTGJYBcvBzA8u5NOf9XQQk',
    appId: '1:317022121600:web:6756bcf856c110cdba4065',
    messagingSenderId: '317022121600',
    projectId: 'receituagronew',
    authDomain: 'receituagronew.firebaseapp.com',
    databaseURL: 'https://receituagronew-default-rtdb.firebaseio.com',
    storageBucket: 'receituagronew.appspot.com',
    measurementId: 'G-80HVTELSK5',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAdheXkyjRAbaLdhbl2cOdSYakBRzCYkRw',
    appId: '1:317022121600:android:72d5ac91f2e92014ba4065',
    messagingSenderId: '317022121600',
    projectId: 'receituagronew',
    databaseURL: 'https://receituagronew-default-rtdb.firebaseio.com',
    storageBucket: 'receituagronew.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDSe-fGLxn320vyDdss7th9glJYMOUc3RU',
    appId: '1:317022121600:ios:a33f2f63356f5563ba4065',
    messagingSenderId: '317022121600',
    projectId: 'receituagronew',
    databaseURL: 'https://receituagronew-default-rtdb.firebaseio.com',
    storageBucket: 'receituagronew.appspot.com',
    iosClientId:
        '317022121600-6j3a7bd3gju7sjnj2h504hja9larrjvn.apps.googleusercontent.com',
    iosBundleId: 'br.com.agrimind.pragassoja',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDSe-fGLxn320vyDdss7th9glJYMOUc3RU',
    appId: '1:317022121600:ios:a33f2f63356f5563ba4065',
    messagingSenderId: '317022121600',
    projectId: 'receituagronew',
    databaseURL: 'https://receituagronew-default-rtdb.firebaseio.com',
    storageBucket: 'receituagronew.appspot.com',
    iosClientId:
        '317022121600-6j3a7bd3gju7sjnj2h504hja9larrjvn.apps.googleusercontent.com',
    iosBundleId: 'br.com.agrimind.pragassoja',
  );
}
