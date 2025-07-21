import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/models/inquiry_type.dart';
import 'package:k_airways_flutter/providers.dart'
    show bookingServiceProvider, currentUserProvider;

class BookingInquiryScreen extends ConsumerStatefulWidget {
  const BookingInquiryScreen({super.key, String? initialBookingId});

  @override
  ConsumerState<BookingInquiryScreen> createState() =>
      _BookingInquiryScreenState();
}

class _BookingInquiryScreenState extends ConsumerState<BookingInquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bookingIdController = TextEditingController();
  final _inquiryController = TextEditingController();
  final _bookingIdFocusNode = FocusNode();
  final _inquiryFocusNode = FocusNode();

  bool _isSubmitting = false;
  String? _submissionError;

  InquiryType? _selectedInquiryType;

  @override
  void dispose() {
    _bookingIdController.dispose();
    _inquiryController.dispose();
    _bookingIdFocusNode.dispose();
    _inquiryFocusNode.dispose();
    super.dispose();
  }

  String? _validateBookingId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Booking ID is required';
    }

    final bookingService = ref.read(bookingServiceProvider);
    if (!bookingService.isValidBookingId(value)) {
      return 'Invalid booking ID format';
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
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (!mounted) return;
    setState(() {
      _submissionError = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

     // Add validation for inquiry type
    if (_selectedInquiryType == null) {
      if (!mounted) return;
      setState(() => _submissionError = 'Please select an inquiry type');
      _showErrorMessage(_submissionError!);
      return;
    } 

    final bookingId = _bookingIdController.text.trim().toUpperCase();
    if (bookingId.isEmpty) {
      if (!mounted) return;
      setState(() {
        _submissionError = 'Booking ID cannot be empty';
      });
      _showErrorMessage(_submissionError!);
      return;
    }

    final email = ref.read(currentUserProvider)?.email;
    if (email == null) {
      if (!mounted) return;
      setState(() {
        _submissionError = 'Please log in to submit an inquiry';
      });
      _showErrorMessage(_submissionError!);
      return;
    }

    if (!mounted) return;
    setState(() {
      _isSubmitting = true;
    });

    try {
      final bookingService = ref.read(bookingServiceProvider);

      await bookingService.submitInquiry(
        bookingId: bookingId, // Now properly passing the required parameter
        message: _inquiryController.text.trim(),
        priority: InquiryPriority.medium,
        email: email,
        inquiryType: _selectedInquiryType !,
      );

      // Clear form on successful submission
      _bookingIdController.clear();
      _inquiryController.clear();
      setState(() => _selectedInquiryType = null);

      if (mounted) {
        _showSuccessMessage();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _submissionError = _getErrorMessage(error);
        });
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

  void _resetForm() {
    _formKey.currentState?.reset();
    _bookingIdController.clear();
    _inquiryController.clear();
    if (!mounted) return;
    setState(() {
      _submissionError = null;
    });
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network')) {
      return 'Network error. Please check your connection and try again.';
    } else if (errorString.contains('booking not found')) {
      return 'Booking ID not found. Please verify your booking reference.';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('unauthorized')) {
      return 'Session expired. Please log in again.';
    } else if (errorString.contains('invalid booking id')) {
      return 'Invalid booking ID format. Please check and try again.';
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
            Expanded(
              child: Text(
                'Inquiry submitted successfully! We\'ll get back to you within 24 hours.',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Inquiry'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 32),
                _buildBookingIdField(theme, colors),
                const SizedBox(height: 24),
                _buildInquiryTypeDropdown(theme),
                const SizedBox(height: 24),
                _buildInquiryField(theme, colors),
                const SizedBox(height: 8),
                _buildCharacterCounter(theme),
                const SizedBox(height: 32),
                if (_submissionError != null) ...[
                  _buildErrorCard(theme),
                  const SizedBox(height: 16),
                ],
                _buildSubmitButton(),
                if (!_isSubmitting) ...[
                  const SizedBox(height: 8),
                  _buildResetButton(colors),
                ],
                const SizedBox(height: 16),
                _buildHelpText(theme, colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Have a Question?',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Submit your booking inquiry and our team will get back to you within 24 hours.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingIdField(ThemeData theme, ColorScheme colors) {
    return TextFormField(
      controller: _bookingIdController,
      focusNode: _bookingIdFocusNode,
      decoration: InputDecoration(
        labelText: 'Booking Reference*',
        hintText: 'e.g., ABC123 or KA123456',
        prefixIcon: const Icon(Icons.confirmation_number),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: colors.surfaceContainerHighest.withOpacity(0.3),
      ),
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) => _inquiryFocusNode.requestFocus(),
      textCapitalization: TextCapitalization.characters,
      validator: _validateBookingId,
      enabled: !_isSubmitting,
      onChanged: (value) {
        if (_submissionError != null) {
          setState(() {
            _submissionError = null;
          });
        }
      },
    );
  }

  Widget _buildInquiryTypeDropdown(ThemeData theme) {
    return DropdownButtonFormField<InquiryType>(
      value: _selectedInquiryType,
      decoration: InputDecoration(
        labelText: 'Inquiry Type*',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      ),
      items: InquiryType.values.map((type) {
        return DropdownMenuItem<InquiryType>(
          value: type,
          child: Text(type.toString().split('.').last),
        );
      }).toList(),
      onChanged: !_isSubmitting
          ? (InquiryType? newValue) {
              setState(() {
                _selectedInquiryType = newValue;
              });
            }
          : null,
      validator: (value) =>
          value == null ? 'Please select an inquiry type' : null,
    );
  }

  Widget _buildInquiryField(ThemeData theme, ColorScheme colors) {
    return TextFormField(
      controller: _inquiryController,
      focusNode: _inquiryFocusNode,
      decoration: InputDecoration(
        labelText: 'Inquiry Details*',
        hintText: 'Please describe your issue or question in detail...',
        prefixIcon: const Icon(Icons.help_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: colors.surfaceContainerHighest.withOpacity(0.3),
        alignLabelWithHint: true,
      ),
      maxLines: 6,
      maxLength: 1000,
      validator: _validateInquiry,
      enabled: !_isSubmitting,
      onChanged: (value) {
        setState(() {});
        if (_submissionError != null) {
          setState(() {
            _submissionError = null;
          });
        }
      },
    );
  }

  Widget _buildCharacterCounter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Text(
        '${_inquiryController.text.length}/1000 characters',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.end,
      ),
    );
  }

  Widget _buildErrorCard(ThemeData theme) {
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

  Widget _buildResetButton(ColorScheme colors) {
    return TextButton(
      onPressed: _resetForm,
      style: TextButton.styleFrom(foregroundColor: colors.error),
      child: const Text('Reset Form'),
    );
  }

  Widget _buildHelpText(ThemeData theme, ColorScheme colors) {
    return Card(
      color: colors.primaryContainer.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: colors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Need Help?',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '• Response time: Within 24 hours\n'
              '• For urgent matters, call our hotline\n'
              '• Have your booking reference ready\n'
              '• Check your email for responses',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
