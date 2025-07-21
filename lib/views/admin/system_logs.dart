import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/providers.dart';

// Log model for type safety
class SystemLog {
  final String id;
  final String action;
  final DateTime timestamp;
  final String user;
  final LogStatus status;
  final String? description;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;

  const SystemLog({
    required this.id,
    required this.action,
    required this.timestamp,
    required this.user,
    required this.status,
    this.description,
    this.errorMessage,
    this.metadata,
  });

  factory SystemLog.fromMap(Map<String, dynamic> map) {
    return SystemLog(
      id:
          map['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      action: map['action']?.toString() ?? 'Unknown Action',
      timestamp: _parseTimestamp(map['timestamp']),
      user: map['user']?.toString() ?? 'Unknown User',
      status: LogStatus.fromString(map['status']?.toString()),
      description: map['description']?.toString(),
      errorMessage: map['errorMessage']?.toString() ?? map['error']?.toString(),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is DateTime) return timestamp;
    if (timestamp is String) {
      return DateTime.tryParse(timestamp) ?? DateTime.now();
    }
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return DateTime.now();
  }

  String get formattedTimestamp {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago • ${_formatTime(timestamp)}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago • ${_formatTime(timestamp)}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

enum LogStatus {
  success,
  error,
  warning,
  info,
  pending,
  unknown;

  static LogStatus fromString(String? status) {
    if (status == null) return LogStatus.unknown;

    switch (status.toLowerCase()) {
      case 'success':
      case 'completed':
      case 'ok':
        return LogStatus.success;
      case 'error':
      case 'failed':
      case 'failure':
        return LogStatus.error;
      case 'warning':
      case 'warn':
        return LogStatus.warning;
      case 'info':
      case 'information':
        return LogStatus.info;
      case 'pending':
      case 'processing':
        return LogStatus.pending;
      default:
        return LogStatus.unknown;
    }
  }

  Color get color {
    switch (this) {
      case LogStatus.success:
        return Colors.green;
      case LogStatus.error:
        return Colors.red;
      case LogStatus.warning:
        return Colors.orange;
      case LogStatus.info:
        return Colors.blue;
      case LogStatus.pending:
        return Colors.purple;
      case LogStatus.unknown:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case LogStatus.success:
        return Icons.check_circle;
      case LogStatus.error:
        return Icons.error;
      case LogStatus.warning:
        return Icons.warning;
      case LogStatus.info:
        return Icons.info;
      case LogStatus.pending:
        return Icons.hourglass_empty;
      case LogStatus.unknown:
        return Icons.help_outline;
    }
  }

  String get displayName {
    switch (this) {
      case LogStatus.success:
        return 'SUCCESS';
      case LogStatus.error:
        return 'ERROR';
      case LogStatus.warning:
        return 'WARNING';
      case LogStatus.info:
        return 'INFO';
      case LogStatus.pending:
        return 'PENDING';
      case LogStatus.unknown:
        return 'UNKNOWN';
    }
  }
}

class SystemLogsScreen extends ConsumerStatefulWidget {
  const SystemLogsScreen({super.key});

  @override
  ConsumerState<SystemLogsScreen> createState() => _SystemLogsScreenState();
}

class _SystemLogsScreenState extends ConsumerState<SystemLogsScreen> {
  final TextEditingController _searchController = TextEditingController();
  LogStatus? _selectedStatus;
  bool _sortByNewest = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(systemLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
           onPressed: () => ref.invalidate(systemLogsProvider), 
            tooltip: 'Refresh Logs',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('Export Logs'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 20),
                    SizedBox(width: 8),
                    Text('Clear Filters'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search logs...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                // Filter Row
                Row(
                  children: [
                    // Status Filter
                    Expanded(
                      child: DropdownButtonFormField<LogStatus?>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Filter by Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<LogStatus?>(
                            value: null,
                            child: Text('All Status'),
                          ),
                          ...LogStatus.values.map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Row(
                                children: [
                                  Icon(
                                    status.icon,
                                    size: 16,
                                    color: status.color,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(status.displayName),
                                ],
                              ),
                            ),
                          ),
                        ],
                        onChanged: (status) {
                          setState(() {
                            _selectedStatus = status;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Sort Button
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _sortByNewest = !_sortByNewest;
                        });
                      },
                      icon: Icon(
                        _sortByNewest
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                      ),
                      label: Text(_sortByNewest ? 'Newest' : 'Oldest'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Logs Content
          Expanded(
            child: logsAsync.when(
              loading: () => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading system logs...'),
                  ],
                ),
              ),
              error: (err, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading logs',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      err.toString(),
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => ref.invalidate(systemLogsProvider), 
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (logsData) {
                final logs = logsData
                    .map((logMap) => SystemLog.fromMap(logMap))
                    .toList();
                final filteredLogs = _filterLogs(logs);

                if (filteredLogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          logs.isEmpty ? Icons.description : Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          logs.isEmpty
                              ? 'No system logs available'
                              : 'No logs match your filters',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        if (logs.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text('Clear Filters'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(systemLogsProvider);
                    await ref.read(systemLogsProvider.future);
                  },
                  child: ListView.builder(
                    itemCount: filteredLogs.length,
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        child: ListTile(
                          leading: Icon(
                            log.status.icon,
                            color: log.status.color,
                            size: 24,
                          ),
                          title: Text(
                            log.action,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${log.formattedTimestamp} • ${log.user}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              if (log.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  log.description!,
                                  style: const TextStyle(fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: log.status.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: log.status.color.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              log.status.displayName,
                              style: TextStyle(
                                color: log.status.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          onTap: () => _showLogDetails(context, log),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<SystemLog> _filterLogs(List<SystemLog> logs) {
    var filtered = logs.where((log) {
      final matchesSearch =
          _searchController.text.isEmpty ||
          log.action.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          log.user.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          (log.description?.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              ) ??
              false);

      final matchesStatus =
          _selectedStatus == null || log.status == _selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();

    // Sort logs
    filtered.sort((a, b) {
      return _sortByNewest
          ? b.timestamp.compareTo(a.timestamp)
          : a.timestamp.compareTo(b.timestamp);
    });

    return filtered;
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = null;
      _sortByNewest = true;
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportLogs();
        break;
      case 'clear':
        _clearFilters();
        break;
    }
  }

  void _exportLogs() {
    // TODO: Implement log export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality will be implemented'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showLogDetails(BuildContext context, SystemLog log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(log.status.icon, color: log.status.color),
            const SizedBox(width: 8),
            const Expanded(child: Text('Log Details')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(label: 'Action', value: log.action),
              _DetailRow(label: 'Status', value: log.status.displayName),
              _DetailRow(label: 'User', value: log.user),
              _DetailRow(
                label: 'Timestamp',
                value:
                    '${log.timestamp.toLocal().toString().split('.')[0]}\n${log.formattedTimestamp}',
              ),
              if (log.description != null)
                _DetailRow(label: 'Description', value: log.description!),
              if (log.errorMessage != null)
                _DetailRow(
                  label: 'Error',
                  value: log.errorMessage!,
                  valueColor: Colors.red,
                ),
              if (log.metadata != null && log.metadata!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  'Metadata:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    log.metadata.toString(),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _formatLogForCopy(log)));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Log copied to clipboard')),
              );
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatLogForCopy(SystemLog log) {
    final buffer = StringBuffer();
    buffer.writeln('Action: ${log.action}');
    buffer.writeln('Status: ${log.status.displayName}');
    buffer.writeln('User: ${log.user}');
    buffer.writeln('Timestamp: ${log.timestamp.toLocal()}');
    if (log.description != null) {
      buffer.writeln('Description: ${log.description}');
    }
    if (log.errorMessage != null) {
      buffer.writeln('Error: ${log.errorMessage}');
    }
    return buffer.toString();
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w500, color: valueColor),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
