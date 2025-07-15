import 'package:k_airways_flutter/constants/api_endpoints.dart';
import 'package:k_airways_flutter/models/booking_inquiry.dart';
import 'package:k_airways_flutter/services/api_service.dart';
import 'package:k_airways_flutter/utils/logger.dart';

class HelpService {
  final ApiService _api;

  HelpService(this._api);

  /// Submit a new help ticket (passenger-only)
  Future<BookingInquiry> createHelpTicket({
    required String type,
    required String details,
  }) async {
    try {
      final response = await _api.post(
        ApiEndpoints.helpTickets,
        data: {'type': type, 'details': details},
      );
      Logger.logInfo('Help ticket created successfully.');
      return BookingInquiry.fromJson(response.data['ticket']);
    } catch (e) {
      Logger.logError('Failed to create help ticket: $e');
      rethrow;
    }
  }

  /// Get help tickets for the current user
  Future<List<BookingInquiry>> getUserHelpTickets() async {
    try {
      final response = await _api.get(ApiEndpoints.helpTickets);
      return (response.data as List)
          .map((json) => BookingInquiry.fromJson(json))
          .toList();
    } catch (e) {
      Logger.logError('Failed to fetch user help tickets: $e');
      rethrow;
    }
  }

  /// Get details of a specific help ticket
  Future<BookingInquiry> getHelpTicketDetails(int ticketId) async {
    try {
      final response = await _api.get('${ApiEndpoints.helpTickets}/$ticketId');
      return BookingInquiry.fromJson(response.data);
    } catch (e) {
      Logger.logError('Failed to fetch help ticket $ticketId: $e');
      rethrow;
    }
  }

  /// Update a help ticket (staff/admin only)
  Future<void> updateHelpTicket({
    required int ticketId,
    String? status, // e.g. 'in_progress', 'closed'
    String? resolutionNotes,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (status != null) updates['status'] = status;
      if (resolutionNotes != null) {
        updates['resolution_notes'] = resolutionNotes;
      }

      await _api.put(
        '${ApiEndpoints.helpTickets}/$ticketId/update',
        data: updates,
      );
      Logger.logInfo('Help ticket $ticketId updated successfully.');
    } catch (e) {
      Logger.logError('Failed to update help ticket $ticketId: $e');
      rethrow;
    }
  }

  /// Get all help tickets (admin/staff)
  Future<List<BookingInquiry>> getAllHelpTickets() async {
    try {
      final response = await _api.get('${ApiEndpoints.helpTickets}/admin');
      return (response.data['feedbacks'] as List)
          .map((json) => BookingInquiry.fromJson(json))
          .toList();
    } catch (e) {
      Logger.logError('Failed to fetch all help tickets: $e');
      rethrow;
    }
  }

  /// Get public knowledge base articles
  Future<List<Map<String, dynamic>>> getKnowledgeBaseArticles() async {
    try {
      final response = await _api.get(ApiEndpoints.knowledgeBase);
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      Logger.logError('Failed to fetch knowledge base articles: $e');
      rethrow;
    }
  }

  /// Get details of a specific knowledge base article
  Future<Map<String, dynamic>> getKnowledgeBaseArticle(int articleId) async {
    try {
      final response = await _api.get(ApiEndpoints.knowledgeArticle(articleId));
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      Logger.logError('Failed to fetch knowledge article $articleId: $e');
      rethrow;
    }
  }
}
