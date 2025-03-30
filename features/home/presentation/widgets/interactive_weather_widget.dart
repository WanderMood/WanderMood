import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailedHourlyWeather {
  final int hour;
  final double temperature;
  final IconData icon;
  final String description;

  DetailedHourlyWeather({
    required this.hour,
    required this.temperature,
    required this.icon,
    required this.description,
  });
}

class InteractiveWeatherWidget extends StatefulWidget {
  const InteractiveWeatherWidget({super.key});

  @override
  State<InteractiveWeatherWidget> createState() => _InteractiveWeatherWidgetState();
}

class _InteractiveWeatherWidgetState extends State<InteractiveWeatherWidget> {
  bool _isDetailExpanded = false;

  // Simulated hourly weather data
  final List<DetailedHourlyWeather> hourlyWeatherData = List.generate(24, (index) {
    return DetailedHourlyWeather(
      hour: index,
      temperature: _generateTemperature(index),
      icon: _getWeatherIcon(index),
      description: _getWeatherDescription(index),
    );
  });

  // Generate daily forecast data
  final List<DailyForecast> dailyForecastData = [
    DailyForecast(day: 'Vandaag', high: 32, low: 24, condition: 'Zonnig', icon: Icons.wb_sunny),
    DailyForecast(day: 'Morgen', high: 30, low: 22, condition: 'Meestal zonnig', icon: Icons.wb_sunny),
    DailyForecast(day: 'Woensdag', high: 29, low: 23, condition: 'Gedeeltelijk bewolkt', icon: Icons.wb_cloudy),
    DailyForecast(day: 'Donderdag', high: 31, low: 22, condition: 'Zonnig', icon: Icons.wb_sunny),
    DailyForecast(day: 'Vrijdag', high: 28, low: 21, condition: 'Kans op regen', icon: Icons.beach_access),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  static double _generateTemperature(int hour) {
    if (hour >= 15 && hour <= 19) {
      return 26.0 - (hour - 15);
    }
    return 27.0 + (hour % 5 * 0.5);
  }

  static IconData _getWeatherIcon(int hour) {
    if (hour >= 6 && hour <= 18) {
      return Icons.wb_sunny;
    }
    return Icons.nights_stay;
  }

  static String _getWeatherDescription(int hour) {
    if (hour >= 6 && hour < 12) {
      return 'Ochtend, mild en helder';
    } else if (hour >= 12 && hour < 18) {
      return 'Middag, warme zonneschijn';
    } else {
      return 'Avond, afkoelend';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isDetailExpanded = !_isDetailExpanded;
        });
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade100,
                Colors.blue.shade200,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Washington DC, 32°',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Icon(
                    Icons.wb_sunny,
                    color: Colors.yellow,
                    size: 40,
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms),
              
              const SizedBox(height: 10),
              
              const Text(
                'De rest van de dag zonnig. Windvlagen tot 19 km/u.',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
              
              const SizedBox(height: 10),
              
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: hourlyWeatherData.map((hourly) => 
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Text(
                            '${hourly.hour.toString().padLeft(2, '0')}:00',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            hourly.icon,
                            color: Colors.yellow,
                            size: 24,
                          ),
                          Text(
                            '${hourly.temperature.toStringAsFixed(1)}°',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  ).toList(),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
              
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isDetailExpanded
                    ? Column(
                        key: const ValueKey('expanded'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            'Gedetailleerde Weersinformatie',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: hourlyWeatherData.map((hourly) => 
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${hourly.hour.toString().padLeft(2, '0')}:00',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          hourly.icon,
                                          color: Colors.yellow,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          hourly.description,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${hourly.temperature.toStringAsFixed(1)}°',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ).toList(),
                          ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
                        ],
                      )
                    : Container(
                        key: const ValueKey('collapsed'),
                      ),
              ),
              
              Center(
                child: Icon(
                  _isDetailExpanded 
                    ? Icons.keyboard_arrow_up 
                    : Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}

// Model class to represent daily forecast
class DailyForecast {
  final String day;
  final int high;
  final int low;
  final String condition;
  final IconData icon;

  DailyForecast({
    required this.day,
    required this.high,
    required this.low,
    required this.condition,
    required this.icon,
  });
} 