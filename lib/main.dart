import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isekai/data/definition/app_mode.dart';
import 'package:isekai/firebase_options_dev.dart' as dev;
import 'package:isekai/firebase_options_emulator.dart' as emulator;
import 'package:isekai/ui/root_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final FirebaseOptions firebaseOptions;
  switch (serverEnv) {
    case ServerEnv.emulator:
      firebaseOptions = emulator.DefaultFirebaseOptions.currentPlatform;
    case ServerEnv.dev:
      firebaseOptions = dev.DefaultFirebaseOptions.currentPlatform;
  }
  await Firebase.initializeApp(options: firebaseOptions);

  if (serverEnv == ServerEnv.emulator) {
    await FirebaseAuth.instance.useAuthEmulator(firebaseEmulatorHost, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(firebaseEmulatorHost, 8080);
  }

  if (isCrashlyticsEnabled) {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  runApp(
    const ProviderScope(
      child: RootApp(),
    ),
  );
}
