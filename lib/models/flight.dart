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
    final String flightNumber; // ADD THIS
  final String airline; // ADD THIS
  final String aircraft; // ADD THIS
  final double basePrice; // ADD THIS
  final Duration duration; // ADD THIS


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
    required this.flightNumber,
    required this.airline,
    required this.aircraft,
    required this.basePrice,
    required this.duration,
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
      flightNumber: json['flight_number']?.toString() ?? 'N/A',
      airline: json['airline']?.toString() ?? 'Unknown',
      aircraft: json['aircraft']?.toString() ?? 'Unknown',
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      duration: Duration(minutes: (json['duration'] as num?)?.toInt() ?? 0),
     
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
      'flight_number': flightNumber,
      'airline': airline,
      'aircraft': aircraft,
      'base_price': basePrice,
      'duration': duration.inMinutes, // Store duration in minutes
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
