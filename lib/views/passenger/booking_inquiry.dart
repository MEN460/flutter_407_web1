import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/providers.dart';
import 'package:k_airways_flutter/l10n/app_localizations.dart';

class BookingInquiryScreen extends ConsumerStatefulWidget {
  const BookingInquiryScreen({super.key});

  @override
  ConsumerState<BookingInquiryScreen> createState() =>
      _BookingInquiryScreenState();
}

class _BookingInquiryScreenState extends ConsumerState<BookingInquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bookingIdController = TextEditingController();
  final _inquiryController = TextEditingController();
  bool _isSubmitting = false;
  String? _submissionError;

  @override
  void dispose() {
    _bookingIdController.dispose();
    _inquiryController.dispose();
    super.dispose();
  }

  Future<void> _submitInquiry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });

    try {
      final bookingService = ref.read(bookingServiceProvider);
      await bookingService.submitInquiry(
        bookingId: _bookingIdController.text,
        message: _inquiryController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.thankYouFeedback),
            backgroundColor: Colors.green,
          ),
        );
        _formKey.currentState!.reset();
      }
    } catch (e) {
      setState(() => _submissionError = e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.helpCenter)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.bookingInquiryTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bookingIdController,
                decoration: InputDecoration(
                  labelText: loc.bookingIdLabel,
                  hintText: loc.bookingIdHint,
                  prefixIcon: const Icon(Icons.confirmation_number),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.bookingIdRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _inquiryController,
                decoration: InputDecoration(
                  labelText: loc.inquiryDetails,
                  hintText: loc.inquiryHint,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return loc.inquiryRequired;
                  }
                  if (value.length < 20) {
                    return loc.inquiryTooShort;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_submissionError != null)
                Text(
                  _submissionError!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitInquiry,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : Text(loc.submitButton),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              Text(
                loc.faqSectionTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              _buildFAQItem(loc.faqQuestion1, loc.faqAnswer1),
              _buildFAQItem(loc.faqQuestion2, loc.faqAnswer2),
              _buildFAQItem(loc.faqQuestion3, loc.faqAnswer3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(answer),
        ),
      ],
    );
  }
}
