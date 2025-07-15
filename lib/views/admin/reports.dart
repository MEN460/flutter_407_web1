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

  late Future<Report> _reportFuture;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  void _loadReport() {
    final reportService = ref.read(reportServiceProvider);
    _reportFuture = reportService.generateCustomReport(
      type: _selectedReportType,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

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
              onChanged: (value) {
                setState(() {
                  _selectedReportType = value!;
                  _loadReport();
                });
              },
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
              onPressed: () {
                setState(() {
                  _loadReport();
                });
              },
              child: const Text('Generate Report'),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<Report>(
                future: _reportFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final report = snapshot.data!;
                    return SingleChildScrollView(
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
                    );
                  } else {
                    return const Center(child: Text('No data found.'));
                  }
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
    // TODO: Implement PDF export
  }
}
