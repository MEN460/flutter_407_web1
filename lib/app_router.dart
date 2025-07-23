import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/models/user.dart';
import 'package:k_airways_flutter/providers.dart';
import 'package:k_airways_flutter/utils/router_debugger.dart';

/// Main router configuration for the Kenya Airways app
class AppRouter {
  static GoRouter createRouter(Ref ref) {
    return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: kDebugMode,

      // Authentication state listener
      refreshListenable: _AuthStateListenable(ref),

      // Route definitions
      routes: _buildRoutes(),

      // Global redirect handler
      redirect: (context, state) => _handleRedirect(ref, context, state),

      // Error page builder
      errorBuilder: (context, state) => _ErrorPage(
        error: state.error,
        location: state.matchedLocation,
        pathParameters: state.pathParameters,
        queryParameters: state.uri.queryParameters,
      ),

      // Debug navigation observer
      observers: kDebugMode ? [_DebugNavigatorObserver()] : [],
    );
  }


  /// Build all application routes
  static List<RouteBase> _buildRoutes() {
    return [
      // Loading route
      GoRoute(
        path: '/loading',
        name: 'loading',
        builder: (context, state) => const _LoadingPage(),
      ),

      // Debug route (only in debug mode)
      if (kDebugMode)
        GoRoute(
          path: '/debug',
          name: 'debug',
          redirect: (context, state) {
            // Only allow in debug builds
            if (!kDebugMode) return '/';
            return null;
          },
          builder: (context, state) => const _DebugRoutingScreen(),
        ),

      // Home route
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const _HomePage(),
      ),

      // Authentication routes with custom transitions
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const _LoginPage(),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
              ),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: '/register',
        name: 'register',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const _RegisterPage(),
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // Role-based protected routes (flattened structure)
      GoRoute(
        path: '/admin/dashboard',
        name: 'admin-dashboard',
        redirect: (context, state) =>
            _requireRole(context, state, UserRole.admin),
        builder: (context, state) => const _AdminDashboard(),
      ),

      GoRoute(
        path: '/employee/dashboard',
        name: 'employee-dashboard',
        redirect: (context, state) =>
            _requireRole(context, state, UserRole.employee),
        builder: (context, state) => const _EmployeeDashboard(),
      ),

      // Customer routes
      GoRoute(
        path: '/flight/search',
        name: 'flight-search',
        builder: (context, state) => const _FlightSearchPage(),
      ),

      GoRoute(
        path: '/bookings',
        name: 'bookings',
        redirect: (context, state) =>
            _requireRole(context, state, UserRole.customer),
        builder: (context, state) => const _BookingsPage(),
      ),

      GoRoute(
        path: '/settings',
        name: 'settings',
        redirect: (context, state) =>
            _requireRole(context, state, UserRole.customer),
        builder: (context, state) => const _SettingsPage(),
      ),

      GoRoute(
        path: '/help',
        name: 'help',
        builder: (context, state) => const _HelpPage(),
      ),
    ];
  }

  /// Main redirect handler
  static String? _handleRedirect(
    Ref ref,
    BuildContext context,
    GoRouterState state,
  ) {
    if (kDebugMode) {
      _logRedirectAttempt(state);
    }

    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => _handleLoadingState(state),
      error: (error, stackTrace) => _handleAuthError(state, error),
      data: (user) => _handleUserRedirect(user, state),
    );
  }

  /// Log redirect attempts for debugging
  static void _logRedirectAttempt(GoRouterState state) {
    debugPrint('🔍 REDIRECT CHECK:');
    debugPrint('  📍 Location: ${state.matchedLocation}');
    debugPrint('  📍 Full Path: ${state.fullPath}');
    debugPrint('  📍 Name: ${state.name}');
    debugPrint('  📋 Path Params: ${state.pathParameters}');
    debugPrint('  📋 Query Params: ${state.uri.queryParameters}');
    debugPrint('  📋 Extra: ${state.extra?.runtimeType}');
    debugPrint('  🕒 Timestamp: ${DateTime.now().toIso8601String()}');
  }

  /// Handle loading authentication state
  static String? _handleLoadingState(GoRouterState state) {
    if (kDebugMode) {
      debugPrint('  🔄 Auth State: LOADING');
    }

    // Show loading screen for protected routes
    final protectedRoutes = [
      '/admin/dashboard',
      '/employee/dashboard',
      '/bookings',
      '/settings',
    ];
    final isProtectedRoute = protectedRoutes.any(
      (route) => state.matchedLocation.startsWith(route),
    );

    return isProtectedRoute ? '/loading' : null;
  }

  /// Handle authentication errors
  static String? _handleAuthError(GoRouterState state, Object error) {
    if (kDebugMode) {
      debugPrint('  ❌ Auth State: ERROR - $error');
    }

    // Redirect to login if accessing protected routes
    final protectedRoutes = [
      '/admin/dashboard',
      '/employee/dashboard',
      '/bookings',
      '/settings',
    ];
    final isProtectedRoute = protectedRoutes.any(
      (route) => state.matchedLocation.startsWith(route),
    );

    return isProtectedRoute ? '/login' : null;
  }

  /// Handle user-specific redirects
  static String? _handleUserRedirect(User? user, GoRouterState state) {
    if (kDebugMode) {
      debugPrint('  ✅ Auth State: DATA');
      debugPrint('  👤 User: ${user?.email ?? 'null'}');
    }

    final location = state.matchedLocation;

    // Redirect authenticated users away from auth pages
    if (user != null && (location == '/login' || location == '/register')) {
      return _getDefaultRouteForUser(user);
    }

    return null;
  }

  /// Get default route based on user role
  static String _getDefaultRouteForUser(User user) {
    switch (user.role) {
      case UserRole.admin:
        return '/admin/dashboard';
      case UserRole.employee:
        return '/employee/dashboard';
      case UserRole.customer:
      default:
        return '/';
    }
  }

  /// Check if user has required role for a route
  static String? _requireRole(
    BuildContext context,
    GoRouterState state,
    UserRole requiredRole,
  ) {
    // Get auth state from context
    final container = ProviderScope.containerOf(context);
    final authState = container.read(authStateProvider);

    return authState.when(
      loading: () => '/loading',
      error: (_, __) => '/login',
      data: (user) {
        if (user == null) return '/login';
        if (user.role != requiredRole) {
          return '/'; // Redirect to home if insufficient privileges
        }
        return null; // Allow access
      },
    );
  }
}

