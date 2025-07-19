import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:k_airways_flutter/l10n/app_localizations.dart';
import 'package:k_airways_flutter/providers.dart';
import 'package:k_airways_flutter/services/log_service.dart';
import 'package:k_airways_flutter/utils/theme_provider.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    appLogger.error('Flutter Error: ${details.exception}', 'Main');
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };
  
  PlatformDispatcher.instance.onError = (error, stack) {
    appLogger.error('Platform Error: $error', 'Main', stackTrace: stack);
    return true;
  };
  
  // Only log in debug mode to avoid sensitive data in production
  if (kDebugMode) {
    developer.log('Starting Kenya Airways App...');
  }
  
  appLogger.info('App started', 'Main');
  
  runApp(const ProviderScope(child: KenyaAirwaysApp()));
}

class KenyaAirwaysApp extends ConsumerWidget {
  const KenyaAirwaysApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Kenya Airways',
      theme: ThemeData.light(
        useMaterial3: true,
      ).copyWith(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: theme.themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('sw'), // Swahili
      ],
      builder: (context, child) {
        // Global error boundary wrapper
        return ErrorBoundary(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool hasError = false;
  Object? error;

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (FlutterErrorDetails details) {
      if (mounted) {
        setState(() {
          hasError = true;
          error = details.exception;
        });
      }
    };
  }

  void _retry() {
    setState(() {
      hasError = false;
      error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Something went wrong',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Error: ${error.toString()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _retry,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}