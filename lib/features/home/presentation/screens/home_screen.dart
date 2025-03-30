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
import 'package:wandermood/features/explore/presentation/widgets/mood_selection_widget.dart';
import '../widgets/compact_weather_widget.dart';
import '../widgets/interactive_weather_widget.dart';
import '../widgets/mood_tile.dart';
import 'package:wandermood/features/weather/presentation/widgets/hourly_weather_widget.dart';
import 'explore_screen.dart';
import 'agenda_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:wandermood/features/location/presentation/widgets/location_dropdown.dart';
import 'trending_screen.dart';

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
    const TrendingScreen(),
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
                offset: Offset(0, -5),
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
                  _buildNavItem(2, Icons.local_fire_department, 'Trending', _selectedIndex == 2),
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
      margin: EdgeInsets.only(right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            hour,
            style: GoogleFonts.openSans(
              fontSize: 16,
              color: Color(0xFF1A4A24),
            ),
          ),
          SizedBox(height: 4),
          Text(
            weatherEmoji,
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 4),
          Text(
            temp,
            style: GoogleFonts.openSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A4A24),
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
            color: Color(0xFF1A4A24),
          ),
        ),
        SizedBox(height: 8),
        Icon(icon, color: Color(0xFFF9C21B), size: 24),
        SizedBox(height: 8),
        Text(
          temp,
          style: GoogleFonts.openSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A4A24),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF1A4A24), size: 20),
        SizedBox(height: 4),
          Text(
          label,
          style: GoogleFonts.openSans(
            fontSize: 12,
            color: Color(0xFF1A4A24).withOpacity(0.8),
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.openSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A4A24),
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
            SizedBox(height: 4),
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

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _isWeatherExpanded = false;
  final List<Map<String, dynamic>> _firstRowMoods = [
    {
      'icon': '🏕️',
      'label': 'Adventurous',
      'color': Colors.blue.shade50,
      'borderColor': Colors.blue.shade200,
    },
    {
      'icon': '🍃',
      'label': 'Relaxed',
      'color': Colors.green.shade50,
      'borderColor': Colors.green.shade200,
    },
    {
      'icon': '💖',
      'label': 'Romantic',
      'color': Colors.pink.shade50,
      'borderColor': Colors.pink.shade200,
    },
    {
      'icon': '⚡',
      'label': 'Energetic',
      'color': Colors.yellow.shade50,
      'borderColor': Colors.yellow.shade200,
    },
    {
      'icon': '🤩',
      'label': 'Excited',
      'color': Colors.purple.shade50,
      'borderColor': Colors.purple.shade200,
    },
    {
      'icon': '☕',
      'label': 'Cozy',
      'color': Colors.brown.shade50,
      'borderColor': Colors.brown.shade200,
    },
  ];

  final List<Map<String, dynamic>> _secondRowMoods = [
    {
      'icon': '😲',
      'label': 'Surprise',
      'color': Colors.orange.shade50,
      'borderColor': Colors.orange.shade200,
    },
    {
      'icon': '🍽️',
      'label': 'Foody',
      'color': Colors.red.shade50,
      'borderColor': Colors.red.shade200,
    },
    {
      'icon': '🎉',
      'label': 'Festive',
      'color': Colors.indigo.shade50,
      'borderColor': Colors.indigo.shade200,
    },
    {
      'icon': '🧠',
      'label': 'Mind',
      'color': Colors.teal.shade50,
      'borderColor': Colors.teal.shade200,
    },
    {
      'icon': '👨‍👩‍👧‍👦',
      'label': 'Family fun',
      'color': Colors.deepPurple.shade50,
      'borderColor': Colors.deepPurple.shade200,
    },
    {
      'icon': '🌍',
      'label': 'Cultural',
      'color': Colors.cyan.shade50,
      'borderColor': Colors.cyan.shade200,
    },
  ];

  Set<String> _selectedMoods = {};

  void _handleMoodSelect(String mood) {
    setState(() {
      if (_selectedMoods.contains(mood)) {
        _selectedMoods.remove(mood);
      } else if (_selectedMoods.length < 3) {
          _selectedMoods.add(mood);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            const SizedBox(height: 12),
            
            // Header with profile and weather
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.green, size: 12),
                        const SizedBox(width: 2),
          Text(
                          'Washington DC',
            style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
      child: Row(
        children: [
                          const Icon(Icons.wb_sunny, color: Colors.amber, size: 12),
                          const SizedBox(width: 2),
          Text(
                            '32°',
            style: TextStyle(
                              fontSize: 11,
              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.notifications_none, color: Colors.green, size: 18),
                  ],
                ),
              ],
          ).animate().fadeIn(duration: 400.ms),
          
          const SizedBox(height: 16),
          
            // Greeting
            Text(
              'Hello, John!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          
          const SizedBox(height: 16),
          
            // Weather widget
            GestureDetector(
              onTap: () {
        setState(() {
                  _isWeatherExpanded = !_isWeatherExpanded;
                });
              },
        child: Container(
          padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sunny for the rest of the day. Wind speeds up to 19 km/h.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                        ),
                        AnimatedRotation(
                          duration: const Duration(milliseconds: 200),
                          turns: _isWeatherExpanded ? 0.5 : 0,
                          child: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(7, (index) {
                          final hour = (DateTime.now().hour + index) % 24;
                          final temp = 29 - index;
                          final isNight = hour < 6 || hour > 18;
                          
                          return Container(
                            margin: const EdgeInsets.only(right: 24),
                            child: Column(
                              children: [
                                Text(
                                  index == 0 ? 'Now' : '$hour:00',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Icon(
                                  isNight ? Icons.nightlight_round : Icons.wb_sunny,
                                  color: isNight ? Colors.blueGrey : Colors.amber,
                                  size: 24,
                                ),
                                const SizedBox(height: 8),
                    Text(
                                  '$temp°',
                style: const TextStyle(
                                    fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ],
      ),
    );
                        }),
                      ),
                    ),
                    if (_isWeatherExpanded) ...[
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: Colors.black12),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildWeatherDetail(
                            icon: Icons.air,
                            label: 'Wind',
                            value: '19 km/h',
                          ),
                          _buildWeatherDetail(
                            icon: Icons.water_drop,
                            label: 'Humidity',
                            value: '65%',
                          ),
                          _buildWeatherDetail(
                            icon: Icons.wb_twilight,
                            label: 'UV Index',
                            value: '6 of 10',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildWeatherDetail(
                            icon: Icons.wb_sunny,
                            label: 'Sunrise',
                            value: '6:24 AM',
                          ),
                          _buildWeatherDetail(
                            icon: Icons.nightlight,
                            label: 'Sunset',
                            value: '8:16 PM',
                          ),
                          _buildWeatherDetail(
                            icon: Icons.visibility,
                            label: 'Visibility',
                            value: '16.1 km',
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

            const SizedBox(height: 32),

            // Mood selection title
            Text(
              'How are you feeling today?',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

            const SizedBox(height: 24),

            // First row of moods
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: _firstRowMoods.length,
                itemBuilder: (context, index) {
                  final mood = _firstRowMoods[index];
                  final isSelected = _selectedMoods.contains(mood['label']);
                  return Container(
                    width: 80,
                    margin: EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? (mood['color'] as Color).withOpacity(0.7)
                        : mood['color'] as Color,
        borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                          ? mood['borderColor'] as Color
                          : (mood['borderColor'] as Color).withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (mood['color'] as Color).withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                    ),
                    child: Stack(
                      children: [
                        if (isSelected)
                          Positioned(
                            top: 8,
                            right: 8,
        child: Container(
                              padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
                                color: mood['borderColor'] as Color,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
            color: Colors.white,
                                size: 12,
              ),
            ),
          ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
            children: [
                            Text(
                              mood['icon'],
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mood['label'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected 
                                  ? mood['borderColor'] as Color
                                  : Colors.grey[800],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate(
                    onPlay: (controller) => controller.repeat(),
                  ).shimmer(
                    duration: const Duration(seconds: 2),
                    color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
                  );
                },
              ),
            ).animate().fadeIn(delay: 800.ms, duration: 400.ms),

            const SizedBox(height: 16),

            // Second row of moods
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: _secondRowMoods.length,
                itemBuilder: (context, index) {
                  final mood = _secondRowMoods[index];
                  final isSelected = _selectedMoods.contains(mood['label']);
                  return Container(
                    width: 80,
                    margin: EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                      color: isSelected 
                        ? (mood['color'] as Color).withOpacity(0.7)
                        : mood['color'] as Color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected 
                          ? mood['borderColor'] as Color
                          : (mood['borderColor'] as Color).withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (mood['color'] as Color).withOpacity(0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                    ),
                    child: Stack(
                      children: [
                        if (isSelected)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: mood['borderColor'] as Color,
                  shape: BoxShape.circle,
                ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                              mood['icon'],
                              style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 4),
                    Text(
                              mood['label'],
                style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected 
                                  ? mood['borderColor'] as Color
                                  : Colors.grey[800],
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                      ],
                    ),
                  ).animate(
                    onPlay: (controller) => controller.repeat(),
                  ).shimmer(
                    duration: const Duration(seconds: 2),
                    color: isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
                  );
                },
              ),
            ).animate().fadeIn(delay: 1000.ms, duration: 400.ms),

            const SizedBox(height: 24),
            ],
          ),
      ),
    );
  }

  Widget _buildWeatherDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class PlannerTab extends StatelessWidget {
  const PlannerTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

// Dashboard tab volgens ontwerp
class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  bool _isWeatherExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          
          // Top row with profile, location, weather and notification
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.green,
                child: Icon(Icons.person, color: Colors.white),
              ).animate().fadeIn(duration: 400.ms),
              
              const SizedBox(width: 8),
              
              Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFF4CAF50), size: 16),
                  const SizedBox(width: 4),
          Text(
                    'Washington DC',
            style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              
              const Spacer(),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wb_sunny, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
          Text(
                      '32°',
            style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          
              const SizedBox(width: 8),
              
              const Icon(Icons.notifications, color: Color(0xFF4CAF50), size: 20)
                  .animate().fadeIn(delay: 300.ms, duration: 400.ms),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Hello, John!',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4CAF50),
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 12),
          
          // Weather widget with expandable view
          Flexible(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isWeatherExpanded = !_isWeatherExpanded;
                });
              },
              child: HourlyWeatherWidget(
                location: 'Washington DC',
                hourlyWeather: List.generate(24, (index) {
                  final hour = DateTime.now().add(Duration(hours: index));
                  return HourlyWeather(
                    time: index == 0 ? 'Now' : '${hour.hour}:00',
                    temperature: 25 + (index % 5),
                  );
                }),
                windSpeed: '19 km/h',
                uvIndex: 6,
                sunriseTime: '6:24 AM',
                sunsetTime: '7:45 PM',
                aqi: 45,
              ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
            ),
          ),
          
          SizedBox(height: MediaQuery.of(context).size.height * 0.06), // Increased responsive spacing
          
          // "How are you feeling today?" text with enhanced spacing
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'How are you feeling today?',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          
          const SizedBox(height: 20), // Consistent spacing before mood selection
          
          // Mood Selection Widget
          Expanded(
            child: MoodSelectionWidget(
              onMoodsSelected: (selectedMoods) {
                print('Selected moods: $selectedMoods');
              },
            ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final Set<String> _selectedMoods = {};
  static const int maxMoodSelections = 3;

  void _toggleMoodSelection(String mood) {
    setState(() {
      if (_selectedMoods.contains(mood)) {
        _selectedMoods.remove(mood);
      } else if (_selectedMoods.length < maxMoodSelections) {
        _selectedMoods.add(mood);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get MediaQuery data safely inside build method
    final mediaQuery = MediaQuery.of(context);
    final statusBarHeight = mediaQuery.viewPadding.top;
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFAFF4), // Roze
            Color(0xFFFFF5AF), // Lichtgeel
          ],
        ),
      ),
        child: Column(
          children: [
          // Status bar height compensation using safely obtained value
          SizedBox(height: statusBarHeight),
          
          // Content area
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App bar section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: _buildAppBar(context),
                  ),
                ),

                // Main content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        
                        // Greeting
                        _buildGreeting(),

                        const SizedBox(height: 24),

                        // Weather Widget
                        _buildWeatherWidget(),

                        const SizedBox(height: 24),

                        // Mood Selection Title
                        _buildMoodSelectionTitle(),

                        const SizedBox(height: 24),

                        // Mood Selection Rows
                        _buildMoodSelectionRows(),

                        // Add more padding before the button
                        const SizedBox(height: 40),  // Increased from 24 to 40
                        
                        // Unlock the Fun button
                        _buildUnlockButton(context),

                        // Extra space for navigation bar, using safe area
                        SizedBox(height: mediaQuery.padding.bottom + 90),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
          // Profile and location
                  Row(
                    children: [
              _buildProfileButton(),
              const SizedBox(width: 12),
              const LocationDropdown(),
            ],
          ),
          
          // Weather info only
          _buildWeatherInfo(),
        ],
      ),
    );
  }

  Widget _buildProfileButton() {
    return GestureDetector(
      onTap: () {
        // Profile interaction to be implemented
      },
      child: Container(
        width: 56,
        height: 56,
                    decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF12B347), Color(0xFF0F9A3F)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF12B347).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0), // Border width
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              image: const DecorationImage(
                image: NetworkImage('https://i.pravatar.cc/150?img=12'), // Temporary avatar
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideX(begin: -0.2, end: 0);
  }

  Widget _buildWeatherInfo() {
    return GestureDetector(
      onTap: () {
        // Weather details to be implemented
      },
                        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
                              ),
                            ],
                          ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Row(
                              children: [
                const Icon(
                  Icons.wb_sunny,
                  color: Color(0xFFF9C21B),
                  size: 24,
                ),
                const SizedBox(width: 6),
                                Text(
                  '32°',
                                  style: GoogleFonts.poppins(
                    color: const Color(0xFF1A4A24),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
    ).animate()
      .fadeIn(delay: 400.ms, duration: 400.ms)
      .slideX(begin: 0.2, end: 0);
  }

  Widget _buildGreeting() {
    return Text(
      'Hello, John!',
      style: GoogleFonts.openSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF12B347),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildWeatherWidget() {
    return HourlyWeatherWidget(
      location: 'Washington DC',
      hourlyWeather: List.generate(24, (index) {
        final hour = DateTime.now().add(Duration(hours: index));
        return HourlyWeather(
          time: index == 0 ? 'Now' : '${hour.hour}:00',
          temperature: 25 + (index % 5),
        );
      }),
      windSpeed: '19 km/h',
      uvIndex: 6,
      sunriseTime: '6:24 AM',
      sunsetTime: '7:45 PM',
      aqi: 45,
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  Widget _buildMoodSelectionTitle() {
    return Center(
      child: Text(
        'How are you feeling today?',
        style: GoogleFonts.openSans(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1A4A24),
        ),
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 400.ms);
  }

  Widget _buildMoodSelectionRows() {
    return Column(
      children: [
        _buildMoodRow(const [
          {'label': 'Adventurous', 'emoji': '🏕️', 'color': Color(0xFFCAE5FC)},
          {'label': 'Relaxed', 'emoji': '🧖🏾‍♀️', 'color': Color(0xFFE7CCEB)},
          {'label': 'Romantic', 'emoji': '💖', 'color': Color(0xFFFFD5DC)},
          {'label': 'Energetic', 'emoji': '⚡', 'color': Color(0xFFFFEED4)},
          {'label': 'Excited', 'emoji': '🤩', 'color': Color(0xFFD0EBD1)},
          {'label': 'Cozy', 'emoji': '☕', 'color': Color(0xFFD2F3F8)},
        ]),
                      const SizedBox(height: 16),
        _buildMoodRow(const [
          {'label': 'Surprise', 'emoji': '😲', 'color': Color(0xFFFFE0B2)},
          {'label': 'Foody', 'emoji': '🍽️', 'color': Color(0xFFFFCDD2)},
          {'label': 'Festive', 'emoji': '🎉', 'color': Color(0xFFE8EAF6)},
          {'label': 'Mind full', 'emoji': '🧠', 'color': Color(0xFFB2DFDB)},
          {'label': 'Family fun', 'emoji': '👨‍👩‍👧‍👦', 'color': Color(0xFFD1C4E9)},
          {'label': 'Cultural', 'emoji': '🌍', 'color': Color(0xFFB2EBF2)},
        ]),
      ],
    );
  }

  Widget _buildMoodRow(List<Map<String, dynamic>> moods) {
    return SizedBox(
      height: 85,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: moods.length,
        itemBuilder: (context, index) {
          final mood = moods[index];
          final isEnabled = _selectedMoods.length < maxMoodSelections || 
                          _selectedMoods.contains(mood['label']);
          
          return MoodTile(
            label: mood['label'] as String,
            emoji: mood['emoji'] as String,
            bgColor: mood['color'] as Color,
            isSelected: _selectedMoods.contains(mood['label']),
            isSelectionEnabled: isEnabled,
            onTap: () => _toggleMoodSelection(mood['label']),
          );
        },
      ),
    );
  }

  Widget _buildUnlockButton(BuildContext context) {
    final bool hasSelectedMoods = _selectedMoods.isNotEmpty;
    
    return Center(
      child: ElevatedButton(
        onPressed: hasSelectedMoods ? () => context.go('/adventure-plan') : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: hasSelectedMoods ? const Color(0xFF12B347) : Colors.grey.shade300,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: hasSelectedMoods ? 4 : 0,
        ).copyWith(
          overlayColor: MaterialStateProperty.all(
            Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Unlock the Fun',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '🎯',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    ).animate(target: hasSelectedMoods ? 1 : 0)
      .fadeIn(duration: 300.ms)
      .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }
} 