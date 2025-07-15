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
      await bookingService.createBooking(
        flightId: int.parse(widget.flight.id), // ✅ int
        seatClass: _selectedClass!, // ✅ String
        seatNumber: 'AUTO', // ✅ temporary placeholder
      );
      if (mounted) {
        context.push('/seat-selection', extra: widget.flight);
      }
    } catch (e) {
      if (mounted) {
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
      appBar: AppBar(title: Text('Book Flight ${widget.flight.number}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Route: ${widget.flight.origin} → ${widget.flight.destination}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            Text(
              'Departure: ${widget.flight.departureTime}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Class:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...widget.flight.capacities.entries.map(
              (entry) => RadioListTile<String>(
                title: Text(
                  '${entry.key.toUpperCase()} (${entry.value} seats available)',
                ),
                value: entry.key,
                groupValue: _selectedClass,
                onChanged: (value) => setState(() => _selectedClass = value),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _isSubmitting || _selectedClass == null
                  ? null
                  : _createBooking,
              icon: _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.flight_takeoff),
              label: const Text('Continue to Seat Selection'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
              