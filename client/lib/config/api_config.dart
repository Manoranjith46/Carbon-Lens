import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
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
