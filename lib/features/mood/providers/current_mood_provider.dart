import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

part 'current_mood_provider.g.dart';

@riverpod
class CurrentMood extends _$CurrentMood {
  @override
  String build() {
    debugPrint('🌈 Building CurrentMood provider');
    // Default mood - ensure it matches a key in _moodToActivityTypes map
    return 'Social'; // Will return restaurants, bars, cafes, etc.
  }

  void setMood(String mood) {
    debugPrint('🌈 Setting mood to: $mood');
    state = mood;
  }
} 