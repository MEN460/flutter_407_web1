import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.login(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AsyncValue.data(null);
  }
}


/// -----------------------
/// 📦 Data Providers
/// -----------------------

// 🚨 Authenticated user snapshot
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

// 📃 All Flights
final flightListProvider = FutureProvider.autoDispose<List<Flight>>((ref) {
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
  final user = ref.watch(authStateProvider).value;
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
  final user = ref.watch(authStateProvider).value;
  if (user == null) throw Exception('User not authenticated');
  return ref.read(bookingServiceProvider).getUserBookings();
});

// 📝 Booking Inquiry
final bookingInquiryProvider = FutureProvider.autoDispose
    .family<BookingInquiry, String>((ref, bookingId) {
      return ref.read(bookingServiceProvider).getBookingInquiry(bookingId);
    });

// 📊 Dashboard Report
final dashboardReportProvider = FutureProvider.autoDispose<Report>((ref) {
  return ref.read(reportServiceProvider).fetchDashboardReport();
});

// 👥 All Users (Admin-only)
final allUsersProvider = FutureProvider.autoDispose<List<User>>((ref) {
  return ref.read(userServiceProvider).getAllUsers();
});

// 👤 Filtered Passengers
final passengerListProvider = FutureProvider.autoDispose<List<User>>((
  ref,
) async {
  final users = await ref.read(userServiceProvider).searchUsersByRole('passenger');
  return users;
});

// 🔍 User Search
final userSearchProvider = FutureProvider.autoDispose
    .family<List<User>, String>((ref, query) {
      return ref.read(userServiceProvider).searchUsers(query);
    });

// 🛠️ System Logs
final systemLogsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
      return ref.read(logServiceProvider).getSystemLogs();
    });
