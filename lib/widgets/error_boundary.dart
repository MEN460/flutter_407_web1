import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails)? fallback;
  final VoidCallback? onError;
  final bool resetOnHotReload;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.fallback,
    this.onError,
    this.resetOnHotReload = true,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  // Use ValueNotifier instead of setState to avoid build phase violations
  final ValueNotifier<_ErrorState> _errorNotifier = ValueNotifier(
    const _ErrorState(),
  );

  bool _isDisposed = false;
  bool _isErrorHandlingSetup = false;
  ErrorWidgetBuilder? _originalErrorWidgetBuilder;
  FlutterExceptionHandler? _originalOnError;
  Timer? _resetTimer;
  int _errorCount = 0;
  static const int _maxErrorCount = 5;

  // Global error tracking to prevent multiple boundaries from interfering
  static bool _globalErrorHandling = false;

  @override
  void initState() {
    super.initState();

    // Setup error boundary after first frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        _setupErrorBoundary();
      }
    });

    // Handle hot reload resets
    if (widget.resetOnHotReload && kDebugMode) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          _resetError();
        }
      });
    }
  }

  void _setupErrorBoundary() {
    if (_isErrorHandlingSetup || _isDisposed || _globalErrorHandling) return;

    _isErrorHandlingSetup = true;
    _globalErrorHandling = true;

    // Store original error handlers
    _originalOnError = FlutterError.onError;
    _originalErrorWidgetBuilder = ErrorWidget.builder;

    // Set up error handling that never calls setState
    FlutterError.onError = (FlutterErrorDetails details) {
      // Always call original handler first
      _originalOnError?.call(details);

      // Handle error without setState
      _handleErrorSafely(details);
    };

    // Replace error widget builder
    ErrorWidget.builder = (FlutterErrorDetails details) {
      _handleErrorSafely(details);

      return Container(
        constraints: const BoxConstraints(minHeight: 50, minWidth: 50),
        color: Colors.red[50],
        child: const Center(
          child: Icon(Icons.error_outline, color: Colors.red, size: 24),
        ),
      );
    };
  }

  void _handleErrorSafely(FlutterErrorDetails details) {
    if (_isDisposed) return;

    // Increment error count
    _errorCount++;
    if (_errorCount > _maxErrorCount) {
      debugPrint('ErrorBoundary: Too many errors, stopping error handling');
      return;
    }

    // Update error state using ValueNotifier (no setState needed)
    _errorNotifier.value = _ErrorState(
      hasError: true,
      errorDetails: details,
      errorCount: _errorCount,
    );

    // Call error callback
    try {
      widget.onError?.call();
    } catch (e) {
      debugPrint('ErrorBoundary: onError callback failed: $e');
    }

    // Schedule auto-reset
    _scheduleAutoReset();
  }

  void _scheduleAutoReset() {
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(seconds: 15), () {
      if (!_isDisposed) {
        _resetError();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_ErrorState>(
      valueListenable: _errorNotifier,
      builder: (context, errorState, _) {
        if (errorState.hasError && errorState.errorDetails != null) {
          try {
            return widget.fallback?.call(errorState.errorDetails!) ??
                _defaultErrorWidget(errorState.errorDetails!);
          } catch (e) {
            return _safeErrorWidget();
          }
        }

        // Wrap child in error-catching builder
        return _SafeBuilder(onError: _handleErrorSafely, child: widget.child);
      },
    );
  }

  Widget _safeErrorWidget() {
    return Container(
      constraints: const BoxConstraints.expand(),
      color: Colors.red[50],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(
              'Critical Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'The application encountered a critical error.\nPlease restart the app.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultErrorWidget(FlutterErrorDetails details) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Something went wrong'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _resetError),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Error Type:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getErrorType(details),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error Details:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            details.exception.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (kDebugMode && details.stack != null) ...[
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),
                            const Text(
                              'Stack Trace (Debug Mode):',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              details.stack.toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _resetError,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                    ),
                    if (_errorCount > 1) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _resetWithDelay,
                          icon: const Icon(Icons.timer),
                          label: const Text('Reset & Wait'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getErrorType(FlutterErrorDetails details) {
    final error = details.exception.toString().toLowerCase();

    if (error.contains('setstate') || error.contains('markneedsbuild')) {
      return 'Build Phase Violation';
    } else if (error.contains('!_dirty') || error.contains('dirty')) {
      return 'Widget Tree Corruption';
    } else if (error.contains('renderobject') || error.contains('child')) {
      return 'Render Tree Inconsistency';
    } else if (error.contains('buildtarget') || error.contains('build')) {
      return 'Build Context Issue';
    } else if (error.contains('mounted') || error.contains('disposed')) {
      return 'Widget Lifecycle Issue';
    } else if (error.contains('assertion')) {
      return 'Flutter Framework Assertion';
    } else {
      return 'General Error';
    }
  }

  void _resetError() {
    if (_isDisposed) return;

    _resetTimer?.cancel();

    // Reset using ValueNotifier (no setState)
    _errorNotifier.value = _ErrorState();
    _errorCount = 0;
  }

  void _resetWithDelay() {
    Timer(const Duration(seconds: 3), () {
      if (!_isDisposed) {
        _resetError();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _resetTimer?.cancel();
    _errorNotifier.dispose();

    // Restore original error handlers
    if (_isErrorHandlingSetup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          FlutterError.onError = _originalOnError;
          ErrorWidget.builder =
              _originalErrorWidgetBuilder ??
              (FlutterErrorDetails details) => ErrorWidget(details.exception);
          _globalErrorHandling = false;
        } catch (e) {
          debugPrint('Error restoring handlers: $e');
        }
      });
    }

    super.dispose();
  }
}

/// Error state container
class _ErrorState {
  final bool hasError;
  final FlutterErrorDetails? errorDetails;
  final int errorCount;

  const _ErrorState({
    this.hasError = false,
    this.errorDetails,
    this.errorCount = 0,
  });
}

/// Safe builder that catches build-time errors without using setState
class _SafeBuilder extends StatelessWidget {
  final Widget child;
  final Function(FlutterErrorDetails) onError;

  const _SafeBuilder({required this.child, required this.onError});

  @override
  Widget build(BuildContext context) {
    try {
      return child;
    } catch (error, stackTrace) {
      // Create error details
      final details = FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'ErrorBoundary',
        context: ErrorDescription('Error caught during widget build'),
      );

      // Report error without triggering setState
      SchedulerBinding.instance.addPostFrameCallback((_) {
        onError(details);
      });

      // Return safe fallback immediately
      return Container(
        constraints: const BoxConstraints(minHeight: 50, minWidth: 50),
        color: Colors.red[50],
        child: const Center(
          child: Icon(Icons.error_outline, color: Colors.red, size: 24),
        ),
      );
    }
  }
}

/// Extension to add error boundary functionality to any widget
extension ErrorBoundaryExtension on Widget {
  /// Wraps this widget with an ErrorBoundary
  Widget withErrorBoundary({
    Widget Function(FlutterErrorDetails)? fallback,
    VoidCallback? onError,
    bool resetOnHotReload = true,
  }) {
    return ErrorBoundary(
      fallback: fallback,
      onError: onError,
      resetOnHotReload: resetOnHotReload,
      child: this,
    );
  }
}
