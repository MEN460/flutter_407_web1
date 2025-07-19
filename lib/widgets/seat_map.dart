import 'package:flutter/material.dart';
import 'package:k_airways_flutter/models/flight.dart';

enum SeatClass { executive, middle, economy }

enum SeatStatus { available, selected, occupied }

class SeatInfo {
  final String seatNumber;
  final SeatClass seatClass;
  final SeatStatus status;
  final double price;

  const SeatInfo({
    required this.seatNumber,
    required this.seatClass,
    required this.status,
    this.price = 0.0,
  });
}

class SeatMap extends StatefulWidget {
  final Flight flight;
  final ValueChanged<String?> onSeatSelected;
  final String? selectedSeat;

  const SeatMap({
    super.key,
    required this.flight,
    required this.onSeatSelected,
    this.selectedSeat,
  });

  @override
  State<SeatMap> createState() => _SeatMapState();
}

class _SeatMapState extends State<SeatMap> {
  late List<SeatInfo> seats;
  String? currentSelectedSeat;

  @override
  void initState() {
    super.initState();
    currentSelectedSeat = widget.selectedSeat;
    _generateSeats();
  }

  void _generateSeats() {
    seats = [];

    // Get capacities with null safety
    final executiveCapacity = widget.flight.capacities['executive'] ?? 0;
    final middleCapacity = widget.flight.capacities['middle'] ?? 0;
    final economyCapacity =
        widget.flight.capacities['economy'] ??
        widget.flight.capacities['coach'] ??
        0;

    // Generate Executive seats (rows 1-3, seats A-F)
    _generateSeatsByClass(
      SeatClass.executive,
      executiveCapacity,
      startRow: 1,
      rowLetters: ['A', 'B', 'C', 'D', 'E', 'F'],
    );

    // Generate Middle/Business seats (rows 4-8, seats A-F)
    _generateSeatsByClass(
      SeatClass.middle,
      middleCapacity,
      startRow: _getLastRow() + 1,
      rowLetters: ['A', 'B', 'C', 'D', 'E', 'F'],
    );

    // Generate Economy seats (remaining rows, seats A-F)
    _generateSeatsByClass(
      SeatClass.economy,
      economyCapacity,
      startRow: _getLastRow() + 1,
      rowLetters: ['A', 'B', 'C', 'D', 'E', 'F'],
    );
  }

  void _generateSeatsByClass(
    SeatClass seatClass,
    int capacity, {
    required int startRow,
    required List<String> rowLetters,
  }) {
    int seatsPerRow = rowLetters.length;
    int rowsNeeded = (capacity / seatsPerRow).ceil();

    for (int row = 0; row < rowsNeeded; row++) {
      for (
        int col = 0;
        col < seatsPerRow &&
            seats.length < _getTotalCapacityUpToClass(seatClass);
        col++
      ) {
        String seatNumber = '${startRow + row}${rowLetters[col]}';

        // Simulate some occupied seats (in a real app, this would come from the backend)
        SeatStatus status = _getSimulatedSeatStatus(seatNumber);

        seats.add(
          SeatInfo(
            seatNumber: seatNumber,
            seatClass: seatClass,
            status: status,
            price: _getSeatPrice(seatClass),
          ),
        );
      }
    }
  }

  int _getLastRow() {
    if (seats.isEmpty) return 0;
    return seats
        .map(
          (s) =>
              int.tryParse(s.seatNumber.replaceAll(RegExp(r'[A-Z]'), '')) ?? 0,
        )
        .reduce((a, b) => a > b ? a : b);
  }

  int _getTotalCapacityUpToClass(SeatClass targetClass) {
    final executiveCapacity = widget.flight.capacities['executive'] ?? 0;
    final middleCapacity = widget.flight.capacities['middle'] ?? 0;
    final economyCapacity =
        widget.flight.capacities['economy'] ??
        widget.flight.capacities['coach'] ??
        0;

    switch (targetClass) {
      case SeatClass.executive:
        return executiveCapacity;
      case SeatClass.middle:
        return executiveCapacity + middleCapacity;
      case SeatClass.economy:
        return executiveCapacity + middleCapacity + economyCapacity;
    }
  }

