import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReportChart extends StatelessWidget {
  final Map<String, dynamic> data;

  const ReportChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final chartData = _prepareData();

    // Handle empty data
    if (chartData.barGroups.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.insert_chart_outlined,
                color: Colors.grey,
                size: 48,
              ),
              const SizedBox(height: 8),
              Text(
                'No data available',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.3, // 30% of screen height
      child: BarChart(
        BarChartData(
          barGroups: chartData.barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < chartData.labels.length) {
                    return Tooltip(
                      message: chartData.fullLabels[index],
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          chartData.labels[index],
                          style: const TextStyle(fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          alignment: BarChartAlignment.spaceAround,
        ),
        swapAnimationDuration: const Duration(milliseconds: 400),
        swapAnimationCurve: Curves.easeInOut,
      ),
    );
  }

  _ChartData _prepareData() {
    final entries = data.entries
        .where((e) => e.value is num && (e.value as num) >= 0)
        .toList();

    if (entries.isEmpty) {
      return _ChartData([], [], []);
    }

    final barGroups = <BarChartGroupData>[];
    final labels = <String>[];
    final fullLabels = <String>[]; // Store original labels for tooltips

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final value = entry.value as num;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value.toDouble(),
              color: _getColorForIndex(i),
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );

      // Save truncated and full labels
      String label = entry.key;
      String truncatedLabel = label.length > 8
          ? '${label.substring(0, 8)}…'
          : label;

      labels.add(truncatedLabel);
      fullLabels.add(label);
    }

    return _ChartData(barGroups, labels, fullLabels);
  }

  Color _getColorForIndex(int index) {
    const colors = [
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.redAccent,
      Colors.tealAccent,
      Colors.amberAccent,
      Colors.deepPurpleAccent,
    ];
    return colors[index % colors.length];
  }
}

class _ChartData {
  final List<BarChartGroupData> barGroups;
  final List<String> labels;
  final List<String> fullLabels;

  _ChartData(this.barGroups, this.labels, this.fullLabels);
}
