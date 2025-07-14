import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/providers.dart';

class BookingInquiryScreen extends ConsumerStatefulWidget {
  const BookingInquiryScreen({super.key});

  @override
  ConsumerState<BookingInquiryScreen> createState() =>
      _BookingInquiryScreenState();
}

class _BookingInquiryScreenState extends ConsumerState<BookingInquiryScreen> {
  final _bookingIdController = TextEditingController();
  final _inquiryController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitInquiry() async {
    if (_bookingIdController.text.isEmpty || _inquiryController.text.isEmpty) {
      return;
    }

    setState(() => _isSubmitting = true);
    final bookingService = ref.read(bookingServiceProvider);
   await bookingService.submitInquiry(
      bookingId: _bookingIdController.text,
      message: _inquiryController.text, details: '',
    );
    setState(() => _isSubmitting = false);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inquiry submitted successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Inquiry')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _bookingIdController,
              decoration: const InputDecoration(
                labelText: 'Booking ID',
                hintText: 'Enter booking reference',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _inquiryController,
              decoration: const InputDecoration(
                labelText: 'Inquiry Details',
                hintText: 'Describe the issue...',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitInquiry,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('Submit Inquiry'),
            ),
          ],
        ),
      ),
    );
  }
}
