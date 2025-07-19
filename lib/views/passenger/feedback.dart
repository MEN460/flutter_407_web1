import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/providers.dart';
import 'package:k_airways_flutter/widgets/rating_stars.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({super.key, required this.flightId});

  final int flightId;

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  static const List<String> _categories = [
    'Booking',
    'Check-in',
    'Staff',
    'Website',
    'In-flight Service',
    'Other',
  ];

  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  final _contentController = TextEditingController();
  int _rating = 0; // Start with no rating to force user selection
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    // Additional validation for rating
    if (_rating == 0) {
      _showErrorSnackBar('Please provide a rating');
      return;
    }

    setState(() => _isSubmitting = true);

    final feedbackService = ref.read(feedbackServiceProvider);

    try {
      await feedbackService.submitFeedback(
        flightId: widget.flightId,
        inquiryType: 'feedback',
        category: _selectedCategory!,
        content: _contentController.text.trim(),
        rating: _rating,
      );

      if (mounted) {
        _showSuccessSnackBar('Feedback submitted successfully!');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to submit feedback. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Feedback'), elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Selection
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          items: _categories
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() {
                            _selectedCategory = value;
                          }),
                          decoration: const InputDecoration(
                            labelText: 'Feedback Category',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
                          ),
                          validator: (value) =>
                              value == null ? 'Please select a category' : null,
                        ),

                        const SizedBox(height: 20),

                        // Feedback Content
                        TextFormField(
                          controller: _contentController,
                          maxLines: 6,
                          maxLength: 500,
                          decoration: const InputDecoration(
                            labelText: 'Your Feedback',
                            hintText: 'Please share your experience...',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.comment),
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Feedback cannot be empty';
                            }
                            if (value.trim().length < 10) {
                              return 'Please provide more detailed feedback';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Rating Section
                        const Text(
                          'Overall Rating',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RatingStars(
                          rating: _rating,
                          onRatingChanged: (rating) {
                            setState(() => _rating = rating);
                          },
                        ),
                        if (_rating > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            _getRatingDescription(_rating),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                      _isSubmitting ? 'Submitting...' : 'Submit Feedback',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getRatingDescription(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }
}
