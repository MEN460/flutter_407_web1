import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/models/booking.dart';
import 'package:k_airways_flutter/providers.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  final _bookingIdController = TextEditingController();
  Booking? _booking;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Passenger Check-In')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _bookingIdController,
              decoration: InputDecoration(
                labelText: 'Booking ID',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _findBooking,
                ),
              ),
            ),
            if (_isLoading) const LinearProgressIndicator(),
            if (_booking != null) ...[
              const SizedBox(height: 20),
              Text('Passenger: ${_booking!.user.email}'),
              Text('Flight: ${_booking!.flight.number}'),
              Text('Seat: ${_booking!.seatNumber}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkInPassenger,
                child: const Text('Check In Passenger'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _findBooking() async {
    setState(() => _isLoading = true);
    final bookingService = ref.read(bookingServiceProvider);
    try {
      final booking = await bookingService.getBooking(
        _bookingIdController.text,
      );
      setState(() => _booking = booking);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkInPassenger() async {
    if (_booking == null) return;

    final bookingService = ref.read(bookingServiceProvider);
    await bookingService.checkInPassenger(_booking!.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passenger checked in successfully')),
      );
      setState(() => _booking = null);
      _bookingIdController.clear();
    }
  }
}
