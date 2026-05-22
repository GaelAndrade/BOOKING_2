import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    if (Platform.isAndroid) {
      return android;
    }
    if (Platform.isIOS) {
      return ios;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDiLb9ihk_giPXXEqfHFRbUPyckg9-leCQ',
    appId: '1:580542129623:web:5f5e6d7c8a9b0c1d2e3f',
    messagingSenderId: '580542129623',
    projectId: 'tutorial-1baaf',
    authDomain: 'tutorial-1baaf.firebaseapp.com',
    storageBucket: 'tutorial-1baaf.firebasestorage.app',
    measurementId: 'G-XXXXXXXXXX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDiLb9ihk_giPXXEqfHFRbUPyckg9-leCQ',
    appId: '1:580542129623:android:6535376212f19dcd09d792',
    messagingSenderId: '580542129623',
    projectId: 'tutorial-1baaf',
    storageBucket: 'tutorial-1baaf.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDiLb9ihk_giPXXEqfHFRbUPyckg9-leCQ',
    appId: '1:580542129623:ios:REPLACE_WITH_IOS_APP_ID',
    messagingSenderId: '580542129623',
    projectId: 'tutorial-1baaf',
    storageBucket: 'tutorial-1baaf.firebasestorage.app',
    iosClientId:
        '580542129623-qm5nnuf44ubn6ql2na1v4s03ltvmpr68.apps.googleusercontent.com',
  );
}
