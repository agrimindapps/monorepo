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
    apiKey: 'AIzaSyBpNH66zlN5aslCFzZI-PVjcC3YK2i6LV0',
    appId: '1:160272216420:web:b7b7f3e318c94107b20a71',
    messagingSenderId: '160272216420',
    projectId: 'compendio-de-racas',
    authDomain: 'compendio-de-racas.firebaseapp.com',
    storageBucket: 'compendio-de-racas.firebasestorage.app',
    measurementId: 'G-5XPCTV6EZX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyANKIv4gps07OmftEDf-XwMHhvu-xreLNk',
    appId: '1:160272216420:android:d6eea68c08fccd9eb20a71',
    messagingSenderId: '160272216420',
    projectId: 'compendio-de-racas',
    storageBucket: 'compendio-de-racas.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAzQH2cZ8ymfGY0ryfqYo4SPFz--2DSbS8',
    appId: '1:160272216420:ios:45e169d2d31c1d0eb20a71',
    messagingSenderId: '160272216420',
    projectId: 'compendio-de-racas',
    storageBucket: 'compendio-de-racas.firebasestorage.app',
    iosBundleId: 'br.com.agrimind.racasdecachorros',
  );

}