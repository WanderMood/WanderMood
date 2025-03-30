import 'package:flutter/material.dart';
import 'package:wandermood/features/weather/presentation/widgets/hourly_weather_widget.dart';

// Weather data model en voorbeeldgegevens
Map<String, dynamic> weatherDetails = {
  'location': 'Washington DC',
  'temperature': 29,
  'condition': 'Sunny',
  'wind': 10,
  'humidity': 65,
  'visibility': 10,
};

List<Map<String, dynamic>> dailyForecast = [
  {
    'day': 'Vandaag',
    'highTemp': 32,
    'lowTemp': 25,
    'icon': '☀️',
    'condition': 'Sunny'
  },
  {
    'day': 'Morgen',
    'highTemp': 30,
    'lowTemp': 24,
    'icon': '⛅',
    'condition': 'Partly Cloudy'
  },
  {
    'day': 'Overmorgen',
    'highTemp': 28,
    'lowTemp': 23,
    'icon': '🌧️',
    'condition': 'Rain'
  }
]; 