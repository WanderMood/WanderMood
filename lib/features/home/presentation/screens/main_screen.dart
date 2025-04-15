import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
// Import home screen content/widgets but not the HomeScreen itself
import 'package:wandermood/core/presentation/widgets/swirl_background.dart';
import 'package:wandermood/features/auth/providers/user_provider.dart';
import 'package:wandermood/core/domain/providers/location_notifier_provider.dart';
import 'package:wandermood/features/weather/providers/weather_provider.dart';
import 'package:wandermood/features/profile/presentation/screens/profile_screen.dart';
import 'package:wandermood/features/home/presentation/widgets/moody_character.dart';
import 'explore_screen.dart';

// Home content widget to replace direct HomeScreen usage
class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userDataProvider).maybeWhen(
      data: (data) => data?['name'] ?? 'Friend',
      orElse: () => 'Friend',
    );
    
    final locationState = ref.watch(locationNotifierProvider);
    final location = locationState.city ?? 'Select Location';

    return Container(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'WanderMood',
                    style: GoogleFonts.museoModerno(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF12B347),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: const Color(0xFF12B347),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF12B347),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Welcome Message
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Text(
                'Welcome, $userName!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.1, end: 0),
            ),
            
            // Moody Character
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: MoodyCharacter(
                  size: 150,
                  mood: 'default',
                ).animate(
                  onPlay: (controller) => controller.repeat(),
                ).scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.05, 1.05),
                  duration: const Duration(milliseconds: 2000),
                  curve: Curves.easeInOut,
                ),
              ),
            ),
            
            // Call to Action Button
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF12B347),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Start Exploring',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

// Placeholder screens for other sections
class TrendingScreen extends ConsumerWidget {
  const TrendingScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => const Center(child: Text('Trending Coming Soon'));
}

class AgendaScreen extends ConsumerWidget {
  const AgendaScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => const Center(child: Text('Agenda Coming Soon'));
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(), // Use HomeContent instead of HomeScreen
    const ExploreScreen(),
    const TrendingScreen(),
    const AgendaScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    // Initialize data after frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }
  
  void _initializeData() {
    // Start listening to user data
    ref.read(userDataProvider);
    
    // Initialize location if not already set
    final locationState = ref.read(locationNotifierProvider);
    if (locationState.currentLatitude == null || locationState.currentLongitude == null) {
      ref.read(locationNotifierProvider.notifier).getCurrentLocation();
    }
    
    // Start fetching weather data
    ref.read(weatherProvider);
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationNotifierProvider);
    
    if (locationState.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing...'),
          ],
        ),
      );
    }
    
    if (locationState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: ${locationState.error}'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(locationNotifierProvider.notifier).retryLocationAccess();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (!locationState.hasLocation) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Getting your location...'),
          ],
        ),
      );
    }
    
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
} 