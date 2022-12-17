// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options_dev.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    // ignore: missing_enum_constant_in_switch
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
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA7yukFYMIvZw60wCAXk6zDsNKsYwie7qM',
    appId: '1:496690593871:android:de24aece4f9aff1205ea3a',
    messagingSenderId: '496690593871',
    projectId: 'shicolabs-dev',
    databaseURL: 'https://shicolabs-dev.firebaseio.com',
    storageBucket: 'shicolabs-dev.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBV5oYvj9uT7-Vbxt7AkcMq-SN5jC3aUOg',
    appId: '1:496690593871:ios:4274153b504d4d6905ea3a',
    messagingSenderId: '496690593871',
    projectId: 'shicolabs-dev',
    databaseURL: 'https://shicolabs-dev.firebaseio.com',
    storageBucket: 'shicolabs-dev.appspot.com',
    iosClientId: '496690593871-ek0i1r0s6df317dpop3i49r3t7dmmgf3.apps.googleusercontent.com',
    iosBundleId: 'com.gmash.LiveBresto.dev',
  );
}
