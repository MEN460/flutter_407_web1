import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ReportChart extends StatelessWidget {
  final Map<String, dynamic> data;

  const ReportChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final chartData = _prepareData();

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barGroups: chartData.barGroups,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString());
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < chartData.labels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        chartData.labels[index],
                        style: const TextStyle(fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          alignment: BarChartAlignment.spaceAround,
        ),
        swapAnimationDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  _ChartData _prepareData() {
    final entries = data.entries.where((e) => e.value is num).toList();

    final barGroups = <BarChartGroupData>[];
    final labels = <String>[];

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
            ),
          ],
        ),
      );

      labels.add(entry.key);
    }

    return _ChartData(barGroups, labels);
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.redAccent,
    ];
    return colors[index % colors.length];
  }
}

class _ChartData {
  final List<BarChartGroupData> barGroups;
  final List<String> labels;

  _ChartData(this.barGroups, this.labels);
}