/// Authentication state listener for GoRouter
class _AuthStateListenable extends ChangeNotifier {
  final Ref _ref;
  ProviderSubscription? _subscription;
  bool _disposed = false;

  _AuthStateListenable(this._ref) {
    try {
      _subscription = _ref.listen<AsyncValue<User?>>(authStateProvider, (
        previous,
        next,
      ) {
        if (!_disposed) notifyListeners();
      });
    } catch (e) {
      debugPrint('Error setting up auth listener: $e');
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.close();
    super.dispose();
  }
}

/// Debug navigation observer
class _DebugNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('📱 NAVIGATION: didPush');
    debugPrint('  ➡️  New: ${route.settings.name}');
    debugPrint('  ⬅️  Previous: ${previousRoute?.settings.name ?? 'none'}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('📱 NAVIGATION: didPop');
    debugPrint('  ⬅️  Popped: ${route.settings.name}');
    debugPrint('  ➡️  Returned to: ${previousRoute?.settings.name ?? 'none'}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    debugPrint('📱 NAVIGATION: didReplace');
    debugPrint('  🔄 Old: ${oldRoute?.settings.name ?? 'none'}');
    debugPrint('  🔄 New: ${newRoute?.settings.name ?? 'none'}');
  }
}

/// Error page widget
class _ErrorPage extends StatelessWidget {
  final Object? error;
  final String location;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;

