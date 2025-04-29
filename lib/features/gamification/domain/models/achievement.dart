import 'package:flutter/material.dart';

enum AchievementCategory {
  exploration,
  activity,
  social,
  streak,
  mood,
  special
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final Color color;
  final AchievementCategory category;
  final int requiredValue;
  final int currentValue;
  final bool unlocked;
  final DateTime? unlockedAt;
  final String reward; // Description of the reward
  
  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.category,
    required this.requiredValue,
    this.currentValue = 0,
    this.unlocked = false,
    this.unlockedAt,
    this.reward = '',
  });
  
  double get progress => currentValue / requiredValue;
  
  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    Color? color,
    AchievementCategory? category,
    int? requiredValue,
    int? currentValue,
    bool? unlocked,
    DateTime? unlockedAt,
    String? reward,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      category: category ?? this.category,
      requiredValue: requiredValue ?? this.requiredValue,
      currentValue: currentValue ?? this.currentValue,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      reward: reward ?? this.reward,
    );
  }
}

// Predefined achievements
class AchievementPresets {
  static Achievement explorer = Achievement(
    id: 'explorer',
    title: 'Explorer',
    description: 'Visit 5 different locations',
    icon: 'explore',
    color: Colors.blue,
    category: AchievementCategory.exploration,
    requiredValue: 5,
  );
  
  static Achievement earlyBird = Achievement(
    id: 'early_bird',
    title: 'Early Bird',
    description: 'Complete 3 morning activities',
    icon: 'wb_sunny',
    color: Colors.amber,
    category: AchievementCategory.activity,
    requiredValue: 3,
  );
  
  static Achievement streakMaster = Achievement(
    id: 'streak_master',
    title: 'Streak Master',
    description: 'Maintain a 7-day activity streak',
    icon: 'local_fire_department',
    color: Colors.deepOrange,
    category: AchievementCategory.streak,
    requiredValue: 7,
  );
  
  static Achievement moodTracker = Achievement(
    id: 'mood_tracker',
    title: 'Mood Tracker',
    description: 'Log your mood for 5 consecutive days',
    icon: 'emoji_emotions',
    color: Colors.purple,
    category: AchievementCategory.mood,
    requiredValue: 5,
  );
  
  static Achievement adventurer = Achievement(
    id: 'adventurer',
    title: 'Adventurer',
    description: 'Try 3 different types of activities',
    icon: 'hiking',
    color: Colors.green,
    category: AchievementCategory.activity,
    requiredValue: 3,
  );
  
  static List<Achievement> getDefaultAchievements() {
    return [
      explorer,
      earlyBird,
      streakMaster,
      moodTracker,
      adventurer,
    ];
  }
} 
 
 
 