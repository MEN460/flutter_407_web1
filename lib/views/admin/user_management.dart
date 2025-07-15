import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/models/user.dart';
import 'package:k_airways_flutter/providers.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            'Error loading users: $err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }
          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    user.email.isNotEmpty ? user.email[0].toUpperCase() : '?',
                  ),
                ),
                title: Text(user.email),
                subtitle: Text(
                  user.role[0].toUpperCase() +
                      user.role.substring(1), // Capitalize role
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditUserDialog(context, ref, user),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, ref, user),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, WidgetRef ref) {
    // TODO: Implement add user dialog with a form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add User Dialog not implemented.')),
    );
  }

  void _showEditUserDialog(BuildContext context, WidgetRef ref, User user) {
    // TODO: Implement edit user dialog with a form
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit User for ${user.email} not implemented.')),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    User user,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.email}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteUser(ref, user.id, context);
    }
  }

  Future<void> _deleteUser(
    WidgetRef ref,
    String userId,
    BuildContext context,
  ) async {
    try {
      final userService = ref.read(userServiceProvider);
      await userService.deleteUser(userId);
      ref.invalidate(allUsersProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete user: $e')));
    }
  }
}
