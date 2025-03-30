import 'package:wandermood/features/mood/domain/models/mood.dart';

class MoodDTO {
  final String id;
  final String userId;
  final String label;
  final String emoji;
  final DateTime createdAt;

  MoodDTO({
    required this.id,
    required this.userId,
    required this.label,
    required this.emoji,
    required this.createdAt,
  });

  factory MoodDTO.fromJson(Map<String, dynamic> json) {
    return MoodDTO(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      label: json['label'] as String,
      emoji: json['emoji'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  factory MoodDTO.fromMood(Mood mood) {
    return MoodDTO(
      id: mood.id,
      userId: mood.userId,
      label: mood.label,
      emoji: mood.emoji,
      createdAt: mood.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'label': label,
      'emoji': emoji,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Mood toMood() {
    return Mood(
      id: id,
      userId: userId,
      label: label,
      emoji: emoji,
      createdAt: createdAt,
    );
  }
} 