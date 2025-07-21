import 'package:k_airways_flutter/constants/api_endpoints.dart';
import 'package:k_airways_flutter/models/booking.dart';
import 'package:k_airways_flutter/models/booking_inquiry.dart'; // Import BookingInquiry from models
import 'package:k_airways_flutter/models/inquiry_type.dart'; // Import centralized enums
import 'package:k_airways_flutter/services/api_service.dart';

// Enhanced BookingService with proper error handling and consistency
class BookingService {
  final ApiService _api;

  BookingService(this._api);

  /// Create a new booking
  Future<Booking> createBooking({
    required int flightId,
    required String seatNumber,
    required String seatClass,
  }) async {
    try {
      final response = await _api.post(
        ApiEndpoints.bookings,
        data: {
          'flight_id': flightId,
          'seat_number': seatNumber,
          'seat_class': seatClass,
        },
      );
      return Booking.fromJson(response.data);
    } catch (e) {
      throw _handleBookingError(e, 'Failed to create booking');
    }
  }

  /// Fetch all bookings for the logged-in user
  Future<List<Booking>> getUserBookings() async {
    try {
      final response = await _api.get(ApiEndpoints.bookings);
      return (response.data as List)
          .map((json) => Booking.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleBookingError(e, 'Failed to fetch user bookings');
    }
  }

  /// Fetch a single booking by ID
  Future<Booking> getBooking(String bookingId) async {
    try {
      final response = await _api.get('${ApiEndpoints.bookings}/$bookingId');
      return Booking.fromJson(response.data);
    } catch (e) {
      if (e.toString().contains('404') || e.toString().contains('not found')) {
        throw Exception('booking not found');
      }
      throw _handleBookingError(e, 'Failed to fetch booking');
    }
  }

  /// Cancel a booking
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _api.post(ApiEndpoints.cancelBooking(int.parse(bookingId)));
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid booking ID format');
      }
      throw _handleBookingError(e, 'Failed to cancel booking');
    }
  }

  /// Check in passenger
  Future<void> checkInPassenger(String bookingId) async {
    try {
      await _api.post(ApiEndpoints.bookingCheckIn(int.parse(bookingId)));
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid booking ID format');
      }
      throw _handleBookingError(e, 'Failed to check in passenger');
    }
  }

  /// Get a booking inquiry by ID
  Future<BookingInquiry> getBookingInquiry(String inquiryId) async {
    try {
      final response = await _api.get('${ApiEndpoints.helpTickets}/$inquiryId');
      return BookingInquiry.fromJson(response.data);
    } catch (e) {
      throw _handleBookingError(e, 'Failed to fetch booking inquiry');
    }
  }

  /// Get all inquiries for a user
  Future<List<BookingInquiry>> getUserInquiries() async {
    try {
      final response = await _api.get(ApiEndpoints.helpTickets);
      return (response.data as List)
          .map((json) => BookingInquiry.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleBookingError(e, 'Failed to fetch user inquiries');
    }
  }

  /// Get inquiries for a specific booking
  Future<List<BookingInquiry>> getBookingInquiries(String bookingId) async {
    try {
      final response = await _api.get(
        '${ApiEndpoints.helpTickets}?booking_id=$bookingId',
      );
      return (response.data as List)
          .map((json) => BookingInquiry.fromJson(json))
          .toList();
    } catch (e) {
      throw _handleBookingError(e, 'Failed to fetch booking inquiries');
    }
  }

/// Submit a booking inquiry - Enhanced with better validation
  Future<BookingInquiry> submitInquiry({
    String? bookingId,
    required String message,
    String? details,
    String? email,
    required InquiryType inquiryType,
    InquiryPriority priority = InquiryPriority.medium,
  }) async {
    try {
      // Validate booking ID if provided
      if (bookingId != null && bookingId.isNotEmpty) {
        if (!isValidBookingId(bookingId)) {
          throw Exception('Invalid booking ID format');
        }
        await getBooking(bookingId); // Verify booking exists
      }

      // Validate email format if provided
      if (email != null && email.isNotEmpty && !isValidEmail(email)) {
        throw Exception('Invalid email format');
      }

      // Validate message content
      if (message.trim().length < 10) {
        throw Exception('Message must be at least 10 characters');
      }

      final response = await _api.post(
        ApiEndpoints.helpTickets,
        data: {
          'type': 'booking',
          if (bookingId != null && bookingId.isNotEmpty)
            'booking_id': bookingId,
          'inquiry_type': inquiryType.value,
          'priority': priority.value,
          'message': message,
          'details':
              details ?? message, // Fallback to message if details not provided
          if (email != null && email.isNotEmpty) 'email': email,
        },
      );
      return BookingInquiry.fromJson(response.data);
    } catch (e) {
      if (e.toString().contains('booking not found')) {
        throw Exception('Booking not found');
      }
      throw _handleBookingError(e, 'Failed to submit inquiry');
    }
  }

  /// Update inquiry status (for staff/admin)
  Future<BookingInquiry> updateInquiryStatus({
    required String inquiryId,
    required InquiryStatus status,
    String? resolutionNotes,
  }) async {
    try {
      final response = await _api.patch(
        '${ApiEndpoints.helpTickets}/$inquiryId',
        data: {
          'status': status.value,
          if (resolutionNotes != null && resolutionNotes.isNotEmpty)
            'resolution_notes': resolutionNotes,
        },
      );
      return BookingInquiry.fromJson(response.data);
    } catch (e) {
      throw _handleBookingError(e, 'Failed to update inquiry status');
    }
  }

  /// Add response to inquiry (for staff/admin)
  Future<BookingInquiry> addInquiryResponse({
    required String inquiryId,
    required String response,
    InquiryStatus? newStatus,
  }) async {
    try {
      final responseData = await _api.post(
        '${ApiEndpoints.helpTickets}/$inquiryId/response',
        data: {
          'response': response,
          if (newStatus != null) 'status': newStatus.value,
        },
      );
      return BookingInquiry.fromJson(responseData.data);
    } catch (e) {
      throw _handleBookingError(e, 'Failed to add inquiry response');
    }
  }

  /// Enhanced error handling method
  Exception _handleBookingError(dynamic error, String defaultMessage) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('socket')) {
      return Exception('network');
    } else if (errorString.contains('timeout')) {
      return Exception('timeout');
    } else if (errorString.contains('booking not found') ||
        errorString.contains('404')) {
      return Exception('booking not found');
    } else if (errorString.contains('unauthorized') ||
        errorString.contains('401')) {
      return Exception('Unauthorized access');
    } else if (errorString.contains('forbidden') ||
        errorString.contains('403')) {
      return Exception('Access forbidden');
    } else {
      return Exception(defaultMessage);
    }
  }

  /// Booking ID validation helper
  bool isValidBookingId(String bookingId) {
    if (bookingId.trim().isEmpty) return false;
    final cleanId = bookingId.trim().toUpperCase();
    return cleanId.length >= 6 && RegExp(r'^[A-Z0-9]+$').hasMatch(cleanId);
  }

  /// Email validation helper - Made public for UI validation
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  /// Get booking status - utility method
  Future<String> getBookingStatus(String bookingId) async {
    try {
      final booking = await getBooking(bookingId);
      return booking.status;
    } catch (e) {
      return 'unknown';
    }
  }
}
