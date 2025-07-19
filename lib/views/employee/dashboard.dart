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
      appBar: AppBar(
        title: const Text('My Dashboard'),
        elevation: 2,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(assignedFlightsProvider);
          await ref.read(assignedFlightsProvider.future);
        },
        child: flightsAsync.when(
          loading: () => const _LoadingState(),
          error: (error, stackTrace) => _ErrorState(
            error: error,
            onRetry: () => ref.invalidate(assignedFlightsProvider),
          ),
          data: (flights) => flights.isEmpty
              ? const _EmptyState()
              : _FlightsList(flights: flights),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading your assigned flights...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load flights',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getErrorMessage(error),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getErrorMessage(Object error) {
    if (error.toString().contains('network') ||
        error.toString().contains('connection')) {
      return 'Please check your internet connection and try again.';
    } else if (error.toString().contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (error.toString().contains('unauthorized') ||
        error.toString().contains('401')) {
      return 'Authentication failed. Please log in again.';
    } else {
      return 'Something went wrong. Please try again later.';
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flight_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No flights assigned',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'You don\'t have any flights assigned at the moment.\nCheck back later or contact your supervisor.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FlightsList extends StatelessWidget {
  const _FlightsList({required this.flights});

  final List<Flight> flights;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.assignment, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                'Assigned Flights (${flights.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: flights.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final flight = flights[index];
              return Semantics(
                label:
                    'Flight ${flight.flightNumber} from ${flight.origin} to ${flight.destination}',
                button: true,
                child: FlightCard(
                  flight: flight,
                  onTap: () => _navigateToFlightOperations(context, flight),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16), // Bottom padding
      ],
    );
  }

  void _navigateToFlightOperations(BuildContext context, Flight flight) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlightOperationsScreen(flight: flight),
        settings: RouteSettings(name: '/flight-operations', arguments: flight),
      ),
    );
  }
}

// Extension to add some utility methods if needed
extension FlightListExtensions on List<Flight> {
  List<Flight> get upcoming =>
      where((flight) => flight.departureTime.isAfter(DateTime.now())).toList();

  List<Flight> get today => where(
    (flight) => _isSameDay(flight.departureTime, DateTime.now()),
  ).toList();
}

bool _isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}
