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

  String? _validateBookingId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Booking ID is required';
    }

    // Assuming booking ID has a specific format (adjust as needed)
    final bookingId = value.trim().toUpperCase();
    if (bookingId.length < 3) {
      return 'Booking ID must be at least 3 characters';
    }

    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(bookingId)) {
      return 'Booking ID should contain only letters and numbers';
    }

    return null;
  }

  String? _validateInquiry(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please describe your inquiry';
    }

    if (value.trim().length < 10) {
      return 'Please provide more details (at least 10 characters)';
    }

    if (value.trim().length > 1000) {
      return 'Inquiry is too long (maximum 1000 characters)';
    }

    return null;
  }

  Future<void> _submitInquiry() async {
    // Clear previous error
    setState(() {
      _submissionError = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final bookingService = ref.read(bookingServiceProvider);

      await bookingService.submitInquiry(
        bookingId: _bookingIdController.text.trim().toUpperCase(),
        message: _inquiryController.text.trim(),
        details: _inquiryController.text
            .trim(), // Using the actual inquiry text
      );

      // Clear form on successful submission
      _bookingIdController.clear();
      _inquiryController.clear();

      if (mounted) {
        _showSuccessMessage();
      }
    } catch (error) {
      setState(() {
        _submissionError = _getErrorMessage(error);
      });

      if (mounted) {
        _showErrorMessage(_submissionError!);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    // Customize based on your error types
    if (error.toString().contains('network')) {
      return 'Network error. Please check your connection and try again.';
    } else if (error.toString().contains('booking not found')) {
      return 'Booking ID not found. Please verify and try again.';
    } else if (error.toString().contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else {
      return 'An error occurred while submitting your inquiry. Please try again.';
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Inquiry submitted successfully'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Inquiry'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildBookingIdField(),
                const SizedBox(height: 24),
                _buildInquiryField(),
                const SizedBox(height: 8),
                _buildCharacterCounter(),
                const SizedBox(height: 32),
                if (_submissionError != null) ...[
                  _buildErrorCard(),
                  const SizedBox(height: 16),
                ],
                _buildSubmitButton(),
                const SizedBox(height: 16),
                _buildHelpText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Have a Question?',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Submit your booking inquiry and our team will get back to you within 24 hours.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingIdField() {
    return TextFormField(
      controller: _bookingIdController,
      decoration: InputDecoration(
        labelText: 'Booking ID*',
        hintText: 'e.g., ABC123',
        prefixIcon: const Icon(Icons.confirmation_number),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      textCapitalization: TextCapitalization.characters,
      validator: _validateBookingId,
      enabled: !_isSubmitting,
      onChanged: (value) {
        // Clear form-level errors when user starts typing
        if (_submissionError != null) {
          setState(() {
            _submissionError = null;
          });
        }
      },
    );
  }

  Widget _buildInquiryField() {
    return TextFormField(
      controller: _inquiryController,
      decoration: InputDecoration(
        labelText: 'Inquiry Details*',
        hintText: 'Please describe your issue or question in detail...',
        prefixIcon: const Icon(Icons.help_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceVariant.withOpacity(0.3),
        alignLabelWithHint: true,
      ),
      maxLines: 6,
      maxLength: 1000,
      validator: _validateInquiry,
      enabled: !_isSubmitting,
      onChanged: (value) {
        // Clear form-level errors when user starts typing
        if (_submissionError != null) {
          setState(() {
            _submissionError = null;
          });
        }
      },
    );
  }

  Widget _buildCharacterCounter() {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Text(
        '${_inquiryController.text.length}/1000 characters',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.end,
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _submissionError!,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submitInquiry,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isSubmitting
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Submitting...'),
              ],
            )
          : const Text(
              'Submit Inquiry',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    );
  }

  Widget _buildHelpText() {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Need Help?',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '• Response time: Within 24 hours\n'
              '• For urgent matters, call our hotline\n'
              '• Have your booking reference ready',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
