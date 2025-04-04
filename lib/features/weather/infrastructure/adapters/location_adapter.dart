import 'package:hive/hive.dart';
import '../../domain/models/weather_location.dart';

class LocationAdapter extends TypeAdapter<WeatherLocation> {
  @override
  final int typeId = 2;

  @override
  WeatherLocation read(BinaryReader reader) {
    return WeatherLocation.fromJson(Map<String, dynamic>.from(reader.readMap()));
  }

  @override
  void write(BinaryWriter writer, WeatherLocation obj) {
    writer.writeMap(obj.toJson());
  }
} 