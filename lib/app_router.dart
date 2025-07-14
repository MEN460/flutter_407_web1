import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/providers.dart';
import 'package:k_airways_flutter/views/auth/login_screen.dart';
import 'package:k_airways_flutter/views/passenger/home_screen.dart';
import 'package:k_airways_flutter/views/admin/dashboard.dart';
import 'package:k_airways_flutter/views/admin/user_management.dart';
import 'package:k_airways_flutter/views/shared/error_fallback.dart';

/// ✅ Define GoRouter with guards and nested routes
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    /// 🏠 Home (Passenger)
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),

    /// 🔐 Login
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

    /// 👨‍💼 Admin Dashboard
    GoRoute(
      path: '/admin-dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
      routes: [
        GoRoute(
          path: 'user-management',
          builder: (context, state) => const UserManagementScreen(),
        ),
        // ✅ Add other nested admin routes here
      ],
    ),

    /// 🛫 Add employee-specific routes later
  ],

  /// ⚠️ Error fallback
  errorBuilder: (context, state) => const ErrorFallbackScreen(),

  /// 🔐 Auth-based redirect logic
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context, listen: false);
    final authState = container.read(authStateProvider);
    final loggedIn = authState.value != null;
    final goingToLogin = state.uri.path == '/login';

    if (!loggedIn && !goingToLogin) {
      return '/login'; // force login if not authenticated
    }
    if (loggedIn && goingToLogin) {
      return '/'; // redirect to home if already logged in
    }
    return null; // no redirect
  },
);
