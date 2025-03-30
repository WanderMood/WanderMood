import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../home/presentation/widgets/moody_character.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/services/tts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SwirlingGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Create flowing wave gradients with maximum opacity
    final Paint wavePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFFFDF5).withOpacity(0.95),  // Warm cream yellow
          const Color(0xFFFFF3E0).withOpacity(0.85),  // Slightly darker warm yellow
          const Color(0xFFFFF9E8).withOpacity(0.75),  // Medium warm yellow
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Create accent wave paint with higher opacity
    final Paint accentPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          const Color(0xFFFFF3E0).withOpacity(0.85),  // Slightly darker warm yellow
          const Color(0xFFFFF9E8).withOpacity(0.75),  // Medium warm yellow
          const Color(0xFFFFFDF5).withOpacity(0.65),  // Warm cream yellow
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final Path mainWavePath = Path();
    final Path accentWavePath = Path();

    // Create multiple flowing wave layers with larger amplitude
    for (int i = 0; i < 3; i++) {
      double amplitude = size.height * 0.12;  // Increased from 0.08
      double frequency = math.pi / (size.width * 0.4);  // Adjusted for wider waves
      double verticalOffset = size.height * (0.2 + i * 0.3);

      mainWavePath.moveTo(0, verticalOffset);
      
      // Create more pronounced flowing wave
      for (double x = 0; x <= size.width; x += 4) {  // Decreased step for smoother waves
        double y = verticalOffset + 
                   math.sin(x * frequency + i) * amplitude +
                   math.cos(x * frequency * 0.5) * amplitude * 0.9;  // Increased from 0.7
        
        if (x == 0) {
          mainWavePath.moveTo(x, y);
        } else {
          mainWavePath.lineTo(x, y);
        }
      }

      // Create accent waves with larger amplitude
      amplitude = size.height * 0.09;  // Increased from 0.06
      verticalOffset = size.height * (0.1 + i * 0.3);
      
      for (double x = 0; x <= size.width; x += 4) {  // Decreased step for smoother waves
        double y = verticalOffset + 
                   math.sin(x * frequency * 1.5 + i + math.pi) * amplitude +
                   math.cos(x * frequency * 0.7) * amplitude * 1.2;  // Increased multiplier
        
        if (x == 0) {
          accentWavePath.moveTo(x, y);
        } else {
          accentWavePath.lineTo(x, y);
        }
      }
    }

    // Create more pronounced flowing curves
    for (int i = 0; i < 2; i++) {
      double startY = size.height * (0.3 + i * 0.4);
      double controlY = size.height * (0.1 + i * 0.4);  // Lower control point for more curve
      
      mainWavePath.moveTo(0, startY);
      mainWavePath.quadraticBezierTo(
        size.width * 0.5,
        controlY,
        size.width,
        startY
      );
    }

    // Add larger dots along the waves
    for (int i = 0; i < 15; i++) {  // Increased number of dots
      double x = size.width * (i / 15);
      double y = size.height * (0.3 + math.sin(i * 0.8) * 0.25);  // Increased amplitude
      
      canvas.drawCircle(
        Offset(x, y),
        5,  // Increased from 4
        wavePaint
      );
    }

    // Draw all elements with stronger blur effect
    canvas.drawPath(mainWavePath, wavePaint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));  // Increased from 4
    canvas.drawPath(accentWavePath, accentPaint..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));  // Increased from 3
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PreferencesSummaryScreen extends ConsumerStatefulWidget {
  const PreferencesSummaryScreen({super.key});

  @override
  ConsumerState<PreferencesSummaryScreen> createState() => _PreferencesSummaryScreenState();
}

