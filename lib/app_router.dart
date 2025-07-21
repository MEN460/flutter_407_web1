import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_airways_flutter/models/booking.dart';
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
import 'package:k_airways_flutter/views/employee/booking_inquiry.dart'
    as employee;
import 'package:k_airways_flutter/views/employee/check_in.dart';
import 'package:k_airways_flutter/views/employee/dashboard.dart';
import 'package:k_airways_flutter/views/employee/flight_operations.dart';
import 'package:k_airways_flutter/views/employee/passenger_lookup.dart';
import 'package:k_airways_flutter/views/passenger/booking_confirm.dart';
import 'package:k_airways_flutter/views/passenger/booking_history.dart';
import 'package:k_airways_flutter/views/passenger/booking_screen.dart'
    as passenger;
import 'package:k_airways_flutter/views/passenger/feedback.dart';
import 'package:k_airways_flutter/views/passenger/flight_search.dart';
import 'package:k_airways_flutter/views/passenger/flight_status.dart';
import 'package:k_airways_flutter/views/passenger/home_screen.dart';
import 'package:k_airways_flutter/views/passenger/seat_selection.dart';
import 'package:k_airways_flutter/views/shared/error_fallback.dart';
import 'package:k_airways_flutter/views/shared/help_center.dart';
import 'package:k_airways_flutter/views/shared/settings.dart';
import 'package:k_airways_flutter/views/shared/unauthorized_screen.dart';

