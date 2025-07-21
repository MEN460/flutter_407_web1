import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:k_airways_flutter/models/flight.dart';
import 'package:k_airways_flutter/constants/app_colors.dart';

class FlightCard extends StatelessWidget {
  final Flight flight;
  final VoidCallback? onTap;
  final bool showPricing;
  final bool isSelected;

  const FlightCard({
    super.key,
    required this.flight,
    this.onTap,
    this.showPricing = true,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      elevation: isSelected ? 8 : 2,
      shadowColor: isSelected ? theme.primaryColor.withOpacity(0.3) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: theme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap ?? () => _handleDefaultTap(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 16),
              _buildFlightRoute(theme),
              const SizedBox(height: 20),
              _buildFlightTiming(theme),
              const SizedBox(height: 16),
              _buildCapacityInfo(theme),
              if (showPricing) ...[
                const SizedBox(height: 16),
                _buildPricingInfo(theme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      flight.number,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      flight.airline,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                ],
              ),
              ...[
              const SizedBox(height: 4),
              Text(
                flight.aircraft,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.airplanemode_active,
            color: theme.primaryColor,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildFlightRoute(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FROM',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                flight.origin,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  width: 40,
                  height: 2,
                  color: theme.primaryColor,
                ),
              ),
              Icon(Icons.flight_takeoff, color: theme.primaryColor, size: 20),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'TO',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                flight.destination,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.end,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlightTiming(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTimeInfo(
            theme,
            'Departure',
            flight.departureTime,
            Icons.flight_takeoff,
          ),
          if (flight.arrivalTime != null)
            _buildTimeInfo(
              theme,
              'Arrival',
              flight.arrivalTime!,
              Icons.flight_land,
            ),
          _buildDurationInfo(theme),
        ],
      ),
    );
  }

  Widget _buildTimeInfo(
    ThemeData theme,
    String label,
    DateTime time,
    IconData icon,
  ) {
    final formatter = DateFormat('HH:mm');
    final dateFormatter = DateFormat('MMM dd');

    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          formatter.format(time),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          dateFormatter.format(time),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationInfo(ThemeData theme) {
    return Column(
      children: [
        Icon(
          Icons.schedule,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(height: 4),
        Text(
          'Duration',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _formatDuration(flight.duration),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCapacityInfo(ThemeData theme) {
    final capacities = flight.capacities;

    if (capacities.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, size: 16, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Text(
              'Seat availability information not available',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Seats',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: capacities.entries.map((entry) {
            return _buildClassBadge(theme, entry.key, entry.value);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildClassBadge(ThemeData theme, String classType, int available) {
    final color = _getClassColor(classType);
    final isLowAvailability = available < 5;
    final isUnavailable = available == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isUnavailable
            ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.5)
            : color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnavailable
              ? theme.colorScheme.outline.withOpacity(0.3)
              : color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isUnavailable
                  ? theme.colorScheme.outline.withOpacity(0.5)
                  : color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _formatClassName(classType),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isUnavailable
                  ? theme.colorScheme.onSurface.withOpacity(0.5)
                  : theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$available',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isUnavailable
                  ? theme.colorScheme.error
                  : isLowAvailability
                  ? Colors.orange[700]
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Starting from',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                _formatPrice(flight.basePrice),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Select',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDefaultTap(BuildContext context) {
    try {
      context.push('/booking', extra: flight);
    } catch (e) {
      // Fallback navigation or error handling
      debugPrint('Navigation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to navigate to booking page')),
      );
    }
  }

  String _formatClassName(String className) {
    switch (className.toLowerCase()) {
      case 'executive':
      case 'first':
        return 'Executive';
      case 'middle':
      case 'business':
        return 'Business';
      case 'economy':
      case 'coach':
        return 'Economy';
      default:
        return className.replaceFirst(className[0], className[0].toUpperCase());
    }
  }

  Color _getClassColor(String className) {
    try {
      switch (className.toLowerCase()) {
        case 'executive':
        case 'first':
          return AppColors.executiveClass;
        case 'middle':
        case 'business':
          return AppColors.middleClass;
        case 'economy':
        case 'coach':
          return AppColors.economyClass;
        default:
          return Colors.grey[600] ?? Colors.grey;
      }
    } catch (e) {
      // Fallback if AppColors is not available
      switch (className.toLowerCase()) {
        case 'executive':
        case 'first':
          return Colors.purple[400] ?? Colors.purple;
        case 'middle':
        case 'business':
          return Colors.blue[400] ?? Colors.blue;
        case 'economy':
        case 'coach':
          return Colors.green[400] ?? Colors.green;
        default:
          return Colors.grey[600] ?? Colors.grey;
      }
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _formatPrice(double price) {
    // You might want to use intl package for proper currency formatting
    return '\$${price.toStringAsFixed(0)}';
  }
}
