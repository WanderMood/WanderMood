import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../home/presentation/widgets/moody_character.dart';

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
  late final FlutterTts _flutterTts;
  double _budgetValue = 2;
  bool _showSparkles = false;

  final List<Map<String, dynamic>> _budgetLevels = [
    {
      'label': 'Budget-Friendly',
      'emoji': '💰',
      'description': 'Affordable adventures and hidden gems',
      'color': const Color(0xFF4CAF50),
    },
    {
      'label': 'Mid-Range',
      'emoji': '💳',
      'description': 'Balance of value and experience',
      'color': const Color(0xFF2196F3),
    },
    {
      'label': 'Premium',
      'emoji': '✨',
      'description': 'Luxury experiences and exclusive spots',
      'color': const Color(0xFF9C27B0),
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
      duration: const Duration(milliseconds: 300),
    );
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _initializeTts();
    _startAnimation();
  }

  void _initializeTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setVoice({
      "name": "com.apple.ttsbundle.Moira-compact",
      "locale": "en-US"
    });
    await _flutterTts.setSpeechRate(0.9);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
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
    await _flutterTts.speak(message);
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
  }

  Future<void> _speakBudgetMessage() async {
    String message;
    if (_budgetValue <= 1) {
      message = "Smart choice! I know some amazing hidden gems that won't break the bank!";
    } else if (_budgetValue <= 2) {
      message = "Perfect balance! We'll mix comfort with some special experiences!";
    } else {
      message = "Ooh, fancy! Let's make your trip extra special with some luxury touches!";
    }
    await _flutterTts.speak(message);
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
    _flutterTts.stop();
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
              Color(0xFFFFAFF4), // Pink
              Color(0xFFFFF5AF), // Yellow
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
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
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _currentBudgetColor.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentBudgetEmoji,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _currentBudgetLabel,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: _currentBudgetColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(_descriptionController),
                            child: FadeTransition(
                              opacity: _descriptionController,
                              child: Text(
                                _currentBudgetDescription,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: _currentBudgetColor,
                              inactiveTrackColor: Colors.grey.withOpacity(0.2),
                              thumbColor: _currentBudgetColor,
                              overlayColor: _currentBudgetColor.withOpacity(0.2),
                              trackHeight: 8,
                              thumbShape: _CustomSliderThumb(
                                color: _currentBudgetColor,
                                showSparkle: _showSparkles,
                                sparkleController: _sparkleController,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 24,
                              ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Slider(
                                  value: _budgetValue,
                                  min: 1,
                                  max: 3,
                                  divisions: 2,
                                  onChanged: _toggleBudgetLevel,
                                  onChangeEnd: (value) {
                                    setState(() {
                                      _showSparkles = false;
                                    });
                                  },
                                ),
                                if (_showSparkles)
                                  Positioned(
                                    left: (_budgetValue - 1) * (MediaQuery.of(context).size.width - 96) / 2,
                                    child: FadeTransition(
                                      opacity: Tween<double>(
                                        begin: 1.0,
                                        end: 0.0,
                                      ).animate(_sparkleController),
                                      child: const Icon(
                                        Icons.auto_awesome,
                                        color: Colors.amber,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: _budgetLevels.map((level) => Text(
                              level['emoji'],
                              style: const TextStyle(fontSize: 24),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
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