import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyDhfNcx1cu8UvSzYtgA5nbeKGu23lFwou8',
    appId: '1:660468746247:web:ea80812cab4f9f204682a2',
    messagingSenderId: '660468746247',
    projectId: 'termos-tecnicos',
    authDomain: 'termos-tecnicos.firebaseapp.com',
    storageBucket: 'termos-tecnicos.appspot.com',
    measurementId: 'G-DZ3VXWSJ1J',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCYXFJ3fBtNBcMy2ij484nB3TteJsYOtCY',
    appId: '1:660468746247:android:70add83e32b21ccf4682a2',
    messagingSenderId: '660468746247',
    projectId: 'termos-tecnicos',
    storageBucket: 'termos-tecnicos.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBxvPEvnxes8aXxXajWhEHAbpOC9_Z8pEY',
    appId: '1:660468746247:ios:ac17a8136ff6b6444682a2',
    messagingSenderId: '660468746247',
    projectId: 'termos-tecnicos',
    storageBucket: 'termos-tecnicos.appspot.com',
    iosClientId: '660468746247-o63krfuej6tr7joum7cdat1b1vddqh04.apps.googleusercontent.com',
    iosBundleId: 'br.com.agrimind.dicionariomedico',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBxvPEvnxes8aXxXajWhEHAbpOC9_Z8pEY',
    appId: '1:660468746247:ios:ac17a8136ff6b6444682a2',
    messagingSenderId: '660468746247',
    projectId: 'termos-tecnicos',
    storageBucket: 'termos-tecnicos.appspot.com',
    iosClientId: '660468746247-o63krfuej6tr7joum7cdat1b1vddqh04.apps.googleusercontent.com',
    iosBundleId: 'br.com.agrimind.dicionariomedico',
  );
}