/// App routing configuration with comprehensive passenger journey support
class AppRouter {
  static GoRouter createRouter(Ref ref) {
    return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: _AuthStateListenable(ref),
      routes: _buildRoutes(),
      redirect: (context, state) => _handleRedirect(ref, context, state),
      errorBuilder: (context, state) => ErrorFallbackScreen(
        errorMessage: state.error?.toString() ?? 'Unknown error occurred',
      ),
    );
  }

  static List<RouteBase> _buildRoutes() {
    return [
      // 🌐 Public Routes - Accessible without authentication
      _buildPublicRoutes(),

      // 👑 Admin Routes - Administrative functionality
      _buildAdminRoutes(),

      // 👨‍💼 Employee Routes - Staff operations
      _buildEmployeeRoutes(),

      // 🛫 Passenger Routes - Customer journey
      _buildPassengerRoutes(),

      // 🔗 Shared Routes - Common functionality
      _buildSharedRoutes(),

      // 🚫 Error handling routes
      _buildErrorRoutes(),
    ];
  }

  /// Public routes accessible without authentication
  static RouteBase _buildPublicRoutes() {
    return GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: 'register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),
      ],
    );
  }

  /// Administrative routes with nested structure
  static RouteBase _buildAdminRoutes() {
    return GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (context, state) => const AdminDashboardScreen(),
      routes: [
        GoRoute(
          path: 'dashboard',
          name: 'admin-dashboard',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: 'users',
          name: 'admin-user-management',
          builder: (context, state) => const UserManagementScreen(),
        ),
        GoRoute(
          path: 'flights',
          name: 'admin-flight-management',
          builder: (context, state) => const FlightManagementScreen(),
        ),
        GoRoute(
          path: 'passengers',
          name: 'admin-passenger-list',
          builder: (context, state) => const PassengerListScreen(),
        ),
        GoRoute(
          path: 'reports',
          name: 'admin-reports',
          builder: (context, state) => const ReportsScreen(),
        ),
        GoRoute(
          path: 'logs',
          name: 'admin-system-logs',
          builder: (context, state) => const SystemLogsScreen(),
        ),
        GoRoute(
          path: 'operations',
          name: 'admin-flight-operations',
          builder: (context, state) => const FlightOperationsScreen(),
        ),
      ],
    );
  }

  /// Employee routes with nested structure
  static RouteBase _buildEmployeeRoutes() {
    return GoRoute(
      path: '/employee',
      name: 'employee',
      builder: (context, state) => const EmployeeDashboardScreen(),
      routes: [
        GoRoute(
          path: 'dashboard',
          name: 'employee-dashboard',
          builder: (context, state) => const EmployeeDashboardScreen(),
        ),
        GoRoute(
          path: 'inquiries',
          name: 'employee-booking-inquiries',
          builder: (context, state) => const employee.BookingInquiryScreen(),
        ),
        GoRoute(
          path: 'checkin',
          name: 'employee-check-in',
          builder: (context, state) => const CheckInScreen(),
        ),
        GoRoute(
          path: 'operations/:flightId',
          name: 'employee-flight-operations',
          builder: (context, state) {
            final flightId = state.pathParameters['flightId'];
            final flight = state.extra as Flight?;

            if (flightId == null || flight == null) {
              return const ErrorFallbackScreen(
                errorMessage: 'Flight information is required for operations',
              );
            }
            return FlightOperationsScreen(flight: flight);
          },
        ),
        GoRoute(
          path: 'passengers',
          name: 'employee-passenger-lookup',
          builder: (context, state) => const PassengerLookupScreen(),
        ),
      ],
    );
  }

  /// Comprehensive passenger routes covering the complete booking journey
  static RouteBase _buildPassengerRoutes() {
    return ShellRoute(
      builder: (context, state, child) {
        // Optional: Add a shell wrapper for passenger routes
        // This could include common navigation or layout elements
        return child;
      },
      routes: [
        // Flight search and booking flow
        GoRoute(
          path: '/flight/search',
          name: 'flight-search',
          builder: (context, state) => const FlightSearchScreen(),
          routes: [
            GoRoute(
              path: 'results',
              name: 'search-results',
              builder: (context, state) {
                final flightSearchParams = state.extra as Map<String, dynamic>?;
                // Pass search parameters to FlightSearchScreen
                return FlightSearchScreen(
                  initialSearchParams: flightSearchParams,
                );
              },
            ),
          ],
        ),

        // Booking process
        GoRoute(
          path: '/book/:flightId',
          name: 'flight-booking',
          builder: (context, state) {
            final flightId = state.pathParameters['flightId'];
            final flight = state.extra as Flight?;

            if (flightId == null) {
              return const ErrorFallbackScreen(
                errorMessage: 'Flight ID is required for booking',
              );
            }

            if (flight == null) {
              return const ErrorFallbackScreen(
                errorMessage: 'Flight data is required for booking',
              );
            }

            return passenger.BookingInquiryScreen(flight: flight);
          },
          routes: [
            // Seat selection within booking flow
            GoRoute(
              path: 'seats',
              name: 'seat-selection',
              builder: (context, state) {
                final flight = state.extra as Flight?;
                if (flight == null) {
                  return const ErrorFallbackScreen(
                    errorMessage: 'Flight data is required for seat selection',
                  );
                }
                return SeatSelectionScreen(flight: flight);
              },
            ),
          ],
        ),

        // Booking confirmation
        GoRoute(
          path: '/booking-confirmation/:bookingId',
          name: 'booking-confirmation',
          builder: (context, state) {
            final bookingId = state.pathParameters['bookingId'];
            final booking = state.extra as Booking?;

            if (bookingId == null) {
              return const ErrorFallbackScreen(
                errorMessage: 'Booking ID is required for confirmation',
              );
            }

            if (booking == null) {
              return const ErrorFallbackScreen(
                errorMessage: 'Booking data is required for confirmation',
              );
            }

            return BookingConfirmationScreen(booking: booking);
          },
        ),

        // Booking management
        GoRoute(
          path: '/bookings',
          name: 'booking-history',
          builder: (context, state) => const BookingHistoryScreen(),
          routes: [
            // Individual booking details
            GoRoute(
              path: ':bookingId',
              name: 'booking-details',
              builder: (context, state) {
                final bookingId = state.pathParameters['bookingId'];
                final booking = state.extra as Booking?;

                if (bookingId == null) {
                  return const ErrorFallbackScreen(
                    errorMessage: 'Booking ID is required',
                  );
                }

                // If booking object is passed, use it directly
                if (booking != null) {
                  return BookingConfirmationScreen(booking: booking);
                }

                // Otherwise, create a detail view that fetches booking by ID
                // You might want to create a separate BookingDetailScreen
                return ErrorFallbackScreen(
                  errorMessage:
                      'Booking details not available for ID: $bookingId',
                );
              },
            ),
          ],
        ),

        // Flight status and information
        GoRoute(
          path: '/flight-status',
          name: 'flight-status-search',
          builder: (context, state) {
            // FlightStatusScreen requires both flightId and flightNumber
            // For search page, we'll show an error or create a search interface
            return const ErrorFallbackScreen(
              errorMessage:
                  'Please search for a specific flight to view its status',
            );
          },
          routes: [
            GoRoute(
              path: ':flightNumber/:flightId',
              name: 'flight-status-details',
              builder: (context, state) {
                final flightNumber = state.pathParameters['flightNumber'];
                final flightId = state.pathParameters['flightId'];

                if (flightNumber == null || flightId == null) {
                  return const ErrorFallbackScreen(
                    errorMessage: 'Flight number and ID are required',
                  );
                }
                return FlightStatusScreen(
                  flightNumber: flightNumber,
                  flightId: flightId,
                );
              },
            ),
          ],
        ),

        // Customer support and inquiries
        GoRoute(
          path: '/support',
          name: 'passenger-support',
          builder: (context, state) {
            // Since BookingInquiryScreen requires a flight, we need to handle this differently
            // Option 1: Redirect to a general support/help page
            // Option 2: Create a support screen that doesn't require flight data
            // For now, redirecting to help center
            return const ErrorFallbackScreen(
              errorMessage:
                  'Please select a flight first to make an inquiry, or visit our help center.',
            );
          },
          routes: [
            GoRoute(
              path: 'inquiry/:bookingId',
              name: 'booking-inquiry-specific',
              builder: (context, state) {
                final bookingId = state.pathParameters['bookingId'];
                // This route also needs flight data, so we'll need to fetch it
                // or create a different inquiry screen that doesn't require flight
                return const ErrorFallbackScreen(
                  errorMessage:
                      'Booking inquiry requires flight information. Please access via booking history.',
                );
              },
            ),
            GoRoute(
              path: 'flight/:flightId/inquiry',
              name: 'flight-specific-inquiry',
              builder: (context, state) {
                final flightIdParam = state.pathParameters['flightId'];
                final flight = state.extra as Flight?;

                if (flightIdParam == null || flight == null) {
                  return const ErrorFallbackScreen(
                    errorMessage: 'Flight data is required for inquiry',
                  );
                }

                return passenger.BookingInquiryScreen(
                  flight: flight,
                  initialBookingId: state.uri.queryParameters['bookingId'],
                );
              },
            ),
          ],
        ),

        // Feedback system
        GoRoute(
          path: '/feedback',
          name: 'passenger-feedback',
          builder: (context, state) {
            // FeedbackScreen requires flightId, so show error for general feedback
            return const ErrorFallbackScreen(
              errorMessage:
                  'Please select a specific flight to provide feedback',
            );
          },
          routes: [
            GoRoute(
              path: 'flight/:flightId',
              name: 'flight-feedback',
              builder: (context, state) {
                final flightIdParam = state.pathParameters['flightId'];

                if (flightIdParam == null) {
                  return const ErrorFallbackScreen(
                    errorMessage: 'Flight ID is required for feedback',
                  );
                }

                // Parse flightId to int
                final flightId = int.tryParse(flightIdParam);
                if (flightId == null) {
                  return const ErrorFallbackScreen(
                    errorMessage: 'Invalid flight ID format',
                  );
                }

                return FeedbackScreen(flightId: flightId);
              },
            ),
          ],
        ),

        // Quick actions from deep links or notifications
        GoRoute(
          path: '/checkin/:bookingId',
          name: 'online-checkin',
          builder: (context, state) {
            final bookingId = state.pathParameters['bookingId'];
            if (bookingId == null) {
              return const ErrorFallbackScreen(
                errorMessage: 'Booking ID is required for check-in',
              );
            }
            // Use the bookingId for check-in logic or redirect to employee checkin
            // For now, showing a placeholder message with the booking ID
            return ErrorFallbackScreen(
              errorMessage:
                  'Online check-in for booking $bookingId is coming soon',
            );
          },
        ),
      ],
    );
  }

  /// Shared routes accessible by all authenticated users
  static RouteBase _buildSharedRoutes() {
    return GoRoute(
      path: '/shared',
      builder: (context, state) => const SizedBox.shrink(),
      routes: [
        GoRoute(
          path: '/help',
          name: 'help-center',
          builder: (context, state) => const HelpCenterScreen(),
        ),
        GoRoute(
          path: '/settings',
          name: 'user-settings',
          builder: (context, state) => const SettingsScreen(),
          routes: [
            GoRoute(
              path: 'profile',
              name: 'user-profile',
              builder: (context, state) => const SettingsScreen(),
            ),
            GoRoute(
              path: 'preferences',
              name: 'user-preferences',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    );
  }

  /// Error handling routes
  static RouteBase _buildErrorRoutes() {
    return GoRoute(
      path: '/error',
      builder: (context, state) => const SizedBox.shrink(),
      routes: [
        GoRoute(
          path: '/unauthorized',
          name: 'unauthorized',
          builder: (context, state) => const UnauthorizedScreen(),
        ),
        GoRoute(
          path: '/not-found',
          name: 'not-found',
          builder: (context, state) => const ErrorFallbackScreen(
            errorMessage: 'The requested page was not found',
          ),
        ),
      ],
    );
  }

  /// Enhanced redirect logic with better role-based access control
  static String? _handleRedirect(
    Ref ref,
    BuildContext context,
    GoRouterState state,
  ) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => _handleLoadingState(state),
      error: (error, stackTrace) => _handleAuthError(state, error),
      data: (user) => _redirectForAuthenticatedUser(user, state),
    );
  }

  static String? _handleLoadingState(GoRouterState state) {
    // Allow access to public routes during auth loading
    const publicPaths = ['/', '/login', '/register', '/flight-status', '/help'];

    final currentPath = state.matchedLocation;
    if (!publicPaths.any((path) => currentPath.startsWith(path))) {
      return '/';
    }
    return null;
  }

  static String? _handleAuthError(GoRouterState state, Object error) {
    // On authentication error, redirect to login unless already there
    if (!state.matchedLocation.startsWith('/login')) {
      return '/login';
    }
    return null;
  }

  static String? _redirectForAuthenticatedUser(
    User? user,
    GoRouterState state,
  ) {
    final currentLocation = state.matchedLocation;
    final isLoggedIn = user != null;

    // Public routes that don't require authentication
    const publicRoutes = [
      '/',
      '/login',
      '/register',
      '/flight-status',
      '/help',
    ];

    // If not logged in and accessing protected routes
    if (!isLoggedIn && !_isPublicRoute(currentLocation, publicRoutes)) {
      return '/login';
    }

    // If logged in and accessing auth routes
    if (isLoggedIn && _isAuthRoute(currentLocation)) {
      return _getDefaultDashboardForUser(user);
    }

    // Role-based access control
    if (isLoggedIn) {
      return _enforceRoleBasedAccess(user, currentLocation);
    }

    return null; // No redirect needed
  }

  static bool _isPublicRoute(String location, List<String> publicRoutes) {
    return publicRoutes.any((route) => location.startsWith(route));
  }

  static bool _isAuthRoute(String location) {
    return location == '/login' || location == '/register';
  }

  static String? _enforceRoleBasedAccess(User user, String location) {
    // Admin route access
    if (location.startsWith('/admin') && user.role != 'admin') {
      return '/error/unauthorized';
    }

    // Employee route access
    if (location.startsWith('/employee') && user.role != 'employee') {
      return '/error/unauthorized';
    }

    // Some passenger routes might require specific permissions
    if (location.startsWith('/bookings') && user.role == 'guest') {
      return '/login';
    }

    return null;
  }

  static String _getDefaultDashboardForUser(User user) {
    switch (user.role) {
      case 'admin':
        return '/admin/dashboard';
      case 'employee':
        return '/employee/dashboard';
      case 'passenger':
      default:
        return '/';
    }
  }
}

/// Custom listenable for authentication state changes
class _AuthStateListenable extends ChangeNotifier {
  final Ref _ref;

  _AuthStateListenable(this._ref) {
    // Listen to authentication state changes and notify router
    _ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
      if (previous != next) {
        notifyListeners();
      }
    });
  }
}

