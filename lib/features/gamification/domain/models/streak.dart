class Streak {
  final int currentStreak;
  final int bestStreak;
  final DateTime lastActivityDate;
  final List<DateTime> activityDates;
  
  Streak({
    this.currentStreak = 0,
    this.bestStreak = 0,
    DateTime? lastActivityDate,
    List<DateTime>? activityDates,
  }) : 
    lastActivityDate = lastActivityDate ?? DateTime.now(),
    activityDates = activityDates ?? [];
  
  // Check if the streak is still active (activity within last 24 hours)
  bool get isActive {
    final now = DateTime.now();
    final difference = now.difference(lastActivityDate);
    return difference.inHours < 36; // Give some grace period
  }
  
  // Check if the user has completed an activity today
  bool get hasActivityToday {
    final now = DateTime.now();
    return activityDates.any((date) => 
      date.year == now.year && 
      date.month == now.month && 
      date.day == now.day
    );
  }
  
  // Returns the number of days to the next streak milestone (7, 14, 30, etc.)
  int get daysToNextMilestone {
    if (currentStreak < 7) return 7 - currentStreak;
    if (currentStreak < 14) return 14 - currentStreak;
    if (currentStreak < 30) return 30 - currentStreak;
    if (currentStreak < 60) return 60 - currentStreak;
    if (currentStreak < 90) return 90 - currentStreak;
    if (currentStreak < 180) return 180 - currentStreak;
    if (currentStreak < 365) return 365 - currentStreak;
    return 0; // Already reached a year!
  }
  
  Streak copyWith({
    int? currentStreak,
    int? bestStreak,
    DateTime? lastActivityDate,
    List<DateTime>? activityDates,
  }) {
    return Streak(
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      activityDates: activityDates ?? this.activityDates,
    );
  }
  
  // Record a new activity and update the streak
  Streak recordActivity() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Don't count multiple activities on the same day
    if (hasActivityToday) {
      return this;
    }
    
    final newActivityDates = List<DateTime>.from(activityDates)..add(today);
    
    // Check if streak continues or resets
    if (isActive) {
      // Streak continues
      final newCurrentStreak = currentStreak + 1;
      final newBestStreak = newCurrentStreak > bestStreak ? newCurrentStreak : bestStreak;
      
      return Streak(
        currentStreak: newCurrentStreak,
        bestStreak: newBestStreak,
        lastActivityDate: now,
        activityDates: newActivityDates,
      );
    } else {
      // Streak resets
      return Streak(
        currentStreak: 1,
        bestStreak: bestStreak,
        lastActivityDate: now,
        activityDates: newActivityDates,
      );
    }
  }
} 
 
 
 