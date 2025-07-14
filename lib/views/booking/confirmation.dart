import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:k_airways_flutter/models/booking.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;

  const BookingConfirmationScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Confirmed')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 24),
            Text(
              'Booking ID: ${booking.id}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text('Flight: ${booking.flight.seatNumber}'),
            Text('${booking.flight.origin} → ${booking.flight.destination}'),
            Text(
              'Seat: ${booking.seatNumber} (${booking.seatNumber.toUpperCase()})',
            ),
            const SizedBox(height: 32),
            const Text('An email confirmation has been sent to your account'),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Home'),
                ),
                ElevatedButton(
                  onPressed: () => context.go('/booking/${booking.id}'),
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
