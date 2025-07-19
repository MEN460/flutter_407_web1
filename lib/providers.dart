import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_airways_flutter/app_router.dart';
import 'package:k_airways_flutter/models/booking.dart';
import 'package:k_airways_flutter/models/booking_inquiry.dart';
import 'package:k_airways_flutter/models/flight.dart';
import 'package:k_airways_flutter/models/flight_status.dart';
import 'package:k_airways_flutter/models/report.dart';
import 'package:k_airways_flutter/models/user.dart';
import 'package:k_airways_flutter/services/api_service.dart';
import 'package:k_airways_flutter/services/auth_service.dart';
import 'package:k_airways_flutter/services/booking_service.dart';
import 'package:k_airways_flutter/services/feedback_service.dart';
import 'package:k_airways_flutter/services/flight_service.dart';
import 'package:k_airways_flutter/services/log_service.dart' as log_service;
import 'package:k_airways_flutter/services/payment_service.dart';
import 'package:k_airways_flutter/services/report_service.dart';
import 'package:k_airways_flutter/services/user_service.dart';
import 'package:k_airways_flutter/utils/logger.dart';

/// -----------------------
/// 🌐 Core Service Providers
/// -----------------------
final apiServiceProvider = Provider((ref) => ApiService());

final authServiceProvider = Provider(
  (ref) => AuthService(ref.read(apiServiceProvider)),
);

final flightServiceProvider = Provider(
  (ref) =>
      FlightService(ref.read(apiServiceProvider), ref.read(loggerProvider)),
);

final bookingServiceProvider = Provider(
  (ref) => BookingService(ref.read(apiServiceProvider)),
);

final reportServiceProvider = Provider(
  (ref) => ReportService(ref.read(apiServiceProvider)),
);

final userServiceProvider = Provider(
  (ref) => UserService(ref.read(apiServiceProvider)),
);

final paymentServiceProvider = Provider((ref) => PaymentService());

final feedbackServiceProvider = Provider(
  (ref) => FeedbackService(ref.read(apiServiceProvider)),
);

final logServiceProvider = Provider(
  (ref) => log_service.LogService(ref.read(apiServiceProvider)),
);

final loggerProvider = Provider((ref) => Logger());

/// -----------------------
/// 📱 Router Provider
/// -----------------------
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.createRouter(ref);
});

/// -----------------------
/// 👤 Auth State Provider
/// -----------------------
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
      return AuthNotifier(ref.read(authServiceProvider));
    });

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _loadCurrentUserOnStart();
  }

  Future<void> _loadCurrentUserOnStart() async {
    try {
      final user = await _authService.getCurrentUser();
      if (mounted) {
        state = AsyncValue.data(user);
      }
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.login(email, password);
      if (mounted) {
        state = AsyncValue.data(user);
        return true;
      }
      return false;
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final success = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      if (success) {
        // Auto-login after successful registration
        final user = await _authService.login(email, password);
        if (mounted) {
          state = AsyncValue.data(user);
          return true;
        }
      }
      return false;
    } catch (e, st) {
      if (mounted) {
        state = AsyncValue.error(e, st);
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      // Log error but still clear local state
      print('Logout error: $e');
    } finally {
      if (mounted) {
        state = const AsyncValue.data(null);
      }
    }
  }

  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}

/// -----------------------
/// 📦 Data Providers
/// -----------------------

// 🚨 Authenticated user snapshot with proper state handling
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Loading state provider for UI components
final isAuthLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isLoading;
});

// Auth error provider for error handling
final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (_) => null,
    loading: () => null,
    error: (error, _) => error.toString(),
  );
});

// 📃 All Flights - Made keepAlive to prevent unnecessary refetches
final flightListProvider = FutureProvider.autoDispose<List<Flight>>((ref) {
  ref.keepAlive();
  return ref.read(flightServiceProvider).getFlights();
});

// 🔍 Filtered Flights
final filteredFlightsProvider = FutureProvider.autoDispose
    .family<List<Flight>, Map<String, dynamic>>((ref, filters) {
      return ref.read(flightServiceProvider).searchFlights(filters);
    });

// 🛫 Employee Assigned Flights
final assignedFlightsProvider = FutureProvider.autoDispose<List<Flight>>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('User not authenticated');
  return ref.read(flightServiceProvider).getAssignedFlights(user.id);
});

// 🛬 Flight Status
final flightStatusProvider = FutureProvider.autoDispose
    .family<FlightStatus, String>((ref, flightId) {
      return ref.read(flightServiceProvider).getFlightStatus(flightId);
    });

// 🎟️ User Bookings
final userBookingsProvider = FutureProvider.autoDispose<List<Booking>>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('User not authenticated');
  return ref.read(bookingServiceProvider).getUserBookings();
});

// 📝 Booking Inquiry
final bookingInquiryProvider = FutureProvider.autoDispose
    .family<BookingInquiry, String>((ref, bookingId) {
      return ref.read(bookingServiceProvider).getBookingInquiry(bookingId);
    });

// 📊 Dashboard Report
// 📊 Dashboard Report (Safe & Normalized)
final dashboardReportProvider = FutureProvider.autoDispose<Report>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('User not authenticated');

  try {
    final reportService = ref.read(reportServiceProvider);
    final rawReport = await reportService.fetchDashboardReport();

    // Normalize and provide fallback/defaults
    return Report(
      id: rawReport.id,
      type: rawReport.type,
      startDate:
          rawReport.startDate,
      endDate: rawReport.endDate,
      generatedAt: rawReport.generatedAt,
      data: {
        'bookings': _normalizeMap(rawReport.data['bookings']),
        'flights': _normalizeMap(rawReport.data['flights']),
        'users': _normalizeMap(rawReport.data['users']),
      },
    );
  } catch (e, st) {
    ref.read(loggerProvider).error('Failed to fetch dashboard report', e, st);
    throw Exception('Unable to load dashboard report. Please try again.');
  }
});

Map<String, num> _normalizeMap(dynamic input) {
  if (input is Map) {
    return input.map<String, num>((key, value) {
      if (key is String && value is num && value >= 0) {
        return MapEntry(key, value);
      }
      return const MapEntry('', 0); // Invalid entry placeholder
    })..removeWhere((k, v) => k.isEmpty); // Remove invalid keys
  }
  return <String, num>{};
}


/// 👥 All Users (Admin-only)
final allUsersProvider = FutureProvider.autoDispose<List<User>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user?.role != 'admin') {
    throw Exception('Unauthorized: Admin access required');
  }
  return ref.read(userServiceProvider).getAllUsers();
});

// 👤 Filtered Passengers
final passengerListProvider = FutureProvider.autoDispose<List<User>>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user?.role != 'admin' && user?.role != 'employee') {
    throw Exception('Unauthorized: Staff access required');
  }
  final users = await ref
      .read(userServiceProvider)
      .searchUsersByRole('passenger');
  return users;
});

// 🔍 User Search
final userSearchProvider = FutureProvider.autoDispose
    .family<List<User>, String>((ref, query) {
      final user = ref.watch(currentUserProvider);
      if (user?.role != 'admin' && user?.role != 'employee') {
        throw Exception('Unauthorized: Staff access required');
      }
      return ref.read(userServiceProvider).searchUsers(query);
    });

// 🛠️ System Logs (Admin-only)
final systemLogsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
      final user = ref.watch(currentUserProvider);
      if (user?.role != 'admin') {
        throw Exception('Unauthorized: Admin access required');
      }
      return ref.read(logServiceProvider).getSystemLogs();
    });

// Navigation state provider for managing navigation state
final navigationStateProvider = StateProvider<String?>((ref) => null);
