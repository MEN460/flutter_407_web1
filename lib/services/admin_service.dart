import 'package:k_airways_flutter/constants/api_endpoints.dart';
import 'package:k_airways_flutter/models/user.dart';
import 'package:k_airways_flutter/services/api_service.dart';
class AdminService {
  final ApiService _api;

  AdminService(this._api);

  Future<List<User>> getAllUsers() async {
    final response = await _api.get(ApiEndpoints.adminUsers);
    return (response.data as List).map((json) => User.fromJson(json)).toList();
  }

  Future<void> createFlight(Map<String, dynamic> flightData) async {
    await _api.post(ApiEndpoints.adminCreateFlight, data: flightData);
  }

  Future<void> assignFlight(int flightId, int employeeId) async {
    await _api.post(
      ApiEndpoints.adminAssignFlight(flightId),
      data: {'employee_id': employeeId},
    );
  }

  Future<List<Map<String, dynamic>>> getFlightSeats(int flightId) async {
    final response = await _api.get(ApiEndpoints.adminFlightSeats(flightId));
    return List<Map<String, dynamic>>.from(response.data['seats']);
  }

  Future<Map<String, dynamic>> getBookingReport() async {
    final response = await _api.get(ApiEndpoints.adminBookingReport);
    return response.data;
  }

  Future<Map<String, dynamic>> getFlightReport() async {
    final response = await _api.get(ApiEndpoints.adminFlightReport);
    return response.data;
  }
}
