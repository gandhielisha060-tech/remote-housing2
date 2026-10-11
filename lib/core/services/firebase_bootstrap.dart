import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseBootstrap {
  const FirebaseBootstrap._();

  static Future<bool> initialize() async {
    try {
      await Firebase.initializeApp();
      return true;
    } on Object catch (error) {
      debugPrint('Firebase is not configured yet: $error');
      return false;
    }
  }
}
