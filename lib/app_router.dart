import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_airways_flutter/models/flight.dart';
import 'package:k_airways_flutter/models/user.dart';
import 'package:k_airways_flutter/providers.dart';
import 'package:k_airways_flutter/views/admin/dashboard.dart';
import 'package:k_airways_flutter/views/admin/flight_manage.dart';
import 'package:k_airways_flutter/views/admin/passenger_list.dart';
import 'package:k_airways_flutter/views/admin/reports.dart';
import 'package:k_airways_flutter/views/admin/system_logs.dart';
import 'package:k_airways_flutter/views/admin/user_management.dart';
import 'package:k_airways_flutter/views/auth/login_screen.dart';
import 'package:k_airways_flutter/views/auth/register_screen.dart';
import 'package:k_airways_flutter/views/employee/booking_inquiry.dart';
import 'package:k_airways_flutter/views/employee/check_in.dart';
import 'package:k_airways_flutter/views/employee/dashboard.dart';
import 'package:k_airways_flutter/views/employee/flight_operations.dart';
import 'package:k_airways_flutter/views/employee/passenger_lookup.dart';
import 'package:k_airways_flutter/views/passenger/home_screen.dart';
import 'package:k_airways_flutter/views/shared/error_fallback.dart';
import 'package:k_airways_flutter/views/shared/unauthorized_screen.dart';

class AppRouter {
  static GoRouter createRouter(Ref ref) {
    return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: _AuthStateListenable(ref),
      routes: _buildRoutes(),
      redirect: (context, state) => _handleRedirect(ref, context, state),
      errorBuilder: (context, state) => ErrorFallbackScreen(
        error: state.error?.toString() ?? 'Unknown error occurred',
      ),
    );
  }

  static List<RouteBase> _buildRoutes() {
    return [
      // 🌐 Public Routes
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // 👑 Admin Routes - Always defined, access controlled via redirect
      GoRoute(
        path: '/admin-dashboard',
        name: 'admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'user-management',
            name: 'admin-user-management',
            builder: (context, state) => const UserManagementScreen(),
          ),
          GoRoute(
            path: 'flight-management',
            name: 'admin-flight-management',
            builder: (context, state) => const FlightManagementScreen(),
          ),
          GoRoute(
            path: 'passenger-list',
            name: 'admin-passenger-list',
            builder: (context, state) => const PassengerListScreen(),
          ),
          GoRoute(
            path: 'reports',
            name: 'admin-reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: 'system-logs',
            name: 'admin-system-logs',
            builder: (context, state) => const SystemLogsScreen(),
          ),
        ],
      ),

      // 👨‍💼 Employee Routes - Always defined, access controlled via redirect
      GoRoute(
        path: '/employee-dashboard',
        name: 'employee-dashboard',
        builder: (context, state) => const EmployeeDashboardScreen(),
        routes: [
          GoRoute(
            path: 'booking-inquiries',
            name: 'employee-booking-inquiries',
            builder: (context, state) => const BookingInquiryScreen(),
          ),
          GoRoute(
            path: 'check-in',
            name: 'employee-check-in',
            builder: (context, state) => const CheckInScreen(),
          ),
          GoRoute(
            path: 'flight-operations',
            name: 'employee-flight-operations',
            builder: (context, state) {
              try {
                final flight = state.extra as Flight?;
                if (flight == null) {
                  return const ErrorFallbackScreen(
                    error: 'Flight data is required for this operation',
                  );
                }
                return FlightOperationsScreen(flight: flight);
              } catch (e) {
                return ErrorFallbackScreen(
                  error: 'Invalid flight data: ${e.toString()}',
                );
              }
            },
          ),
          GoRoute(
            path: 'passenger-lookup',
            name: 'employee-passenger-lookup',
            builder: (context, state) => const PassengerLookupScreen(),
          ),
        ],
      ),

      // 🚫 Unauthorized access route
      GoRoute(
        path: '/unauthorized',
        name: 'unauthorized',
        builder: (context, state) => const UnauthorizedScreen(),
      ),
    ];
  }

  static String? _handleRedirect(
    Ref ref,
    BuildContext context,
    GoRouterState state,
  ) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () {
        // During loading, allow navigation to public routes only
        final publicRoutes = ['/', '/login', '/register'];
        if (!publicRoutes.contains(state.matchedLocation)) {
          return '/';
        }
        return null;
      },
      error: (error, stackTrace) {
        // On auth error, redirect to login unless already there
        if (state.matchedLocation != '/login') {
          return '/login';
        }
        return null;
      },
      data: (user) => _redirectForUser(user, state),
    );
  }

  static String? _redirectForUser(User? user, GoRouterState state) {
    final isLoggedIn = user != null;
    final currentLocation = state.matchedLocation;

    // Public routes that don't require authentication
    const publicRoutes = ['/', '/login', '/register'];

    // If not logged in and trying to access protected route
    if (!isLoggedIn && !publicRoutes.contains(currentLocation)) {
      return '/login';
    }

    // If logged in and trying to access auth routes, redirect to appropriate dashboard
    if (isLoggedIn &&
        (currentLocation == '/login' || currentLocation == '/register')) {
      return _getDefaultRouteForUser(user);
    }

    // Check role-based access for protected routes
    if (isLoggedIn) {
      // Admin routes
      if (currentLocation.startsWith('/admin-dashboard') &&
          user.role != 'admin') {
        return '/unauthorized';
      }

      // Employee routes
      if (currentLocation.startsWith('/employee-dashboard') &&
          user.role != 'employee') {
        return '/unauthorized';
      }
    }

    return null; // No redirect needed
  }

  static String _getDefaultRouteForUser(User user) {
    switch (user.role) {
      case 'admin':
        return '/admin-dashboard';
      case 'employee':
        return '/employee-dashboard';
      default:
        return '/';
    }
  }
}

// Custom listenable for auth state changes to trigger router refresh
class _AuthStateListenable extends ChangeNotifier {
  final Ref _ref;

  _AuthStateListenable(this._ref) {
    // Listen to auth state changes and notify router
    _ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
      if (previous != next) {
        notifyListeners();
      }
    });
  }
}
