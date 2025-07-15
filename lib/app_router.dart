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

GoRouter buildAppRouter(WidgetRef ref) {
  final user = ref.watch(authStateProvider).value;

  return GoRouter(
    initialLocation: _initialRouteFor(user),
    debugLogDiagnostics: true,
    routes: [
      // 🌐 Public Routes
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // 👑 Admin Routes
      if (user?.role == 'admin')
        GoRoute(
          path: '/admin-dashboard',
          builder: (context, state) => const AdminDashboardScreen(),
          routes: [
            GoRoute(
              path: 'user-management',
              builder: (context, state) => const UserManagementScreen(),
            ),
            GoRoute(
              path: 'flight-management',
              builder: (context, state) => const FlightManagementScreen(),
            ),
            GoRoute(
              path: 'passenger-list',
              builder: (context, state) => const PassengerListScreen(),
            ),
            GoRoute(
              path: 'reports',
              builder: (context, state) => const ReportsScreen(),
            ),
            GoRoute(
              path: 'system-logs',
              builder: (context, state) => const SystemLogsScreen(),
            ),
          ],
        ),

      // 👨‍💼 Employee Routes
      if (user?.role == 'employee')
        GoRoute(
          path: '/employee-dashboard',
          builder: (context, state) => const EmployeeDashboardScreen(),
          routes: [
            GoRoute(
              path: 'booking-inquiries',
              builder: (context, state) => const BookingInquiryScreen(),
            ),
            GoRoute(
              path: 'check-in',
              builder: (context, state) => const CheckInScreen(),
            ),
            GoRoute(
              path: 'flight-operations',
              builder: (context, state) {
                final flight = state.extra as Flight?;
                if (flight == null) {
                  return const ErrorFallbackScreen();
                }
                return FlightOperationsScreen(flight: flight);
              },
            ),
            GoRoute(
              path: 'passenger-lookup',
              builder: (context, state) => const PassengerLookupScreen(),
            ),
          ],
        ),
    ],

    redirect: (context, state) {
      final isLoggedIn = user != null;
      final goingToLogin = state.matchedLocation == '/login';
      final goingToRegister = state.matchedLocation == '/register';

      if (!isLoggedIn && !(goingToLogin || goingToRegister)) {
        return '/login';
      }
      if (isLoggedIn && (goingToLogin || goingToRegister)) {
        return _initialRouteFor(user);
      }
      return null;
    },

    errorBuilder: (context, state) => const ErrorFallbackScreen(),
  );
}

String _initialRouteFor(User? user) {
  if (user == null) return '/';
  switch (user.role) {
    case 'admin':
      return '/admin-dashboard';
    case 'employee':
      return '/employee-dashboard';
    default:
      return '/';
  }
}
