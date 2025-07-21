import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:k_airways_flutter/l10n/app_localizations.dart';
import 'package:k_airways_flutter/providers.dart';
import 'package:k_airways_flutter/services/log_service.dart';
import 'package:k_airways_flutter/utils/theme_provider.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _setupErrorHandling();

  if (kDebugMode) {
    developer.log('Starting Kenya Airways App...');
  }

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  appLogger.info('App started', 'Main');

  runApp(const ProviderScope(child: KenyaAirwaysApp()));
}

/// Sets up global error handling for the application
Future<void> _setupErrorHandling() async {
  // Handle Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    final errorMessage = 'Flutter Error: ${details.exception}';
    final stackTrace = details.stack?.toString() ?? 'No stack trace available';

    appLogger.error('$errorMessage\nStack trace: $stackTrace', 'Main');

    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };

  // Handle platform/native errors
  PlatformDispatcher.instance.onError = (error, stack) {
    final errorMessage = 'Platform Error: $error';
    final stackTrace = stack.toString();

    appLogger.error('$errorMessage\nStack trace: $stackTrace', 'Main');
    return true;
  };
}

class KenyaAirwaysApp extends ConsumerWidget {
  const KenyaAirwaysApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Kenya Airways',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: theme.themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: _localizationsDelegates,
      supportedLocales: _supportedLocales,
      builder: (context, child) {
        return ErrorBoundary(child: child ?? const SizedBox.shrink());
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData.light(useMaterial3: true).copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1E3A8A),
        brightness: Brightness.light,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData.dark(useMaterial3: true).copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1E3A8A),
        brightness: Brightness.dark,
      ),
    );
  }

  static const List<LocalizationsDelegate<dynamic>> _localizationsDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> _supportedLocales = [Locale('en'), Locale('sw')];
}

class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _setupErrorBoundary();
  }

  void _setupErrorBoundary() {
    FlutterError.onError = (FlutterErrorDetails details) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _hasError = true;
              _error = details.exception;
            });
          }
        });

        appLogger.error(
          'ErrorBoundary caught: ${details.exception}\n'
              'Stack trace: ${details.stack}',
          'ErrorBoundary',
        );
      }
    };
  }

  void _retry() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _hasError = false;
          _error = null;
        });
      });

      appLogger.info(
        'User initiated retry from error boundary',
        'ErrorBoundary',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return MaterialApp(
        title: 'Kenya Airways - Error',
        theme: ThemeData.light(useMaterial3: true),
        home: _buildErrorScreen(),
        debugShowCheckedModeBanner: false,
      );
    }

    return widget.child;
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red[400],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'We encountered an unexpected error. Please try again or contact support if the problem persists.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              if (kDebugMode && _error != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Debug Info:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _error.toString(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'monospace',
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        appLogger.info(
                          'User requested help from error screen',
                          'ErrorBoundary',
                        );
                      },
                      child: const Text('Get Help'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _retry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Try Again'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
