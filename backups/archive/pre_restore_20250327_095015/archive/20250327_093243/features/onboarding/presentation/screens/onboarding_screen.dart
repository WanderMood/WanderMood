import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/splash/application/splash_service.dart';
import '../widgets/onboarding_content.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _navigateToLogin() async {
    // Mark onboarding as complete
    await ref.read(splashServiceProvider).setOnboardingComplete();
    if (!mounted) return;
    
    // Navigate to login
    GoRouter.of(context).go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page content
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: 4,
            itemBuilder: (context, index) {
              return OnboardingContent(
                pageIndex: index,
                isActive: index == _currentPage,
              );
            },
          ),

          // Bottom navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.only(bottom: 50),
              child: Column(
                children: [
                  // Page indicator
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _currentPage == 3 ? 0.0 : 1.0,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: 4,
                        effect: WormEffect(
                          dotColor: Colors.white.withOpacity(0.5),
                          activeDotColor: Colors.white,
                          dotHeight: 8,
                          dotWidth: 8,
                          spacing: 8,
                        ),
                      ),
                    ),
                  ),

                  // Get Started button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_currentPage < 3) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _navigateToLogin();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage < 3 ? 'Get Started' : 'Get Started',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 