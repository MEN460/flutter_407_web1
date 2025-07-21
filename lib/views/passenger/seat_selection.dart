import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:k_airways_flutter/models/flight.dart';
import 'package:k_airways_flutter/widgets/seat_map.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Flight flight;

  const SeatSelectionScreen({super.key, required this.flight});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  String? _selectedSeat;

  void _onSeatSelected(String? seat) {
    setState(() {
      _selectedSeat = seat;
    });
  }

  void _confirmSelection() {
    if (_selectedSeat == null) {
      // Show error message if no seat selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a seat before confirming'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate with proper error handling
    try {
      context.push(
        '/booking-confirm',
        extra: {'flight': widget.flight, 'seat': _selectedSeat},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigation error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Seat - ${widget.flight.number}'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Add seat selection info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flight: ${widget.flight.number}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedSeat != null
                      ? 'Selected Seat: $_selectedSeat'
                      : 'Please select a seat',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _selectedSeat != null
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: _selectedSeat != null
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          // Seat map
          Expanded(
            child: SeatMap(
              flight: widget.flight,
              onSeatSelected: _onSeatSelected,
            ),
          ),
          // Bottom action area
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: FilledButton(
                onPressed: _selectedSeat != null ? _confirmSelection : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: Text(
                  _selectedSeat != null
                      ? 'Confirm Seat $_selectedSeat'
                      : 'Select a Seat First',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
