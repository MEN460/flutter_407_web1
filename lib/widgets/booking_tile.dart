import 'package:flutter/material.dart';
import 'package:k_airways_flutter/models/booking.dart';
import 'package:k_airways_flutter/widgets/status_badge.dart';

class BookingTile extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const BookingTile({
    super.key,
    required this.booking,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap ?? () => _showBookingDetails(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Leading icon with better styling
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.confirmation_num,
                  color: theme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Booking ID with safe substring
                    Text(
                      'Booking ${_getSafeBookingId()}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Flight information
                    if (booking.flight != null) ...[
                      Text(
                        'Flight: ${booking.flight!.number}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${booking.flight!.origin ?? 'Unknown'} → ${booking.flight!.destination ?? 'Unknown'}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        'Flight information unavailable',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Status badge
              StatusBadge(status: booking.status),
            ],
          ),
        ),
      ),
    );
  }

  /// Safely extracts booking ID with proper length handling
  String _getSafeBookingId() {
    final id = booking.id;
    if (id.isEmpty) return 'N/A';
    return id.length >= 8 ? id.substring(0, 8) : id;
  }

  /// Shows booking details in a bottom sheet or dialog
  void _showBookingDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => BookingDetailsSheet(booking: booking),
    );
  }
}

/// Detailed booking information sheet
class BookingDetailsSheet extends StatelessWidget {
  final Booking booking;

  const BookingDetailsSheet({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.confirmation_num,
                        color: theme.primaryColor,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Booking Details',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'ID: ${booking.id}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(status: booking.status),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Flight Information
                  if (booking.flight != null) ...[
                    _buildSection(context, 'Flight Information', [
                      _buildDetailRow(
                        'Flight Number',
                        booking.flight!.number ?? 'N/A',
                      ),
                      _buildDetailRow(
                        'Route',
                        '${booking.flight!.origin ?? 'Unknown'} → ${booking.flight!.destination ?? 'Unknown'}',
                      ),
                      // Add more flight details as needed
                    ]),
                  ] else ...[
                    _buildSection(context, 'Flight Information', [
                      const Text(
                        'Flight information is not available for this booking.',
                      ),
                    ]),
                  ],

                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          label: const Text('Close'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Implement edit/manage booking
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Manage'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
