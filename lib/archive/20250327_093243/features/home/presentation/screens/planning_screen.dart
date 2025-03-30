import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:wandermood/features/home/presentation/widgets/mood_grid_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class DayPart {
  final String title;
  final List<String> activities;
  final IconData icon;

  const DayPart({
    required this.title,
    required this.activities,
    required this.icon,
  });
}

class PlanningScreen extends ConsumerStatefulWidget {
  final String selectedMood;
  final VoidCallback? onBack;

  const PlanningScreen({
    super.key,
    required this.selectedMood,
    this.onBack,
  });

  @override
  ConsumerState<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends ConsumerState<PlanningScreen> {
  Timer? _midnightTimer;
  static const String _lastResetKey = 'last_planning_reset';
  bool _isLoading = true;
  List<DayPart> _dayParts = [];
  Map<String, List<String>> _selectedActivities = {
    'Morning': [],
    'Afternoon': [],
    'Evening': [],
  };

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
    _setupMidnightCheck();
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }

  Future<void> _setupMidnightCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final lastReset = prefs.getString(_lastResetKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Check if we need to reset (it's a new day or past noon)
    if (lastReset == null || 
        DateTime.parse(lastReset).day != today.day ||
        (now.hour >= 12 && DateTime.parse(lastReset).hour < 12)) {
      _resetPlanning();
    }

    // Set timer for next noon
    final nextNoon = DateTime(now.year, now.month, now.day, 12);
    if (now.isAfter(nextNoon)) {
      nextNoon.add(const Duration(days: 1));
    }
    final timeUntilNoon = nextNoon.difference(now);
    
    _midnightTimer = Timer(timeUntilNoon, () {
      _resetPlanning();
      // Setup next day's timer
      _setupMidnightCheck();
    });
  }

  Future<void> _resetPlanning() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastResetKey, DateTime.now().toIso8601String());
    
    if (mounted) {
      widget.onBack?.call(); // Return to mood selection
    }
  }

  Future<void> _loadSuggestions() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Get suggestions based on mood
    final suggestions = _getMoodBasedSuggestions();
    
    setState(() {
      _dayParts = [
        DayPart(
          title: 'Morning',
          activities: suggestions['Morning']!,
          icon: Icons.wb_sunny_outlined,
        ),
        DayPart(
          title: 'Afternoon',
          activities: suggestions['Afternoon']!,
          icon: Icons.wb_sunny,
        ),
        DayPart(
          title: 'Evening',
          activities: suggestions['Evening']!,
          icon: Icons.nights_stay_outlined,
        ),
      ];
      _isLoading = false;
    });
  }

  Map<String, List<String>> _getMoodBasedSuggestions() {
    switch (widget.selectedMood.toLowerCase()) {
      case 'adventurous':
        return {
          'Morning': [
            'Visit Euromast 🗼',
            'Take a Spido Harbor Tour ⛴️',
            'Explore Erasmusbrug 🌉',
          ],
          'Afternoon': [
            'Try Water Taxi Adventure 🚤',
            'Visit Maritime Museum ⚓',
            'Explore Delfshaven Historic Harbor 🏛️',
          ],
          'Evening': [
            'Sunset at Euromast Restaurant 🌅',
            'Night Walk Along the Maas 🌙',
            'Visit Wereldmuseum 🌍',
          ],
        };
      case 'cultural':
        return {
          'Morning': [
            'Visit Museum Boijmans Van Beuningen 🎨',
            'Explore Kunsthal Rotterdam 🖼️',
            'Visit Maritime Museum ⚓',
          ],
          'Afternoon': [
            'Tour the Markthal 🏛️',
            'Visit Wereldmuseum 🌍',
            'Explore Historic Delfshaven 🏛️',
          ],
          'Evening': [
            'Evening Concert at De Doelen 🎵',
            'Theater Show at Luxor 🎭',
            'Cultural Dinner at Hotel New York 🍽️',
          ],
        };
      case 'relaxed':
        return {
          'Morning': [
            'Stroll in Arboretum Trompenburg 🌳',
            'Coffee at Hotel New York ☕',
            'Visit Kralingse Bos 🌲',
          ],
          'Afternoon': [
            'Picnic at Kralingse Plas 🧺',
            'Visit Japanese Garden 🍃',
            'Relax at Dakpark 🌸',
          ],
          'Evening': [
            'Sunset Harbor Walk 🌅',
            'Dinner Cruise ⛴️',
            'Spa Evening at Harbour Club 💆‍♂️',
          ],
        };
      default:
        return {
          'Morning': [
            'Visit Euromast 🗼',
            'Explore Markthal 🏛️',
            'Walk along Erasmusbrug 🌉',
          ],
          'Afternoon': [
            'Visit Maritime Museum ⚓',
            'Shop at Koopgoot 🛍️',
            'Tour Kunsthal 🎨',
          ],
          'Evening': [
            'Dinner at Hotel New York 🍽️',
            'Evening Harbor Tour ⛴️',
            'Walk in Kralingse Bos 🌳',
          ],
        };
    }
  }

  void _toggleActivity(String dayPart, String activity) {
    setState(() {
      if (_selectedActivities[dayPart]!.contains(activity)) {
        _selectedActivities[dayPart]!.remove(activity);
      } else {
        _selectedActivities[dayPart]!.add(activity);
      }
    });
  }

  bool get _hasSelectedActivities =>
      _selectedActivities.values.any((list) => list.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFAFF4),
              Color(0xFFFFF5AF),
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: const Color(0xFF12B347),
                      onPressed: () {
                        if (widget.onBack != null) {
                          widget.onBack!();
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your ${widget.selectedMood} Plan',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Color(0xFF12B347),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Creating your perfect day...',
                          style: GoogleFonts.museoModerno(
                            fontSize: 18,
                            color: const Color(0xFF0B5D24),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _dayParts.length,
                          itemBuilder: (context, index) {
                            final dayPart = _dayParts[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    children: [
                                      Icon(
                                        dayPart.icon,
                                        color: const Color(0xFF12B347),
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        dayPart.title,
                                        style: GoogleFonts.museoModerno(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF0B5D24),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ...dayPart.activities.map((activity) {
                                  final isSelected = _selectedActivities[dayPart.title]!
                                      .contains(activity);
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Card(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(
                                          color: isSelected
                                              ? const Color(0xFF12B347)
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: () => _toggleActivity(dayPart.title, activity),
                                        borderRadius: BorderRadius.circular(16),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  activity,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    color: const Color(0xFF1A4A24),
                                                  ),
                                                ),
                                              ),
                                              if (isSelected)
                                                const Icon(
                                                  Icons.check_circle,
                                                  color: Color(0xFF12B347),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ).animate()
                                      .fadeIn(delay: Duration(milliseconds: index * 100))
                                      .slideX(
                                        begin: 0.2,
                                        end: 0,
                                        delay: Duration(milliseconds: index * 100),
                                        curve: Curves.easeOutQuad,
                                      ),
                                  );
                                }).toList(),
                                if (index < _dayParts.length - 1)
                                  const Divider(height: 24),
                              ],
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: ElevatedButton(
                          onPressed: _hasSelectedActivities
                              ? () {
                                  // TODO: Save selected activities and navigate
                                  context.go('/home');
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF12B347),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Let's Go! 🚀",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 