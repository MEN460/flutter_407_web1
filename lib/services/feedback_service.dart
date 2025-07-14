import 'package:k_airways_flutter/constants/api_endpoints.dart';
import 'package:k_airways_flutter/models/feedback.dart';
import 'package:k_airways_flutter/services/api_service.dart';

class FeedbackService {
  final ApiService _api;

  FeedbackService(this._api);

  /// Submit feedback for a flight
  Future<FeedbackItem> submitFeedback({
    required int flightId,
    required String inquiryType,
    required String content,
    required int rating, required String category,
  }) async {
    final response = await _api.post(
      ApiEndpoints.feedback,
      data: {
        'flight_id': flightId,
        'inquiry_type': inquiryType,
        'content': content,
        'rating': rating,
      },
    );

    return FeedbackItem.fromJson(response.data['feedback']);
  }

  /// Get all feedback submitted by current user
  Future<List<FeedbackItem>> getUserFeedback() async {
    final response = await _api.get(ApiEndpoints.feedback);

    final feedbackList = response.data['feedbacks'] as List;
    return feedbackList.map((json) => FeedbackItem.fromJson(json)).toList();
  }

  /// Admin: Get all feedback in the system
  Future<List<FeedbackItem>> getAllFeedbackAdmin() async {
    final response = await _api.get('${ApiEndpoints.feedback}/admin');

    final feedbackList = response.data['feedbacks'] as List;
    return feedbackList.map((json) => FeedbackItem.fromJson(json)).toList();
  }

  /// Admin: Delete feedback by ID
  Future<void> deleteFeedback(int feedbackId) async {
    await _api.delete('${ApiEndpoints.feedback}/$feedbackId');
  }
}
