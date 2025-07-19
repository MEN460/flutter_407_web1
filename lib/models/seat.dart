import 'package:k_airways_flutter/widgets/seat_map.dart';

class Seat {
  final String id;
  final String flightId;
  final String number;
  final SeatClass seatClass;
  final bool isAvailable;
  final String? userId;

  Seat({
    required this.id,
    required this.flightId,
    required this.number,
    required this.seatClass,
    required this.isAvailable,
    this.userId,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['id'].toString(),
      flightId: json['flight_id'].toString(),
      number: json['number'],
      seatClass: SeatClassHelper.fromString(json['seat_class']),
      isAvailable: json['is_available'] ?? true,
      userId: json['user_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'flight_id': flightId,
    'number': number,
    'seat_class': SeatClassHelper.asString(seatClass),
    'is_available': isAvailable,
    'user_id': userId,
  };

  bool isClass(SeatClass clazz) => seatClass == clazz;

  /// 🔥 Static helper for seat prefix (used in SeatMap too)
  static SeatClass? getSeatClassFromPrefix(String seatNumber) {
    if (seatNumber.length < 2) return null;
    final prefix = seatNumber.substring(0, 2).toUpperCase();
    switch (prefix) {
      case 'EC':
        return SeatClass.economy;
      case 'BU':
        return SeatClass.middle;
      case 'EX':
        return SeatClass.executive;
      default:
        return null;
    }
  }
}

class SeatClassHelper {
  static SeatClass fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'executive':
        return SeatClass.executive;
      case 'middle':
      case 'business':
        return SeatClass.middle;
      case 'economy':
      case 'coach':
        return SeatClass.economy;
      default:
        throw ArgumentError('Unknown seat class: $value');
    }
  }

  static String asString(SeatClass clazz) {
    switch (clazz) {
      case SeatClass.executive:
        return 'executive';
      case SeatClass.middle:
        return 'middle';
      case SeatClass.economy:
        return 'economy';
    }
  }
}
