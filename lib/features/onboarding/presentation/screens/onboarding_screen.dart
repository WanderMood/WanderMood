import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandermood/features/auth/presentation/screens/login_screen.dart';
import 'package:wandermood/features/splash/application/splash_service.dart';
import 'package:go_router/go_router.dart';
import '../../../home/presentation/widgets/moody_character.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final Color backgroundColor;
  final String imagePath;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.backgroundColor,
    required this.imagePath,
  });
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Meet Moody 😄',
      subtitle: 'Your travel BFF 💬🌍',
      description: 'Moody learns what makes you tick—your vibe, your energy, your kind of day. I use all of that to craft personalized plans, made just for you.\nThink of me as your fun, curious sidekick who\'s always down to explore 🗺️ 🎈',
      backgroundColor: const Color(0xFFFFF4E0), // Cream color from image
      imagePath: 'assets/images/onboarding_mood.png',
    ),
    OnboardingPage(
      title: 'Travel by Mood 🌈',
      subtitle: 'Your Feelings, Your Journey 💭',
      description: 'Whether you\'re in a peaceful, romantic, or adventurous mood... just tell me how you feel, and I\'ll create personalized plans 🌸🏞️\nFrom hidden gems to sunset strolls—mood first, always.',
      backgroundColor: const Color(0xFFFDE5F0), // Light pink from image
      imagePath: 'assets/images/onboarding_journey.png',
    ),
    OnboardingPage(
      title: 'Your Day, Your Way ✨',
      subtitle: 'Sunrise to sunset, I\'ve got you ☀️🌙',
      description: 'Your plan is broken into moments—morning, afternoon, evening, and night.\nChoose your vibe, pick your favorites, and I\'ll handle the magic. 🧭🎯\nAll based on location, time, weather & mood.',
      backgroundColor: const Color(0xFFE7F0FF), // Light blue from image
      imagePath: 'assets/images/onboarding_explore.png',
    ),
    OnboardingPage(
      title: 'Every Day\'s a Mood 🎨',
      subtitle: 'Discover something new—every day 🌍',
      description: 'WanderMood makes every day feel like a new adventure.\nWake up, check your vibe, explore hand-picked activities 💡📍\nLet your mood lead the way—again and again.',
      backgroundColor: const Color(0xFFFFF4E0), // Cream color from image
      imagePath: 'assets/images/onboarding_story.png',
    ),
  ];

  void _nextPage() async {
    if (_currentPage < pages.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() => _isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_seen_onboarding', true);
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        context.go('/login');
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
            top: 48,
            right: 16,
            child: TextButton(
              onPressed: () => context.go('/login'),
              child: Text(
                'Skip',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
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
      child: SafeArea(
        child: Column(
          children: [
            // Image area
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    page.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      );
                    },
                  ),
                ).animate()
                  .fadeIn(duration: 800.ms)
                  .slideY(begin: 0.2, end: 0),
              ),
            ),
            // Bottom content area with padding
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.only(left: 32.0, right: 32.0, bottom: 48.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      page.title,
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                    ).animate()
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: -0.2, end: 0),
                    const SizedBox(height: 12),
                    Text(
                      page.subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                        height: 1.3,
                      ),
                    ).animate()
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: -0.1, end: 0),
                    const SizedBox(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          page.description,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.black87.withOpacity(0.7),
                            height: 1.6,
                            letterSpacing: 0.3,
                          ),
                        ).animate()
                          .fadeIn(duration: 600.ms),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: List.generate(
                            pages.length,
                            (index) => Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index 
                                  ? Colors.black.withOpacity(0.5)
                                  : Colors.black.withOpacity(0.2),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: _getButtonColor(page.backgroundColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: _nextPage,
                            icon: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getButtonColor(Color backgroundColor) {
    // Calculate a contrasting color based on the background
    final brightness = backgroundColor.computeLuminance();
    if (brightness > 0.5) {
      return Colors.black.withOpacity(0.8);
    } else {
      return Colors.white.withOpacity(0.8);
    }
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