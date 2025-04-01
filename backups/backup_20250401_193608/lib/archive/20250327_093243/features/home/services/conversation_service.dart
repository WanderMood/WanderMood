import 'package:flutter/foundation.dart';

enum ConversationState {
  initial,
  greeting,
  planning,
  locationInfo,
  weatherCheck,
  confirmation,
  farewell
}

class ConversationContext {
  final String mood;
  final List<String> selectedActivities;
  final String? lastDiscussedActivity;
  final String? lastDiscussedLocation;
  final ConversationState state;

  ConversationContext({
    required this.mood,
    required this.selectedActivities,
    this.lastDiscussedActivity,
    this.lastDiscussedLocation,
    required this.state,
  });

  ConversationContext copyWith({
    String? mood,
    List<String>? selectedActivities,
    String? lastDiscussedActivity,
    String? lastDiscussedLocation,
    ConversationState? state,
  }) {
    return ConversationContext(
      mood: mood ?? this.mood,
      selectedActivities: selectedActivities ?? this.selectedActivities,
      lastDiscussedActivity: lastDiscussedActivity ?? this.lastDiscussedActivity,
      lastDiscussedLocation: lastDiscussedLocation ?? this.lastDiscussedLocation,
      state: state ?? this.state,
    );
  }
}

class ConversationService extends ChangeNotifier {
  ConversationContext _context;
  final int _maxTurns = 3; // Maximum conversation turns before prompting for action
  int _currentTurn = 0;

  ConversationService(String initialMood)
      : _context = ConversationContext(
          mood: initialMood,
          selectedActivities: [],
          state: ConversationState.initial,
        );

  ConversationContext get context => _context;

  void updateContext({
    String? mood,
    List<String>? selectedActivities,
    String? lastDiscussedActivity,
    String? lastDiscussedLocation,
    ConversationState? state,
  }) {
    _context = _context.copyWith(
      mood: mood,
      selectedActivities: selectedActivities,
      lastDiscussedActivity: lastDiscussedActivity,
      lastDiscussedLocation: lastDiscussedLocation,
      state: state,
    );
    _currentTurn++;
    notifyListeners();
  }

  bool get shouldPromptForAction => _currentTurn >= _maxTurns;

  void resetTurns() {
    _currentTurn = 0;
    notifyListeners();
  }

  String getPromptForAction() {
    switch (_context.state) {
      case ConversationState.planning:
        return "Would you like to add any of these activities to your plan?";
      case ConversationState.locationInfo:
        return "Should I show you how to get to ${_context.lastDiscussedLocation}?";
      case ConversationState.weatherCheck:
        return "Shall we adjust the plan based on the weather?";
      default:
        return "Would you like to see all activities that match your ${_context.mood} mood?";
    }
  }

  bool isRelevantToCurrentState(String input) {
    switch (_context.state) {
      case ConversationState.planning:
        return input.contains('plan') ||
            input.contains('activity') ||
            input.contains('do');
      case ConversationState.locationInfo:
        return input.contains('where') ||
            input.contains('location') ||
            input.contains('get to');
      case ConversationState.weatherCheck:
        return input.contains('weather') ||
            input.contains('rain') ||
            input.contains('sun');
      default:
        return true;
    }
  }

  void addSelectedActivity(String activity) {
    final updatedActivities = List<String>.from(_context.selectedActivities)
      ..add(activity);
    updateContext(
      selectedActivities: updatedActivities,
      lastDiscussedActivity: activity,
    );
  }

  void setLocation(String location) {
    updateContext(lastDiscussedLocation: location);
  }

  void transitionState(ConversationState newState) {
    updateContext(state: newState);
  }
} 