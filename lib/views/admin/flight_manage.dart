import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/models/flight.dart';
import 'package:k_airways_flutter/providers.dart';

class FlightManagementScreen extends ConsumerStatefulWidget {
  const FlightManagementScreen({super.key});

  @override
  ConsumerState<FlightManagementScreen> createState() =>
      _FlightManagementScreenState();
}

class _FlightManagementScreenState
    extends ConsumerState<FlightManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _originController = TextEditingController();
  final _destController = TextEditingController();
  final _timeController = TextEditingController();
  final _execController = TextEditingController(text: '0');
  final _midController = TextEditingController(text: '0');
  final _econController = TextEditingController(text: '0');
  bool _isLoading = false;

  Future<void> _createFlight() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final flightService = ref.read(flightServiceProvider);

      // Safe parsing with proper error handling
      final departureTime = DateTime.tryParse(_timeController.text.trim());
      if (departureTime == null) {
        throw Exception('Invalid departure time format');
      }

      final flight = Flight(
        id: '', // Server-generated
        number: _numberController.text.trim(),
        origin: _originController.text.trim(),
        destination: _destController.text.trim(),
        departureTime: departureTime,
        capacities: {
          'executive': int.tryParse(_execController.text.trim()) ?? 0,
          'middle': int.tryParse(_midController.text.trim()) ?? 0,
          'economy': int.tryParse(_econController.text.trim()) ?? 0,
        },
      );

      // Validate flight data
      if (!flight.isValid) {
        throw Exception('Invalid flight data');
      }

      await flightService.createFlight(flight);

      if (mounted) {
        // Clear form on success
        _clearForm();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Flight created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating flight: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearForm() {
    _numberController.clear();
    _originController.clear();
    _destController.clear();
    _timeController.clear();
    _execController.text = '0';
    _midController.text = '0';
    _econController.text = '0';
  }

  // Enhanced validation methods
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateCapacity(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final num = int.tryParse(value.trim());
    if (num == null) return 'Must be a valid number';
    if (num < 0) return 'Must be 0 or greater';
    if (num > 1000) return 'Must be less than 1000';
    return null;
  }

  String? _validateDateTime(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    final dateTime = DateTime.tryParse(value.trim());
    if (dateTime == null) {
      return 'Invalid format (use YYYY-MM-DD HH:MM)';
    }
    if (dateTime.isBefore(DateTime.now())) {
      return 'Departure time cannot be in the past';
    }
    return null;
  }

  @override
  void dispose() {
    _numberController.dispose();
    _originController.dispose();
    _destController.dispose();
    _timeController.dispose();
    _execController.dispose();
    _midController.dispose();
    _econController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Flight')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: 'Flight Number',
                  hintText: 'e.g., KA123',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _validateRequired(v, 'Flight Number'),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _originController,
                decoration: const InputDecoration(
                  labelText: 'Origin',
                  hintText: 'e.g., Nairobi (NBO)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _validateRequired(v, 'Origin'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _destController,
                decoration: const InputDecoration(
                  labelText: 'Destination',
                  hintText: 'e.g., Dubai (DXB)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _validateRequired(v, 'Destination'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Departure Time',
                  hintText: '2025-07-15 14:30',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                validator: _validateDateTime,
              ),
              const SizedBox(height: 20),
              const Text(
                'Seat Capacities:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _execController,
                      decoration: const InputDecoration(
                        labelText: 'Executive',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validateCapacity,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _midController,
                      decoration: const InputDecoration(
                        labelText: 'Middle',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validateCapacity,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _econController,
                      decoration: const InputDecoration(
                        labelText: 'Economy',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: _validateCapacity,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createFlight,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Flight'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
