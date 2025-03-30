import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../domain/models/mood_data.dart';

class MoodHistoryChart extends StatelessWidget {
  final List<MoodData> moodHistory;
  final bool showMoodScore;
  final bool showMoodTypes;

  const MoodHistoryChart({
    super.key,
    required this.moodHistory,
    this.showMoodScore = true,
    this.showMoodTypes = true,
  });

  @override
  Widget build(BuildContext context) {
    if (moodHistory.isEmpty) {
      return const Center(
        child: Text('Geen mood geschiedenis beschikbaar'),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= moodHistory.length) return const Text('');
                final date = moodHistory[value.toInt()].timestamp;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat('HH:mm').format(date),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        minX: 0,
        maxX: (moodHistory.length - 1).toDouble(),
        minY: 0,
        maxY: 10,
        lineBarsData: [
          if (showMoodScore)
            LineChartBarData(
              spots: moodHistory.asMap().entries.map((entry) {
                return FlSpot(
                  entry.key.toDouble(),
                  entry.value.moodScore.toDouble(),
                );
              }).toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
        ],
      ),
    );
  }
} 