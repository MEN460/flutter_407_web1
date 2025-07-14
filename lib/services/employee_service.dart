import 'package:k_airways_flutter/constants/api_endpoints.dart';
import 'package:k_airways_flutter/models/booking.dart';
import 'package:k_airways_flutter/models/flight.dart';
import 'package:k_airways_flutter/services/api_service.dart';

class EmployeeService {
  final ApiService _api;

  EmployeeService(this._api);

  Future<List<Flight>> getAssignedFlights() async {
    final response = await _api.get(ApiEndpoints.employeeFlights);
    return (response.data['data'] as List)
        .map((json) => Flight.fromJson(json))
        .toList();
  }

  Future<void> updateFlightStatus(
    int flightId,
    String eventType, {
    String? details,
  }) async {
    await _api.post(
      ApiEndpoints.employeeUpdateFlightStatus(flightId),
      data: {'event_type': eventType, if (details != null) 'details': details},
    );
  }

  Future<List<Booking>> getPassengerList(int flightId) async {
    final response = await _api.get(
      ApiEndpoints.employeePassengerList(flightId),
    );
    return (response.data['data'] as List)
        .map((json) => Booking.fromJson(json))
        .toList();
  }

  Future<void> checkInPassenger(int flightId, int userId) async {
    await _api.post(ApiEndpoints.employeeCheckInPassenger(flightId, userId));
  }
}
