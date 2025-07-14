import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/models/user.dart';
import 'package:k_airways_flutter/providers.dart';

class PassengerListScreen extends ConsumerWidget {
  const PassengerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passengersAsync = ref.watch(passengerListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Passenger Management')),
      body: passengersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (passengers) => ListView.builder(
          itemCount: passengers.length,
          itemBuilder: (context, index) {
            final passenger = passengers[index];
            return ListTile(
              title: Text(passenger.email),
              subtitle: Text(passenger.role),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editPassenger(context, passenger),
              ),
            );
          },
        ),
      ),
    );
  }

  void _editPassenger(BuildContext context, User passenger) {
    // Implement edit functionality
  }
}
