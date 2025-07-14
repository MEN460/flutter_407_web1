class Report {
  final String id;
  final String type; // 'BOOKING', 'FLIGHT', 'USER'
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, dynamic> data;
  final DateTime generatedAt;

  Report({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.data,
    required this.generatedAt,
  });

  /// Factory constructor for parsing JSON
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'].toString(),
      type: json['type'] ?? 'UNKNOWN',
      startDate: DateTime.tryParse(json['start_date']) ?? DateTime.now(),
      endDate: DateTime.tryParse(json['end_date']) ?? DateTime.now(),
      data: json['data'] ?? <String, dynamic>{},
      generatedAt: DateTime.tryParse(json['generated_at']) ?? DateTime.now(),
    );
  }

  /// Convert Report to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'data': data,
      'generated_at': generatedAt.toIso8601String(),
    };
  }
}
