class FlightStatus {
  final String flightId;
  final String status;
  final DateTime? estimatedDeparture;
  final DateTime? actualDeparture;
  final String? gate;
  final String? remarks;

  FlightStatus({
    required this.flightId,
    required this.status,
    this.estimatedDeparture,
    this.actualDeparture,
    this.gate,
    this.remarks,
  });

  /// Factory constructor to parse JSON
  factory FlightStatus.fromJson(Map<String, dynamic> json) {
    return FlightStatus(
      flightId: json['flight_id'].toString(),
      status: json['status'] ?? 'unknown',
      estimatedDeparture: json['estimated_departure'] != null
          ? DateTime.tryParse(json['estimated_departure'])
          : null,
      actualDeparture: json['actual_departure'] != null
          ? DateTime.tryParse(json['actual_departure'])
          : null,
      gate: json['gate'], // may be null
      remarks: json['remarks'], // may be null
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'flight_id': flightId,
      'status': status,
      'estimated_departure': estimatedDeparture?.toIso8601String(),
      'actual_departure': actualDeparture?.toIso8601String(),
      'gate': gate,
      'remarks': remarks,
    };
  }
}
// This class represents the status of a flight, including its ID, status, estimated and actual departure times, gate information, and any remarks.
// It includes methods for parsing from JSON and converting to JSON format.