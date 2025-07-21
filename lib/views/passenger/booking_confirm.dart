import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:k_airways_flutter/models/booking.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;

  const BookingConfirmationScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Confirmed'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success Icon
              Center(
                child: Icon(
                  Icons.check_circle_rounded,
                  color: colorScheme.primary,
                  size: 120,
                  semanticLabel: 'Booking confirmed successfully',
                ),
              ),

              const SizedBox(height: 32),

              // Success Message
              Text(
                'Booking Confirmed!',
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Booking Details Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking Details',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildDetailRow(
                        context,
                        'Booking ID',
                        booking.id,
                        Icons.confirmation_number,
                      ),

                      const SizedBox(height: 12),

                      _buildDetailRow(
                        context,
                        'Flight',
                        booking.flight?.number ?? 'Not assigned',
                        Icons.flight,
                      ),

                      const SizedBox(height: 12),

                      _buildDetailRow(
                        context,
                        'Route',
                        _buildRouteText(),
                        Icons.route,
                      ),

                      const SizedBox(height: 12),

                      _buildDetailRow(
                        context,
                        'Seat',
                        _buildSeatText(),
                        Icons.airline_seat_recline_normal,
                      ),

                      if (booking.flight?.departureTime != null) ...[
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          context,
                          'Departure',
                          _formatDateTime(booking.flight!.departureTime),
                          Icons.schedule,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Confirmation Message
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'A confirmation email has been sent to your registered email address.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('Back to Home'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/bookings'),
                      icon: const Icon(Icons.list_alt_rounded),
                      label: const Text('View All Bookings'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _buildRouteText() {
    final origin = booking.flight?.origin;
    final destination = booking.flight?.destination;

    if (origin != null && destination != null) {
      return '$origin → $destination';
    } else if (origin != null) {
      return '$origin → Unknown';
    } else if (destination != null) {
      return 'Unknown → $destination';
    } else {
      return 'Route not available';
    }
  }

  String _buildSeatText() {
    final seatNumber = booking.seatNumber;
    final seatClass = booking.seatClass;

    return '$seatNumber (${seatClass.toUpperCase()})';
    
  }

  String _formatDateTime(DateTime dateTime) {
    // You might want to use intl package for better formatting
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
