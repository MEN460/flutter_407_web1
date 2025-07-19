import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/providers.dart';
import 'package:k_airways_flutter/widgets/status_badge.dart';
import 'package:k_airways_flutter/models/flight_status.dart';
import 'package:intl/intl.dart';

class FlightStatusScreen extends ConsumerWidget {
  final String flightId;

  const FlightStatusScreen({super.key, required this.flightId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(flightStatusProvider(flightId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Flight $flightId'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(flightStatusProvider(flightId)),
            tooltip: 'Refresh status',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(flightStatusProvider(flightId));
          // Wait a bit for the refresh to complete
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: statusAsync.when(
          loading: () => const _LoadingState(),
          error: (error, stackTrace) => _ErrorState(
            error: error,
            onRetry: () => ref.refresh(flightStatusProvider(flightId)),
          ),
          data: (status) => _FlightStatusContent(status: status),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading flight status...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 24),
            const Text(
              'Unable to load flight status',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Please check your connection and try again',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlightStatusContent extends StatelessWidget {
  final FlightStatus status;

  const _FlightStatusContent({required this.status});

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Not available';
    return DateFormat('MMM dd, yyyy • h:mm a').format(dateTime.toLocal());
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '--:--';
    return DateFormat('h:mm a').format(dateTime.toLocal());
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'on time':
        return Colors.green;
      case 'delayed':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'boarding':
        return Colors.blue;
      case 'departed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flight Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Flight ${status.flightId}',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          if (status.route != null)
                            Text(
                              status.route!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                      StatusBadge(status: status.status),
                    ],
                  ),

                  const SizedBox(height: 16),

                  if (status.aircraft != null) ...[
                    _InfoRow(
                      icon: Icons.airplanemode_active,
                      label: 'Aircraft',
                      value: status.aircraft!,
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Departure Information
          _SectionCard(
            title: 'Departure',
            icon: Icons.flight_takeoff,
            children: [
              if (status.scheduledDeparture != null)
                _InfoRow(
                  icon: Icons.schedule,
                  label: 'Scheduled',
                  value: _formatDateTime(status.scheduledDeparture),
                ),

              if (status.estimatedDeparture != null) ...[
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.update,
                  label: 'Estimated',
                  value: _formatDateTime(status.estimatedDeparture),
                  valueColor:
                      status.estimatedDeparture != status.scheduledDeparture
                      ? Colors.orange
                      : null,
                ),
              ],

              if (status.actualDeparture != null) ...[
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.check_circle,
                  label: 'Actual',
                  value: _formatDateTime(status.actualDeparture),
                  valueColor: Colors.green,
                ),
              ],

              if (status.gate != null && status.gate!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.location_on,
                  label: 'Gate',
                  value: status.gate!,
                ),
              ],

              if (status.terminal != null && status.terminal!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.business,
                  label: 'Terminal',
                  value: status.terminal!,
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // Arrival Information (if available)
          if (status.scheduledArrival != null ||
              status.estimatedArrival != null ||
              status.actualArrival != null) ...[
            _SectionCard(
              title: 'Arrival',
              icon: Icons.flight_land,
              children: [
                if (status.scheduledArrival != null)
                  _InfoRow(
                    icon: Icons.schedule,
                    label: 'Scheduled',
                    value: _formatDateTime(status.scheduledArrival),
                  ),

                if (status.estimatedArrival != null) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.update,
                    label: 'Estimated',
                    value: _formatDateTime(status.estimatedArrival),
                    valueColor:
                        status.estimatedArrival != status.scheduledArrival
                        ? Colors.orange
                        : null,
                  ),
                ],

                if (status.actualArrival != null) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.check_circle,
                    label: 'Actual',
                    value: _formatDateTime(status.actualArrival),
                    valueColor: Colors.green,
                  ),
                ],

                if (status.arrivalGate != null &&
                    status.arrivalGate!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.location_on,
                    label: 'Arrival Gate',
                    value: status.arrivalGate!,
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),
          ],

          // Additional Information
          if ((status.remarks != null && status.remarks!.isNotEmpty) ||
              (status.delay != null && status.delay! > 0))
            _SectionCard(
              title: 'Additional Information',
              icon: Icons.info_outline,
              children: [
                if (status.delay != null && status.delay! > 0)
                  _InfoRow(
                    icon: Icons.timer,
                    label: 'Delay',
                    value: '${status.delay} minutes',
                    valueColor: Colors.red,
                  ),

                if (status.remarks != null && status.remarks!.isNotEmpty) ...[
                  if (status.delay != null && status.delay! > 0)
                    const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.note,
                    label: 'Remarks',
                    value: status.remarks!,
                  ),
                ],
              ],
            ),

          const SizedBox(height: 16),

          // Last Updated
          if (status.lastUpdated != null)
            Card(
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.update, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Last updated: ${_formatDateTime(status.lastUpdated)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
