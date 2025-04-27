import 'package:wandermood/core/models/activity.dart';

class DayPlan {
  final String id;
  final DateTime date;
  final List<Activity> activities;
  final List<String> moods;
  final double? overallMoodScore;
  final Map<String, dynamic>? weatherData;

  DayPlan({
    required this.id,
    required this.date,
    required this.activities,
    required this.moods,
    this.overallMoodScore,
    this.weatherData,
  });

  // Get activities by time slot
  List<Activity> getActivitiesByTimeSlot(TimeSlot slot) {
    return activities.where((activity) => activity.timeSlot == slot).toList();
  }

  // Check if time slot has activities
  bool hasActivitiesForTimeSlot(TimeSlot slot) {
    return activities.any((activity) => activity.timeSlot == slot);
  }

  // Get start and end times for the whole day plan
  DateTime get startTime => activities.isEmpty 
    ? date 
    : activities.map((a) => a.startTime).reduce((a, b) => a.isBefore(b) ? a : b);

  DateTime get endTime => activities.isEmpty 
    ? date 
    : activities.map((a) => a.endTime).reduce((a, b) => a.isAfter(b) ? a : b);

  // Calculate total duration of all activities
  Duration get totalDuration {
    return activities.fold(
      Duration.zero,
      (total, activity) => total + activity.duration,
    );
  }

  // Check for time conflicts between activities
  List<(Activity, Activity)> findTimeConflicts() {
    final conflicts = <(Activity, Activity)>[];
    
    for (var i = 0; i < activities.length; i++) {
      for (var j = i + 1; j < activities.length; j++) {
        final a1 = activities[i];
        final a2 = activities[j];
        
        if (a1.startTime.isBefore(a2.endTime) && 
            a2.startTime.isBefore(a1.endTime)) {
          conflicts.add((a1, a2));
        }
      }
    }
    
    return conflicts;
  }

  // JSON serialization
  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      activities: (json['activities'] as List)
          .map((a) => Activity.fromJson(a as Map<String, dynamic>))
          .toList(),
      moods: List<String>.from(json['moods'] as List),
      overallMoodScore: (json['overallMoodScore'] as num?)?.toDouble(),
      weatherData: json['weatherData'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'activities': activities.map((a) => a.toJson()).toList(),
      'moods': moods,
      'overallMoodScore': overallMoodScore,
      'weatherData': weatherData,
    };
  }

  // Create a copy with modifications
  DayPlan copyWith({
    String? id,
    DateTime? date,
    List<Activity>? activities,
    List<String>? moods,
    double? overallMoodScore,
    Map<String, dynamic>? weatherData,
  }) {
    return DayPlan(
      id: id ?? this.id,
      date: date ?? this.date,
      activities: activities ?? this.activities,
      moods: moods ?? this.moods,
      overallMoodScore: overallMoodScore ?? this.overallMoodScore,
      weatherData: weatherData ?? this.weatherData,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DayPlan &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
} 