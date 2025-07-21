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
      appBar: AppBar(
        title: const Text('Passenger Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(passengerListProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: passengersAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading passengers...'),
            ],
          ),
        ),
        error: (err, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading passengers',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                err.toString(),
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(passengerListProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (passengers) {
          if (passengers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No passengers found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text('Add passengers to get started'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(passengerListProvider);
              await ref.read(passengerListProvider.future);
            },
            child: ListView.builder(
              itemCount: passengers.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final passenger = passengers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getRoleColor(passenger.role),
                      child: Text(
                        passenger.email.isNotEmpty
                            ? passenger.email[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      passenger.email,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Role: ${_formatRole(passenger.role)}',
                          style: TextStyle(
                            color: _getRoleColor(passenger.role),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'ID: ${passenger.id}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) =>
                          _handleMenuAction(context, ref, value, passenger),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility, size: 20),
                              SizedBox(width: 8),
                              Text('View Details'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () => _viewPassengerDetails(context, passenger),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addPassenger(context, ref),
        tooltip: 'Add Passenger',
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'pilot':
        return Colors.blue;
      case 'crew':
        return Colors.green;
      case 'passenger':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatRole(String role) {
    return role.isNotEmpty
        ? role[0].toUpperCase() + role.substring(1).toLowerCase()
        : 'Unknown';
  }

  void _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    User passenger,
  ) {
    switch (action) {
      case 'edit':
        _editPassenger(context, ref, passenger);
        break;
      case 'view':
        _viewPassengerDetails(context, passenger);
        break;
      case 'delete':
        _deletePassenger(context, ref, passenger);
        break;
    }
  }

  void _addPassenger(BuildContext context, WidgetRef ref) {
    // TODO: Navigate to add passenger screen or show add dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add passenger functionality not implemented yet'),
      ),
    );
  }

  void _editPassenger(BuildContext context, WidgetRef ref, User passenger) {
    // TODO: Navigate to edit passenger screen or show comprehensive edit dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Passenger'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${passenger.email}'),
            const SizedBox(height: 8),
            Text('Role: ${_formatRole(passenger.role)}'),
            ...[
            const SizedBox(height: 8),
            Text('ID: ${passenger.id}'),
          ],
            const SizedBox(height: 16),
            const Text(
              'Full editing functionality will be implemented in a dedicated screen.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to full edit screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit functionality will be implemented'),
                ),
              );
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _viewPassengerDetails(BuildContext context, User passenger) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Passenger Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(label: 'Email', value: passenger.email),
            _DetailRow(label: 'Role', value: _formatRole(passenger.role)),
            _DetailRow(label: 'ID', value: passenger.id.toString()),
            // Add more passenger details as needed
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deletePassenger(BuildContext context, WidgetRef ref, User passenger) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Passenger'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('Are you sure you want to delete ${passenger.email}?'),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // TODO: Implement actual delete functionality
              // Example: await ref.read(passengerRepositoryProvider).deletePassenger(passenger.id);
              // ref.refresh(passengerListProvider);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${passenger.email} deleted'),
                  backgroundColor: Colors.red,
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: Colors.white,
                    onPressed: () {
                      // TODO: Implement undo functionality
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
