import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/models/flight.dart';
import 'package:k_airways_flutter/models/flight_status.dart';
import 'package:k_airways_flutter/providers.dart';
import 'package:k_airways_flutter/widgets/status_badge.dart';

// Constants for flight status values
class FlightStatusConstants {
  static const String onTime = 'ON_TIME';
  static const String delayed = 'DELAYED';
  static const String cancelled = 'CANCELLED';
  static const String boarding = 'BOARDING';
  static const String departed = 'DEPARTED';
  static const String unknown = 'UNKNOWN';

  static const List<String> allStatuses = [
    onTime,
    delayed,
    cancelled,
    boarding,
    departed,
  ];

  static const Map<String, String> statusLabels = {
    onTime: 'On Time',
    delayed: 'Delayed',
    cancelled: 'Cancelled',
    boarding: 'Boarding',
    departed: 'Departed',
  };

  static const Map<String, Color> statusColors = {
    onTime: Colors.green,
    delayed: Colors.orange,
    cancelled: Colors.red,
    boarding: Colors.blue,
    departed: Colors.grey,
  };
}

class FlightOperationsScreen extends ConsumerStatefulWidget {
  final Flight? flight;

  const FlightOperationsScreen({super.key, this.flight});

  @override
  ConsumerState<FlightOperationsScreen> createState() =>
      _FlightOperationsScreenState();
}

