import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../config/firebase_config.dart';

class FirebaseInit {
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: FirebaseConfig.webApiKey,
          appId: FirebaseConfig.appId,
          messagingSenderId: FirebaseConfig.projectNumber,
          projectId: FirebaseConfig.projectId,
          storageBucket: '${FirebaseConfig.projectId}.appspot.com',
        ),
      );

      if (kDebugMode) {
        print('Firebase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize Firebase: $e');
      }
      rethrow;
    }
  }
}
