import 'package:hive_flutter/hive_flutter.dart';
import '../domain/models/weather_data.dart';
import '../domain/models/weather_forecast.dart';
import '../domain/models/weather_alert.dart';
import '../domain/models/location.dart';
import '../infrastructure/adapters/weather_data_adapter.dart';
import '../infrastructure/adapters/weather_forecast_adapter.dart';
import '../infrastructure/adapters/weather_alert_adapter.dart';
import '../infrastructure/adapters/location_adapter.dart';

class WeatherCacheService {
  static const String _weatherBoxName = 'weather_data';
  static const String _forecastBoxName = 'weather_forecasts';
  static const String _alertBoxName = 'weather_alerts';
  static const String _locationBoxName = 'weather_locations';
  static const Duration _cacheDuration = Duration(hours: 1);

  late Box<WeatherData> _weatherBox;
  late Box<List<WeatherForecast>> _forecastBox;
  late Box<List<WeatherAlert>> _alertBox;
  late Box<Location> _locationBox;

  Future<void> init() async {
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(WeatherDataAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(WeatherForecastAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(WeatherAlertAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(LocationAdapter());
    }

    _weatherBox = await Hive.openBox<WeatherData>(_weatherBoxName);
    _forecastBox = await Hive.openBox<List<WeatherForecast>>(_forecastBoxName);
    _alertBox = await Hive.openBox<List<WeatherAlert>>(_alertBoxName);
    _locationBox = await Hive.openBox<Location>(_locationBoxName);
  }

  Future<void> cacheWeatherData(Location location, WeatherData weather) async {
    final key = _getLocationKey(location);
    await _weatherBox.put(key, weather);
  }

  Future<WeatherData?> getCachedWeatherData(Location location) async {
    final key = _getLocationKey(location);
    return _weatherBox.get(key);
  }

  Future<void> cacheForecasts(Location location, List<WeatherForecast> forecasts) async {
    final key = _getLocationKey(location);
    await _forecastBox.put(key, forecasts);
  }

  Future<List<WeatherForecast>?> getCachedForecasts(Location location) async {
    final key = _getLocationKey(location);
    return _forecastBox.get(key);
  }

  Future<void> cacheAlerts(List<WeatherAlert> alerts) async {
    await _alertBox.put('alerts', alerts);
  }

  Future<List<WeatherAlert>?> getCachedAlerts() async {
    return _alertBox.get('alerts');
  }

  Future<void> cacheLocation(Location location) async {
    final key = _getLocationKey(location);
    await _locationBox.put(key, location);
  }

  Future<Location?> getCachedLocation(String name) async {
    final locations = _locationBox.values.where((loc) => 
      loc.name.toLowerCase() == name.toLowerCase()
    ).toList();

    if (locations.isEmpty) return null;
    return locations.first;
  }

  String _getLocationKey(Location location) {
    return '${location.latitude},${location.longitude}';
  }

  Future<void> clearCache() async {
    await _weatherBox.clear();
    await _forecastBox.clear();
    await _alertBox.clear();
    await _locationBox.clear();
  }
}

// Hive adapters
class WeatherDataAdapter extends TypeAdapter<WeatherData> {
  @override
  final int typeId = 0;

  @override
  WeatherData read(BinaryReader reader) {
    return WeatherData.fromJson(Map<String, dynamic>.from(reader.readMap()));
  }

  @override
  void write(BinaryWriter writer, WeatherData obj) {
    writer.writeMap(obj.toJson());
  }
}

class WeatherForecastAdapter extends TypeAdapter<WeatherForecast> {
  @override
  final int typeId = 1;

  @override
  WeatherForecast read(BinaryReader reader) {
    return WeatherForecast.fromJson(Map<String, dynamic>.from(reader.readMap()));
  }

  @override
  void write(BinaryWriter writer, WeatherForecast obj) {
    writer.writeMap(obj.toJson());
  }
}

class WeatherAlertAdapter extends TypeAdapter<WeatherAlert> {
  @override
  final int typeId = 2;

  @override
  WeatherAlert read(BinaryReader reader) {
    return WeatherAlert.fromJson(Map<String, dynamic>.from(reader.readMap()));
  }

  @override
  void write(BinaryWriter writer, WeatherAlert obj) {
    writer.writeMap(obj.toJson());
  }
}

class LocationAdapter extends TypeAdapter<Location> {
  @override
  final int typeId = 3;

  @override
  Location read(BinaryReader reader) {
    return Location.fromJson(Map<String, dynamic>.from(reader.readMap()));
  }

  @override
  void write(BinaryWriter writer, Location obj) {
    writer.writeMap(obj.toJson());
  }
} 