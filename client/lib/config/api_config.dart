import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  // Set this to false if you want to test against the local server (localhost)
  static bool useProduction = true;

  static String get baseUrl {
    if (useProduction) {
      return 'https://carbon-lens-server-664585468768.asia-south1.run.app';
    }

    if (kIsWeb) {
      return 'http://localhost:5000';
    }
    if (Platform.isAndroid) {
      // 10.0.2.2 is the loopback address of the host machine from the Android emulator
      return 'http://10.0.2.2:5000';
    }
    return 'http://localhost:5000';
  }
}
