import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/l10n/app_localizations.dart';
import 'package:k_airways_flutter/models/flight.dart';
import 'package:k_airways_flutter/models/inquiry_type.dart';
import 'package:k_airways_flutter/providers.dart';

class BookingInquiryScreen extends ConsumerStatefulWidget {
  const BookingInquiryScreen({super.key, String? initialBookingId, required Flight flight});

  @override
  ConsumerState<BookingInquiryScreen> createState() =>
      _BookingInquiryScreenState();
}

class _BookingInquiryScreenState extends ConsumerState<BookingInquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _bookingIdController = TextEditingController();
  final _inquiryController = TextEditingController();
  final _bookingIdFocusNode = FocusNode();
  final _inquiryFocusNode = FocusNode();

  bool _isSubmitting = false;
  String? _submissionError;
  InquiryType? _selectedInquiryType;

  @override
  void dispose() {
    _scrollController.dispose();
    _bookingIdController.dispose();
    _inquiryController.dispose();
    _bookingIdFocusNode.dispose();
    _inquiryFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitInquiry() async {
    FocusScope.of(context).unfocus();

    if (!mounted) return;
    setState(() => _submissionError = null);

    if (!_formKey.currentState!.validate()) {
      _scrollToError();
      return;
    }

    if (_selectedInquiryType == null) {
      setState(
        () => _submissionError = _getLocalizedError('inquiryTypeRequired'),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final bookingService = ref.read(bookingServiceProvider);
      final userEmail = ref.read(currentUserProvider)?.email;

      if (userEmail == null) {
        throw Exception('User not logged in');
      }

      await bookingService.submitInquiry(
        bookingId: _bookingIdController.text.trim(),
        message: _inquiryController.text.trim(),
        email: userEmail,
        inquiryType: _selectedInquiryType!,
        details: _getInquiryTypeLabel(_selectedInquiryType!),
      );

      if (mounted) {
        _showSuccessDialog();
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submissionError = _parseError(e));
      }
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
    _formKey.currentState?.reset();
    _bookingIdController.clear();
    _inquiryController.clear();
    setState(() {
      _selectedInquiryType = null;
      _submissionError = null;
    });
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
    } else if (errorStr.contains('not logged in')) {
      return loc.loginRequiredError;
    } else {
      return loc.generalError;
    }
  }

  String _getLocalizedError(String errorKey) {
    final loc = AppLocalizations.of(context)!;
    switch (errorKey) {
      case 'inquiryTypeRequired':
        return loc.inquiryTypeRequired;
      case 'bookingIdRequired':
        return loc.bookingIdRequired;
      case 'bookingIdTooShort':
        return loc.bookingIdTooShort;
      case 'bookingIdInvalidFormat':
        return loc.bookingIdInvalidFormat;
      case 'inquiryRequired':
        return loc.inquiryRequired;
      case 'inquiryTooShort':
        return loc.inquiryTooShort;
      default:
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
      case InquiryType.cancellation:
        return loc.inquiryTypeCancellation;
      case InquiryType.seatChange:
        return loc.inquiryTypeSeatChange;
      case InquiryType.flightChange:
        return loc.inquiryTypeFlightChange;
      case InquiryType.specialAssistance:
        return loc.inquiryTypeSpecialAssistance;
      case InquiryType.feedback:
        return loc.inquiryTypeFeedback;
      case InquiryType.other:
        return loc.inquiryTypeOther;
      }
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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
                color: colors.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.support_agent,
                            color: colors.onPrimaryContainer,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              loc.bookingInquiryTitle,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colors.onPrimaryContainer,
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
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

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
                focusNode: _bookingIdFocusNode,
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
                  final bookingIdRegex = RegExp(r'^[A-Z0-9]{6,}$');
                  if (!bookingIdRegex.hasMatch(value.trim().toUpperCase())) {
                    return loc.bookingIdInvalidFormat;
                  }
                  return null;
                },
                onChanged: (value) {
                  final text = value.toUpperCase();
                  _bookingIdController.value = _bookingIdController.value
                      .copyWith(
                        text: text,
                        selection: TextSelection.collapsed(offset: text.length),
                      );
                },
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _inquiryFocusNode.requestFocus(),
              ),

              const SizedBox(height: 20),

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
                  setState(() => _selectedInquiryType = value);
                },
                validator: (value) {
                  if (value == null) {
                    return loc.inquiryTypeRequired;
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
                focusNode: _inquiryFocusNode,
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
                    color: colors.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: colors.onErrorContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _submissionError!,
                          style: TextStyle(
                            color: colors.onErrorContainer,
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

              if (!_isSubmitting) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _resetForm,
                    child: Text(loc.resetButton),
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
