import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';  // Add this import for ImageFilter
import 'dart:math' as math; // Add for random elements
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wandermood/features/auth/domain/providers/auth_provider.dart';
import 'package:wandermood/features/profile/presentation/screens/profile_screen.dart';
import 'package:wandermood/features/explore/presentation/widgets/mood_selection_widget.dart';
import '../widgets/interactive_weather_widget.dart';
import '../widgets/mood_tile.dart';
import 'package:wandermood/features/weather/presentation/widgets/hourly_weather_widget.dart';
import 'explore_screen.dart';
import 'agenda_screen.dart' as local_agenda;
import 'package:go_router/go_router.dart';
import 'package:wandermood/features/location/presentation/widgets/location_dropdown.dart';
import 'trending_screen.dart' as local_trending;
import 'package:wandermood/core/presentation/widgets/swirl_background.dart';
import 'package:wandermood/features/mood/presentation/widgets/mood_selector.dart';
import 'package:wandermood/core/domain/providers/location_notifier_provider.dart';
import 'package:wandermood/features/auth/providers/user_provider.dart';
import 'package:wandermood/features/weather/providers/weather_provider.dart';
import 'package:wandermood/features/home/presentation/widgets/moody_character.dart';
import 'package:wandermood/features/plans/presentation/screens/plan_result_screen.dart';
import 'package:wandermood/features/plans/presentation/screens/plan_loading_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wandermood/features/profile/presentation/widgets/profile_drawer.dart';
import 'package:wandermood/features/profile/domain/providers/profile_provider.dart';
import 'dart:async';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

// Define time of day enum
enum TimeOfDay {
  morning,
  afternoon,
  evening,
}

