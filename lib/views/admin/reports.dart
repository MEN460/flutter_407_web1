import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/models/report.dart';
import 'package:k_airways_flutter/widgets/report_chart.dart';
import 'package:k_airways_flutter/providers.dart';
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String _selectedReportType = 'BOOKING';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedReportType,
              items: ['BOOKING', 'FLIGHT', 'USER', 'FINANCIAL']
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedReportType = value!),
              decoration: const InputDecoration(labelText: 'Report Type'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectDate(context, isStart: true),
                    child: Text('From: ${_formatDate(_startDate)}'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectDate(context, isStart: false),
                    child: Text('To: ${_formatDate(_endDate)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.refresh(reportServiceProvider),
              child: const Text('Generate Report'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final reportAsync = ref.watch(reportServiceProvider);
                  return reportAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error: $err')),
                    data: (report) => SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            '$_selectedReportType Report',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 20),
                          ReportChart(data: report.data),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => _exportReport(report),
                            child: const Text('Export as PDF'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context, {
    required bool isStart,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _exportReport(Report report) {
    // Implement PDF export
  }
}
