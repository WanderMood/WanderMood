import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'package:wandermood/features/auth/providers/user_provider.dart';
import 'package:wandermood/core/domain/providers/location_notifier_provider.dart';
import 'package:wandermood/features/weather/providers/weather_provider.dart';

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

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => const Center(child: Text('Profile Coming Soon'));
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
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
    if (locationState is AsyncData && locationState.value == null) {
      ref.read(locationNotifierProvider.notifier).getCurrentLocation();
    }
    
    // Start fetching weather data
    ref.read(weatherProvider);
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
                  _buildNavItem(0, Icons.home_outlined, 'Home'),
                  _buildNavItem(1, Icons.explore_outlined, 'Explore'),
                  _buildNavItem(2, Icons.local_fire_department, 'Trending'),
                  _buildNavItem(3, Icons.calendar_today_outlined, 'Agenda'),
                  _buildNavItem(4, Icons.person_outline, 'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
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