  SeatStatus _getSimulatedSeatStatus(String seatNumber) {
    // Simulate some occupied seats - in real app this comes from backend
    List<String> occupiedSeats = ['1A', '1B', '2C', '4A', '5F', '12A', '15C'];
    if (occupiedSeats.contains(seatNumber)) {
      return SeatStatus.occupied;
    }
    return SeatStatus.available;
  }

  double _getSeatPrice(SeatClass seatClass) {
    switch (seatClass) {
      case SeatClass.executive:
        return 150.0;
      case SeatClass.middle:
        return 75.0;
      case SeatClass.economy:
        return 0.0;
    }
  }

  void _onSeatTap(SeatInfo seat) {
    if (seat.status == SeatStatus.occupied) {
      _showSeatUnavailableMessage();
      return;
    }

    setState(() {
      if (currentSelectedSeat == seat.seatNumber) {
        // Deselect if tapping the same seat
        currentSelectedSeat = null;
        widget.onSeatSelected(null);
      } else {
        // Select new seat
        currentSelectedSeat = seat.seatNumber;
        widget.onSeatSelected(seat.seatNumber);
      }
    });
  }

  void _showSeatUnavailableMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This seat is not available'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Color _getSeatColor(SeatInfo seat) {
    if (seat.seatNumber == currentSelectedSeat) {
      return Colors.orange; // Selected seat
    }

    switch (seat.status) {
      case SeatStatus.occupied:
        return Colors.red[300]!;
      case SeatStatus.available:
        switch (seat.seatClass) {
          case SeatClass.executive:
            return Colors.amber[200]!;
          case SeatClass.middle:
            return Colors.blue[200]!;
          case SeatClass.economy:
            return Colors.green[200]!;
        }
      case SeatStatus.selected:
        return Colors.orange;
    }
  }

  Widget _buildSeat(SeatInfo seat) {
    final isSelected = seat.seatNumber == currentSelectedSeat;
    final isOccupied = seat.status == SeatStatus.occupied;

    return GestureDetector(
      onTap: () => _onSeatTap(seat),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _getSeatColor(seat),
          border: Border.all(
            color: isSelected ? Colors.orange[800]! : Colors.grey[400]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOccupied ? Icons.close : Icons.airline_seat_recline_normal,
              size: 16,
              color: isOccupied ? Colors.white : Colors.black87,
            ),
            Text(
              seat.seatNumber,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isOccupied ? Colors.white : Colors.black87,
              ),
            ),
            if (seat.price > 0)
              Text(
                '+\$${seat.price.toInt()}',
                style: const TextStyle(fontSize: 8, color: Colors.black54),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem('Executive', Colors.amber[200]!, '\$150'),
          _buildLegendItem('Business', Colors.blue[200]!, '\$75'),
          _buildLegendItem('Economy', Colors.green[200]!, 'Free'),
          _buildLegendItem('Occupied', Colors.red[300]!, ''),
          _buildLegendItem('Selected', Colors.orange, ''),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String price) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            label == 'Occupied'
                ? Icons.close
                : Icons.airline_seat_recline_normal,
            size: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
        if (price.isNotEmpty)
          Text(price, style: const TextStyle(fontSize: 8, color: Colors.grey)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (seats.isEmpty) {
      return const Center(child: Text('No seats available'));
    }

    return Column(
      children: [
        _buildLegend(),
        const Divider(),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6, // A B C   D E F layout
              childAspectRatio: 0.8,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: seats.length,
            itemBuilder: (context, index) {
              return _buildSeat(seats[index]);
            },
          ),
        ),
      ],
    );
  }
}
