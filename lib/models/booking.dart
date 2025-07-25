import 'flight.dart';
import 'user.dart';

class Booking {
  final String id;
  final int userId;
  final User? user; // Optional for admin context
  final int flightId;
  final Flight? flight; // Optional in case it's not included
  final String seatNumber;
  final String status; // 'confirmed', 'pending', 'cancelled'
  final DateTime createdAt;
  final String seatClass;
  final DateTime bookingDate; // ADD THIS
  final bool checkedIn; // ADD THIS


  Booking({
    required this.id,
    required this.userId,
    this.user,
    required this.flightId,
    this.flight,
    required this.seatNumber,
    required this.status,
    required this.createdAt,
    this.seatClass = 'economy', // Default to economy class
    required this.bookingDate, // Initialize booking date
    this.checkedIn = false, // Default to not checked in
  });

  /// Parse from API JSON
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'].toString(),
      userId: json['user_id'] as int,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      flightId: json['flight_id'] as int,
      flight: json['flight'] != null ? Flight.fromJson(json['flight']) : null,
      seatNumber: json['seat_number'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      seatClass: json['seat_class'] as String? ?? 'economy',
      bookingDate: DateTime.parse(json['booking_date'] as String), // Parse booking date
      checkedIn: json['checked_in'] as bool? ?? false, // Parse checked-in
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      if (user != null) 'user': user!.toJson(),
      'flight_id': flightId,
      if (flight != null) 'flight': flight!.toJson(),
      'seat_number': seatNumber,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'seat_class': seatClass,
      'booking_date': bookingDate.toIso8601String(), // Convert booking date to ISO string
      'checked_in': checkedIn, // Include checked-in status
    };
  }
}
