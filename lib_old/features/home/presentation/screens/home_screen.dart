import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/domain/providers/auth_provider.dart';
import '../../../../features/auth/presentation/screens/login_screen.dart';
import '../../../../features/mood/presentation/pages/mood_page.dart';
import '../../../../features/recommendations/presentation/pages/recommendations_page.dart';
import '../../../../features/weather/presentation/pages/weather_page.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const RecommendationsPage(),
    const MoodPage(),
    const WeatherPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.travel_explore),
            label: 'Aanbevelingen',
          ),
          NavigationDestination(
            icon: Icon(Icons.mood),
            label: 'Mood',
          ),
          NavigationDestination(
            icon: Icon(Icons.wb_sunny),
            label: 'Weer',
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text('WanderMood'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).signOut();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
} 