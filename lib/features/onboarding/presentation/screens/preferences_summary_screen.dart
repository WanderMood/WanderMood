import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../home/presentation/widgets/moody_character.dart';

class PreferencesSummaryScreen extends ConsumerStatefulWidget {
  const PreferencesSummaryScreen({super.key});

  @override
  ConsumerState<PreferencesSummaryScreen> createState() => _PreferencesSummaryScreenState();
}

class _PreferencesSummaryScreenState extends ConsumerState<PreferencesSummaryScreen> 
    with TickerProviderStateMixin {
  late final AnimationController _moodyController;
  late final AnimationController _cardsController;

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

    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    _moodyController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _cardsController.forward();
  }

  @override
  void dispose() {
    _moodyController.dispose();
    _cardsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                                  'Your Travel Profile ✨',
                                  style: GoogleFonts.museoModerno(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF5BB32A),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Here\'s what makes your journey unique',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.black87,
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
                        title: 'Mood & Vibes',
                        icon: Icons.mood,
                        color: const Color(0xFF9C27B0),
                        content: [
                          _buildChip('Adventurous 🏃‍♂️', const Color(0xFF7CB342)),
                          _buildChip('Cultural 🎭', const Color(0xFFEC407A)),
                          _buildChip('Romantic 💑', const Color(0xFF9575CD)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      _buildPreferenceCard(
                        title: 'Travel Interests',
                        icon: Icons.explore,
                        color: const Color(0xFF2196F3),
                        content: [
                          _buildChip('Stays & Getaways 🏠', const Color(0xFFFF80AB)),
                          _buildChip('Arts & Culture 🎨', const Color(0xFFB39DDB)),
                          _buildChip('Shopping & Markets 🛍️', const Color(0xFF90CAF9)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      _buildPreferenceCard(
                        title: 'Budget Style',
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
                      const SizedBox(height: 16),
                      
                      _buildPreferenceCard(
                        title: 'Travel Style',
                        icon: Icons.card_travel,
                        color: const Color(0xFFF57C00),
                        content: [
                          _buildChip('Planned 📅', const Color(0xFF64B5F6)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Create Account Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.go('/auth/signup'),
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
                            'Create Your Account',
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
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: color.withOpacity(0.8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPreferenceCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> content,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.2, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _cardsController,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: _cardsController,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: content,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SwirlingGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFFFDF5).withOpacity(0.1),
          const Color(0xFFFFF3E0).withOpacity(0.1),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final numberOfCurves = 5;
    final curveHeight = size.height / numberOfCurves;

    for (var i = 0; i < numberOfCurves; i++) {
      final startY = i * curveHeight;
      path.moveTo(0, startY);
      
      for (var x = 0.0; x <= size.width; x += 1) {
        final relativeX = x / size.width;
        final amplitude = curveHeight * 0.3;
        final frequency = 2 * math.pi * (i + 1);
        final phase = i * math.pi / 3;
        
        final y = startY + amplitude * math.sin(frequency * relativeX + phase);
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 