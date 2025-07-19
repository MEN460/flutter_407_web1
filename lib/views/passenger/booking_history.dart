import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/providers.dart';
import 'package:k_airways_flutter/widgets/booking_tile.dart';
import 'package:k_airways_flutter/models/booking.dart';

class BookingHistoryScreen extends ConsumerStatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  ConsumerState<BookingHistoryScreen> createState() =>
      _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends ConsumerState<BookingHistoryScreen> {
  String _searchQuery = '';
  BookingFilterType _filterType = BookingFilterType.all;

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(userBookingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showFilterBottomSheet(context),
            icon: Icon(
              _filterType != BookingFilterType.all
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
            ),
            tooltip: 'Filter bookings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              hintText: 'Search by booking ID, flight number...',
              leading: const Icon(Icons.search),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              trailing: _searchQuery.isNotEmpty
                  ? [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    ]
                  : null,
            ),
          ),

          // Content
          Expanded(
            child: bookingsAsync.when(
              loading: () => _buildLoadingState(),
              error: (error, stackTrace) => _buildErrorState(error, stackTrace),
              data: (bookings) => _buildBookingsList(bookings),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading your bookings...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error, StackTrace? stackTrace) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(userBookingsProvider.future),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Unable to load bookings',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _getErrorMessage(error),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => ref.refresh(userBookingsProvider.future),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingsList(List<Booking> bookings) {
    final filteredBookings = _filterBookings(bookings);

    if (filteredBookings.isEmpty) {
      return _buildEmptyState(bookings.isEmpty);
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(userBookingsProvider.future),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        itemCount: filteredBookings.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final booking = filteredBookings[index];
          return BookingTile(booking: booking, key: ValueKey(booking.id));
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isOriginallyEmpty) {
    final theme = Theme.of(context);
    final isFiltered = !isOriginallyEmpty;

    return RefreshIndicator(
      onRefresh: () => ref.refresh(userBookingsProvider.future),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isFiltered ? Icons.search_off : Icons.flight_takeoff_outlined,
                size: 80,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 24),
              Text(
                isFiltered ? 'No matching bookings' : 'No bookings yet',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                isFiltered
                    ? 'Try adjusting your search or filter criteria.'
                    : 'Your flight bookings will appear here once you make your first reservation.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (isFiltered) ...[
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _filterType = BookingFilterType.all;
                    });
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Filters'),
                ),
              ] else ...[
                FilledButton.icon(
                  onPressed: () {
                    // Navigate to flight search or home
                    Navigator.of(context).pushReplacementNamed('/');
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('Book a Flight'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Booking> _filterBookings(List<Booking> bookings) {
    var filtered = bookings.where((booking) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        final matchesId =
            booking.id?.toLowerCase().contains(searchLower) ?? false;
        final matchesFlightNumber =
            booking.flight?.number?.toLowerCase().contains(searchLower) ??
            false;
        final matchesRoute =
            '${booking.flight?.origin} ${booking.flight?.destination}'
                .toLowerCase()
                .contains(searchLower);

        if (!matchesId && !matchesFlightNumber && !matchesRoute) {
          return false;
        }
      }

      // Status filter
      switch (_filterType) {
        case BookingFilterType.active:
          return booking.status == BookingStatus.confirmed ||
              booking.status == BookingStatus.checkedIn;
        case BookingFilterType.completed:
          return booking.status == BookingStatus.completed;
        case BookingFilterType.cancelled:
          return booking.status == BookingStatus.cancelled;
        case BookingFilterType.all:
          return true;
      }
    }).toList();

    // Sort by booking date (most recent first)
    filtered.sort((a, b) {
      final aDate = a.bookingDate ?? DateTime.now();
      final bDate = b.bookingDate ?? DateTime.now();
      return bDate.compareTo(aDate);
    });

    return filtered;
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Bookings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...BookingFilterType.values.map((type) {
                    return RadioListTile<BookingFilterType>(
                      title: Text(_getFilterLabel(type)),
                      subtitle: Text(_getFilterDescription(type)),
                      value: type,
                      groupValue: _filterType,
                      onChanged: (value) {
                        setModalState(() {
                          _filterType = value!;
                        });
                        setState(() {
                          _filterType = value!;
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Apply Filter'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getErrorMessage(Object error) {
    if (error.toString().contains('network') ||
        error.toString().contains('internet')) {
      return 'Please check your internet connection and try again.';
    } else if (error.toString().contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (error.toString().contains('404')) {
      return 'Booking information not found.';
    } else if (error.toString().contains('401') ||
        error.toString().contains('403')) {
      return 'Please sign in again to view your bookings.';
    } else {
      return 'Something went wrong. Please try again later.';
    }
  }

  String _getFilterLabel(BookingFilterType type) {
    switch (type) {
      case BookingFilterType.all:
        return 'All Bookings';
      case BookingFilterType.active:
        return 'Active Bookings';
      case BookingFilterType.completed:
        return 'Completed Flights';
      case BookingFilterType.cancelled:
        return 'Cancelled Bookings';
    }
  }

  String _getFilterDescription(BookingFilterType type) {
    switch (type) {
      case BookingFilterType.all:
        return 'Show all your bookings';
      case BookingFilterType.active:
        return 'Confirmed and checked-in flights';
      case BookingFilterType.completed:
        return 'Past completed flights';
      case BookingFilterType.cancelled:
        return 'Cancelled reservations';
    }
  }
}

// Enum for filter types (add this to your models or create a separate file)
enum BookingFilterType { all, active, completed, cancelled }

// Enum for booking status (if not already defined in your Booking model)
enum BookingStatus { pending, confirmed, checkedIn, completed, cancelled }
