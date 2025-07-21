import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/providers.dart';
import 'package:k_airways_flutter/l10n/app_localizations.dart';


import 'package:k_airways_flutter/models/inquiry_type.dart';

class BookingInquiryScreen extends ConsumerStatefulWidget {
  const BookingInquiryScreen({super.key});

  

  @override
  ConsumerState<BookingInquiryScreen> createState() =>
      _BookingInquiryScreenState();
}

class _BookingInquiryScreenState extends ConsumerState<BookingInquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _bookingIdController = TextEditingController();
  final _inquiryController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isSubmitting = false;
  String? _submissionError;
  InquiryType _selectedInquiryType = InquiryType.general;
  InquiryPriority _selectedPriority = InquiryPriority.medium;

  @override
  void dispose() {
    _scrollController.dispose();
    _bookingIdController.dispose();
    _inquiryController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitInquiry() async {
    if (!_formKey.currentState!.validate()) {
      _scrollToError();
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submissionError = null;
    });

    try {
      final bookingService = ref.read(bookingServiceProvider);
      await bookingService.submitInquiry(
        bookingId: _bookingIdController.text.trim().isEmpty
            ? null
            : _bookingIdController.text.trim(),
        message: _inquiryController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        inquiryType: _selectedInquiryType,
        priority: _selectedPriority,
        details: 'Inquiry about ${_selectedInquiryType.displayName}',
      );

      if (mounted) {
        _showSuccessDialog();
        _resetForm();
      }
    } catch (e) {
      setState(() => _submissionError = _parseError(e));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _scrollToError() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _bookingIdController.clear();
    _inquiryController.clear();
    _emailController.clear();
    setState(() {
      _selectedInquiryType = InquiryType.general;
      _selectedPriority = InquiryPriority.medium;
      _submissionError = null;
    });
  }

  void _showSuccessDialog() {
    final loc = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.primary,
          size: 48,
        ),
        title: Text(loc.inquirySubmittedTitle),
        content: Text(loc.inquirySubmittedMessage),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(loc.okButton),
          ),
        ],
      ),
    );
  }

  String _parseError(Object error) {
    final errorStr = error.toString().toLowerCase();
    final loc = AppLocalizations.of(context)!;

    if (errorStr.contains('network') || errorStr.contains('connection')) {
      return loc.networkError;
    } else if (errorStr.contains('timeout')) {
      return loc.timeoutError;
    } else if (errorStr.contains('booking not found') ||
        errorStr.contains('404')) {
      return loc.bookingNotFoundError;
    } else if (errorStr.contains('unauthorized') || errorStr.contains('401')) {
      return loc.authenticationError;
    } else if (errorStr.contains('forbidden') || errorStr.contains('403')) {
      return loc.authenticationError;
    } else if (errorStr.contains('invalid email')) {
      return loc.emailInvalidFormat;
    } else if (errorStr.contains('invalid booking id')) {
      return loc.bookingIdInvalidFormat;
    } else {
      return loc.generalError;
    }
  }

  String _getInquiryTypeLabel(InquiryType type) {
    final loc = AppLocalizations.of(context)!;

    // Use the centralized display name from the enum, but fallback to localized strings
    switch (type) {
      case InquiryType.general:
        return loc.inquiryTypeGeneral;
      case InquiryType.cancellation:
        return loc.inquiryTypeCancellation;
      case InquiryType.refund:
        return loc.inquiryTypeRefund;
      case InquiryType.modification:
        return loc.inquiryTypeModification;
      case InquiryType.seatChange:
        return loc.inquiryTypeSeatChange;
      case InquiryType.baggage:
        return loc.inquiryTypeBaggage;
      case InquiryType.checkin:
        return loc.inquiryTypeCheckin;
      case InquiryType.flightChange:
        return loc.inquiryTypeFlightChange;
      case InquiryType.specialAssistance:
        return loc.inquiryTypeSpecialAssistance;
      case InquiryType.complaint:
        return loc.inquiryTypeComplaint;
      case InquiryType.feedback:
        return loc.inquiryTypeFeedback;
      case InquiryType.other:
        return loc.inquiryTypeOther;
    }
  }

  String _getPriorityLabel(InquiryPriority priority) {
    final loc = AppLocalizations.of(context)!;

    switch (priority) {
      case InquiryPriority.low:
        return loc.priorityLow;
      case InquiryPriority.medium:
        return loc.priorityMedium;
      case InquiryPriority.high:
        return loc.priorityHigh;
      case InquiryPriority.urgent:
        return loc.priorityUrgent;
    }
  }

  IconData _getInquiryTypeIcon(InquiryType type) {
    switch (type) {
      case InquiryType.general:
        return Icons.help_outline;
      case InquiryType.cancellation:
        return Icons.cancel_outlined;
      case InquiryType.refund:
        return Icons.money_off;
      case InquiryType.modification:
        return Icons.edit_outlined;
      case InquiryType.seatChange:
        return Icons.airline_seat_recline_normal;
      case InquiryType.baggage:
        return Icons.luggage;
      case InquiryType.checkin:
        return Icons.check_circle_outline;
      case InquiryType.flightChange:
        return Icons.flight_takeoff;
      case InquiryType.specialAssistance:
        return Icons.accessible;
      case InquiryType.complaint:
        return Icons.report_outlined;
      case InquiryType.feedback:
        return Icons.feedback_outlined;
      case InquiryType.other:
        return Icons.more_horiz;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.helpCenter),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              Card(
                elevation: 0,
                color: colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.support_agent,
                            color: colorScheme.onPrimaryContainer,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              loc.bookingInquiryTitle,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.bookingInquirySubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Inquiry Type Selection
              Text(
                loc.inquiryTypeLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<InquiryType>(
                value: _selectedInquiryType,
                decoration: InputDecoration(
                  prefixIcon: Icon(_getInquiryTypeIcon(_selectedInquiryType)),
                  border: const OutlineInputBorder(),
                  hintText: loc.selectInquiryType,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                ),
                items: InquiryType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(_getInquiryTypeIcon(type), size: 20),
                        const SizedBox(width: 8),
                        Text(_getInquiryTypeLabel(type)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedInquiryType = value);
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return loc.inquiryTypeRequired;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Priority Selection
              Text(
                loc.priorityLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<InquiryPriority>(
                value: _selectedPriority,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.priority_high),
                  border: const OutlineInputBorder(),
                  hintText: loc.selectPriority,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                ),
                items: InquiryPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(_getPriorityLabel(priority)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedPriority = value);
                  }
                },
              ),

              const SizedBox(height: 20),

              // Booking ID Field (Optional)
              Text(
                '${loc.bookingIdLabel} (${loc.optionalField})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bookingIdController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: loc.bookingIdHint,
                  prefixIcon: const Icon(Icons.confirmation_number),
                  border: const OutlineInputBorder(),
                  helperText: loc.bookingIdHelper,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final bookingService = ref.read(bookingServiceProvider);
                    if (!bookingService.isValidBookingId(value.trim())) {
                      return loc.bookingIdInvalidFormat;
                    }
                  }
                  return null;
                },
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    final text = value.toUpperCase();
                    _bookingIdController.value = _bookingIdController.value
                        .copyWith(
                          text: text,
                          selection: TextSelection.collapsed(
                            offset: text.length,
                          ),
                        );
                  }
                },
              ),

              const SizedBox(height: 20),

              // Email Field (Optional)
              Text(
                '${loc.emailLabel} (${loc.optionalField})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: loc.emailHint,
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: const OutlineInputBorder(),
                  helperText: loc.emailHelper,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final bookingService = ref.read(bookingServiceProvider);
                    if (!bookingService.isValidEmail(value.trim())) {
                      return loc.emailInvalidFormat;
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Inquiry Details
              Text(
                loc.inquiryDetails,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _inquiryController,
                decoration: InputDecoration(
                  hintText: loc.inquiryHint,
                  border: const OutlineInputBorder(),
                  helperText: loc.inquiryHelper,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                maxLength: 1000,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return loc.inquiryRequired;
                  }
                  if (value.trim().length < 20) {
                    return loc.inquiryTooShort;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Error Display
              if (_submissionError != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.error.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: colorScheme.onErrorContainer,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _submissionError!,
                          style: TextStyle(
                            color: colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submitInquiry,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    _isSubmitting ? loc.submittingButton : loc.submitButton,
                  ),
                  style: FilledButton.styleFrom(
                    textStyle: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Contact Alternatives
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.alternativeContactTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildContactOption(
                        icon: Icons.phone,
                        title: loc.phoneSupport,
                        subtitle: loc.phoneSupportNumber,
                        onTap: () {
                          // TODO: Implement phone call functionality
                        },
                      ),
                      const Divider(height: 24),
                      _buildContactOption(
                        icon: Icons.email,
                        title: loc.emailSupport,
                        subtitle: loc.emailSupportAddress,
                        onTap: () {
                          // TODO: Implement email functionality
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // FAQ Section
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerLow,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.quiz_outlined,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            loc.faqSectionTitle,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildFAQItem(loc.faqQuestion1, loc.faqAnswer1),
                      _buildFAQItem(loc.faqQuestion2, loc.faqAnswer2),
                      _buildFAQItem(loc.faqQuestion3, loc.faqAnswer3),
                      _buildFAQItem(loc.faqQuestion4, loc.faqAnswer4),
                      _buildFAQItem(loc.faqQuestion5, loc.faqAnswer5),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 16.0, left: 4.0),
        shape: const Border(),
        title: Text(
          question,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
