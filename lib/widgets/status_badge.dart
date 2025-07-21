import 'package:flutter/material.dart';

/// Enum representing different status types for better type safety
enum StatusType {
  onTime('ON_TIME', 'On Time', Colors.green),
  confirmed('CONFIRMED', 'Confirmed', Colors.green),
  completed('COMPLETED', 'Completed', Colors.green),
  delayed('DELAYED', 'Delayed', Colors.orange),
  cancelled('CANCELLED', 'Cancelled', Colors.red),
  pending('PENDING', 'Pending', Colors.blue),
  boarding('BOARDING', 'Boarding', Colors.blueAccent),
  departed('DEPARTED', 'Departed', Colors.purple),
  inProgress('IN_PROGRESS', 'In Progress', Colors.amber),
  scheduled('SCHEDULED', 'Scheduled', Colors.teal),
  unknown('UNKNOWN', 'Unknown', Colors.grey);

  const StatusType(this.key, this.displayText, this.defaultColor);

  final String key;
  final String displayText;
  final Color defaultColor;

  /// Find StatusType by key string
  static StatusType fromString(String status) {
    final normalizedStatus = status.toUpperCase().trim();
    for (final type in StatusType.values) {
      if (type.key == normalizedStatus) {
        return type;
      }
    }
    return StatusType.unknown;
  }
}

/// Configuration class for badge styling
class StatusBadgeStyle {
  final EdgeInsets padding;
  final double borderRadius;
  final double borderWidth;
  final TextStyle? textStyle;
  final double backgroundOpacity;
  final bool showBorder;
  final bool showIcon;

  const StatusBadgeStyle({
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.borderRadius = 12.0,
    this.borderWidth = 1.0,
    this.textStyle,
    this.backgroundOpacity = 0.1,
    this.showBorder = true,
    this.showIcon = false,
  });

  /// Predefined styles for different use cases
  static const compact = StatusBadgeStyle(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    borderRadius: 8.0,
    backgroundOpacity: 0.08,
  );

  static const pill = StatusBadgeStyle(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    borderRadius: 20.0,
    backgroundOpacity: 0.12,
  );

  static const minimal = StatusBadgeStyle(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    borderRadius: 4.0,
    showBorder: false,
    backgroundOpacity: 0.15,
  );
}

/// A highly customizable status badge widget with built-in accessibility support
class StatusBadge extends StatelessWidget {
  /// The status string to display
  final String status;

  /// Optional custom color override
  final Color? color;

  /// Optional custom display text override
  final String? displayText;

  /// Badge styling configuration
  final StatusBadgeStyle style;

  /// Optional icon to show alongside text
  final IconData? icon;

  /// Custom color mapping function
  final Color Function(StatusType)? colorMapper;

  /// Whether to use uppercase text
  final bool uppercase;

  const StatusBadge({
    super.key,
    required this.status,
    this.color,
    this.displayText,
    this.style = const StatusBadgeStyle(),
    this.icon,
    this.colorMapper,
    this.uppercase = false,
  });

  /// Convenience constructors for common styles
  const StatusBadge.compact({
    super.key,
    required this.status,
    this.color,
    this.displayText,
    this.icon,
    this.colorMapper,
    this.uppercase = false,
  }) : style = StatusBadgeStyle.compact;

  const StatusBadge.pill({
    super.key,
    required this.status,
    this.color,
    this.displayText,
    this.icon,
    this.colorMapper,
    this.uppercase = false,
  }) : style = StatusBadgeStyle.pill;

  const StatusBadge.minimal({
    super.key,
    required this.status,
    this.color,
    this.displayText,
    this.icon,
    this.colorMapper,
    this.uppercase = false,
  }) : style = StatusBadgeStyle.minimal;

