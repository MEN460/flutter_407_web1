import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/providers.dart';
import 'package:k_airways_flutter/widgets/flight_card.dart';
import 'package:intl/intl.dart';

class FlightSearchScreen extends ConsumerStatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  ConsumerState<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends ConsumerState<FlightSearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _originController = TextEditingController();
  final _destController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedClass;
  bool _isSearching = false;

  static const List<String> _flightClasses = [
    'Economy',
    'Business',
    'First Class',
  ];

  @override
  void dispose() {
    _originController.dispose();
    _destController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: Theme.of(context).primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _searchFlights() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      _showErrorSnackBar('Please select a departure date');
      return;
    }

    if (_selectedClass == null) {
      _showErrorSnackBar('Please select a class');
      return;
    }

    setState(() => _isSearching = true);

    try {
      // Create search parameters
      final searchParams = FlightSearchParams(
        origin: _originController.text.trim(),
        destination: _destController.text.trim(),
        departureDate: _selectedDate!,
        flightClass: _selectedClass!.toLowerCase(),
      );

      // Update the search parameters in the provider
      await ref
          .read(flightSearchParamsProvider.notifier)
          .updateSearchParams(searchParams);

      // Refresh the flights provider with new search parameters
      ref.refresh(filteredFlightsProvider as Refreshable);
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Search failed. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _swapOriginDestination() {
    final temp = _originController.text;
    _originController.text = _destController.text;
    _destController.text = temp;
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Flights'), elevation: 0),
      body: SafeArea(
        child: Column(
          children: [
            // Search Form
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Origin and Destination with Swap Button
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _originController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'From',
                              hintText: 'Origin city',
                              prefixIcon: Icon(Icons.flight_takeoff),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter origin city';
                              }
                              if (value.trim().length < 2) {
                                return 'Please enter a valid city';
                              }
                              return null;
                            },
                          ),
                        ),

                        // Swap Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: IconButton(
                            onPressed: _swapOriginDestination,
                            icon: const Icon(Icons.swap_horiz),
                            tooltip: 'Swap cities',
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                            ),
                          ),
                        ),

                        Expanded(
                          child: TextFormField(
                            controller: _destController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'To',
                              hintText: 'Destination city',
                              prefixIcon: Icon(Icons.flight_land),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter destination city';
                              }
                              if (value.trim().length < 2) {
                                return 'Please enter a valid city';
                              }
                              if (value.trim().toLowerCase() ==
                                  _originController.text.trim().toLowerCase()) {
                                return 'Destination must be different from origin';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Date and Class Selection
                    Row(
                      children: [
                        // Date Picker
                        Expanded(
                          flex: 3,
                          child: OutlinedButton.icon(
                            onPressed: () => _selectDate(context),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _selectedDate == null
                                  ? 'Select Date'
                                  : _formatDate(_selectedDate!),
                              style: TextStyle(
                                color: _selectedDate == null
                                    ? Theme.of(context).hintColor
                                    : null,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Class Dropdown
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _selectedClass,
                            items: _flightClasses
                                .map(
                                  (flightClass) => DropdownMenuItem(
                                    value: flightClass,
                                    child: Text(flightClass),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedClass = value),
                            decoration: const InputDecoration(
                              labelText: 'Class',
                              prefixIcon: Icon(
                                Icons.airline_seat_recline_extra,
                              ),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value == null ? 'Please select a class' : null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Search Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isSearching ? null : _searchFlights,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: _isSearching
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.search),
                        label: Text(
                          _isSearching ? 'Searching...' : 'Search Flights',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Flight Results
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final flightsAsync = ref.watch(filteredFlightsProvider as ProviderListenable);

                  return flightsAsync.when(
                    loading: () => const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Searching for flights...'),
                        ],
                      ),
                    ),
                    error: (error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Failed to load flights',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please check your connection and try again',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () =>
                                ref.refresh(filteredFlightsProvider as Refreshable<void>),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                    data: (flights) {
                      if (flights.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.flight_takeoff,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No flights found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your search criteria',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Results Header
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Text(
                              '${flights.length} flight${flights.length != 1 ? 's' : ''} found',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ),

                          // Flight List
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              itemCount: flights.length,
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: FlightCard(flight: flights[index]),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data class for search parameters (add this to your models)
class FlightSearchParams {
  final String origin;
  final String destination;
  final DateTime departureDate;
  final String flightClass;

  const FlightSearchParams({
    required this.origin,
    required this.destination,
    required this.departureDate,
    required this.flightClass,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FlightSearchParams &&
        other.origin == origin &&
        other.destination == destination &&
        other.departureDate == departureDate &&
        other.flightClass == flightClass;
  }

  @override
  int get hashCode {
    return origin.hashCode ^
        destination.hashCode ^
        departureDate.hashCode ^
        flightClass.hashCode;
  }
}
