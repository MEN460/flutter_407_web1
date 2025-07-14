import 'package:k_airways_flutter/models/flight.dart';
import 'package:k_airways_flutter/models/user.dart';

class MockData {
  static List<Flight> get mockFlights => [
    Flight(
      id: 'FL-001',
      number: 'KQ101',
      origin: 'Nairobi',
      destination: 'Mombasa',
      departureTime: DateTime.now().add(const Duration(days: 1)),
      capacities: {'executive': 12, 'middle': 24, 'economy': 120},
    ),
    Flight(
      id: 'FL-002',
      number: 'KQ202',
      origin: 'Nairobi',
      destination: 'Kisumu',
      departureTime: DateTime.now().add(const Duration(days: 2)),
      capacities: {'executive': 8, 'middle': 16, 'economy': 100},
    ),
    Flight(
      id: 'FL-003',
      number: 'KQ305',
      origin: 'Mombasa',
      destination: 'Dodoma',
      departureTime: DateTime.now().add(const Duration(days: 3)),
      capacities: {'executive': 10, 'middle': 20, 'economy': 150},
    ),
  ];

  static List<User> get mockUsers => [
    User(
      id: 'USR-001',
      email: 'passenger1@example.com',
      role: 'passenger',
      isActive: null,
    ),
    User(
      id: 'USR-002',
      email: 'admin@kenyaairways.com',
      role: 'admin', 
      isActive: null,
     
    ),
    User(
      id: 'USR-003',
      email: 'employee@kenyaairways.com',
      role: 'employee',
      isActive: null,
    ),
  ];
}
