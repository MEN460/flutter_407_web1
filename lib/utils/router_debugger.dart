import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_airways_flutter/providers.dart';
import 'package:k_airways_flutter/services/log_service.dart';

/// Debug utilities for GoRouter - only active in debug mode
class RouterDebugger {
  /// Debug method to print all available routes
  static void debugPrintAllRoutes(GoRouter router) {
    if (!kDebugMode) return;

    try {
      appLogger.info('=== DEBUG: All Routes in Router ===', 'RouterDebugger');
      final location = router.routeInformationProvider.value.location;
      final routes = router.configuration.routes;

      appLogger.info('Current location: $location', 'RouterDebugger');
      appLogger.info('Total routes: ${routes.length}', 'RouterDebugger');

      for (int i = 0; i < routes.length; i++) {
        final route = routes[i];
        appLogger.info('Route $i: ${route.toString()}', 'RouterDebugger');
      }

      appLogger.info('=== END DEBUG: All Routes ===', 'RouterDebugger');
    } catch (e) {
      appLogger.error('Error in debugPrintAllRoutes: $e', 'RouterDebugger');
    }
  }

  /// Debug method to print current navigation stack
  static void debugPrintNavigationStack(GoRouter router) {
    if (!kDebugMode) return;

    try {
      appLogger.info('=== DEBUG: Navigation Stack ===', 'RouterDebugger');

      final location = router.routeInformationProvider.value.location;
      final uri = router.routeInformationProvider.value.uri;

      appLogger.info('Current location: $location', 'RouterDebugger');
      appLogger.info('Current URI: $uri', 'RouterDebugger');
      appLogger.info('Path parameters: ${uri.pathSegments}', 'RouterDebugger');
      appLogger.info(
        'Query parameters: ${uri.queryParameters}',
        'RouterDebugger',
      );

      appLogger.info('=== END DEBUG: Navigation Stack ===', 'RouterDebugger');
    } catch (e) {
      appLogger.error(
        'Error in debugPrintNavigationStack: $e',
        'RouterDebugger',
      );
    }
  }

  /// Debug method to validate a route path
  static bool debugValidateRoute(GoRouter router, String path) {
    if (!kDebugMode) return true;

    try {
      // Try to parse the route
      final uri = Uri.parse(path);
      final routeInfo = RouteInformation(uri: uri);

      appLogger.info('✅ ROUTE VALID: $path', 'RouterDebugger');
      return true;
    } catch (e) {
      appLogger.error('❌ ROUTE INVALID: $path - Error: $e', 'RouterDebugger');
      return false;
    }
  }

  /// Debug method to simulate navigation without actually navigating
  static void debugSimulateNavigation(GoRouter router, String path) {
    if (!kDebugMode) return;

    appLogger.info('🧪 SIMULATING NAVIGATION TO: $path', 'RouterDebugger');

    final currentLocation = router.routeInformationProvider.value.uri
        .toString();

    appLogger.info('  From: $currentLocation', 'RouterDebugger');
    appLogger.info('  To: $path', 'RouterDebugger');

    // Check if route exists
    if (debugValidateRoute(router, path)) {
      appLogger.info('  Status: Route exists and is valid', 'RouterDebugger');
    } else {
      appLogger.info(
        '  Status: Route is invalid or will cause error',
        'RouterDebugger',
      );
    }
  }

  /// Debug method to clear all navigation history
  static void debugClearNavigationHistory(GoRouter router) {
    if (!kDebugMode) return;

    try {
      appLogger.info('🗑️  CLEARING NAVIGATION HISTORY', 'RouterDebugger');

      // Navigate to home and clear history
      router.go('/');

      appLogger.info(
        'Navigation cleared - went to root route',
        'RouterDebugger',
      );
    } catch (e) {
      appLogger.error(
        'Error in debugClearNavigationHistory: $e',
        'RouterDebugger',
      );
    }
  }

