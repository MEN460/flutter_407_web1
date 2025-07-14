import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:k_airways_flutter/models/flight.dart';
import 'package:k_airways_flutter/constants/app_colors.dart';

class FlightCard extends StatelessWidget {
  final Flight flight;
  /// Callback when the card is tapped.
  /// If not provided, it will navigate to the booking page with the flight details.
  final VoidCallback? onTap;

  const FlightCard({super.key, required this.flight, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap ?? () => context.push('/booking', extra: flight),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(flight.number, style: const TextStyle(fontSize: 18)),
                  const Icon(Icons.airplanemode_active),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(flight.origin, style: const TextStyle(fontSize: 16)),
                      Text(
                        flight.destination,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Text(
                    '${flight.departureTime.hour}:${flight.departureTime.minute.toString().padLeft(2, '0')}',
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 10,
                children: [
                  _buildClassBadge(
                    'Executive',
                    flight.capacities['executive'] ?? 0,
                  ),
                  _buildClassBadge('Middle', flight.capacities['middle'] ?? 0),
                  _buildClassBadge(
                    'Economy',
                    flight.capacities['economy'] ?? 0,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassBadge(String label, int available) {
    return Chip(
      label: Text('$label: $available'),
      backgroundColor: _getClassColor(label),
    );
  }

  Color _getClassColor(String label) {
    switch (label.toLowerCase()) {
      case 'executive':
        return AppColors.executiveClass;
      case 'middle':
        return AppColors.middleClass;
      case 'economy':
        return AppColors.economyClass;
      default:
        return Colors.grey;
    }
  }
}
