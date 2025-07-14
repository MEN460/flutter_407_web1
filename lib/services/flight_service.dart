import 'package:k_airways_flutter/constants/api_endpoints.dart';
import 'package:k_airways_flutter/models/flight.dart';
import 'package:k_airways_flutter/models/flight_status.dart';
import 'package:k_airways_flutter/services/api_service.dart';
import 'package:k_airways_flutter/utils/logger.dart';

class FlightService {
  final ApiService _api;
  final Logger _logger;

  FlightService(this._api, this._logger);

  /// Get all available flights
  Future<List<Flight>> getFlights() async {
    try {
      final response = await _api.get(ApiEndpoints.flights);
      return (response.data as List)
          .map((json) => Flight.fromJson(json))
          .toList();
    } catch (e, stack) {
      _logger.error('Failed to fetch flights: $e', stack);
      rethrow;
    }
  }

  /// Get the status of a specific flight
  Future<FlightStatus> getFlightStatus(String flightId) async {
    try {
      _logger.info('Fetching flight status for $flightId', 'FlightService');
      final response = await _api.get(ApiEndpoints.flightStatus(flightId));
      return FlightStatus.fromJson(response.data);
    } catch (e, stack) {
      _logger.error('Failed to fetch status for flight $flightId: $e', stack);
      rethrow;
    }
  }

  /// Update the status of a specific flight
  Future<void> updateFlightStatus(String flightId, FlightStatus status) async {
    try {
      await _api.post(
        ApiEndpoints.flightStatus(flightId),
        data: status.toJson(),
      );
      _logger.info('Updated status for flight $flightId', 'FlightService');
    } catch (e, stack) {
      _logger.error('Failed to update flight status: $e', stack);
      rethrow;
    }
  }

  /// Search flights with filters (e.g. origin, destination, date)
  Future<List<Flight>> searchFlights(Map<String, dynamic> filters) async {
    try {
      final response = await _api.get(ApiEndpoints.flights, params: filters);
      return (response.data as List)
          .map((json) => Flight.fromJson(json))
          .toList();
    } catch (e, stack) {
      _logger.error('Flight search failed: $e', stack);
      rethrow;
    }
  }

  /// Get flights assigned to an employee (for staff dashboard)
  Future<List<Flight>> getAssignedFlights(String employeeId) async {
    try {
      final response = await _api.get(ApiEndpoints.employeeFlights);
      return (response.data as List)
          .map((json) => Flight.fromJson(json))
          .toList();
    } catch (e, stack) {
      _logger.error('Failed to fetch assigned flights: $e', stack);
      rethrow;
    }
  }

  /// Create a new flight (admin-only)
  Future<void> createFlight(Flight flight) async {
    try {
      await _api.post(ApiEndpoints.flights, data: flight.toJson());
      _logger.info('Created new flight', 'FlightService');
    } catch (e, stack) {
      _logger.error('Failed to create flight: $e', stack);
      rethrow;
    }
  }
}
