import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import '../../../home/presentation/widgets/moody_character.dart';
import '../../../../core/providers/preferences_provider.dart';
import '../../../../core/services/tts_service.dart';

class SwirlingGradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Create flowing wave gradients with maximum opacity
    final Paint wavePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFFFDF5).withOpacity(0.95),  // Increased from 0.8
          const Color(0xFFFFF3E0).withOpacity(0.85),  // Increased from 0.7
          const Color(0xFFFFF9E8).withOpacity(0.75),  // Increased from 0.6
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Create accent wave paint with higher opacity
    final Paint accentPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          const Color(0xFFFFF3E0).withOpacity(0.85),  // Increased from 0.7
          const Color(0xFFFFF9E8).withOpacity(0.75),  // Increased from 0.6
          const Color(0xFFFFFDF5).withOpacity(0.65),  // Increased from 0.5
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

class BudgetPreferenceScreen extends ConsumerStatefulWidget {
  const BudgetPreferenceScreen({super.key});

  @override
  ConsumerState<BudgetPreferenceScreen> createState() => _BudgetPreferenceScreenState();
}

class _BudgetPreferenceScreenState extends ConsumerState<BudgetPreferenceScreen> with TickerProviderStateMixin {
  late final AnimationController _moodyController;
  late final AnimationController _messageController;
  late final AnimationController _descriptionController;
  late final AnimationController _backgroundController;
  late final AnimationController _sparkleController;
  final TTSService _ttsService = TTSService();
  double _budgetValue = 1.0;
  bool _showSparkles = false;

  final List<Map<String, dynamic>> _budgetLevels = [
    {
      'label': 'Budget-Friendly',
      'emoji': '💰',
      'description': 'Cool plans, low spend — think secret spots, street food, and budget gems',
      'color': const Color(0xFF7CB342), // Softer Green
    },
    {
      'label': 'Mid-Range',
      'emoji': '💳',
      'description': 'A sweet balance — cozy stays, tasty eats, and great experiences without the splurge',
      'color': const Color(0xFF64B5F6), // Softer Blue
    },
    {
      'label': 'Premium',
      'emoji': '✨',
      'description': 'Think luxury hotels, rooftop dinners, spa time, and that "treat yourself" energy',
      'color': const Color(0xFFEC407A), // Softer Pink
    },
  ];

  @override
  void initState() {
    super.initState();
    _moodyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _messageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _descriptionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _initializeTts();
    _startAnimation();
  }

  void _initializeTts() async {
    await _ttsService.initialize();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _moodyController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _messageController.forward();
    _speakMessage();
  }

  Future<void> _speakMessage() async {
    const message = "Let's talk about your ideal budget range";
    await _ttsService.speak(message);
  }

  void _toggleBudgetLevel(double value) {
    final previousValue = _budgetValue;
    setState(() {
      _budgetValue = value;
      // Show sparkles when crossing threshold
      _showSparkles = (previousValue.floor() != value.floor());
    });
    if (_showSparkles) {
      _sparkleController.forward(from: 0);
    }
    _descriptionController.forward(from: 0);
    _speakBudgetMessage();
    
    // Update the preferences provider
    String budgetLevel;
    if (value <= 1) {
      budgetLevel = 'Budget-Friendly';
    } else if (value <= 2) {
      budgetLevel = 'Mid-Range';
    } else {
      budgetLevel = 'Premium';
    }
    ref.read(preferencesProvider.notifier).updateBudgetLevel(budgetLevel);
  }

  Future<void> _speakBudgetMessage() async {
    String message;
    if (_budgetValue <= 1) {
      message = "Nice! I'll show you the coolest hidden spots and local favorites that won't break the bank!";
    } else if (_budgetValue <= 2) {
      message = "Perfect balance! We'll mix comfort with amazing experiences while keeping it budget-smart!";
    } else {
      message = "Ooh, fancy! Get ready for some seriously luxurious experiences and VIP treatment!";
    }
    await _ttsService.speak(message);
  }

  String get _currentBudgetLabel {
    if (_budgetValue <= 1) return _budgetLevels[0]['label'];
    if (_budgetValue <= 2) return _budgetLevels[1]['label'];
    return _budgetLevels[2]['label'];
  }

  String get _currentBudgetDescription {
    if (_budgetValue <= 1) return _budgetLevels[0]['description'];
    if (_budgetValue <= 2) return _budgetLevels[1]['description'];
    return _budgetLevels[2]['description'];
  }

