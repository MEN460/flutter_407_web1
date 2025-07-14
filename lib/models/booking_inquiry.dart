class BookingInquiry {
  final String id;
  final int userId;
  final String? bookingId; // Nullable if not tied to a booking
  final String inquiryType; // e.g. 'baggage', 'refund', 'support'
  final String status; // e.g. 'open', 'in_progress', 'closed'
  final String details;
  final String? resolutionNotes; // Only for staff/admin updates
  final DateTime createdAt;

  BookingInquiry({
    required this.id,
    required this.userId,
    this.bookingId,
    required this.inquiryType,
    required this.status,
    required this.details,
    this.resolutionNotes,
    required this.createdAt,
  });

  /// Parse from API JSON
  factory BookingInquiry.fromJson(Map<String, dynamic> json) {
    return BookingInquiry(
      id: json['id'].toString(),
      userId: json['user_id'] as int,
      bookingId: json['booking_id']?.toString(),
      inquiryType: json['inquiry_type'] ?? json['type'] ?? '',
      status: json['status'] ?? 'open',
      details: json['details'] ?? '',
      resolutionNotes: json['resolution_notes'],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      if (bookingId != null) 'booking_id': bookingId,
      'inquiry_type': inquiryType,
      'status': status,
      'details': details,
      if (resolutionNotes != null) 'resolution_notes': resolutionNotes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
// This model represents a booking inquiry, which can be related to a booking or general inquiries. 