import 'package:k_airways_flutter/constants/api_endpoints.dart';
import 'package:k_airways_flutter/models/booking.dart';
import 'package:k_airways_flutter/models/booking_inquiry.dart';
import 'package:k_airways_flutter/services/api_service.dart';

class BookingService {
  final ApiService _api;

  BookingService(this._api);

  /// Create a new booking
  Future<Booking> createBooking({
    required int flightId,
    required String seatNumber, required String seatClass,
  }) async {
    final response = await _api.post(
      ApiEndpoints.bookings,
      data: {'flight_id': flightId, 'seat_number': seatNumber},
    );
    return Booking.fromJson(response.data);
  }

  /// Fetch all bookings for the logged-in user
  Future<List<Booking>> getUserBookings() async {
    final response = await _api.get(ApiEndpoints.bookings);
    return (response.data as List)
        .map((json) => Booking.fromJson(json))
        .toList();
  }

  /// Fetch a single booking by ID
  Future<Booking> getBooking(String bookingId) async {
    final response = await _api.get('${ApiEndpoints.bookings}/$bookingId');
    return Booking.fromJson(response.data);
  }

  /// Cancel a booking
  Future<void> cancelBooking(String bookingId) async {
    await _api.post(ApiEndpoints.cancelBooking(int.parse(bookingId)));
  }

  /// Check in passenger
  Future<void> checkInPassenger(String bookingId) async {
    await _api.post(ApiEndpoints.bookingCheckIn(int.parse(bookingId)));
  }

  /// Get a booking inquiry (admin/employee)
  Future<BookingInquiry> getBookingInquiry(String bookingId) async {
    final response = await _api.get(
      '${ApiEndpoints.bookings}/$bookingId/inquiry',
    );
    return BookingInquiry.fromJson(response.data);
  }

  /// Submit a booking inquiry
  Future<void> submitInquiry({
    required String bookingId,
    required String details, required String message,
  }) async {
    await _api.post(
      ApiEndpoints.helpTickets,
      data: {'type': 'booking', 'details': details, 'booking_id': bookingId},
    );
  }
}
