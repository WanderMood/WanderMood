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
import 'explore_screen.dart';
import 'agenda_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:wandermood/features/location/presentation/widgets/location_dropdown.dart';
import 'trending_screen.dart';
import 'moody_screen.dart';
import '../widgets/moody_scene_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  bool _isWeatherExpanded = false;
  final Set<String> _selectedMoods = {};
  
  // Voeg de schermen toe die we willen tonen
  final List<Widget> _screens = [
    const HomeContent(),  // Dit is de huidige home content
    const ExploreScreen(),
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
        body: IndexedStack(
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
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

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
                      const MoodGridWidget(),

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