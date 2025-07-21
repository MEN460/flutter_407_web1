import 'dart:async';
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
  final _focusNode = FocusNode();

  List<User> _results = [];
  bool _isSearching = false;
  String? _errorMessage;
  bool _hasSearched = false;
  Timer? _debounceTimer;
  String _lastSearchQuery = '';

  static const int _minSearchLength = 2;
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Clear error when user starts typing
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }

    // If query is too short, clear results
    if (query.length < _minSearchLength) {
      if (_results.isNotEmpty || _hasSearched) {
        setState(() {
          _results = [];
          _hasSearched = false;
        });
      }
      return;
    }

    // If query hasn't changed, don't search again
    if (query == _lastSearchQuery) return;

    // Set up debounced search
    _debounceTimer = Timer(_debounceDelay, () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.length < _minSearchLength) {
      _showError(
        'Please enter at least $_minSearchLength characters to search.',
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _hasSearched = true;
    });

    try {
      final userService = ref.read(userServiceProvider);
      final searchResults = await userService.searchUsers(query);

      // Filter for passengers only
      final passengers = searchResults
          .where((user) => user.role.toLowerCase() == 'passenger')
          .toList();

      if (mounted) {
        setState(() {
          _results = passengers;
          _lastSearchQuery = query;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _results = [];
          _isSearching = false;
        });
        _showError(_getErrorMessage(e));
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  String _getErrorMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorString.contains('timeout')) {
      return 'Search timed out. Please try again.';
    } else if (errorString.contains('unauthorized') ||
        errorString.contains('401')) {
      return 'You don\'t have permission to search passengers.';
    } else if (errorString.contains('server') || errorString.contains('500')) {
      return 'Server error. Please try again later.';
    } else {
      return 'Failed to search passengers. Please try again.';
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _focusNode.unfocus();
    setState(() {
      _results = [];
      _hasSearched = false;
      _errorMessage = null;
    });
  }

  void _retrySearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _performSearch(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passenger Lookup'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          _SearchHeader(),
          _SearchBar(
            controller: _searchController,
            focusNode: _focusNode,
            isSearching: _isSearching,
            onClear: _clearSearch,
            onSubmitted: _performSearch,
          ),
          if (_isSearching) const _LoadingIndicator(),
          if (_errorMessage != null)
            _ErrorDisplay(message: _errorMessage!, onRetry: _retrySearch),
          Expanded(
            child: _SearchResults(
              results: _results,
              hasSearched: _hasSearched,
              isSearching: _isSearching,
              searchQuery: _searchController.text.trim(),
              onPassengerTap: _showPassengerDetails,
            ),
          ),
        ],
      ),
    );
  }

  void _showPassengerDetails(BuildContext context, User passenger) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _PassengerDetailsModal(passenger: passenger),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Theme.of(context).primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Passengers',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Enter name, email, or ID to find passengers',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSearching;
  final VoidCallback onClear;
  final ValueChanged<String> onSubmitted;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.isSearching,
    required this.onClear,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: 'Search by name, email, or ID',
          hintText: 'Type at least 2 characters...',
          prefixIcon: const Icon(Icons.person_search),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
                  tooltip: 'Clear search',
                ),
              IconButton(
                icon: Icon(isSearching ? Icons.hourglass_empty : Icons.search),
                onPressed: isSearching
                    ? null
                    : () => onSubmitted(controller.text.trim()),
                tooltip: 'Search passengers',
              ),
            ],
          ),
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
        enabled: !isSearching,
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const LinearProgressIndicator(),
          const SizedBox(height: 8),
          Text(
            'Searching passengers...',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorDisplay({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<User> results;
  final bool hasSearched;
  final bool isSearching;
  final String searchQuery;
  final Function(BuildContext, User) onPassengerTap;

  const _SearchResults({
    required this.results,
    required this.hasSearched,
    required this.isSearching,
    required this.searchQuery,
    required this.onPassengerTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasSearched && !isSearching) {
      return _EmptySearchState();
    }

    if (isSearching) {
      return const SizedBox.shrink(); // Loading is shown above
    }

    if (results.isEmpty && hasSearched) {
      return _NoResultsState(searchQuery: searchQuery);
    }

    return _ResultsList(results: results, onPassengerTap: onPassengerTap);
  }
}

class _EmptySearchState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Search for Passengers',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a passenger\'s name, email, or ID to begin searching.',
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

class _NoResultsState extends StatelessWidget {
  final String searchQuery;

  const _NoResultsState({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Passengers Found',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'No passengers match "$searchQuery".\nTry searching with different keywords.',
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

class _ResultsList extends StatelessWidget {
  final List<User> results;
  final Function(BuildContext, User) onPassengerTap;

  const _ResultsList({required this.results, required this.onPassengerTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.grey[50],
          child: Text(
            '${results.length} passenger${results.length == 1 ? '' : 's'} found',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: results.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final passenger = results[index];
              return _PassengerListTile(
                passenger: passenger,
                onTap: () => onPassengerTap(context, passenger),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PassengerListTile extends StatelessWidget {
  final User passenger;
  final VoidCallback onTap;

  const _PassengerListTile({required this.passenger, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        child: Text(
          _getInitials(passenger.email),
          style: TextStyle(
            color: Theme.of(context).primaryColor,
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
          Text('ID: ${passenger.id}'),
          if (passenger.name.isNotEmpty == true)
            Text('Name: ${passenger.name}'),
        ],
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  String _getInitials(String email) {
    if (email.isEmpty) return '?';
    final parts = email.split('@');
    final username = parts.first;
    return username.isNotEmpty ? username.substring(0, 1).toUpperCase() : '?';
  }
}

class _PassengerDetailsModal extends StatelessWidget {
  final User passenger;

  const _PassengerDetailsModal({required this.passenger});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Passenger Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailCard(
                        icon: Icons.person,
                        title: 'Personal Information',
                        children: [
                          _DetailRow('Email', passenger.email),
                          _DetailRow('ID', passenger.id.toString()),
                          if (passenger.name.isNotEmpty == true)
                            _DetailRow('Name', passenger.name),
                          _DetailRow('Role', passenger.role),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Add more detail cards here for flights, bookings, etc.
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
