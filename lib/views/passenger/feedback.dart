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
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  final _contentController = TextEditingController();
  int _rating = 3;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit feedback: $e')),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Feedback')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: ['Booking', 'Check-in', 'Staff', 'Website']
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (value) => setState(() {
                  _selectedCategory = value;
                }),
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (v) => v == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Your Feedback',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.isEmpty)
                    ? 'Feedback cannot be empty'
                    : null,
              ),
              const SizedBox(height: 16),
              const Text('Rating:'),
              RatingStars(
                rating: _rating,
                onRatingChanged: (rating) {
                  setState(() => _rating = rating);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitFeedback,
                icon: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.send),
                label: const Text('Submit Feedback'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
