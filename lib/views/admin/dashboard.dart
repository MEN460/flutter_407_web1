import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:k_airways_flutter/providers.dart';
import 'package:k_airways_flutter/widgets/report_chart.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
final reportAsync = ref.watch(
      reportServiceProvider,
      // Fetch the dashboard report
    ).fetchDashboardReport(); // Adjusted to use the correct method for fetching the report

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (report) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Booking Analytics', style: TextStyle(fontSize: 18)),
              ReportChart(data: report.data['bookings']),
              const SizedBox(height: 20),
              const Text('Flight Performance', style: TextStyle(fontSize: 18)),
              ReportChart(data: report.data['flights']),
              const SizedBox(height: 20),
              const Text('User Activity', style: TextStyle(fontSize: 18)),
              ReportChart(data: report.data['users']),
            ],
          ),
        ),
      ),
    );
  }
}
