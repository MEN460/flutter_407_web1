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

  void _confirmSelection() {
    if (_selectedSeat != null) {
      context.push(
        '/booking-confirm',
        extra: {'flight': widget.flight, 'seat': _selectedSeat},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Seat - ${widget.flight.number}')),
      body: Column(
        children: [
          Expanded(
            child: SeatMap(
              flight: widget.flight,
              onSeatSelected: (seat) => setState(() => _selectedSeat = seat),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton(
              onPressed: _selectedSeat != null ? _confirmSelection : null,
              child: const Text('Confirm Seat'),
            ),
          ),
        ],
      ),
    );
  }
}
