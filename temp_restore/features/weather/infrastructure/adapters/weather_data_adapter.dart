import 'package:hive/hive.dart';
import '../../domain/models/weather_data.dart';

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