class _FlightOperationsScreenState
    extends ConsumerState<FlightOperationsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gateController = TextEditingController();
  final _remarksController = TextEditingController();

  FlightStatus? _status;
  FlightStatus? _originalStatus;
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeStatus();
  }

  void _initializeStatus() {
    if (widget.flight != null) {
      _status = FlightStatus(
        flightId: widget.flight!.id,
        status: FlightStatusConstants.onTime,
        gate: '',
        remarks: '',
      );
      _originalStatus = _status?.copyWith();

      // Initialize controllers
      _gateController.text = _status?.gate ?? '';
      _remarksController.text = _status?.remarks ?? '';

      // Listen for changes
      _gateController.addListener(_onFieldChanged);
      _remarksController.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() {
    final hasChanges = _hasStatusChanged();
    if (hasChanges != _hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = hasChanges;
      });
    }
  }

  bool _hasStatusChanged() {
    if (_status == null || _originalStatus == null) return false;

    return _status!.status != _originalStatus!.status ||
        _gateController.text != _originalStatus!.gate ||
        _remarksController.text != _originalStatus!.remarks;
  }

  void _updateStatusField(String newStatus) {
    if (_status != null) {
      setState(() {
        _status = _status!.copyWith(status: newStatus);
        _hasUnsavedChanges = _hasStatusChanged();
      });
    }
  }

  Future<bool> _showUnsavedChangesDialog() async {
    if (!_hasUnsavedChanges) return true;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Unsaved Changes'),
            content: const Text(
              'You have unsaved changes. Are you sure you want to leave without saving?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Discard'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _updateStatus() async {
    if (widget.flight == null ||
        _status == null ||
        !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final flightService = ref.read(flightServiceProvider);

      // Update status with current field values
      final updatedStatus = _status!.copyWith(
        gate: _gateController.text.trim(),
        remarks: _remarksController.text.trim(),
      );

      await flightService.updateFlightStatus(widget.flight!.id, updatedStatus);

      if (mounted) {
        // Update original status to reflect saved state
        _originalStatus = updatedStatus.copyWith();
        _hasUnsavedChanges = false;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Flight ${_getFlightNumber()} status updated successfully',
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, updatedStatus);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(_getErrorMessage(e))),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _updateStatus,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getFlightNumber() {
    // Handle both 'number' and 'flightNumber' properties
    try {
      return widget.flight?.flightNumber ??
          (widget.flight as dynamic)?.number ??
          'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getErrorMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your connection and try again.';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('unauthorized') ||
        errorString.contains('401')) {
      return 'You don\'t have permission to update this flight.';
    } else if (errorString.contains('not found') ||
        errorString.contains('404')) {
      return 'Flight not found. It may have been removed.';
    } else {
      return 'Failed to update flight status. Please try again.';
    }
  }

  @override
  void dispose() {
    _gateController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flight == null) {
      return _NoFlightDataScreen();
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _showUnsavedChangesDialog();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Flight ${_getFlightNumber()} Operations'),
          centerTitle: true,
          actions: [
            if (_hasUnsavedChanges)
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Unsaved',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FlightInfoCard(flight: widget.flight!),
                const SizedBox(height: 24),
                _CurrentStatusSection(status: _status),
                const SizedBox(height: 24),
                _StatusUpdateForm(
                  status: _status,
                  gateController: _gateController,
                  remarksController: _remarksController,
                  onStatusChanged: _updateStatusField,
                ),
                const SizedBox(height: 32),
                _UpdateButton(
                  isLoading: _isLoading,
                  hasChanges: _hasUnsavedChanges,
                  onPressed: _updateStatus,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoFlightDataScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flight Operations')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flight_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No Flight Data',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'No flight data was provided to this screen.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlightInfoCard extends StatelessWidget {
  final Flight flight;

  const _FlightInfoCard({required this.flight});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flight_takeoff,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Flight Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
              label: 'Route',
              value: '${flight.origin} → ${flight.destination}',
              icon: Icons.route,
            ),
            _InfoRow(
              label: 'Scheduled Departure',
              value: _formatDateTime(flight.departureTime),
              icon: Icons.schedule,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _CurrentStatusSection extends StatelessWidget {
  final FlightStatus? status;

  const _CurrentStatusSection({this.status});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Status',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        StatusBadge(status: status?.status ?? FlightStatusConstants.unknown),
      ],
    );
  }
}

class _StatusUpdateForm extends StatelessWidget {
  final FlightStatus? status;
  final TextEditingController gateController;
  final TextEditingController remarksController;
  final ValueChanged<String> onStatusChanged;

  const _StatusUpdateForm({
    required this.status,
    required this.gateController,
    required this.remarksController,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Update Status',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: status?.status,
          decoration: const InputDecoration(
            labelText: 'Flight Status',
            prefixIcon: Icon(Icons.flight),
            border: OutlineInputBorder(),
          ),
          items: FlightStatusConstants.allStatuses.map((statusValue) {
            return DropdownMenuItem(
              value: statusValue,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: FlightStatusConstants.statusColors[statusValue],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    FlightStatusConstants.statusLabels[statusValue] ??
                        statusValue,
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onStatusChanged(value);
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a status';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: gateController,
          decoration: const InputDecoration(
            labelText: 'Gate',
            prefixIcon: Icon(Icons.gate),
            border: OutlineInputBorder(),
            hintText: 'e.g., A12, B5',
          ),
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            LengthLimitingTextInputFormatter(10),
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
          ],
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!RegExp(r'^[A-Za-z]\d+$').hasMatch(value.trim())) {
                return 'Gate should be in format like A12, B5, etc.';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: remarksController,
          decoration: const InputDecoration(
            labelText: 'Remarks',
            prefixIcon: Icon(Icons.note),
            border: OutlineInputBorder(),
            hintText: 'Additional notes about the flight status...',
          ),
          maxLines: 3,
          maxLength: 500,
          textCapitalization: TextCapitalization.sentences,
          validator: (value) {
            if (value != null && value.length > 500) {
              return 'Remarks cannot exceed 500 characters';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class _UpdateButton extends StatelessWidget {
  final bool isLoading;
  final bool hasChanges;
  final VoidCallback? onPressed;

  const _UpdateButton({
    required this.isLoading,
    required this.hasChanges,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : (hasChanges ? onPressed : null),
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save),
        label: Text(
          isLoading
              ? 'Updating...'
              : hasChanges
              ? 'Update Status'
              : 'No Changes to Save',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: hasChanges
              ? Theme.of(context).primaryColor
              : Colors.grey[300],
          foregroundColor: hasChanges ? Colors.white : Colors.grey[600],
        ),
      ),
    );
  }
}