  String get _currentBudgetEmoji {
    if (_budgetValue <= 1) return _budgetLevels[0]['emoji'];
    if (_budgetValue <= 2) return _budgetLevels[1]['emoji'];
    return _budgetLevels[2]['emoji'];
  }

  Color get _currentBudgetColor {
    if (_budgetValue <= 1) return _budgetLevels[0]['color'];
    if (_budgetValue <= 2) return _budgetLevels[1]['color'];
    return _budgetLevels[2]['color'];
  }

  @override
  void dispose() {
    _moodyController.dispose();
    _messageController.dispose();
    _descriptionController.dispose();
    _backgroundController.dispose();
    _sparkleController.dispose();
    _ttsService.dispose();
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
              Color(0xFFFFF8E1), // Even softer warm yellow
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background waves
              Positioned.fill(
                child: CustomPaint(
                  painter: SwirlingGradientPainter(),
                ),
              ),

              // Floating background elements
              ...List.generate(10, (index) {
                final isEven = index.isEven;
                return Positioned(
                  left: (MediaQuery.of(context).size.width / 10) * index,
                  top: (MediaQuery.of(context).size.height / 8) * (index % 4),
                  child: RotationTransition(
                    turns: Tween(begin: 0.0, end: isEven ? 1.0 : -1.0)
                      .animate(_backgroundController),
                    child: FadeTransition(
                      opacity: Tween(begin: 0.3, end: 0.7)
                        .animate(_backgroundController),
                      child: Icon(
                        isEven ? Icons.star : Icons.monetization_on,
                        size: isEven ? 24 : 32,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ),
                );
              }),

              // Progress indicator
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(3, (index) => Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5BB32A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5BB32A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.2),
                        end: Offset.zero,
                      ).animate(_messageController),
                      child: FadeTransition(
                        opacity: _messageController,
                        child: Text(
                          'Budget preferences 💫',
                          style: GoogleFonts.museoModerno(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5BB32A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.2),
                        end: Offset.zero,
                      ).animate(_messageController),
                      child: FadeTransition(
                        opacity: _messageController,
                        child: Text(
                          'Let\'s talk about your ideal budget range',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _budgetLevels.length,
                        itemBuilder: (context, index) {
                          final level = _budgetLevels[index];
                          final isSelected = _budgetValue == index + 1;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _budgetValue = index + 1.0;
                                  _showSparkles = true;
                                });
                                _speakBudgetMessage();
                                _sparkleController.forward(from: 0);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSelected
                                    ? level['color'].withOpacity(0.85)
                                    : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                      ? level['color']
                                      : Colors.grey.withOpacity(0.3),
                                    width: isSelected ? 2 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                        ? level['color'].withOpacity(0.4)
                                        : Colors.black.withOpacity(0.05),
                                      blurRadius: 12,
                                      spreadRadius: isSelected ? 2 : 0,
                                      offset: Offset(0, isSelected ? 2 : 4),
                                    ),
                                    if (isSelected)
                                      BoxShadow(
                                        color: level['color'].withOpacity(0.2),
                                        blurRadius: 20,
                                        spreadRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                            ? Colors.white.withOpacity(0.2)
                                            : level['color'].withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Center(
                                          child: Text(
                                            level['emoji'],
                                            style: const TextStyle(fontSize: 32),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              level['label'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: isSelected
                                                  ? Colors.white
                                                  : Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              level['description'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: isSelected
                                                  ? Colors.white.withOpacity(0.9)
                                                  : Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check,
                                            color: level['color'],
                                            size: 16,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/preferences/style'),
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
                          'Continue',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Moody character
              Positioned(
                right: 20,
                bottom: MediaQuery.of(context).size.height * 0.08,
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.5,
                    end: 1.0,
                  ).animate(_moodyController),
                  child: const MoodyCharacter(
                    size: 120,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomSliderThumb extends SliderComponentShape {
  final Color color;
  final bool showSparkle;
  final AnimationController sparkleController;

  const _CustomSliderThumb({
    required this.color,
    required this.showSparkle,
    required this.sparkleController,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(28, 28);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Draw main circle
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 14, paint);

    // Draw sparkle icon
    const sparkleIcon = Icons.star;
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(sparkleIcon.codePoint),
        style: TextStyle(
          fontSize: 16,
          fontFamily: sparkleIcon.fontFamily,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    // Draw glow effect when showing sparkles
    if (showSparkle) {
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawCircle(center, 18, glowPaint);
    }
  }
} 