/// Extension methods for easier route navigation
extension AppRouterExtension on GoRouter {
  /// Navigate to flight booking with flight data
  void goToFlightBooking(Flight flight) {
    go('/book/${flight.id}', extra: flight);
  }

  /// Navigate to booking confirmation with booking data
  void goToBookingConfirmation(Booking booking) {
    go('/booking-confirmation/${booking.id}', extra: booking);
  }

  /// Navigate to flight status with flight number and ID
  void goToFlightStatus(String flightNumber, String flightId) {
    go('/flight-status/$flightNumber/$flightId');
  }

  /// Navigate to flight feedback with flight ID
  void goToFlightFeedback(int flightId) {
    go('/feedback/flight/$flightId');
  }

  /// Navigate to specific booking inquiry with flight data
  void goToBookingInquiry({String? bookingId, Flight? flight}) {
    if (flight != null) {
      if (bookingId != null) {
        go(
          '/support/flight/${flight.id}/inquiry?bookingId=$bookingId',
          extra: flight,
        );
      } else {
        go('/support/flight/${flight.id}/inquiry', extra: flight);
      }
    } else {
      // Fallback to general support/help
      go('/help');
    }
  }

  /// Navigate to seat selection with flight data
  void goToSeatSelection(Flight flight) {
    go('/book/${flight.id}/seats', extra: flight);
  }
}
