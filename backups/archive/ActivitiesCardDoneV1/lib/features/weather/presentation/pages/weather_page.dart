import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/weather_card.dart';
import '../widgets/weather_history_chart.dart';
import '../widgets/weather_forecast_card.dart';
import '../widgets/location_selector.dart';
import '../../application/weather_service.dart' hide Location;
import '../../domain/models/weather_data.dart';
import '../../domain/models/weather_forecast.dart';
import '../../domain/models/location.dart';
import 'package:wandermood/features/location/providers/location_provider.dart';

class WeatherPage extends ConsumerStatefulWidget {
  const WeatherPage({super.key});

  @override
  ConsumerState<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends ConsumerState<WeatherPage> {
  bool showTemperature = true;
  bool showHumidity = false;
  bool showPrecipitation = false;
  bool isChartExpanded = false;
  bool isForecastExpanded = false;
  List<WeatherForecast>? forecasts;

  @override
  void initState() {
    super.initState();
    _loadForecasts();
  }

  Future<void> _loadForecasts() async {
    final locationState = ref.read(locationProvider);
    
    locationState.whenData((location) async {
      if (location == null) return;
      
      try {
        final weatherService = ref.read(weatherServiceProvider.notifier);
        final locationObj = Location(
          id: location.toLowerCase(),
          name: location,
          // You might want to implement geocoding here to get lat/long
          latitude: 52.3676, // Default for now
          longitude: 4.9041, // Default for now
        );
        forecasts = await weatherService.getWeatherForecast(locationObj);
        if (mounted) setState(() {});
      } catch (e) {
        print('Error loading forecasts: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final weatherState = ref.watch(weatherServiceProvider);
    
    return locationState.when(
      data: (location) {
        if (location == null) {
          return const Center(child: Text('Location not available'));
        }
        
        final locationObj = Location(
          id: location.toLowerCase(),
          name: location,
          latitude: 52.3676, // Default for now
          longitude: 4.9041, // Default for now
        );
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Weer'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.invalidate(weatherServiceProvider);
                  _loadForecasts();
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LocationSelector(
                  selectedLocation: locationObj,
                  onLocationSelected: (location) {
                    ref.read(locationProvider.notifier).update((state) => location.name);
                    _loadForecasts();
                  },
                ),
                const SizedBox(height: 24),
                weatherState.when(
                  data: (weatherData) => WeatherCard(
                    weather: weatherData,
                    onTap: () {
                      setState(() {
                        isChartExpanded = !isChartExpanded;
                      });
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                ),
                const SizedBox(height: 24),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: isChartExpanded ? 400 : 200,
                  child: Card(
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
                                  isChartExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isChartExpanded = !isChartExpanded;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          WeatherHistoryChart(
                            weatherHistory: [], // TODO: Implement weather history
                            showTemperature: showTemperature,
                            showHumidity: showHumidity,
                            showPrecipitation: showPrecipitation,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildChartToggleButton(
                                icon: Icons.thermostat,
                                label: 'Temperatuur',
                                isSelected: showTemperature,
                                onTap: () => setState(() {
                                  showTemperature = !showTemperature;
                                }),
                              ),
                              _buildChartToggleButton(
                                icon: Icons.water_drop,
                                label: 'Vochtigheid',
                                isSelected: showHumidity,
                                onTap: () => setState(() {
                                  showHumidity = !showHumidity;
                                }),
                              ),
                              _buildChartToggleButton(
                                icon: Icons.umbrella,
                                label: 'Neerslag',
                                isSelected: showPrecipitation,
                                onTap: () => setState(() {
                                  showPrecipitation = !showPrecipitation;
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
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
                                isForecastExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                              ),
                              onPressed: () {
                                setState(() {
                                  isForecastExpanded = !isForecastExpanded;
                                });
                              },
                            ),
                          ],
                        ),
                        if (isForecastExpanded) ...[
                          const SizedBox(height: 16),
                          if (forecasts == null)
                            const Center(
                              child: CircularProgressIndicator(),
                            )
                          else if (forecasts!.isEmpty)
                            const Center(
                              child: Text('Geen voorspellingen beschikbaar'),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: forecasts!.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: WeatherForecastCard(
                                    forecast: forecasts![index],
                                  ),
                                );
                              },
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildChartToggleButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 