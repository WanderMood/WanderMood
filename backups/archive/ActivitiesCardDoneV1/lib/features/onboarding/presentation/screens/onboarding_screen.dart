import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandermood/features/auth/presentation/screens/login_screen.dart';
import 'package:wandermood/features/splash/application/splash_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Welcome to WanderMood',
      description: 'Your personal travel companion that adapts to your mood and preferences.',
      backgroundColor: Color(0xFFFDE5F0),
    ),
    OnboardingPage(
      title: 'Discover New Places',
      description: 'Find exciting destinations and activities based on how you feel.',
      backgroundColor: Color(0xFFE7CCEB),
    ),
    OnboardingPage(
      title: 'Plan Your Adventure',
      description: 'Get personalized recommendations and create memorable experiences.',
      backgroundColor: Color(0xFFCAE5FC),
    ),
    OnboardingPage(
      title: 'Share Your Story',
      description: 'Connect with other travelers and share your journey.',
      backgroundColor: Color(0xFFFFF4E0),
    ),
  ];

  void _nextPage() async {
    if (_currentPage < pages.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Mark onboarding as completed
      await ref.read(splashServiceProvider).setOnboardingComplete();
      
      // Navigate to login screen
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return _buildOnboardingPage(pages[index]);
            },
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? Color(0xFF12B347)
                            : Color(0xFF12B347).withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF12B347),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    _currentPage == pages.length - 1 ? 'Get Started' : 'Next',
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildOnboardingPage(OnboardingPage page) {
    return Container(
      decoration: BoxDecoration(
        color: page.backgroundColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              page.title,
              style: GoogleFonts.openSans(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A4A24),
              ),
            ),
            SizedBox(height: 16),
            Text(
              page.description,
              style: GoogleFonts.openSans(
                fontSize: 18,
                color: Color(0xFF1A4A24).withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Color _getBackgroundColorForPage(String headerText) {
    switch (headerText) {
      case 'Express mood':
        return const Color(0xFF80DEEA); // Blauw voor Mood
      case 'Plan travel':
        return const Color(0xFF455A64); // Donkergrijs voor Journey
      case 'Explore events':
        // Dit is een speciale case omdat we twee pagina's met dezelfde header hebben
        // We controleren de huidige pagina index
        return _currentPage == 3 
            ? const Color(0xFF000000) // Zwart voor Story (laatste pagina)
            : const Color(0xFF7E57C2); // Paars voor Explore (derde pagina)
      default:
        return Colors.black; // Default fallback
    }
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final Color backgroundColor;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.backgroundColor,
  });
} 