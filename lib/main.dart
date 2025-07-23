import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:k_airways_flutter/l10n/app_localizations.dart';
import 'package:k_airways_flutter/providers.dart';
import 'package:k_airways_flutter/services/log_service.dart';
import 'package:k_airways_flutter/utils/theme_provider.dart';
import 'package:k_airways_flutter/utils/router_debugger.dart';
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

    return ErrorBoundary(
      child: MaterialApp.router(
        title: 'Kenya Airways',
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: theme.themeMode,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: _localizationsDelegates,
        supportedLocales: _supportedLocales,
        builder: (context, child) {
          // Now the context here has access to GoRouter
          return DebugOverlay(
            router: router, // Pass router directly
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
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

// Debug Overlay Widget - only shows in debug mode
class DebugOverlay extends ConsumerStatefulWidget {
  final Widget child;
  final GoRouter router; // Accept router directly

  const DebugOverlay({Key? key, required this.child, required this.router})
    : super(key: key);

  @override
  ConsumerState<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends ConsumerState<DebugOverlay> {
  bool _showDebugInfo = false;
  String _currentRoute = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (kDebugMode) {
      _updateCurrentRoute();
    }
  }

  void _updateCurrentRoute() {
    try {
      // Use the router passed as parameter instead of context
      setState(() {
        _currentRoute = widget.router.routeInformationProvider.value.uri
            .toString();
      });
    } catch (e) {
      setState(() {
        _currentRoute = 'Unknown route';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return widget.child;

    return Stack(
      children: [
        widget.child,

        // Debug toggle button
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 10,
          child: FloatingActionButton.small(
            onPressed: () {
              setState(() {
                _showDebugInfo = !_showDebugInfo;
                _updateCurrentRoute();
              });
            },
            backgroundColor: Colors.red,
            child: const Icon(Icons.bug_report, color: Colors.white),
          ),
        ),

        // Debug info panel
        if (_showDebugInfo)
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            right: 10,
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🐛 Debug Info',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Route: $_currentRoute',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Screen: ${MediaQuery.of(context).size.width.toInt()}x${MediaQuery.of(context).size.height.toInt()}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          try {
                            widget.router.go('/debug');
                          } catch (e) {
                            appLogger.error(
                              'Failed to navigate to debug route: $e',
                              'DebugOverlay',
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(80, 32),
                        ),
                        child: const Text(
                          'Debug',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      const SizedBox(width: 4),
                      ElevatedButton(
                        onPressed: () {
                          try {
                            widget.router.go('/');
                          } catch (e) {
                            appLogger.error(
                              'Failed to navigate to home route: $e',
                              'DebugOverlay',
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(60, 32),
                        ),
                        child: const Text(
                          'Home',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Debug utility buttons - now passing router directly
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _buildDebugButton(
                        'Routes',
                        Colors.purple,
                        () => RouterDebugger.debugAllRoutesInRouter(
                          widget.router,
                        ),
                      ),
                      _buildDebugButton(
                        'Auth',
                        Colors.orange,
                        () => RouterDebugger.debugTestAuthStates(ref),
                      ),
                      _buildDebugButton(
                        'Stack',
                        Colors.teal,
                        () => RouterDebugger.debugPrintNavigationStack(
                          widget.router,
                        ),
                      ),
                      _buildDebugButton(
                        'Clear',
                        Colors.red,
                        () => RouterDebugger.debugClearNavigationHistory(
                          widget.router,
                        ),
                      ),
                      _buildDebugButton(
                        'Quick',
                        Colors.indigo,
                        () => RouterDebugger.debugQuickInfo(widget.router, ref),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDebugButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: () {
        try {
          onPressed();
        } catch (e) {
          appLogger.error('Debug button error ($label): $e', 'DebugOverlay');
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(50, 28),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 9, color: Colors.white),
      ),
    );
  }
}

// Error Boundary Widget
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
    