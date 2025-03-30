import 'package:hive/hive.dart';
import '../../domain/models/weather_forecast.dart';

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