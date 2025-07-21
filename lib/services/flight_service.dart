import 'package:k_airways_flutter/constants/api_endpoints.dart';
import 'package:k_airways_flutter/models/flight.dart';
import 'package:k_airways_flutter/models/flight_status.dart';
import 'package:k_airways_flutter/services/api_service.dart';
import 'package:k_airways_flutter/utils/logger.dart';

class FlightService {
  final ApiService _api;
  final Logger _logger;

  FlightService(this._api, this._logger);

  /// ✅ Get all available flights with improved error handling
  Future<List<Flight>> getFlights() async {
    try {
      final response = await _api.get(ApiEndpoints.flights);
      final data = response.data;

      // Enhanced response structure handling
      List<dynamic>? flightsJson;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('flights')) {
          flightsJson = data['flights'] as List<dynamic>?;
        } else if (data.containsKey('data')) {
          final dataSection = data['data'];
          if (dataSection is List) {
            flightsJson = dataSection;
          } else if (dataSection is Map && dataSection.containsKey('flights')) {
            flightsJson = dataSection['flights'] as List<dynamic>?;
          }
        }
      } else if (data is List) {
        flightsJson = data;
      }

      if (flightsJson == null || flightsJson.isEmpty) {
        _logger.info('No flights data found in response', 'FlightService');
        return []; // Return empty list instead of throwing
      }

      return flightsJson
          .map((json) => Flight.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      _logger.error('Failed to fetch flights: $e', stack);
      // Return empty list for UI graceful handling instead of rethrowing
      return [];
    }
  }

  /// ✅ Get the status of a specific flight
  Future<FlightStatus> getFlightStatus(String flightId) async {
    try {
      _logger.info('Fetching flight status for $flightId', 'FlightService');
      final response = await _api.get(ApiEndpoints.flightStatus(flightId));
      return FlightStatus.fromJson(response.data);
    } catch (e, stack) {
      _logger.error('Failed to fetch status for flight $flightId: $e', stack);
      rethrow; // Keep original behavior for this method since provider expects non-null
    }
  }

  /// ✅ Update the status of a specific flight
  Future<bool> updateFlightStatus(String flightId, FlightStatus status) async {
    try {
      await _api.post(
        ApiEndpoints.flightStatus(flightId),
        data: status.toJson(),
      );
      _logger.info('Updated status for flight $flightId', 'FlightService');
      return true;
    } catch (e, stack) {
      _logger.error('Failed to update flight status: $e', stack);
      return false; // Return false instead of rethrowing
    }
  }

  /// ✅ Search flights with filters with improved error handling
  Future<List<Flight>> searchFlights(Map<String, dynamic> filters) async {
    try {
      final response = await _api.get(ApiEndpoints.flights, params: filters);
      final data = response.data;

      // Enhanced response structure handling (same as getFlights)
      List<dynamic>? flightsJson;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('flights')) {
          flightsJson = data['flights'] as List<dynamic>?;
        } else if (data.containsKey('data')) {
          final dataSection = data['data'];
          if (dataSection is List) {
            flightsJson = dataSection;
          } else if (dataSection is Map && dataSection.containsKey('flights')) {
            flightsJson = dataSection['flights'] as List<dynamic>?;
          }
        }
      } else if (data is List) {
        flightsJson = data;
      }

      if (flightsJson == null || flightsJson.isEmpty) {
        _logger.info('No flights found for filters: $filters', 'FlightService');
        return []; // Return empty list instead of throwing
      }

      return flightsJson
          .map((json) => Flight.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      _logger.error('Flight search failed: $e', stack);
      return []; // Return empty list for graceful UI handling
    }
  }

  /// ✅ Get flights assigned to an employee with improved error handling
  Future<List<Flight>> getAssignedFlights(String employeeId) async {
    try {
      final response = await _api.get(ApiEndpoints.employeeFlights);
      final data = response.data;

      // Enhanced response structure handling
      List<dynamic>? flightsJson;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('flights')) {
          flightsJson = data['flights'] as List<dynamic>?;
        } else if (data.containsKey('data')) {
          final dataSection = data['data'];
          if (dataSection is List) {
            flightsJson = dataSection;
          } else if (dataSection is Map && dataSection.containsKey('flights')) {
            flightsJson = dataSection['flights'] as List<dynamic>?;
          }
        }
      } else if (data is List) {
        flightsJson = data;
      }

      if (flightsJson == null || flightsJson.isEmpty) {
        _logger.info(
          'No assigned flights found for employee $employeeId',
          'FlightService',
        );
        return []; // Return empty list instead of throwing
      }

      return flightsJson
          .map((json) => Flight.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      _logger.error('Failed to fetch assigned flights: $e', stack);
      return []; // Return empty list for graceful UI handling
    }
  }

  /// ✅ Create a new flight (admin-only) with better error handling
  Future<bool> createFlight(Flight flight) async {
    try {
      await _api.post(ApiEndpoints.flights, data: flight.toJson());
      _logger.info('Created new flight', 'FlightService');
      return true;
    } catch (e, stack) {
      _logger.error('Failed to create flight: $e', stack);
      return false; // Return false instead of rethrowing
    }
  }
}
