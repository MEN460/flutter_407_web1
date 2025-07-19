class FlightStatus {
  final String flightId;
  final String status;
  final String? route;
  final String? aircraft;
  final DateTime? scheduledDeparture;
  final DateTime? estimatedDeparture;
  final DateTime? actualDeparture;
  final DateTime? scheduledArrival;
  final DateTime? estimatedArrival;
  final DateTime? actualArrival;
  final String? gate;
  final String? arrivalGate;
  final String? terminal;
  final String? remarks;
  final int? delay; // in minutes
  final DateTime? lastUpdated;

  const FlightStatus({
    required this.flightId,
    required this.status,
    this.route,
    this.aircraft,
    this.scheduledDeparture,
    this.estimatedDeparture,
    this.actualDeparture,
    this.scheduledArrival,
    this.estimatedArrival,
    this.actualArrival,
    this.gate,
    this.arrivalGate,
    this.terminal,
    this.remarks,
    this.delay,
    this.lastUpdated,
  });

  /// Factory constructor to parse JSON
  factory FlightStatus.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null) return null;
      return DateTime.tryParse(dateStr);
    }

    return FlightStatus(
      flightId: json['flight_id'].toString(),
      status: json['status'] ?? 'unknown',
      route: json['route'],
      aircraft: json['aircraft'],
      scheduledDeparture: parseDate(json['scheduled_departure']),
      estimatedDeparture: parseDate(json['estimated_departure']),
      actualDeparture: parseDate(json['actual_departure']),
      scheduledArrival: parseDate(json['scheduled_arrival']),
      estimatedArrival: parseDate(json['estimated_arrival']),
      actualArrival: parseDate(json['actual_arrival']),
      gate: json['gate'],
      arrivalGate: json['arrival_gate'],
      terminal: json['terminal'],
      remarks: json['remarks'],
      delay: json['delay'] != null
          ? int.tryParse(json['delay'].toString())
          : null,
      lastUpdated: parseDate(json['last_updated']),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'flight_id': flightId,
      'status': status,
      'route': route,
      'aircraft': aircraft,
      'scheduled_departure': scheduledDeparture?.toIso8601String(),
      'estimated_departure': estimatedDeparture?.toIso8601String(),
      'actual_departure': actualDeparture?.toIso8601String(),
      'scheduled_arrival': scheduledArrival?.toIso8601String(),
      'estimated_arrival': estimatedArrival?.toIso8601String(),
      'actual_arrival': actualArrival?.toIso8601String(),
      'gate': gate,
      'arrival_gate': arrivalGate,
      'terminal': terminal,
      'remarks': remarks,
      'delay': delay,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }

  /// Create a copy with optional overrides
  FlightStatus copyWith({
    String? flightId,
    String? status,
    String? route,
    String? aircraft,
    DateTime? scheduledDeparture,
    DateTime? estimatedDeparture,
    DateTime? actualDeparture,
    DateTime? scheduledArrival,
    DateTime? estimatedArrival,
    DateTime? actualArrival,
    String? gate,
    String? arrivalGate,
    String? terminal,
    String? remarks,
    int? delay,
    DateTime? lastUpdated,
  }) {
    return FlightStatus(
      flightId: flightId ?? this.flightId,
      status: status ?? this.status,
      route: route ?? this.route,
      aircraft: aircraft ?? this.aircraft,
      scheduledDeparture: scheduledDeparture ?? this.scheduledDeparture,
      estimatedDeparture: estimatedDeparture ?? this.estimatedDeparture,
      actualDeparture: actualDeparture ?? this.actualDeparture,
      scheduledArrival: scheduledArrival ?? this.scheduledArrival,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      actualArrival: actualArrival ?? this.actualArrival,
      gate: gate ?? this.gate,
      arrivalGate: arrivalGate ?? this.arrivalGate,
      terminal: terminal ?? this.terminal,
      remarks: remarks ?? this.remarks,
      delay: delay ?? this.delay,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Equality operator override
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FlightStatus &&
        other.flightId == flightId &&
        other.status == status &&
        other.route == route &&
        other.aircraft == aircraft &&
        other.scheduledDeparture == scheduledDeparture &&
        other.estimatedDeparture == estimatedDeparture &&
        other.actualDeparture == actualDeparture &&
        other.scheduledArrival == scheduledArrival &&
        other.estimatedArrival == estimatedArrival &&
        other.actualArrival == actualArrival &&
        other.gate == gate &&
        other.arrivalGate == arrivalGate &&
        other.terminal == terminal &&
        other.remarks == remarks &&
        other.delay == delay &&
        other.lastUpdated == lastUpdated;
  }

  /// Hash code override
  @override
  int get hashCode {
    return Object.hashAll([
      flightId,
      status,
      route,
      aircraft,
      scheduledDeparture,
      estimatedDeparture,
      actualDeparture,
      scheduledArrival,
      estimatedArrival,
      actualArrival,
      gate,
      arrivalGate,
      terminal,
      remarks,
      delay,
      lastUpdated,
    ]);
  }
}
