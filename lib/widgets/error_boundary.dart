import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/providers.dart';

class ErrorBoundary extends ConsumerStatefulWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  ConsumerState<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends ConsumerState<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      final logger = ref.read(loggerProvider);
      logger.error('Widget Error: $_error', _stackTrace);

      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text('Something went wrong', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Please restart the app', style: TextStyle(fontSize: 14)),
          ],
        ),
      );
    }

    return widget.child;
  }

}
  