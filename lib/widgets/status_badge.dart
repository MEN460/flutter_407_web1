import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    String displayText;

    switch (status.toUpperCase()) {
      case 'ON_TIME':
      case 'CONFIRMED':
      case 'COMPLETED':
        backgroundColor = Colors.green;
        displayText = status == 'ON_TIME'
            ? 'On Time'
            : status == 'CONFIRMED'
            ? 'Confirmed'
            : 'Completed';
        break;
      case 'DELAYED':
        backgroundColor = Colors.orange;
        displayText = 'Delayed';
        break;
      case 'CANCELLED':
        backgroundColor = Colors.red;
        displayText = 'Cancelled';
        break;
      case 'PENDING':
        backgroundColor = Colors.blue;
        displayText = 'Pending';
        break;
      case 'BOARDING':
        backgroundColor = Colors.blueAccent;
        displayText = 'Boarding';
        break;
      case 'DEPARTED':
        backgroundColor = Colors.purple;
        displayText = 'Departed';
        break;
      default:
        backgroundColor = Colors.grey;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        
       color: backgroundColor.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: backgroundColor),
      ),
      child: Text(
        displayText,
        style: TextStyle(color: backgroundColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
