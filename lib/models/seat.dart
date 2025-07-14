class Seat {
  final String id;
  final String flightId;
  final String number;
  final String seatClass;
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
      seatClass: json['seat_class'],
      isAvailable: json['is_available'] ?? true,
      userId: json['user_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'flight_id': flightId,
    'number': number,
    'seat_class': seatClass,
    'is_available': isAvailable,
    'user_id': userId,
  };

  bool isClass(String clazz) => seatClass.toLowerCase() == clazz.toLowerCase();

  /// 🔥 Static helper
  static String? getSeatClass(String seatNumber) {
    if (seatNumber.length < 2) return null;
    final prefix = seatNumber.substring(0, 2).toUpperCase();
    switch (prefix) {
      case 'EC':
        return 'economy';
      case 'BU':
        return 'business';
      case 'EX':
        return 'executive';
      default:
        return null;
    }
  }
}
