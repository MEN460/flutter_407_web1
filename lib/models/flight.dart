class Flight {
  final String id;
  final String number;
  final String origin;
  final String destination;
  final DateTime departureTime;
  final DateTime? arrivalTime; // New: Arrival time from API
  final Map<String, int> capacities; // e.g., {'executive': 20, 'economy': 150}
  final String? status; // e.g., active, canceled
  final String? assignedEmployeeId; // For admin-assigned flights

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
      number: json['number'] ?? json['flight_number'] ?? 'N/A',
      origin: json['origin'] ?? 'Unknown',
      destination: json['destination'] ?? 'Unknown',
      departureTime:
          DateTime.tryParse(json['departure_time'] ?? '') ?? DateTime.now(),
      arrivalTime: json['arrival_time'] != null
          ? DateTime.tryParse(json['arrival_time'])
          : null,
      capacities: Map<String, int>.from(json['capacities'] ?? {}),
      status: json['status'], // optional
      assignedEmployeeId: json['assigned_employee_id']?.toString(),
    );
  }

  /// Convert Flight to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
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
}
