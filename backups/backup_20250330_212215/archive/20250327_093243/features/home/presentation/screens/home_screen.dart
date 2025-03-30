import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';  // Add this import for ImageFilter
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wandermood/features/auth/domain/providers/auth_provider.dart';
import 'package:wandermood/features/profile/presentation/screens/profile_screen.dart';
import '../widgets/mood_selection_widget.dart';
import '../widgets/mood_grid_widget.dart';
import '../widgets/compact_weather_widget.dart';
import '../widgets/interactive_weather_widget.dart';
import '../widgets/mood_tile.dart';
import '../widgets/weather_detail.dart';
import 'package:wandermood/features/weather/presentation/widgets/hourly_weather_widget.dart';
// import 'explore_screen.dart';  // TODO: Re-enable when new explore screen is implemented
import 'agenda_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:wandermood/features/location/presentation/widgets/location_dropdown.dart';
import 'trending_screen.dart';
import 'moody_screen.dart';
import '../widgets/moody_scene_widget.dart';
import 'planning_screen.dart';
import 'package:wandermood/features/home/presentation/widgets/openai_test_widget.dart';
import 'package:wandermood/features/recommendations/providers/recommendation_provider.dart';
import 'package:wandermood/features/location/providers/location_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  bool _isWeatherExpanded = false;
  final Set<String> _selectedMoods = {};
  bool _showPlanning = false;
  bool _isGenerating = false;
  
  // Update screens list to pass callback
  late final List<Widget> _screens = [
    HomeContent(
      selectedMoods: _selectedMoods,
      onMoodSelected: (mood) => _onMoodSelected(mood, !_selectedMoods.contains(mood)),
      onGeneratePress: _handleGeneratePress,
    ),
    const TrendingScreen(), // Using TrendingScreen for Explore temporarily
    const MoodyScreen(),
    const AgendaScreen(),
    const ProfileScreen(),
  ];
  
  @override
  void initState() {
    super.initState();
    // Configureer de status bar voor optimale weergave
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFAFF4), // Pink
                      Color(0xFFFFF5AF), // Light yellow
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'WanderMood',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your personal travel companion',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.home_outlined),
                title: Text('Home'),
                onTap: () {
                  setState(() => _selectedIndex = 0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.explore_outlined),
                title: Text('Explore'),
                onTap: () {
                  setState(() => _selectedIndex = 1);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.smart_toy_outlined),
                title: Text('Moody'),
                onTap: () {
                  setState(() => _selectedIndex = 2);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.calendar_today_outlined),
                title: Text('Agenda'),
                onTap: () {
                  setState(() => _selectedIndex = 3);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.person_outline),
                title: Text('Profile'),
                onTap: () {
                  setState(() => _selectedIndex = 4);
                  Navigator.pop(context);
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.settings_outlined),
                title: Text('Settings'),
                onTap: () {
                  // TODO: Implement settings
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.help_outline),
                title: Text('Help & Support'),
                onTap: () {
                  // TODO: Implement help & support
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        body: _showPlanning 
          ? PlanningScreen(selectedMood: _selectedMoods.join(','))
          : IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.home_outlined, 'Home', _selectedIndex == 0),
                  _buildNavItem(1, Icons.explore_outlined, 'Explore', _selectedIndex == 1),
                  _buildNavItem(2, Icons.smart_toy_outlined, 'Moody', _selectedIndex == 2),
                  _buildNavItem(3, Icons.calendar_today_outlined, 'Agenda', _selectedIndex == 3),
                  _buildNavItem(4, Icons.person_outline, 'Profile', _selectedIndex == 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherHourItem(String hour, String temp, bool isDaytime) {
    // Bepaal het uur van de dag
    int currentHour;
    if (hour == 'Nu') {
      currentHour = 14; // Stel de huidige tijd in op 14:00
    } else {
      currentHour = int.parse(hour.split(':')[0]);
    }

    // Bepaal of het dag of nacht is (dag tussen 6:00 en 20:00)
    bool isDay = currentHour >= 6 && currentHour < 20;
    
    // Kies het juiste emoji op basis van tijd
    String weatherEmoji;
    if (isDay) {
      weatherEmoji = '☀️';
    } else {
      weatherEmoji = '🌕'; // Witte maan emoji
    }

    return Container(
      margin: const EdgeInsets.only(right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            hour,
            style: GoogleFonts.openSans(
              fontSize: 16,
              color: const Color(0xFF1A4A24),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            weatherEmoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            temp,
            style: GoogleFonts.openSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A4A24),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDayForecast(String day, String temp, IconData icon) {
    return Column(
      children: [
        Text(
          day,
          style: GoogleFonts.openSans(
            fontSize: 14,
            color: const Color(0xFF1A4A24),
          ),
        ),
        const SizedBox(height: 8),
        Icon(icon, color: const Color(0xFFF9C21B), size: 24),
        const SizedBox(height: 8),
        Text(
          temp,
          style: GoogleFonts.openSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A4A24),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodTile(String label, Color bgColor, String emoji) {
    final isSelected = _selectedMoods.contains(label);
    return GestureDetector(
      onTap: () {
          setState(() {
          if (isSelected) {
            _selectedMoods.remove(label);
          } else if (_selectedMoods.length < 3) {
            _selectedMoods.add(label);
          }
          });
        },
      child: Container(
        width: 80,
        margin: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: isSelected ? bgColor.withOpacity(0.7) : bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Color(0xFF12B347) : bgColor.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: bgColor.withOpacity(0.5),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            if (isSelected)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Color(0xFF12B347),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    emoji,
            style: TextStyle(
                      fontSize: isSelected ? 32 : 28,
                    ),
                  ),
                  SizedBox(height: 2),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      label,
                      style: GoogleFonts.openSans(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Color(0xFF12B347) : Color(0xFF1A4A24),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNavItem(int index, IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 64,
        height: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFF12B347) : const Color(0xFF9D9DA5),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.openSans(
                fontSize: 12,
                color: isActive ? const Color(0xFF12B347) : const Color(0xFF9D9DA5),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMoodSelection(String mood, bool selected) {
    setState(() {
      if (selected) {
        _selectedMoods.add(mood);
      } else {
        _selectedMoods.remove(mood);
      }
    });
  }

  void _handleGeneratePress() {
    if (_selectedMoods.isNotEmpty) {
      _generatePlan();
    }
  }

  Future<void> _generatePlan() async {
    if (_selectedMoods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one mood')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final location = ref.read(locationProvider).value ?? 'Amsterdam';
      
      await ref.read(recommendationProvider.notifier).generateRecommendations(
        mood: _selectedMoods.join(', '),
        location: location,
      );

      if (mounted) {
        setState(() {
          _selectedIndex = 1;  // Switch to explore screen
          _isGenerating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating plan: $e')),
        );
        setState(() => _isGenerating = false);
      }
    }
  }

  void _onMoodSelected(String mood, bool selected) {
    setState(() {
      if (selected) {
        _selectedMoods.add(mood);
      } else {
        _selectedMoods.remove(mood);
      }
    });
  }
}

class HomeContent extends StatefulWidget {
  final Set<String> selectedMoods;    // Add selected moods from parent
  final Function(String) onMoodSelected;  // Add callback for mood selection
  final Function() onGeneratePress;  // Add generate plan callback

  const HomeContent({
    super.key,
    required this.selectedMoods,
    required this.onMoodSelected,
    required this.onGeneratePress,
  });

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _isListening = false;

  void _handleVoiceInputTap() {
    setState(() {
      _isListening = !_isListening;
    });
    // TODO: Implement voice input functionality
  }

  void _handleMoodSelection(String mood) {
    // Call the parent's callback instead of managing state locally
    widget.onMoodSelected(mood);
  }

  void _handleGeneratePress() {
    if (widget.selectedMoods.isNotEmpty && widget.onGeneratePress != null) {
      widget.onGeneratePress();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFAFF4), // Pink
            Color(0xFFFFF5AF), // Light yellow
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top Bar with Location and Profile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Rotterdam, Netherlands',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  // Profile Picture
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Colors.green,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Moody Scene
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: MoodySceneWidget(),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: 24),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MoodGridWidget(
                        selectedMoods: widget.selectedMoods,  // Use parent's selected moods
                        onMoodSelected: _handleMoodSelection,
                        onGeneratePress: _handleGeneratePress,
                      ),

                      const SizedBox(height: 24),

                      // Voice Input Button
                      GestureDetector(
                        onTap: _handleVoiceInputTap,
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isListening ? Icons.mic : Icons.mic_none,
                                  color: _isListening ? Colors.green : Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Voice Input',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: _isListening ? Colors.green : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      
                      // Add OpenAI test widget
                      const OpenAITestWidget(),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 