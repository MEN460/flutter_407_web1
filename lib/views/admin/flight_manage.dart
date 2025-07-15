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
    final flightService = ref.read(flightServiceProvider);
    final flight = Flight(
      id: '', // Server-generated
      number: _numberController.text.trim(),
      origin: _originController.text.trim(),
      destination: _destController.text.trim(),
      departureTime: DateTime.parse(_timeController.text),
      capacities: {
        'executive': int.tryParse(_execController.text) ?? 0,
        'middle': int.tryParse(_midController.text) ?? 0,
        'economy': int.tryParse(_econController.text) ?? 0,
      },
    );

    try {
      await flightService.createFlight(flight);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
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
                decoration: const InputDecoration(labelText: 'Flight Number'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _originController,
                decoration: const InputDecoration(labelText: 'Origin'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _destController,
                decoration: const InputDecoration(labelText: 'Destination'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Departure Time (YYYY-MM-DD HH:MM)',
                  hintText: '2025-07-15 14:30',
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  try {
                    DateTime.parse(v);
                    return null;
                  } catch (_) {
                    return 'Invalid format';
                  }
                },
              ),
              const SizedBox(height: 20),
              const Text('Capacities:'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _execController,
                      decoration: const InputDecoration(labelText: 'Executive'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _midController,
                      decoration: const InputDecoration(labelText: 'Middle'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _econController,
                      decoration: const InputDecoration(labelText: 'Economy'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _createFlight,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Create Flight'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