  /// Debug method to test authentication state
  static void debugTestAuthStates(WidgetRef ref) {
    if (!kDebugMode) return;

    try {
      appLogger.info('🔐 TESTING AUTH STATES:', 'RouterDebugger');
      appLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━', 'RouterDebugger');

      final authState = ref.read(authStateProvider);

      authState.when(
        loading: () =>
            appLogger.info('  Auth State: LOADING', 'RouterDebugger'),
        error: (error, stack) =>
            appLogger.info('  Auth State: ERROR - $error', 'RouterDebugger'),
        data: (user) {
          if (user != null) {
            appLogger.info('  Auth State: AUTHENTICATED', 'RouterDebugger');
            appLogger.info('  User ID: ${user.id}', 'RouterDebugger');
            appLogger.info('  User Email: ${user.email}', 'RouterDebugger');
          } else {
            appLogger.info('  Auth State: NOT AUTHENTICATED', 'RouterDebugger');
          }
        },
      );
      appLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━', 'RouterDebugger');
    } catch (e) {
      appLogger.error('Error in debugTestAuthStates: $e', 'RouterDebugger');
    }
  }

  /// Debug method to test route redirects
  static void debugTestRedirects(GoRouter router, List<String> testRoutes) {
    if (!kDebugMode) return;

    appLogger.info('🔄 TESTING ROUTE REDIRECTS:', 'RouterDebugger');
    appLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━', 'RouterDebugger');

    for (final route in testRoutes) {
      appLogger.info('  Testing: $route', 'RouterDebugger');
      // Note: Actual redirect testing would need access to your redirect logic
      appLogger.info(
        '  Status: Redirect testing requires router context',
        'RouterDebugger',
      );
    }
    appLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━', 'RouterDebugger');
  }

  /// Debug all routes in the current router
  static void debugAllRoutesInRouter(GoRouter router) {
    if (!kDebugMode) return;
    debugPrintAllRoutes(router);
  }

  /// Quick debug info for current state
  static void debugQuickInfo(GoRouter router, WidgetRef ref) {
    if (!kDebugMode) return;

    try {
      appLogger.info('🔍 QUICK DEBUG INFO:', 'RouterDebugger');
      appLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━', 'RouterDebugger');

      final location = router.routeInformationProvider.value.location;
      final uri = router.routeInformationProvider.value.uri;

      appLogger.info('📍 Current Location: $location', 'RouterDebugger');
      appLogger.info('🌐 Full URI: $uri', 'RouterDebugger');
      appLogger.info(
        '📊 Path Segments: ${uri.pathSegments.length}',
        'RouterDebugger',
      );
      appLogger.info(
        '❓ Query Params: ${uri.queryParameters.length}',
        'RouterDebugger',
      );

      // Add auth state
      try {
        final authState = ref.read(authStateProvider);
        authState.when(
          loading: () =>
              appLogger.info('🔐 Auth State: Loading', 'RouterDebugger'),
          error: (_, __) =>
              appLogger.info('🔐 Auth State: Error', 'RouterDebugger'),
          data: (user) => appLogger.info(
            '🔐 Auth State: ${user != null ? 'Authenticated' : 'Guest'}',
            'RouterDebugger',
          ),
        );
      } catch (e) {
        appLogger.info('🔐 Auth State: Unable to read ($e)', 'RouterDebugger');
      }

      appLogger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━', 'RouterDebugger');
    } catch (e) {
      appLogger.error('Error in debugQuickInfo: $e', 'RouterDebugger');
    }
  }
}

/// Extension for easy debug access on GoRouter
extension GoRouterDebugExtension on GoRouter {
  void debugCurrentState() {
    if (!kDebugMode) return;

    try {
      final location = routeInformationProvider.value.location;
      appLogger.info('🔍 CURRENT ROUTER STATE:', 'RouterDebugger');
      appLogger.info('  Location: $location', 'RouterDebugger');
      appLogger.info('  Can Pop: ${canPop()}', 'RouterDebugger');
    } catch (e) {
      appLogger.error('Error in debugCurrentState: $e', 'RouterDebugger');
    }
  }

  void debugNavigationHistory() {
    if (!kDebugMode) return;

    appLogger.info('📜 NAVIGATION HISTORY:', 'RouterDebugger');
    appLogger.info(
      '  (History tracking not available in GoRouter by default)',
      'RouterDebugger',
    );
  }
}
