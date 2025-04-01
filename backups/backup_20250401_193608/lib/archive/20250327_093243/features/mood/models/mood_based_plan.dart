import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'mood_based_plan.freezed.dart';
part 'mood_based_plan.g.dart';

@freezed
class MoodBasedPlanData with _$MoodBasedPlanData {
  const factory MoodBasedPlanData({
    required String mood,
    required List<ActivitySuggestion> activities,
    required DateTime timestamp,
    @Default(false) bool hasMoreActivities,
  }) = _MoodBasedPlanData;

  factory MoodBasedPlanData.fromJson(Map<String, dynamic> json) =>
      _$MoodBasedPlanDataFromJson(json);

  static List<MoodOption> get predefinedMoods => [
    MoodOption(
      name: 'Energetic',
      description: 'Looking for active and exciting experiences',
      emoji: '⚡',
      color: 0xFFFF4B4B,
    ),
    MoodOption(
      name: 'Relaxed',
      description: 'Seeking peaceful and calming activities',
      emoji: '🌿',
      color: 0xFF4CAF50,
    ),
    MoodOption(
      name: 'Adventurous',
      description: 'Ready to explore and try new things',
      emoji: '🗺️',
      color: 0xFFFFA726,
    ),
    MoodOption(
      name: 'Cultural',
      description: 'Interested in arts, history, and local experiences',
      emoji: '🎭',
      color: 0xFF9C27B0,
    ),
    MoodOption(
      name: 'Social',
      description: 'Looking to meet people and enjoy company',
      emoji: '👥',
      color: 0xFF2196F3,
    ),
    MoodOption(
      name: 'Romantic',
      description: 'In the mood for intimate and special moments',
      emoji: '💝',
      color: 0xFFE91E63,
    ),
    MoodOption(
      name: 'Foodie',
      description: 'Craving culinary adventures and tasty experiences',
      emoji: '🍽️',
      color: 0xFFFF9800,
    ),
    MoodOption(
      name: 'Creative',
      description: 'Seeking inspiration and artistic activities',
      emoji: '🎨',
      color: 0xFF673AB7,
    ),
  ];
}

@freezed
class ActivitySuggestion with _$ActivitySuggestion {
  const factory ActivitySuggestion({
    required String type,
    required String description,
    required List<String> keywords,
    @Default(false) bool isLoading,
    String? error,
  }) = _ActivitySuggestion;

  factory ActivitySuggestion.fromJson(Map<String, dynamic> json) =>
      _$ActivitySuggestionFromJson(json);
}

class MoodOption {
  final String name;
  final String description;
  final String emoji;
  final int color;

  const MoodOption({
    required this.name,
    required this.description,
    required this.emoji,
    required this.color,
  });
} 