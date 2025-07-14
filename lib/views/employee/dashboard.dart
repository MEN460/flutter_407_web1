import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/models/flight.dart';
import 'package:k_airways_flutter/providers.dart';
import 'package:k_airways_flutter/widgets/flight_card.dart';
import 'package:k_airways_flutter/views/employee/flight_operations.dart';

class EmployeeDashboardScreen extends ConsumerWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flightsAsync = ref.watch(assignedFlightsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Dashboard')),
      body: flightsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (flights) => ListView.builder(
          itemCount: flights.length,
          itemBuilder: (context, index) => FlightCard(
            flight: flights[index],
            onTap: () => _showFlightDetails(context, flights[index]),
          ),
        ),
      ),
    );
  }

  void _showFlightDetails(BuildContext context, Flight flight) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlightOperationsScreen(flight: flight),
      ),
    );
  }
}