  const _ErrorPage({
    required this.error,
    required this.location,
    required this.pathParameters,
    required this.queryParameters,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              const Text(
                'Page Not Found',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'The page you\'re looking for doesn\'t exist.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 16),
                Card(
                  color: Colors.grey[100],
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Debug Info:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Error: $error'),
                        Text('Location: $location'),
                        if (pathParameters.isNotEmpty)
                          Text('Path Params: $pathParameters'),
                        if (queryParameters.isNotEmpty)
                          Text('Query Params: $queryParameters'),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Go Home'),
                  ),
                  if (context.canPop()) ...[
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Go Back'),
                    ),
                  ],
                  const SizedBox(width: 16),
                  // Retry button
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go(location);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
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

/// Loading page widget
class _LoadingPage extends StatelessWidget {
  const _LoadingPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text('Loading...', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

/// Debug routing screen
class _DebugRoutingScreen extends StatefulWidget {
  const _DebugRoutingScreen();

  @override
  State<_DebugRoutingScreen> createState() => _DebugRoutingScreenState();
}

class _DebugRoutingScreenState extends State<_DebugRoutingScreen> {
  final TextEditingController _routeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Route Debugger'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentLocationInfo(),
            const SizedBox(height: 16),
            _buildNavigationTester(),
            const SizedBox(height: 16),
            _buildQuickNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLocationInfo() {
    final router = GoRouter.of(context);
    final location = router.routeInformationProvider.value.uri.toString();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📍 Current Location',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(location),
            const SizedBox(height: 8),
            Text('Can Pop: ${router.canPop()}'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationTester() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🧪 Navigation Tester',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _routeController,
              decoration: const InputDecoration(
                labelText: 'Route Path',
                hintText: '/admin/dashboard',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _testNavigation(isGo: true),
                  child: const Text('GO'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _testNavigation(isGo: false),
                  child: const Text('PUSH'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickNavigation() {
    final routes = [
      ('Home', '/'),
      ('Login', '/login'),
      ('Register', '/register'),
      ('Admin Dashboard', '/admin/dashboard'),
      ('Employee Dashboard', '/employee/dashboard'),
      ('Flight Search', '/flight/search'),
      ('Bookings', '/bookings'),
      ('Settings', '/settings'),
      ('Help', '/help'),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚡ Quick Navigation',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: routes.map((route) {
                return ElevatedButton(
                  onPressed: () => _navigateToRoute(route.$2),
                  child: Text(route.$1),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _testNavigation({required bool isGo}) {
    final route = _routeController.text.trim();
    if (route.isEmpty) return;

    try {
      if (isGo) {
        context.go(route);
      } else {
        context.push(route);
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Navigation successful: $route')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Navigation failed: $e')));
    }
  }

  void _navigateToRoute(String route) {
    try {
      context.go(route);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Navigation failed: $e')));
    }
  }
}

// Placeholder widgets for the routes
class _HomePage extends StatelessWidget {
  const _HomePage();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Home Page')));
}

class _LoginPage extends StatelessWidget {
  const _LoginPage();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Login Page')));
}

class _RegisterPage extends StatelessWidget {
  const _RegisterPage();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Register Page')));
}

class _AdminDashboard extends StatelessWidget {
  const _AdminDashboard();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Admin Dashboard')));
}

class _EmployeeDashboard extends StatelessWidget {
  const _EmployeeDashboard();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Employee Dashboard')));
}

class _FlightSearchPage extends StatelessWidget {
  const _FlightSearchPage();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Flight Search Page')));
}

class _BookingsPage extends StatelessWidget {
  const _BookingsPage();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Bookings Page')));
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Settings Page')));
}

class _HelpPage extends StatelessWidget {
  const _HelpPage();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Help Page')));
}

// Enum for user roles (you'll need to define this in your models)
enum UserRole { admin, employee, customer }
