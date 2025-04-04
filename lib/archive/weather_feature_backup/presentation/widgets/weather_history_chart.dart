import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../domain/models/weather_data.dart';

class WeatherHistoryChart extends StatelessWidget {
  final List<WeatherData> weatherHistory;
  final bool showTemperature;
  final bool showHumidity;
  final bool showPrecipitation;

  const WeatherHistoryChart({
    super.key,
    required this.weatherHistory,
    this.showTemperature = true,
    this.showHumidity = false,
    this.showPrecipitation = false,
  });

  @override
  Widget build(BuildContext context) {
    if (weatherHistory.isEmpty) {
      return const Center(
        child: Text('Geen historische gegevens beschikbaar'),
      );
    }

    // Filter out entries without timestamps
    final validHistory = weatherHistory.where((data) => data.timestamp != null).toList();
    if (validHistory.isEmpty) {
      return const Center(
        child: Text('Geen geldige historische gegevens beschikbaar'),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final date = validHistory[value.toInt()].timestamp!;
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          DateFormat('HH:mm').format(date),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                    interval: 6,
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 5,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                if (showTemperature)
                  LineChartBarData(
                    spots: validHistory.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value.temperature,
                      );
                    }).toList(),
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 2,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.red,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.red.withOpacity(0.1),
                    ),
                  ),
                if (showHumidity)
                  LineChartBarData(
                    spots: validHistory.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value.humidity.toDouble(),
                      );
                    }).toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 2,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.blue,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                  ),
                if (showPrecipitation)
                  LineChartBarData(
                    spots: validHistory.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value.precipitation,
                      );
                    }).toList(),
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 2,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.green,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withOpacity(0.1),
                    ),
                  ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 500.ms),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ChartLegendItem(
              color: Colors.red,
              label: 'Temperatuur (°C)',
              isSelected: showTemperature,
            ),
            const SizedBox(width: 16),
            _ChartLegendItem(
              color: Colors.blue,
              label: 'Vochtigheid (%)',
              isSelected: showHumidity,
            ),
            const SizedBox(width: 16),
            _ChartLegendItem(
              color: Colors.green,
              label: 'Neerslag (mm)',
              isSelected: showPrecipitation,
            ),
          ],
        ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
      ],
    );
  }
}

class _ChartLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isSelected;

  const _ChartLegendItem({
    required this.color,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
} 