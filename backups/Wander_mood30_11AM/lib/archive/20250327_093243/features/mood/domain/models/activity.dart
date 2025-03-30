import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity.freezed.dart';
part 'activity.g.dart';

@freezed
abstract class Activity with _$Activity {
  const factory Activity({
    required String id,
    required String name,
    required String emoji,
    required String category,
    String? description,
    @Default(false) bool isCustom,
    DateTime? lastUsed,
  }) = _Activity;

  factory Activity.fromJson(Map<String, dynamic> json) => _$ActivityFromJson(json);
} 