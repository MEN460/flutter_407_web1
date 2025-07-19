import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/providers.dart';
import 'package:k_airways_flutter/l10n/app_localizations.dart';

enum InquiryType { general, refund, modification, baggage, checkin, complaint }

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

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    _scrollController.dispose();
    _bookingIdController.dispose();
    _inquiryController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitInquiry() async {
    if (!_formKey.currentState!.validate()) {
      // Scroll to first error field
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
        bookingId: _bookingIdController.text.trim(),
        message: _inquiryController.text.trim(),
        email: _emailController.text.trim(),
        inquiryType: _selectedInquiryType,
        details:
            'Inquiry about booking - ${_getInquiryTypeLabel(_selectedInquiryType)}',
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

    if (errorStr.contains('network') || errorStr.contains('internet')) {
      return loc.networkError;
    } else if (errorStr.contains('timeout')) {
      return loc.timeoutError;
    } else if (errorStr.contains('404')) {
      return loc.bookingNotFoundError;
    } else if (errorStr.contains('401') || errorStr.contains('403')) {
      return loc.authenticationError;
    } else {
      return loc.generalError;
    }
  }

  String _getInquiryTypeLabel(InquiryType type) {
    final loc = AppLocalizations.of(context)!;
    switch (type) {
      case InquiryType.general:
        return loc.inquiryTypeGeneral;
      case InquiryType.refund:
        return loc.inquiryTypeRefund;
      case InquiryType.modification:
        return loc.inquiryTypeModification;
      case InquiryType.baggage:
        return loc.inquiryTypeBaggage;
      case InquiryType.checkin:
        return loc.inquiryTypeCheckin;
      case InquiryType.complaint:
        return loc.inquiryTypeComplaint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(loc.helpCenter), centerTitle: true),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                              style: theme.textTheme.titleLarge?.copyWith(
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
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<InquiryType>(
                value: _selectedInquiryType,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.category),
                  border: const OutlineInputBorder(),
                  hintText: loc.selectInquiryType,
                ),
                items: InquiryType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getInquiryTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedInquiryType = value!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return loc.inquiryTypeRequired;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Booking ID Field
              Text(
                loc.bookingIdLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
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
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return loc.bookingIdRequired;
                  }
                  if (value.trim().length < 6) {
                    return loc.bookingIdTooShort;
                  }
                  // Add format validation if needed
                  final bookingIdRegex = RegExp(r'^[A-Z0-9]{6,}$');
                  if (!bookingIdRegex.hasMatch(value.trim().toUpperCase())) {
                    return loc.bookingIdInvalidFormat;
                  }
                  return null;
                },
                onChanged: (value) {
                  // Auto-format to uppercase
                  final text = value.toUpperCase();
                  _bookingIdController.value = _bookingIdController.value
                      .copyWith(
                        text: text,
                        selection: TextSelection.collapsed(offset: text.length),
                      );
                },
              ),

              const SizedBox(height: 20),

              // Email Field
              Text(
                loc.emailLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: loc.emailHint,
                  prefixIcon: const Icon(Icons.email),
                  border: const OutlineInputBorder(),
                  helperText: loc.emailHelper,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return loc.emailRequired;
                  }
                  final emailRegex = RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  );
                  if (!emailRegex.hasMatch(value.trim())) {
                    return loc.emailInvalidFormat;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Inquiry Details
              Text(
                loc.inquiryDetails,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _inquiryController,
                decoration: InputDecoration(
                  hintText: loc.inquiryHint,
                  border: const OutlineInputBorder(),
                  helperText: loc.inquiryHelper,
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: colorScheme.onErrorContainer,
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
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    _isSubmitting ? loc.submittingButton : loc.submitButton,
                  ),
                  style: FilledButton.styleFrom(
                    textStyle: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Contact Alternatives
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.alternativeContactTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildContactOption(
                        icon: Icons.phone,
                        title: loc.phoneSupport,
                        subtitle: loc.phoneSupportNumber,
                        onTap: () {
                          // Implement phone call functionality
                        },
                      ),
                      const Divider(),
                      _buildContactOption(
                        icon: Icons.email,
                        title: loc.emailSupport,
                        subtitle: loc.emailSupportAddress,
                        onTap: () {
                          // Implement email functionality
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // FAQ Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.faqSectionTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.onPrimaryContainer,
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
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
        childrenPadding: const EdgeInsets.only(bottom: 16.0),
        title: Text(
          question,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Text(
            answer,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
