import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../firebase_options.dart';

class AppBootstrap {
  const AppBootstrap({
    required this.firebaseReady,
    required this.demoMode,
    this.message,
  });

  final bool firebaseReady;
  final bool demoMode;
  final String? message;

  bool get hasWarning => message != null && message!.isNotEmpty;

  static Future<AppBootstrap> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // The app still runs without local environment overrides.
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      return const AppBootstrap(firebaseReady: true, demoMode: false);
    } catch (error) {
      return AppBootstrap(
        firebaseReady: false,
        demoMode: true,
        message: 'Firebase init failed: $error',
      );
    }
  }

  const AppBootstrap.demo()
    : firebaseReady = false,
      demoMode = true,
      message = null;
}
