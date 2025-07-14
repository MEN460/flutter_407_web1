import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:k_airways_flutter/providers.dart';
import 'package:k_airways_flutter/widgets/flight_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flightsAsync = ref.watch(flightListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Available Flights')),
      body: flightsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (flights) => ListView.builder(
          itemCount: flights.length,
          itemBuilder: (context, index) => FlightCard(flight: flights[index]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/flight-search'),
        child: const Icon(Icons.search),
      ),
    );
  }
}
