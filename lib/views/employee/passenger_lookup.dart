import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/models/user.dart';
import 'package:k_airways_flutter/providers.dart';

class PassengerLookupScreen extends ConsumerStatefulWidget {
  const PassengerLookupScreen({super.key});

  @override
  ConsumerState<PassengerLookupScreen> createState() =>
      _PassengerLookupScreenState();
}

class _PassengerLookupScreenState extends ConsumerState<PassengerLookupScreen> {
  final _searchController = TextEditingController();
  List<User> _results = [];
  bool _isSearching = false;

  Future<void> _search() async {
    if (_searchController.text.isEmpty) return;

    setState(() => _isSearching = true);
    final userService = ref.read(userServiceProvider);
    _results = (await userService.searchUsers(
      _searchController.text,
    )).where((u) => u.role == 'passenger').toList();
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Passenger Lookup')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Passengers',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 20),
            if (_isSearching) const LinearProgressIndicator(),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final passenger = _results[index];
                  return ListTile(
                    title: Text( passenger.email),
                    subtitle: Text('ID: ${passenger.id}'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () => _showPassengerDetails(context, passenger),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPassengerDetails(BuildContext context, User passenger) {
    // Implement details view
  }
}
