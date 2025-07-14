import 'package:flutter/material.dart';
import 'package:k_airways_flutter/models/booking.dart';
import 'package:k_airways_flutter/widgets/status_badge.dart';

class BookingTile extends StatelessWidget {
  final Booking booking;
  const BookingTile({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: const Icon(Icons.confirmation_num),
      title: Text('Booking ${booking.id.substring(0, 8)}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Flight: ${booking.flight?.number ?? 'Unknown Flight'}'),
          Text('${booking.flight?.origin ?? 'Unknown Origin'} → ${booking.flight?.destination ?? 'Unknown Destination'}'),
        ],
      ),
      trailing: StatusBadge(status: booking.status),
      onTap: () => _showBookingDetails(context),
    );
  }

  void _showBookingDetails(BuildContext context) {
    // Implement booking details view
  }
}
