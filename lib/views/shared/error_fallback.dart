import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorFallbackScreen extends StatelessWidget {
  final String? errorMessage;
  final int statusCode;

  const ErrorFallbackScreen({
    super.key,
    this.errorMessage,
    this.statusCode = 404,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error icon
                Icon(Icons.error_outline, size: 72, color: colorScheme.error),
                const SizedBox(height: 24),

                // Status code
                Text(
                  statusCode.toString(),
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Error title
                Text(
                  _getErrorTitle(statusCode),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Error message (if provided)
                if (errorMessage != null) ...[
                  Text(
                    errorMessage!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 24),
                ] else
                  const SizedBox(height: 24),

                // Default error description
                Text(
                  _getErrorDescription(statusCode),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Action buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => context.go('/'),
                        icon: const Icon(Icons.home),
                        label: const Text('Return Home'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/');
                          }
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Go Back'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getErrorTitle(int statusCode) {
    switch (statusCode) {
      case 404:
        return 'Page Not Found';
      case 403:
        return 'Access Forbidden';
      case 500:
        return 'Server Error';
      case 503:
        return 'Service Unavailable';
      default:
        return 'Something Went Wrong';
    }
  }

  String _getErrorDescription(int statusCode) {
    switch (statusCode) {
      case 404:
        return 'The page you\'re looking for doesn\'t exist or has been moved.';
      case 403:
        return 'You don\'t have permission to access this resource.';
      case 500:
        return 'We\'re experiencing technical difficulties. Please try again later.';
      case 503:
        return 'The service is temporarily unavailable. Please try again later.';
      default:
        return 'An unexpected error occurred. Please try again or contact support if the problem persists.';
    }
  }
}
