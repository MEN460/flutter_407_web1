import 'package:flutter/foundation.dart';
import 'package:k_airways_flutter/constants/api_endpoints.dart';
import 'package:k_airways_flutter/services/api_service.dart';

enum LogLevel { debug, info, warning, error, critical }

class LogService {
  final ApiService _api;

  LogService(this._api);

  /// Fetch system logs (admin-only route in Flask)
  Future<List<Map<String, dynamic>>> getSystemLogs() async {
    final response = await _api.get(ApiEndpoints.adminSystemLogs);
    return List<Map<String, dynamic>>.from(response.data);
  }
}

class Logger {
  final ApiService? _api;
  final bool _enableRemoteLogging;

  Logger({ApiService? api, bool enableRemoteLogging = false})
    : _api = api,
      _enableRemoteLogging = enableRemoteLogging;

  void log(String message, LogLevel level, [String? context]) {
    final formattedMessage = _formatMessage(message, level, context);

    // Always log to console in debug mode
    if (kDebugMode) {
      debugPrint(formattedMessage);
    }

    // Send to remote server if enabled and severity >= warning
    if (_enableRemoteLogging &&
        _api != null &&
        level.index >= LogLevel.warning.index) {
      _sendToServer(message, level, context);
    }
  }

  String _formatMessage(String message, LogLevel level, [String? context]) {
    final prefix = _getLevelPrefix(level);
    final time = DateTime.now().toIso8601String();
    final contextPart = context != null ? '[$context]' : '';
    return '$time $prefix$contextPart: $message';
  }

  String _getLevelPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🐛 DEBUG';
      case LogLevel.info:
        return 'ℹ️ INFO';
      case LogLevel.warning:
        return '⚠️ WARN';
      case LogLevel.error:
        return '⛔ ERROR';
      case LogLevel.critical:
        return '🔥 CRITICAL';
    }
  }

  Future<void> _sendToServer(
    String message,
    LogLevel level, [
    String? context,
  ]) async {
    try {
      await _api?.post(
        ApiEndpoints.adminLogs, // Use centralized endpoint
        data: {
          'message': message,
          'level': level.name.toUpperCase(),
          'context': context,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Failed to send log to server: $e');
    }
  }

  // Convenience methods
  void debug(String message, [String? context]) =>
      log(message, LogLevel.debug, context);

  void info(String message, [String? context]) =>
      log(message, LogLevel.info, context);

  void warning(String message, [String? context]) =>
      log(message, LogLevel.warning, context);

  void error(String message, [String? context]) =>
      log(message, LogLevel.error, context);

  void critical(String message, [String? context]) =>
      log(message, LogLevel.critical, context);
}

/// 🌍 Global logger instance for app-wide usage
final appLogger = Logger(enableRemoteLogging: true);
