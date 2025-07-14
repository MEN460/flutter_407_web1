import 'package:flutter/material.dart';
import 'package:k_airways_flutter/models/flight.dart';

class SeatMap extends StatelessWidget {
  final Flight flight;
  final ValueChanged<String> onSeatSelected;

  const SeatMap({
    super.key,
    required this.flight,
    required this.onSeatSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
      ),
      itemCount: flight.capacities.values.reduce((a, b) => a + b),
      itemBuilder: (context, index) {
        final seatNumber = '${_getSeatClass(index)}${index + 1}';
        return GestureDetector(
          onTap: () => onSeatSelected(seatNumber),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _getSeatColor(index),
              border: Border.all(),
            ),
            child: Center(child: Text(seatNumber)),
          ),
        );
      },
    );
  }

  String _getSeatClass(int index) {
    if (index < flight.capacities['executive']!) return 'E';
    if (index <
        flight.capacities['executive']! + flight.capacities['middle']!) {
      return 'M';
    }
    return 'C';
  }

  Color _getSeatColor(int index) {
    return _getSeatClass(index) == 'E'
        ? Colors.amber
        : _getSeatClass(index) == 'M'
        ? Colors.blue[200]!
        : Colors.green[200]!;
  }
}
