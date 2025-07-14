import 'package:k_airways_flutter/constants/api_endpoints.dart';
import 'package:k_airways_flutter/models/report.dart';
import 'package:k_airways_flutter/services/api_service.dart';

class ReportService {
  final ApiService _api;

  ReportService(this._api);

  /// Fetch the admin dashboard report
  Future<Report> fetchDashboardReport() async {
    final response = await _api.get(ApiEndpoints.adminDashboardReport);
    return Report.fromJson(response.data);
  }

  /// Generate a custom report for a specific type and date range
  Future<Report> generateCustomReport({
    required String type, // e.g. 'BOOKING', 'FLIGHT', 'USER'
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _api.post(
      '${ApiEndpoints.adminBookingReport}/custom',
      data: {
        'type': type,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      },
    );
    return Report.fromJson(response.data);
  }

  /// Retrieve a list of previously generated reports
  Future<List<Report>> getReportHistory() async {
    final response = await _api.get('${ApiEndpoints.adminBookingReport}/history');
    return (response.data as List)
        .map((json) => Report.fromJson(json))
        .toList();
  }
}
// This service handles report generation and retrieval for the admin dashboard.