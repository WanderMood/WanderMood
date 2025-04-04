import 'package:hive/hive.dart';
import '../../domain/models/location.dart';

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