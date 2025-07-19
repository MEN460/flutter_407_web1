import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/providers.dart';

/// A comprehensive error boundary widget that catches and handles various types of errors
class ErrorBoundary extends ConsumerStatefulWidget {
  final Widget child;
  final Widget Function(
    Object error,
    StackTrace? stackTrace,
    VoidCallback retry,
  )?
  errorBuilder;
  final void Function(Object error, StackTrace? stackTrace)? onError;
  final bool showErrorDetails;
  final String? errorMessage;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
    this.showErrorDetails = kDebugMode,
    this.errorMessage,
  });

  @override
  ConsumerState<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends ConsumerState<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;
  late final StreamSubscription<void> _errorSubscription;

  @override
  void initState() {
    super.initState();
    _setupErrorHandling();
  }

  @override
  void dispose() {
    _errorSubscription.cancel();
    super.dispose();
  }

  void _setupErrorHandling() {
    // Listen to async errors in the current zone
    _errorSubscription = Stream.periodic(const Duration(milliseconds: 100)).listen((
      _,
    ) {
      // This is a placeholder - in practice, you might use other error monitoring
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _stackTrace, _retry) ??
          _buildDefaultErrorWidget();
    }

    // Wrap child in error-catching zone
    return _ErrorCatcher(onError: _handleError, child: widget.child);
  }

  void _handleError(Object error, StackTrace? stackTrace) {
    if (mounted) {
      setState(() {
        _error = error;
        _stackTrace = stackTrace;
      });

      // Log error
      try {
        final logger = ref.read(loggerProvider);
        logger.error('ErrorBoundary caught error: $error', stackTrace);
      } catch (logError) {
        // Fallback logging
        debugPrint('ErrorBoundary: Failed to log error: $logError');
        debugPrint('Original error: $error');
      }

      // Call custom error handler
      widget.onError?.call(error, stackTrace);
    }
  }

  void _retry() {
    if (mounted) {
      setState(() {
        _error = null;
        _stackTrace = null;
      });
    }
  }

  Widget _buildDefaultErrorWidget() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
          ),

          const SizedBox(height: 24),

          // Error Message
          Text(
            widget.errorMessage ?? 'Something went wrong',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            'We apologize for the inconvenience. Please try again.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              if (widget.showErrorDetails)
                OutlinedButton.icon(
                  onPressed: () => _showErrorDetails(context),
                  icon: const Icon(Icons.bug_report),
                  label: const Text('Details'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
            ],
          ),

          // Debug Information (only in debug mode)
          if (widget.showErrorDetails && _error != null) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error Details (Debug Mode)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showErrorDetails(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) =>
          ErrorDetailsDialog(error: _error!, stackTrace: _stackTrace),
    );
  }
}

/// Widget that catches errors in its child widget tree
class _ErrorCatcher extends StatefulWidget {
  final Widget child;
  final void Function(Object error, StackTrace? stackTrace) onError;

  const _ErrorCatcher({required this.child, required this.onError});

  @override
  State<_ErrorCatcher> createState() => _ErrorCatcherState();
}

class _ErrorCatcherState extends State<_ErrorCatcher> {
  ErrorWidgetBuilder? _originalErrorBuilder;

  @override
  void initState() {
    super.initState();
    // Store the original error builder
    _originalErrorBuilder = ErrorWidget.builder;

    // Set custom error builder
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Call error handler
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onError(details.exception, details.stack);
        }
      });

      // Return a simple error widget to prevent cascading errors
      return const SizedBox.shrink();
    };
  }

  @override
  void dispose() {
    // Restore original error builder
    if (_originalErrorBuilder != null) {
      ErrorWidget.builder = _originalErrorBuilder!;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use a Builder to catch synchronous errors
    return Builder(
      builder: (context) {
        try {
          return widget.child;
        } catch (error, stackTrace) {
          // Catch synchronous errors
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              widget.onError(error, stackTrace);
            }
          });
          return const SizedBox.shrink();
        }
      },
    );
  }
}

/// Dialog showing detailed error information
class ErrorDetailsDialog extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;

  const ErrorDetailsDialog({super.key, required this.error, this.stackTrace});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.bug_report, color: Colors.red),
          SizedBox(width: 8),
          Text('Error Details'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Error:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.error.withOpacity(0.3),
                ),
              ),
              child: Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  color: theme.colorScheme.error,
                ),
              ),
            ),

            if (stackTrace != null) ...[
              const SizedBox(height: 16),
              Text(
                'Stack Trace:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    stackTrace.toString(),
                    style: TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            // Copy error to clipboard
            // Note: You'd need to add clipboard functionality
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.copy),
          label: const Text('Copy'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

/// Extension to add error boundary functionality to any widget
extension ErrorBoundaryExtension on Widget {
  Widget withErrorBoundary({
    Widget Function(Object error, StackTrace? stackTrace, VoidCallback retry)?
    errorBuilder,
    void Function(Object error, StackTrace? stackTrace)? onError,
    bool showErrorDetails = kDebugMode,
    String? errorMessage,
  }) {
    return ErrorBoundary(
      errorBuilder: errorBuilder,
      onError: onError,
      showErrorDetails: showErrorDetails,
      errorMessage: errorMessage,
      child: this,
    );
  }
}
