import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/models/flight.dart';
import 'package:k_airways_flutter/models/flight_status.dart';
import 'package:k_airways_flutter/providers.dart';
import 'package:k_airways_flutter/widgets/status_badge.dart';

class FlightOperationsScreen extends ConsumerStatefulWidget {
  final Flight? flight; // ✅ Nullable Flight for flexibility

  const FlightOperationsScreen({super.key, this.flight});

  @override
  ConsumerState<FlightOperationsScreen> createState() =>
      _FlightOperationsScreenState();
}

class _FlightOperationsScreenState
    extends ConsumerState<FlightOperationsScreen> {
  FlightStatus? _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.flight != null) {
      _status = FlightStatus(
        flightId: widget.flight!.id,
        status: 'ON_TIME',
        gate: '',
        remarks: '',
      );
    }
  }

  Future<void> _updateStatus() async {
    if (widget.flight == null || _status == null) return;

    setState(() => _isLoading = true);
    final flightService = ref.read(flightServiceProvider);

    try {
      await flightService.updateFlightStatus(widget.flight!.id, _status!);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Flight status updated')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flight == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flight Operations')),
        body: const Center(
          child: Text(
            'No flight data provided.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Flight ${widget.flight!.number} Operations')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Route: ${widget.flight!.origin} → ${widget.flight!.destination}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text('Scheduled: ${widget.flight!.departureTime}'),
            const SizedBox(height: 20),
            const Text('Current Status:'),
            StatusBadge(status: _status?.status ?? 'UNKNOWN'),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _status?.status,
              items: ['ON_TIME', 'DELAYED', 'CANCELLED']
                  .map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null && _status != null) {
                  setState(() {
                    _status = _status!.copyWith(status: value);
                  });
                }
              },
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Gate'),
              onChanged: (value) {
                if (_status != null) {
                  setState(() {
                    _status = _status!.copyWith(gate: value);
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Remarks'),
              maxLines: 3,
              onChanged: (value) {
                if (_status != null) {
                  setState(() {
                    _status = _status!.copyWith(remarks: value);
                  });
                }
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading || _status == null ? null : _updateStatus,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Updating...' : 'Update Status'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
