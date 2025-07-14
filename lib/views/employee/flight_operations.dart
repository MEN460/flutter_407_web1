import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/models/flight.dart';
import 'package:k_airways_flutter/models/flight_status.dart';
import 'package:k_airways_flutter/providers.dart';
import 'package:k_airways_flutter/widgets/status_badge.dart';

class FlightOperationsScreen extends ConsumerStatefulWidget {
  final Flight flight;

  const FlightOperationsScreen({super.key, required this.flight});

  @override
  ConsumerState<FlightOperationsScreen> createState() =>
      _FlightOperationsScreenState();
}

class _FlightOperationsScreenState
    extends ConsumerState<FlightOperationsScreen> {
  late FlightStatus _status;

  @override
  void initState() {
    super.initState();
    _status = FlightStatus(
      flightId: widget.flight.id,
      status: 'ON_TIME',
      gate: '',
      remarks: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flight ${widget.flight.number} Operations')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Route: ${widget.flight.origin} → ${widget.flight.destination}',
            ),
            Text('Scheduled: ${widget.flight.departureTime}'),
            const SizedBox(height: 20),
            const Text('Current Status:'),
            StatusBadge(status: _status.status),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _status.status,
              items: ['ON_TIME', 'DELAYED', 'CANCELLED']
                  .map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _status.status = value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Gate'),
              onChanged: (value) => _status.gate = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Remarks'),
              maxLines: 3,
              onChanged: (value) => _status.remarks = value,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _updateStatus,
              child: const Text('Update Status'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus() async {
    final flightService = ref.read(flightServiceProvider);
    await flightService.updateFlightStatus(widget.flight.id, _status);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Flight status updated')));
      Navigator.pop(context);
    }
  }
}