  @override
  Widget build(BuildContext context) {
    final statusType = StatusType.fromString(status);
    final badgeColor = _getBadgeColor(statusType);
    final text = _getDisplayText(statusType);
    final backgroundColor = badgeColor.withValues(
      alpha: style.backgroundOpacity,
    );

    return Semantics(
      label: 'Status: $text',
      child: Container(
        padding: style.padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(style.borderRadius),
          border: style.showBorder
              ? Border.all(color: badgeColor, width: style.borderWidth)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null ||
                (style.showIcon && _getDefaultIcon(statusType) != null)) ...[
              Icon(
                icon ?? _getDefaultIcon(statusType),
                color: badgeColor,
                size: 16,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              uppercase ? text.toUpperCase() : text,
              style: _getTextStyle(context, badgeColor),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBadgeColor(StatusType statusType) {
    if (color != null) return color!;
    if (colorMapper != null) return colorMapper!(statusType);
    return statusType.defaultColor;
  }

  String _getDisplayText(StatusType statusType) {
    if (displayText != null) return displayText!;
    return statusType == StatusType.unknown ? status : statusType.displayText;
  }

  TextStyle _getTextStyle(BuildContext context, Color badgeColor) {
    final baseStyle =
        style.textStyle ??
        Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600) ??
        const TextStyle(fontWeight: FontWeight.w600);

    return baseStyle.copyWith(color: badgeColor);
  }

  IconData? _getDefaultIcon(StatusType statusType) {
    switch (statusType) {
      case StatusType.completed:
        return Icons.check_circle_outline;
      case StatusType.confirmed:
        return Icons.verified_outlined;
      case StatusType.onTime:
        return Icons.schedule;
      case StatusType.delayed:
        return Icons.access_time;
      case StatusType.cancelled:
        return Icons.cancel_outlined;
      case StatusType.pending:
        return Icons.hourglass_empty;
      case StatusType.boarding:
        return Icons.flight_takeoff;
      case StatusType.departed:
        return Icons.flight;
      case StatusType.inProgress:
        return Icons.sync;
      case StatusType.scheduled:
        return Icons.event;
      case StatusType.unknown:
        return Icons.help_outline;
    }
  }
}

/// Collection widget for displaying multiple status badges
class StatusBadgeGroup extends StatelessWidget {
  final List<String> statuses;
  final StatusBadgeStyle style;
  final double spacing;
  final WrapAlignment alignment;
  final Color Function(StatusType)? colorMapper;

  const StatusBadgeGroup({
    super.key,
    required this.statuses,
    this.style = const StatusBadgeStyle(),
    this.spacing = 8.0,
    this.alignment = WrapAlignment.start,
    this.colorMapper,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      alignment: alignment,
      children: statuses
          .map(
            (status) => StatusBadge(
              status: status,
              style: style,
              colorMapper: colorMapper,
            ),
          )
          .toList(),
    );
  }
}

/// Example usage demonstrating the StatusBadge component
class StatusBadgeExample extends StatelessWidget {
  const StatusBadgeExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status Badge Examples')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Default Style:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const StatusBadgeGroup(
              statuses: [
                'ON_TIME',
                'DELAYED',
                'CANCELLED',
                'PENDING',
                'BOARDING',
                'DEPARTED',
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              'Compact Style:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const StatusBadgeGroup(
              statuses: ['CONFIRMED', 'COMPLETED', 'IN_PROGRESS', 'SCHEDULED'],
              style: StatusBadgeStyle.compact,
            ),

            const SizedBox(height: 24),
            const Text(
              'Pill Style with Icons:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusBadge(
                  status: 'COMPLETED',
                  style: StatusBadgeStyle.pill.copyWith(showIcon: true),
                ),
                StatusBadge(
                  status: 'DELAYED',
                  style: StatusBadgeStyle.pill.copyWith(showIcon: true),
                ),
                StatusBadge(
                  status: 'CANCELLED',
                  style: StatusBadgeStyle.pill.copyWith(showIcon: true),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              'Custom Colors & Text:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusBadge(
                  status: 'CUSTOM_STATUS',
                  displayText: 'Custom Status',
                  color: Colors.deepPurple,
                  icon: Icons.star,
                ),
                StatusBadge(
                  status: 'ANOTHER_STATUS',
                  displayText: 'UPPERCASE',
                  color: Colors.teal,
                  uppercase: true,
                  style: StatusBadgeStyle.minimal,
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              'Custom Color Mapping:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StatusBadgeGroup(
              statuses: const ['ON_TIME', 'DELAYED', 'CANCELLED'],
              colorMapper: (statusType) {
                // Custom monochrome color scheme
                switch (statusType) {
                  case StatusType.onTime:
                    return Colors.green.shade800;
                  case StatusType.delayed:
                    return Colors.grey.shade700;
                  case StatusType.cancelled:
                    return Colors.red.shade900;
                  default:
                    return Colors.blueGrey;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

extension StatusBadgeStyleExtensions on StatusBadgeStyle {
  StatusBadgeStyle copyWith({
    EdgeInsets? padding,
    double? borderRadius,
    double? borderWidth,
    TextStyle? textStyle,
    double? backgroundOpacity,
    bool? showBorder,
    bool? showIcon,
  }) {
    return StatusBadgeStyle(
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      textStyle: textStyle ?? this.textStyle,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      showBorder: showBorder ?? this.showBorder,
      showIcon: showIcon ?? this.showIcon,
    );
  }
}

// Add this extension
extension ColorExtensions on Color {
  Color withValues({double? alpha}) {
    return withOpacity(alpha ?? opacity);
  }
}