class _PreferencesSummaryScreenState extends ConsumerState<PreferencesSummaryScreen> 
    with TickerProviderStateMixin {
  late final AnimationController _moodyController;
  late final AnimationController _cardsController;
  late final AnimationController _loadingController;
  final TTSService _ttsService = TTSService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _moodyController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _cardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    _moodyController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _cardsController.forward();
    
    // Initialize TTS
    await _ttsService.initialize();

    // Simulate loading
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      _speakSummary();
    }
  }

  Future<void> _speakSummary() async {
    if (!mounted) return;
    const message = "Perfect! I've got your preferences ready. Let's make your journey amazing!";
    await _ttsService.speak(message);
  }

  @override
  void dispose() {
    _moodyController.dispose();
    _cardsController.dispose();
    _loadingController.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFDF5), // Warm cream yellow
              Color(0xFFFFF3E0), // Slightly darker warm yellow
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background swirl effect
              Positioned.fill(
                child: CustomPaint(
                  painter: SwirlingGradientPainter(),
                ),
              ),

              // Main content
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      // Title section with Moody
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '🧳 Your Travel Profile',
                                  style: GoogleFonts.museoModerno(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF5BB32A), // Matching CTA button color
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Here\'s what I\'ve learned about your vibe so far—looks pretty awesome if you ask me 😎',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Moody positioned in the top-right
                          ScaleTransition(
                            scale: Tween<double>(
                              begin: 0.5,
                              end: 1.0,
                            ).animate(_moodyController),
                            child: const MoodyCharacter(
                              size: 80, // Reduced size
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Preference Cards
                      _buildPreferenceCard(
                        title: 'Your Current Vibe',
                        subtitle: 'How you like to feel as you explore',
                        icon: Icons.mood,
                        color: const Color(0xFF9C27B0),
                        content: [
                          _buildChip('Adventurous 🏃‍♂️', const Color(0xFF7CB342)),
                          _buildChip('Cultural 👥', const Color(0xFFEC407A)),
                          _buildChip('Romantic', const Color(0xFF9575CD)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      _buildPreferenceCard(
                        title: 'Things That Spark Your Curiosity',
                        subtitle: 'Stuff that catches your eye',
                        icon: Icons.search,
                        color: const Color(0xFF2196F3),
                        content: [
                          _buildChip('Stays & Getaways 🏠', const Color(0xFFFF80AB)),
                          _buildChip('Arts & Culture 🎨', const Color(0xFFB39DDB)),
                          _buildChip('Shopping & Markets 🛍️', const Color(0xFF90CAF9)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      _buildPreferenceCard(
                        title: 'How You Like to Spend',
                        subtitle: 'We\'ll match the vibe to your wallet',
                        icon: Icons.account_balance_wallet,
                        color: const Color(0xFF4CAF50),
                        content: [
                          _buildChip('Mid-Range ⭐', const Color(0xFFFFA726)),
                          const SizedBox(height: 8),
                          Text(
                            'Balance of value and unique experiences',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Bottom message
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                            children: const [
                              TextSpan(
                                text: 'You\'ve got great taste! I\'m cooking up something unforgettable ',
                              ),
                              TextSpan(
                                text: '💡',
                                style: TextStyle(fontSize: 18),
                              ),
                              TextSpan(
                                text: ' Ready to see where it takes you?',
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Create Account Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            // Save preferences before navigation
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('has_seen_onboarding', true);
                            if (mounted) {
                              context.go('/auth/signup');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5BB32A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Let\'s Set You Up! 📝',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPreferenceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<Widget> content,
  }) {
    // Define glassy gradient colors for each card type
    List<Color> gradientColors;
    Color overlayColor;
    
    switch (color.value) {
      case 0xFF9C27B0: // Lavender for Mood & Vibes
        gradientColors = [
          const Color(0xFFE1BEE7).withOpacity(0.95),
          const Color(0xFFD1C4E9).withOpacity(0.85),
        ];
        overlayColor = const Color(0xFF9575CD);
        break;
      case 0xFF2196F3: // Light Yellow for Travel Interests
        gradientColors = [
          const Color(0xFFFFF9C4).withOpacity(0.95),
          const Color(0xFFFFF59D).withOpacity(0.85),
        ];
        overlayColor = const Color(0xFFFBC02D);
        break;
      case 0xFF4CAF50: // Orange for Budget
        gradientColors = [
          const Color(0xFFFFCCBC).withOpacity(0.95),
          const Color(0xFFFFAB91).withOpacity(0.85),
        ];
        overlayColor = const Color(0xFFFF7043);
        break;
      default:
        gradientColors = [color.withOpacity(0.95), color.withOpacity(0.85)];
        overlayColor = color;
    }

    return Transform.translate(
      offset: const Offset(0, -2), // Subtle floating effect
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: overlayColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: overlayColor.withOpacity(0.15),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              blurRadius: 12,
              spreadRadius: -2,
              offset: const Offset(0, -2),
            ),
            BoxShadow(
              color: overlayColor.withOpacity(0.1),
              blurRadius: 1,
              spreadRadius: 0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: overlayColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: overlayColor.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: overlayColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: content,
            ),
          ],
        ),
      ),
    );
  }
} 