class _MainScreenState extends ConsumerState<MainScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _showMoodSelector = false;
  bool _isMoodSelectorVisible = false;
  bool _showNavigationBar = true;  // Changed to true so navigation bar is always visible
  Set<String> _selectedMoods = {};
  String _greeting = '';
  String _timeGreeting = '';
  late AnimationController _animationController;
  MoodyFeature _currentMoodyFeature = MoodyFeature.none;
  int _selectedIndex = 0;
  final List<String> _funGreetings = [
    "What's cookin', good lookin'?",
    "Hey there, superstar!",
    "Well hello, adventurer!",
    "Howdy, partner!",
    "Greetings, explorer!",
  ];
  
  // Add more contextual greeting options
  final Map<String, List<String>> _contextualGreetings = {
    'morning': [
      "Rise and shine! ☀️",
      "Good morning, sunshine! 🌅",
      "Top of the morning! 🌄",
      "Ready for adventure? 🗺️",
      "Let's make today amazing! ✨",
    ],
    'afternoon': [
      "Having a good day? 🌈",
      "Afternoon vibes! ☀️",
      "Time for exploration! 🌎",
      "Adventure awaits! 🚀",
      "Let's discover something new! 🔍",
    ],
    'evening': [
      "Evening explorer! 🌙",
      "Starlight greetings! ⭐",
      "Night adventures? 🌃",
      "Magical evening! ✨",
      "Time for night wonders! 🌠",
    ],
  };
  
  // Mock previous mood - in a real app, this would come from storage/database
  final String _previousMood = "Adventurous";
  final String _lastTravelDestination = "Barcelona";
  
  // Mock user interaction history (in a real app, this would be stored in a database)
  final Map<String, dynamic> _userPreferences = {
    'favoriteType': 'beach',
    'lastSearched': 'museums in Paris',
    'recommendationCount': 3,
    'hasViewedItinerary': true,
  };
  
  // Time tracking for background
  late TimeOfDay _currentTimeOfDay = TimeOfDay.morning;
  
  // Define the screens to show for each tab
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _updateGreeting();
    _updateTimeOfDay();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _showRandomMoodyFeature();

    // Update greeting periodically
    Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        _updateGreeting();
        _updateTimeOfDay();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _showRandomMoodyFeature() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _currentMoodyFeature = MoodyFeature.moodTracking;
        });
      }
    });
  }
  
  void _updateGreeting() {
    final hour = DateTime.now().hour;
    String timeKey;
    String timeGreeting;
    
    if (hour >= 5 && hour < 12) {
      timeKey = 'morning';
      timeGreeting = 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      timeKey = 'afternoon';
      timeGreeting = 'Good afternoon';
    } else if (hour >= 17 && hour < 21) {
      timeKey = 'evening';
      timeGreeting = 'Good evening';
    } else {
      timeKey = 'evening';
      timeGreeting = 'Good night';
    }
    
    // Get user name from userData
    final userData = ref.read(userDataProvider);
    final userName = userData.when(
      data: (data) => data != null && data.containsKey('name') && data['name'] != null 
          ? data['name'] 
          : 'explorer',
      loading: () => 'explorer',
      error: (_, __) => 'explorer',
    );

    final greetings = _contextualGreetings[timeKey] ?? _contextualGreetings['afternoon']!;
    final randomIndex = DateTime.now().microsecond % greetings.length;
    final randomGreeting = greetings[randomIndex];
    
    setState(() {
      _timeGreeting = timeGreeting;
      _greeting = "$randomGreeting\nHey $userName! ${_getRandomEmojiGroup()}";
    });
  }
  
  String _getRandomEmojiGroup() {
    final emojiGroups = [
      "✨🌟⭐",
      "🌈🦋🌸",
      "🎯🎨🎭",
      "🌍🗺️🧭",
      "🎪🎡🎢",
    ];
    return emojiGroups[DateTime.now().microsecond % emojiGroups.length];
  }

  void _updateTimeOfDay() {
    final hour = DateTime.now().hour;
    setState(() {
      if (hour >= 5 && hour < 12) {
        _currentTimeOfDay = TimeOfDay.morning;
      } else if (hour >= 12 && hour < 17) {
        _currentTimeOfDay = TimeOfDay.afternoon;
      } else {
        _currentTimeOfDay = TimeOfDay.evening;
      }
    });
  }

  void _onPlanGenerated() {
    setState(() {
      _showNavigationBar = true;  // Show navigation bar after plan is generated
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(locationStateProvider);
    final userData = ref.watch(userDataProvider);
    final weatherAsync = ref.watch(weatherProvider);
    
    // Fetch location if not already available
    locationAsync.whenData((state) {
      if (state.city == null) {
        Future.microtask(() {
          ref.read(locationNotifierProvider.notifier).getCurrentLocation();
        });
      }
    });

    // Initialize screens lazily here instead of in initState
    final screens = [
      _buildHomeContent(),
      const ExploreScreen(),
      const local_trending.TrendingScreen(),
      const local_agenda.AgendaScreen(),
      const ProfileScreen(),
    ];

    return SwirlBackground(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          key: _scaffoldKey,
          extendBodyBehindAppBar: true,
          extendBody: true,
          drawer: const ProfileDrawer(),
          body: IndexedStack(
            index: _selectedIndex,
            children: screens,
          ),
          bottomNavigationBar: _showNavigationBar ? Container(
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
                    _buildNavItem(2, Icons.local_fire_department, 'Trending', _selectedIndex == 2),
                    _buildNavItem(3, Icons.calendar_today_outlined, 'Agenda', _selectedIndex == 3),
                    _buildNavItem(4, Icons.person_outline, 'Profile', _selectedIndex == 4),
                  ],
                ),
              ),
            ),
          ) : null,
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isSelected) {
    final emoji = _getEmojiForTab(index);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF12B347).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF12B347) : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmojiForTab(int index) {
    switch (index) {
      case 0:
        return '🏠'; // Home
      case 1:
        return '🌍'; // Explore
      case 2:
        return '🔥'; // Trending
      case 3:
        return '📅'; // Agenda
      case 4:
        return '👤'; // Profile
      default:
        return '❓';
    }
  }

  Widget _buildHomeContent() {
    final locationAsync = ref.watch(locationStateProvider);
    final userData = ref.watch(userDataProvider);
    final weatherAsync = ref.watch(weatherProvider);

    return SafeArea(
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar with profile, location and weather
            Padding(
              padding: const EdgeInsets.all(16.0),
                  child: _buildTopBar(
                    locationAsync,
                    userData,
                    weatherAsync,
                  ),
                ),

                // Greeting text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Heading 1: Good morning (user's first name)
                      Center(
                        child: userData.when(
                          data: (data) {
                            String firstName = '';
                            if (data != null && data.containsKey('name') && data['name'] != null) {
                              firstName = data['name'].toString().split(' ')[0]; // Get only first name
                            } else {
                              firstName = 'explorer';
                            }
                            return Text(
                              "$_timeGreeting $firstName 👋",
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            );
                          },
                          loading: () => Text(
                            "$_timeGreeting explorer 👋",
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          error: (_, __) => Text(
                            "$_timeGreeting explorer 👋",
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Heading 2: How are you feeling today?
                      Center(
                        child: Text(
                          "How are you feeling today?",
                        style: GoogleFonts.poppins(
                            fontSize: 24,
                          fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Moody character
                Container(
                  height: 180,
                  alignment: Alignment.center,
                child: MoodyCharacter(
                  size: 150,
                  mood: 'default',
                ).animate(
                  onPlay: (controller) => controller.repeat(),
                ).scale(
                    duration: const Duration(milliseconds: 2000),
                    begin: const Offset(0.95, 0.95),
                  end: const Offset(1.05, 1.05),
                  curve: Curves.easeInOut,
                  ),
                ),

                const SizedBox(height: 20),

                // Heading 3: Talk to me or select moods (moved here)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Center(
                    child: Text(
                      "Talk to me or select moods for your daily plan",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                ),
              ),
            ),
            
                const SizedBox(height: 12),

                // Mood selector
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: MoodSelector(
                    onMoodsSelected: (moods) {
                      setState(() {
                        _selectedMoods = moods;
                      });
                    },
                  ),
                ),

                // Generate Plan Button - Reduced spacing and moved up
                if (_selectedMoods.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Removed text heading to bring button closer to mood tiles
                        ElevatedButton(
                          onPressed: () {
                            _navigateToPlanResult();
                          },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF12B347),
                  foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 4,
                            shadowColor: const Color(0xFF12B347).withOpacity(0.4),
                          ).copyWith(
                            elevation: MaterialStateProperty.resolveWith<double>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return 2;
                                }
                                return 4;
                              },
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                              "Let's create your perfect plan! 🎯",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                  ),
                ),
              ),
                      ],
                    ),
                  ),

                // Add bottom padding to prevent overlap with navigation bar
                const SizedBox(height: 100),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(
    AsyncValue<LocationState> locationAsync,
    AsyncValue<Map<String, dynamic>?> userData,
    AsyncValue<WeatherData?> weatherAsync,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Profile and location group
        Expanded(
          child: Row(
            children: [
              // Profile button
              _buildProfileButton(),

              const SizedBox(width: 8),

              // Location dropdown
              Expanded(
                child: GestureDetector(
                  onTap: () => _showLocationDialog(context, ref),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on, 
                          color: const Color(0xFF4CAF50).withOpacity(0.8),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            locationAsync.when(
                              data: (state) => state?.city ?? 'Select Location',
                              loading: () => 'Loading...',
                              error: (_, __) => 'Error loading location',
                            ),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF2E7D32),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_drop_down, 
                          color: const Color(0xFF4CAF50).withOpacity(0.8),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Weather widget
        weatherAsync.when(
          data: (weather) => weather != null ? InkWell(
            onTap: () => _showWeatherDetails(context, weather),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wb_sunny, 
                  color: const Color(0xFFFFA000).withOpacity(0.8),
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '${weather.temperature.round()}°',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF8F00),
                  ),
                ),
              ],
            ),
          ) : const SizedBox(),
          loading: () => _buildShimmerWeather(),
          error: (_, __) => _buildErrorWeather(),
        ),
      ],
    );
  }

  Widget _buildProfileButton() {
    final profileData = ref.watch(profileProvider);
    
    return GestureDetector(
      onTap: () {
        _scaffoldKey.currentState?.openDrawer();
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
          padding: const EdgeInsets.all(2.0),
          child: profileData.when(
            data: (profile) => profile?.imageUrl != null
              ? Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    image: DecorationImage(
                      image: NetworkImage(profile!.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Center(
                    child: Text(
                      profile?.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF12B347),
                      ),
                    ),
                  ),
                ),
            loading: () => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF12B347),
                  ),
                ),
              ),
            ),
            error: (_, __) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.error_outline,
                color: Color(0xFF12B347),
              ),
            ),
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideX(begin: -0.2, end: 0);
  }

  void _showLocationDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.35,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'We use your location to provide relevant recommendations.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
              onPressed: () {
                      ref.read(locationNotifierProvider.notifier).getCurrentLocation();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.my_location),
                    label: const Text('Use Current Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
    
  void _showWeatherDetails(BuildContext context, WeatherData weather) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            // Weather content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    weather.location,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wb_sunny,
                        color: const Color(0xFFFFA000),
                        size: 32,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${weather.temperature.round()}°',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF8F00),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    weather.condition,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: InteractiveWeatherWidget(),
            ),
          ],
        ),
        ),
      );
    }
    
  Widget _buildShimmerWeather() {
    return Container(
      width: 80,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
      .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.2));
  }

  Widget _buildErrorWeather() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFCDD2).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD32F2F).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: IconButton(
        icon: const Icon(Icons.refresh, color: Color(0xFFD32F2F), size: 20),
        onPressed: () => ref.refresh(weatherProvider),
      ),
    );
  }

  void _navigateToPlanResult() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanLoadingScreen(
          selectedMoods: _selectedMoods.toList(),
          onLoadingComplete: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PlanResultScreen(
                  selectedMoods: _selectedMoods.toList(),
                  moodString: _selectedMoods.join(", "),
                  onPlanGenerated: _onPlanGenerated,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
} 