import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/models/booking.dart';
import 'package:k_airways_flutter/providers.dart';

enum CheckInState {
  initial,
  searchingBooking,
  bookingFound,
  checkingIn,
  completed,
}

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bookingIdController = TextEditingController();
  final _focusNode = FocusNode();

  Booking? _booking;
  CheckInState _currentState = CheckInState.initial;
  String? _errorMessage;

  @override
  void dispose() {
    _bookingIdController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String? _validateBookingId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your booking ID';
    }

    final bookingId = value.trim().toUpperCase();
    if (bookingId.length < 3) {
      return 'Booking ID must be at least 3 characters';
    }

    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(bookingId)) {
      return 'Booking ID should contain only letters and numbers';
    }

    return null;
  }

  Future<void> _findBooking() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _currentState = CheckInState.searchingBooking;
    });

    try {
      final bookingService = ref.read(bookingServiceProvider);
      final booking = await bookingService.getBooking(
        _bookingIdController.text.trim().toUpperCase(),
      );

      if (mounted) {
        setState(() {
          _booking = booking;
          _currentState = CheckInState.bookingFound;
        });

        // Validate check-in eligibility
        _validateCheckInEligibility();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _currentState = CheckInState.initial;
          _errorMessage = _getBookingErrorMessage(error);
        });
        _showErrorSnackBar(_errorMessage!);
      }
    }
  }

  void _validateCheckInEligibility() {
    if (_booking == null) return;

    // Check if already checked in
    if (_booking!.checkedIn == true) {
      setState(() {
        _errorMessage = 'This booking is already checked in.';
      });
      return;
    }

    // Check flight status
    if (_booking!.flight?.status == 'CANCELLED') {
      setState(() {
        _errorMessage =
            'This flight has been cancelled. Please contact customer service.';
      });
      return;
    }

    // Check check-in time window (typically 24 hours before to 2 hours before departure)
    if (_booking!.flight?.departureTime != null) {
      final now = DateTime.now();
      final departureTime = _booking!.flight!.departureTime;
      final timeToDeparture = departureTime.difference(now);

      if (timeToDeparture.inHours > 24) {
        setState(() {
          _errorMessage = 'Check-in opens 24 hours before departure.';
        });
        return;
      }

      if (timeToDeparture.inHours < 2) {
        setState(() {
          _errorMessage = 'Check-in has closed. Please contact the airline.';
        });
        return;
      }
    }
  }

  Future<void> _checkInPassenger() async {
    if (_booking == null) return;

    setState(() {
      _currentState = CheckInState.checkingIn;
      _errorMessage = null;
    });

    try {
      final bookingService = ref.read(bookingServiceProvider);
      await bookingService.checkInPassenger(_booking!.id);

      if (mounted) {
        setState(() {
          _currentState = CheckInState.completed;
        });

        _showSuccessMessage();

        // Reset form after successful check-in
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            _resetForm();
          }
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _currentState = CheckInState.bookingFound;
          _errorMessage = _getCheckInErrorMessage(error);
        });
        _showErrorSnackBar(_errorMessage!);
      }
    }
  }

  void _resetForm() {
    setState(() {
      _booking = null;
      _currentState = CheckInState.initial;
      _errorMessage = null;
    });
    _bookingIdController.clear();
    _focusNode.requestFocus();
  }

  String _getBookingErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('not found') || errorStr.contains('404')) {
      return 'Booking not found. Please check your booking ID and try again.';
    } else if (errorStr.contains('network') ||
        errorStr.contains('connection')) {
      return 'Network error. Please check your connection and try again.';
    } else if (errorStr.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else {
      return 'Unable to find booking. Please try again or contact customer service.';
    }
  }

  String _getCheckInErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('already checked')) {
      return 'You have already checked in for this flight.';
    } else if (errorStr.contains('closed')) {
      return 'Check-in is closed for this flight.';
    } else if (errorStr.contains('cancelled')) {
      return 'This flight has been cancelled.';
    } else {
      return 'Check-in failed. Please try again or contact customer service.';
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Check-in successful! Have a great flight!'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
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
        title: const Text('Passenger Check-In'),
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
                _buildSearchSection(),
                const SizedBox(height: 24),
                if (_currentState == CheckInState.searchingBooking)
                  _buildSearchingIndicator(),
                if (_booking != null &&
                    _currentState != CheckInState.searchingBooking)
                  _buildBookingDetails(),
                if (_currentState == CheckInState.completed)
                  _buildSuccessSection(),
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
          'Online Check-In',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Check in online and save time at the airport. Enter your booking reference to get started.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Column(
      children: [
        TextFormField(
          controller: _bookingIdController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: 'Booking Reference*',
            hintText: 'e.g., ABC123',
            prefixIcon: const Icon(Icons.confirmation_number),
            suffixIcon: _currentState == CheckInState.searchingBooking
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _currentState == CheckInState.searchingBooking
                        ? null
                        : _findBooking,
                  ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
          ),
          textCapitalization: TextCapitalization.characters,
          validator: _validateBookingId,
          enabled: _currentState != CheckInState.searchingBooking,
          onFieldSubmitted: (_) => _findBooking(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _currentState == CheckInState.searchingBooking
                ? null
                : _findBooking,
            icon: _currentState == CheckInState.searchingBooking
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.search),
            label: Text(
              _currentState == CheckInState.searchingBooking
                  ? 'Searching...'
                  : 'Find Booking',
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchingIndicator() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching for your booking...'),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetails() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flight_takeoff,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Booking Found',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow('Passenger', _booking!.user?.email ?? 'N/A'),
            const SizedBox(height: 12),
            _buildDetailRow('Flight', _booking!.flight?.number ?? 'N/A'),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Route',
              '${_booking!.flight?.origin ?? 'N/A'} → ${_booking!.flight?.destination ?? 'N/A'}',
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Seat', _booking!.seatNumber.toUpperCase()),
            if (_booking!.flight?.departureTime != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                'Departure',
                _formatDateTime(_booking!.flight!.departureTime),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    (_currentState == CheckInState.checkingIn ||
                        _errorMessage != null)
                    ? null
                    : _checkInPassenger,
                icon: _currentState == CheckInState.checkingIn
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(
                  _currentState == CheckInState.checkingIn
                      ? 'Checking In...'
                      : 'Check In Now',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessSection() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600, size: 64),
            const SizedBox(height: 16),
            Text(
              'Check-In Successful!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You are now checked in for your flight. Have a great journey!',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.green.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _resetForm,
              child: const Text('Check In Another Booking'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
