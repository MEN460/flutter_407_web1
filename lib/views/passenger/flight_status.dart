import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/providers.dart';
import 'package:k_airways_flutter/widgets/status_badge.dart';

class FlightStatusScreen extends ConsumerWidget {
  final String flightId;

  const FlightStatusScreen({super.key, required this.flightId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(flightStatusProvider(flightId));

    return Scaffold(
      appBar: AppBar(title: const Text('Flight Status')),
      body: statusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (status) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Flight: ${status.flightId}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              StatusBadge(status: status.status),
              const SizedBox(height: 20),
              if (status.estimatedDeparture != null)
                Text('Estimated: ${status.estimatedDeparture!.toLocal()}'),
              if (status.actualDeparture != null)
                Text('Actual: ${status.actualDeparture!.toLocal()}'),
              Text('Gate: ${status.gate}'),
              Text('Remarks: ${status.remarks}'),
            ],
          ),
        ),
      ),
    );
  }
}
