import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:k_airways_flutter/l10n/app_localizations.dart';
import 'package:k_airways_flutter/app_router.dart';
import 'package:k_airways_flutter/services/log_service.dart';
import 'package:k_airways_flutter/utils/theme_provider.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  developer.log('Starting Kenya Airways App...');
  appLogger.info('App started', 'Main');
  runApp(const ProviderScope(child: KenyaAirwaysApp()));
}

class KenyaAirwaysApp extends ConsumerWidget {
  const KenyaAirwaysApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final router = buildAppRouter(ref);

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
    );
  }
}
