class FeedbackItem {
  final int id;
  final int userId;
  final int flightId; // Linked flight
  final String inquiryType; // e.g., 'baggage', 'booking', etc.
  final String content;
  final int rating; // 1-5
  final DateTime createdAt;

  FeedbackItem({
    required this.id,
    required this.userId,
    required this.flightId,
    required this.inquiryType,
    required this.content,
    required this.rating,
    required this.createdAt,
  });

  factory FeedbackItem.fromJson(Map<String, dynamic> json) {
    return FeedbackItem(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      flightId: json['flight_id'] as int,
      inquiryType: json['inquiry_type'] as String,
      content: json['content'] as String,
      rating: json['rating'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'flight_id': flightId,
      'inquiry_type': inquiryType,
      'content': content,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
