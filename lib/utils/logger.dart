import 'package:flutter/foundation.dart';

class Logger {
static void logInfo(String message) {
    if (kDebugMode) print('[INFO] $message');
  }

  static void logWarning(String message) {
    if (kDebugMode) print('[WARN] $message');
  }

  static void logError(String message) {
    if (kDebugMode) print('[ERROR] $message');
  }

  static void logDebug(String message) {
    if (kDebugMode) print('[DEBUG] $message');

  }

   void error(String message, [StackTrace? stack]) {
    debugPrint('[ERROR] $message\n${stack ?? StackTrace.current}');
  }

  void info(String s, String t) {
    debugPrint('[INFO] $s\n$t');
    }

}
