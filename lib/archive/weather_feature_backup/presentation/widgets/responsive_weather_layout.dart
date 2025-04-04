import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/weather_service.dart';
import '../../domain/models/weather_data.dart';
import '../../domain/models/weather_forecast.dart';
import '../../domain/models/weather_alert.dart';
import 'weather_card.dart';
import 'weather_history_chart.dart';
import 'weather_forecast_card.dart';
import 'weather_alert_card.dart';
import 'weather_stats_card.dart';

class ResponsiveWeatherLayout extends ConsumerWidget {
  final List<WeatherData> weatherHistory;
  final List<WeatherForecast> forecasts;
  final List<WeatherAlert> alerts;
  final bool showTemperature;
  final bool showHumidity;
  final bool showPrecipitation;
  final bool isChartExpanded;
  final bool isForecastExpanded;
  final VoidCallback onChartExpand;
  final VoidCallback onForecastExpand;
  final Function(bool) onTemperatureToggle;
  final Function(bool) onHumidityToggle;
  final Function(bool) onPrecipitationToggle;

  const ResponsiveWeatherLayout({
    super.key,
    required this.weatherHistory,
    required this.forecasts,
    required this.alerts,
    required this.showTemperature,
    required this.showHumidity,
    required this.showPrecipitation,
    required this.isChartExpanded,
    required this.isForecastExpanded,
    required this.onChartExpand,
    required this.onForecastExpand,
    required this.onTemperatureToggle,
    required this.onHumidityToggle,
    required this.onPrecipitationToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherServiceProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 600 && screenWidth <= 1200;

    return weatherState.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error) => Center(
        child: Text('Fout bij het laden van weergegevens: $error'),
      ),
      data: (currentWeather, historicalWeather) {
        if (isDesktop) {
          return _buildDesktopLayout(
            context,
            currentWeather,
            historicalWeather,
          );
        } else if (isTablet) {
          return _buildTabletLayout(
            context,
            currentWeather,
            historicalWeather,
          );
        } else {
          return _buildMobileLayout(
            context,
            currentWeather,
            historicalWeather,
          );
        }
      },
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    WeatherData currentWeather,
    List<WeatherData> historicalWeather,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              WeatherCard(weather: currentWeather),
              const SizedBox(height: 16),
              WeatherStatsCard(
                weatherHistory: historicalWeather,
                title: 'Weerstatistieken',
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildChartSection(context, historicalWeather),
              const SizedBox(height: 16),
              _buildForecastSection(context),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: _buildAlertsSection(context),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    WeatherData currentWeather,
    List<WeatherData> historicalWeather,
  ) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: WeatherCard(weather: currentWeather),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: WeatherStatsCard(
                weatherHistory: historicalWeather,
                title: 'Weerstatistieken',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildChartSection(context, historicalWeather),
        const SizedBox(height: 16),
        _buildForecastSection(context),
        const SizedBox(height: 16),
        _buildAlertsSection(context),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    WeatherData currentWeather,
    List<WeatherData> historicalWeather,
  ) {
    return Column(
      children: [
        WeatherCard(weather: currentWeather),
        const SizedBox(height: 16),
        WeatherStatsCard(
          weatherHistory: historicalWeather,
          title: 'Weerstatistieken',
        ),
        const SizedBox(height: 16),
        _buildChartSection(context, historicalWeather),
        const SizedBox(height: 16),
        _buildForecastSection(context),
        const SizedBox(height: 16),
        _buildAlertsSection(context),
      ],
    );
  }

  Widget _buildChartSection(
    BuildContext context,
    List<WeatherData> historicalWeather,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weergeschiedenis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isChartExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: onChartExpand,
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: isChartExpanded ? 400 : 200,
              child: WeatherHistoryChart(
                weatherHistory: historicalWeather,
                showTemperature: showTemperature,
                showHumidity: showHumidity,
                showPrecipitation: showPrecipitation,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildChartToggleButton(
                  context,
                  Icons.thermostat,
                  'Temperatuur',
                  showTemperature,
                  onTemperatureToggle,
                ),
                _buildChartToggleButton(
                  context,
                  Icons.water_drop,
                  'Vochtigheid',
                  showHumidity,
                  onHumidityToggle,
                ),
                _buildChartToggleButton(
                  context,
                  Icons.umbrella,
                  'Neerslag',
                  showPrecipitation,
                  onPrecipitationToggle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weervoorspelling',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isForecastExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: onForecastExpand,
                ),
              ],
            ),
            if (isForecastExpanded) ...[
              const SizedBox(height: 16),
              if (forecasts.isEmpty)
                const Center(
                  child: Text('Geen voorspellingen beschikbaar'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: forecasts.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: WeatherForecastCard(
                        forecast: forecasts[index],
                      ),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weeralerts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (alerts.isEmpty)
              const Center(
                child: Text('Geen actieve alerts'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  return WeatherAlertCard(
                    alert: alerts[index],
                    onDismiss: () {
                      // Implementeer alert dismiss functionaliteit
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartToggleButton(
    BuildContext context,
    IconData icon,
    String label,
    bool isSelected,
    Function(bool) onToggle,
  ) {
    return InkWell(
      onTap: () => onToggle(!isSelected),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.blue : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 