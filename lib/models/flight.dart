class Flight {
  final String id;
  final String number;
  final String origin;
  final String destination;
  final DateTime departureTime;
  final DateTime? arrivalTime;
  final Map<String, int> capacities;
  final String? status;
  final String? assignedEmployeeId;

  Flight({
    required this.id,
    required this.number,
    required this.origin,
    required this.destination,
    required this.departureTime,
    this.arrivalTime,
    required this.capacities,
    this.status,
    this.assignedEmployeeId,
  });

  /// Create Flight from JSON
  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id'].toString(),
      // Standardize on 'number' field
      number: json['number'] ?? json['flight_number'] ?? 'N/A',
      origin: json['origin'] ?? 'Unknown',
      destination: json['destination'] ?? 'Unknown',
      departureTime:
          DateTime.tryParse(json['departure_time'] ?? '') ?? DateTime.now(),
      arrivalTime: json['arrival_time'] != null
          ? DateTime.tryParse(json['arrival_time'])
          : null,
      // Ensure capacities are valid positive integers
      capacities: _parseCapacities(json['capacities']),
      status: json['status'],
      assignedEmployeeId: json['assigned_employee_id']?.toString(),
    );
  }

  /// Parse and validate capacities
  static Map<String, int> _parseCapacities(dynamic capacitiesJson) {
    if (capacitiesJson == null) return {};

    final Map<String, int> result = {};
    if (capacitiesJson is Map) {
      capacitiesJson.forEach((key, value) {
        if (value is num && value >= 0) {
          result[key.toString()] = value.toInt();
        }
      });
    }
    return result;
  }

  /// Convert Flight to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number, // Consistent field name
      'origin': origin,
      'destination': destination,
      'departure_time': departureTime.toIso8601String(),
      if (arrivalTime != null) 'arrival_time': arrivalTime!.toIso8601String(),
      'capacities': capacities,
      if (status != null) 'status': status,
      if (assignedEmployeeId != null)
        'assigned_employee_id': assignedEmployeeId,
    };
  }

  /// Validate flight data
  bool get isValid {
    return number.isNotEmpty &&
        origin.isNotEmpty &&
        destination.isNotEmpty &&
        capacities.isNotEmpty &&
        capacities.values.every((capacity) => capacity >= 0);
  }
}
