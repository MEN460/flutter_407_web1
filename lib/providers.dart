
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

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(apiServiceProvider));
});

final flightServiceProvider = Provider<FlightService>((ref) {
  return FlightService(
    ref.watch(apiServiceProvider),
    ref.watch(loggerProvider),
  );
});

final bookingServiceProvider = Provider<BookingService>((ref) {
  return BookingService(ref.watch(apiServiceProvider));
});

final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService(ref.watch(apiServiceProvider));
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.watch(apiServiceProvider));
});

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

final feedbackServiceProvider = Provider<FeedbackService>((ref) {
  return FeedbackService(ref.watch(apiServiceProvider));
});

final logServiceProvider = Provider<log_service.LogService>((ref) {
  return log_service.LogService(ref.watch(apiServiceProvider));
});

final loggerProvider = Provider<Logger>((ref) {
  return Logger();
});

/// -----------------------
/// 📱 Router Provider
/// -----------------------

final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.createRouter(ref);
});

/// -----------------------
/// 🔍 Flight Search Parameters
/// -----------------------

class FlightSearchParams {
  final String departure;
  final String arrival;
  final DateTime departureDate;
  final DateTime? returnDate;
  final int passengers;
  final String flightClass;

  const FlightSearchParams({
    required this.departure,
    required this.arrival,
    required this.departureDate,
    this.returnDate,
    this.passengers = 1,
    this.flightClass = 'economy',
  });

  FlightSearchParams copyWith({
    String? departure,
    String? arrival,
    DateTime? departureDate,
    DateTime? returnDate,
    int? passengers,
    String? flightClass,
  }) {
    return FlightSearchParams(
      departure: departure ?? this.departure,
      arrival: arrival ?? this.arrival,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      passengers: passengers ?? this.passengers,
      flightClass: flightClass ?? this.flightClass,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'departure': departure,
      'arrival': arrival,
      'departureDate': departureDate.toIso8601String(),
      if (returnDate != null) 'returnDate': returnDate!.toIso8601String(),
      'passengers': passengers,
      'flightClass': flightClass,
    };
  }
}

class FlightSearchParamsNotifier extends StateNotifier<FlightSearchParams> {
  FlightSearchParamsNotifier()
    : super(
        FlightSearchParams(
          departure: '',
          arrival: '',
          departureDate: DateTime.now(),
        ),
      );

  void update(FlightSearchParams newParams) {
    if (state == newParams) return;
    state = newParams;
  }
}

final flightSearchParamsProvider =
    StateNotifierProvider<FlightSearchParamsNotifier, FlightSearchParams>((
      ref,
    ) {
      return FlightSearchParamsNotifier();
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
  bool _isDisposed = false;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _loadCurrentUserOnStart();
  }

  Future<void> _loadCurrentUserOnStart() async {
    if (_isDisposed) return;

    state = const AsyncValue.loading();
    try {
      final user = await _authService.getCurrentUser();
      if (!_isDisposed) {
        state = AsyncValue.data(user);
      }
    } catch (error, stackTrace) {
      if (!_isDisposed) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<bool> login(String email, String password) async {
    if (_isDisposed) return false;

    state = const AsyncValue.loading();
    try {
      final user = await _authService.login(email, password);
      if (!_isDisposed) {
        state = AsyncValue.data(user);
        return true;
      }
      return false;
    } catch (error, stackTrace) {
      if (!_isDisposed) {
        state = AsyncValue.error(error, stackTrace);
      }
      rethrow;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (_isDisposed) return false;

    state = const AsyncValue.loading();
    try {
      final success = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      if (success && !_isDisposed) {
        final user = await _authService.login(email, password);
        if (!_isDisposed) {
          state = AsyncValue.data(user);
          return true;
        }
      }
      return false;
    } catch (error, stackTrace) {
      if (!_isDisposed) {
        state = AsyncValue.error(error, stackTrace);
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (error, stackTrace) {
      if (!_isDisposed) {
        state = AsyncValue.error(error, stackTrace);
      }
    } finally {
      if (!_isDisposed) {
        state = const AsyncValue.data(null);
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

/// -----------------------
/// 📦 Data Providers
/// -----------------------

final currentUserProvider = Provider<User?>((ref) {
  return ref
      .watch(authStateProvider)
      .maybeWhen(data: (user) => user, orElse: () => null);
});

final isAuthLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref
      .watch(authStateProvider)
      .maybeWhen(error: (error, _) => error.toString(), orElse: () => null);
});

final flightListProvider = FutureProvider<List<Flight>>((ref) {
  return ref.watch(flightServiceProvider).getFlights();
});

final filteredFlightsProvider =
    FutureProvider.family<List<Flight>, Map<String, dynamic>>((ref, filters) {
      return ref.watch(flightServiceProvider).searchFlights(filters);
    });

final assignedFlightsProvider = FutureProvider<List<Flight>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('User not authenticated');
  return ref.watch(flightServiceProvider).getAssignedFlights(user.id);
});

final flightStatusProvider = FutureProvider.family<FlightStatus, String>((
  ref,
  flightId,
) {
  return ref.watch(flightServiceProvider).getFlightStatus(flightId);
});

final userBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('User not authenticated');
  return ref.watch(bookingServiceProvider).getUserBookings();
});

final bookingInquiryProvider = FutureProvider.family<BookingInquiry, String>((
  ref,
  bookingId,
) {
  return ref.watch(bookingServiceProvider).getBookingInquiry(bookingId);
});

final dashboardReportProvider = FutureProvider<Report>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw Exception('User not authenticated');

  try {
    final reportService = ref.watch(reportServiceProvider);
    final rawReport = await reportService.fetchDashboardReport();

    return Report(
      id: rawReport.id,
      type: rawReport.type,
      startDate: rawReport.startDate,
      endDate: rawReport.endDate,
      generatedAt: rawReport.generatedAt,
      data: {
        'bookings': _normalizeMap(rawReport.data['bookings']),
        'flights': _normalizeMap(rawReport.data['flights']),
        'users': _normalizeMap(rawReport.data['users']),
      },
    );
  } catch (error, stackTrace) {
    ref
        .read(loggerProvider)
        .error('Failed to fetch dashboard report', error, stackTrace);
    throw Exception('Unable to load dashboard report. Please try again.');
  }
});

Map<String, num> _normalizeMap(dynamic input) {
  if (input is Map) {
    return input.map<String, num>((key, value) {
      if (key is String && value is num && value >= 0) {
        return MapEntry(key, value);
      }
      return const MapEntry('', 0);
    })..removeWhere((k, v) => k.isEmpty);
  }
  return <String, num>{};
}

final allUsersProvider = FutureProvider<List<User>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user?.role != 'admin') {
    throw Exception('Unauthorized: Admin access required');
  }
  return ref.watch(userServiceProvider).getAllUsers();
});

final passengerListProvider = FutureProvider<List<User>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user?.role != 'admin' && user?.role != 'employee') {
    throw Exception('Unauthorized: Staff access required');
  }
  return ref.watch(userServiceProvider).searchUsersByRole('passenger');
});

final userSearchProvider = FutureProvider.family<List<User>, String>((
  ref,
  query,
) {
  final user = ref.watch(currentUserProvider);
  if (user?.role != 'admin' && user?.role != 'employee') {
    throw Exception('Unauthorized: Staff access required');
  }
  return ref.watch(userServiceProvider).searchUsers(query);
});

final systemLogsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user?.role != 'admin') {
    throw Exception('Unauthorized: Admin access required');
  }
  return ref.watch(logServiceProvider).getSystemLogs();
});

final navigationStateProvider = StateProvider<String?>((ref) => null);
