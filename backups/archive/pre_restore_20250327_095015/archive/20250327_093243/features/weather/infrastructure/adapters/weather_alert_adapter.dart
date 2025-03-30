import 'package:hive/hive.dart';
import '../../domain/models/weather_alert.dart';

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