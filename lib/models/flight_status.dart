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

  /// Create a copy with optional overrides
  FlightStatus copyWith({
    String? flightId,
    String? status,
    DateTime? estimatedDeparture,
    DateTime? actualDeparture,
    String? gate,
    String? remarks,
  }) {
    return FlightStatus(
      flightId: flightId ?? this.flightId,
      status: status ?? this.status,
      estimatedDeparture: estimatedDeparture ?? this.estimatedDeparture,
      actualDeparture: actualDeparture ?? this.actualDeparture,
      gate: gate ?? this.gate,
      remarks: remarks ?? this.remarks,
    );
  }

  /// Equality operator override
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FlightStatus &&
        other.flightId == flightId &&
        other.status == status &&
        other.estimatedDeparture == estimatedDeparture &&
        other.actualDeparture == actualDeparture &&
        other.gate == gate &&
        other.remarks == remarks;
  }

  /// Hash code override
  @override
  int get hashCode {
    return flightId.hashCode ^
        status.hashCode ^
        estimatedDeparture.hashCode ^
        actualDeparture.hashCode ^
        gate.hashCode ^
        remarks.hashCode;
  }
}
