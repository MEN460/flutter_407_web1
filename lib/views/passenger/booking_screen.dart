import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_airways_flutter/models/flight.dart';
import 'package:k_airways_flutter/providers.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final Flight flight;
  const BookingScreen({super.key, required this.flight});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  String? _selectedClass;
  bool _isSubmitting = false;

 Future<void> _createBooking() async {
    if (_selectedClass == null) return;

    setState(() => _isSubmitting = true);
    final bookingService = ref.read(bookingServiceProvider);

    try {
      // Create the booking
      await bookingService.createBooking(
        flightId: widget.flight.id,
        seatClass: _selectedClass!,
      );

      // Only navigate if the widget is still in the tree
      if (context.mounted) {
        context.push('/seat-selection', extra: widget.flight);
      }
    } catch (e) {
      // Handle booking creation errors
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create booking: $e')));
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.flight.number}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Route: ${widget.flight.origin} → ${widget.flight.destination}',
            ),
            Text('Departure: ${widget.flight.departureTime}'),
            const SizedBox(height: 30),
            const Text('Select Class:'),
            ...widget.flight.capacities.keys.map(
              (cls) => RadioListTile(
                title: Text(
                  '${cls.toUpperCase()} (${widget.flight.capacities[cls]} available)',
                ),
                value: cls,
                groupValue: _selectedClass,
                onChanged: (value) => setState(() => _selectedClass = value),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isSubmitting || _selectedClass == null
                  ? null
                  : _createBooking,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('Continue to Seat Selection'),
            ),
          ],
        ),
      ),
    );
  }
}
