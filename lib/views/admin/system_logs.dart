import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/providers.dart';

class SystemLogsScreen extends ConsumerWidget {
  const SystemLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(systemLogsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('System Logs')),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            'Error loading logs: $err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (logs) {
          if (logs.isEmpty) {
            return const Center(child: Text('No system logs available.'));
          }

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];

              final action = log['action'] ?? 'Unknown Action';
              final timestamp = log['timestamp'] ?? 'No Timestamp';
              final user = log['user'] ?? 'Unknown User';
              final status =
                  log['status']?.toString().toUpperCase() ?? 'UNKNOWN';

              final isSuccess = status == 'SUCCESS';

              return ListTile(
                leading: Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
                title: Text(action),
                subtitle: Text('$timestamp - $user'),
                trailing: Text(
                  status,
                  style: TextStyle(
                    color: isSuccess ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
