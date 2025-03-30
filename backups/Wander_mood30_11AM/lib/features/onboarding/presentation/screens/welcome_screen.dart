import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../../home/presentation/widgets/moody_character.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vector_math/vector_math.dart' as vector;
import 'package:confetti/confetti.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> with TickerProviderStateMixin {
  late final AnimationController _moodyController;
  late final ConfettiController _confettiController;
  late final FlutterTts _flutterTts;
  bool _isSpeaking = false;
  bool _isPressed = false;
  late final AnimationController _bubbleAnimationController;
  late final Animation<double> _bubbleScaleAnimation;
  late final Animation<double> _bubbleBounceAnimation;

  late final AnimationController _messageController;
  late final Animation<double> _messageSlideAnimation;
  late final Animation<double> _messageOpacityAnimation;
  int _currentMessageIndex = -1;
  bool _isMessageVisible = false;

  final List<String> _messages = [
    'Hey you, I\'m Moody! 😊',
    'I\'ll help plan your perfect day, based on your vibe.',
    'Let\'s walk through a few quick steps to get started.',
    'Sound good? Let\'s go! 🎯',
  ];

  // Add new state variable
  bool _isReadyForNextStep = false;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _moodyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 500),
    );

    _initializeTts();
    
    _messageController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _messageSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _messageController,
      curve: Curves.easeOutQuad,
    ));

    _messageOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _messageController,
      curve: Curves.easeInOut,
    ));

    // Start the animation sequence
    _startAnimationSequence();

    _bubbleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bubbleScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 60.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40.0,
      ),
    ]).animate(_bubbleAnimationController);

    _bubbleBounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -4.0)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -4.0, end: 0.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50.0,
      ),
    ]).animate(_bubbleAnimationController);

    // Start bubble animation after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      _bubbleAnimationController.forward();
    });

    // Initialize pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_pulseController);
  }

  Future<void> _startAnimationSequence() async {
    debugPrint('Starting animation sequence');
    // First, let Moody appear
    await Future.delayed(const Duration(milliseconds: 300));
    await _moodyController.forward();
    _confettiController.play();
    
    // Start showing messages first
    _showNextMessage();
    
    // Slight delay before starting speech
    await Future.delayed(const Duration(milliseconds: 500));
    // Then start speech
    await _speakWelcomeMessage();
  }

  Future<void> _showNextMessage() async {
    if (_currentMessageIndex >= _messages.length - 1) {
      setState(() {
        _isReadyForNextStep = true;
        _pulseController.repeat();  // Start pulsing when last message is shown
      });
      return;
    }

    // Show next message without hiding the current one
    _currentMessageIndex++;
    setState(() {
      _isMessageVisible = true;
    });
    
    // Reset and forward the animation controller for the new message
    await _messageController.forward(from: 0);

    // Show next message after a shorter delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (_currentMessageIndex < _messages.length - 1) {
      _showNextMessage();
    } else {
      // Enable button after the last message
      setState(() {
        _isReadyForNextStep = true;
        _pulseController.repeat();
      });
    }
  }

  void _initializeTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('en-US');
    _flutterTts.setSpeechRate(0.4);  // Slower speech rate for better sync
    _flutterTts.setVolume(1.0);
  }

  Future<void> _speakWelcomeMessage() async {
    const message = "Hey you, I'm Moody! I'll help plan your perfect day, based on your vibe. Let's walk through a few quick steps to get started. Sound good? Let's go!";
    setState(() => _isSpeaking = true);
    await _flutterTts.speak(message);
    setState(() {
      _isSpeaking = false;
    });
  }

  @override
  void dispose() {
    _moodyController.dispose();
    _confettiController.dispose();
    _flutterTts.stop();
    _bubbleAnimationController.dispose();
    _messageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background container with warm yellow gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFFDF5), // Lighter warm cream yellow
                  Color(0xFFFFF9E8), // Lighter warm yellow
                ],
              ),
            ),
          ),
          // Subtle swirl gradient overlay
          CustomPaint(
            size: Size.infinite,
            painter: SwirlingGradientPainter(),
          ),
          // Main content
          Container(
            child: Stack(
              children: [
                // Confetti
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirection: math.pi / 2,
                    maxBlastForce: 5,
                    minBlastForce: 2,
                    emissionFrequency: 0.05,
                    numberOfParticles: 50,
                    gravity: 0.1,
                    colors: const [
                      Color(0xFFFFE074), // Vibrant yellow
                      Color(0xFFA4D4FF), // Sky blue
                      Color(0xFFFFB199), // Coral
                      Color(0xFF9747FF), // Purple
                    ],
                  ),
                ),
                
                SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            // Welcome Text with MuseoModerno
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                children: [
                                  Text(
                                    'Welcome to',
                                    style: GoogleFonts.museoModerno(
                                      fontSize: 48,  // Increased font size
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF5BB32A),
                                      letterSpacing: -0.5,
                                      height: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),  // Small gap between lines
                                  Text(
                                    'WanderMood',
                                    style: GoogleFonts.museoModerno(
                                      fontSize: 52,  // Even larger for emphasis
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF5BB32A),
                                      letterSpacing: -0.5,
                                      height: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 40),
                            
                            // Message Area with Moody
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Messages Container aligned to the left
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.5, // Increased height
                                  margin: EdgeInsets.only(
                                    left: 24,
                                    right: 24,
                                    top: 20,
                                    bottom: 20,
                                  ),
                                  child: ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _currentMessageIndex + 1,
                                    itemBuilder: (context, index) {
                                      return _buildMessageBubble(index);
                                    },
                                  ),
                                ),
                                
                                // Moody Character positioned on top of bubbles
                                Positioned(
                                  bottom: -40,
                                  right: 20,
                                  child: Transform.translate(
                                    offset: const Offset(-20, 0),
                                    child: ScaleTransition(
                                      scale: Tween<double>(begin: 0.5, end: 1.0).animate(
                                        CurvedAnimation(
                                          parent: _moodyController,
                                          curve: Curves.elasticOut,
                                        ),
                                      ),
                                      child: FadeTransition(
                                        opacity: _moodyController,
                                        child: MoodyCharacter(
                                          size: 160, // Increased size
                                          mood: _isSpeaking ? 'speaking' : 'default',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Bottom Section with CTA Button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        margin: const EdgeInsets.only(bottom: 32),
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _isReadyForNextStep ? _pulseAnimation.value : 1.0,
                              child: Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF5BB32A).withOpacity(_isReadyForNextStep ? 0.3 : 0.1),
                                      offset: const Offset(0, 4),
                                      blurRadius: 12,
                                      spreadRadius: _isReadyForNextStep ? _pulseAnimation.value * 2 : 2,
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isReadyForNextStep 
                                    ? () {
                                        debugPrint('Button pressed, navigating...');
                                        context.go('/preferences/location');
                                      }
                                    : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isReadyForNextStep 
                                      ? const Color(0xFF5BB32A)
                                      : const Color(0xFF5BB32A).withOpacity(0.5),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    elevation: _isReadyForNextStep ? 4 : 0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'I\'m ready, let\'s go',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: _isReadyForNextStep ? Colors.white : Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 24,
                                        color: _isReadyForNextStep ? Colors.white : Colors.white.withOpacity(0.7),
                                      ).animate(
                                        target: _isReadyForNextStep ? 1 : 0,
                                        onComplete: (controller) => _isReadyForNextStep ? controller.repeat() : null,
                                      ).slideX(
                                        begin: 0,
                                        end: 0.3,
                                        duration: const Duration(seconds: 1),
                                        curve: Curves.easeInOut,
                                      ).then()
                                      .slideX(
                                        begin: 0.3,
                                        end: 0,
                                        duration: const Duration(seconds: 1),
                                        curve: Curves.easeInOut,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble([int? messageIndex]) {
    final index = messageIndex ?? _currentMessageIndex;
    if (index < 0 || index >= _messages.length) return const SizedBox.shrink();
    
    // Define bubble colors based on index
    final List<Color> bubbleColors = [
      const Color(0xFFA4D4FF), // Sky blue
      const Color(0xFFFFB199), // Coral
      const Color(0xFFFFE074), // Yellow
      const Color(0xFF9747FF), // Purple
    ];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: AnimatedBuilder(
        animation: _messageController,
        builder: (context, child) {
          final isCurrentMessage = index == _currentMessageIndex;
          final offset = isCurrentMessage ? -_messageSlideAnimation.value : 0.0;
          final opacity = isCurrentMessage ? _messageOpacityAnimation.value : 1.0;
          
          return Transform.translate(
            offset: Offset(offset, 0),
            child: Opacity(
              opacity: opacity,
              child: Container(
                margin: const EdgeInsets.only(right: 48),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 48),
                      child: GlassmorphicContainer(
                        width: index == 2 ? 380 : 340,
                        height: _getMessageHeight(index),
                        borderRadius: 24,
                        blur: 10,
                        border: 1.5,
                        linearGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            bubbleColors[index % bubbleColors.length].withOpacity(0.9),
                            bubbleColors[index % bubbleColors.length].withOpacity(0.8),
                          ],
                        ),
                        borderGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.8),
                            bubbleColors[index % bubbleColors.length].withOpacity(0.3),
                          ],
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: _getMessagePadding(index),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: bubbleColors[index % bubbleColors.length].withOpacity(0.3),
                                offset: const Offset(0, 8),
                                blurRadius: 20,
                                spreadRadius: -2,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.9),
                                offset: const Offset(0, -1),
                                blurRadius: 4,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            _messages[index],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: const Color(0xFF1E4D4B),
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ),
                    // Add floating effect animation
                    if (isCurrentMessage)
                      Positioned(
                        bottom: -15,
                        left: 20,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: bubbleColors[index % bubbleColors.length].withOpacity(0.9),
                            boxShadow: [
                              BoxShadow(
                                color: bubbleColors[index % bubbleColors.length].withOpacity(0.3),
                                offset: const Offset(0, 4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ).animate(
      onComplete: (controller) => controller.repeat(reverse: true),
    ).moveY(
      begin: 0,
      end: -4,
      duration: const Duration(seconds: 2),
      curve: Curves.easeInOut,
    );
  }

  double _getMessageHeight(int index) {
    // Adjust height based on content length
    if (index == 2) return 90;  // Longer message
    if (index == 3) return 60;  // Last message
    return 60;  // Default height
  }

  double _getMessagePadding(int index) {
    // Adjust padding based on content
    if (index == 2) return 16;  // Longer message
    return 12;  // Default padding
  }

  Widget _buildEnhancedFeatureCard(String title, IconData icon, Color color) {
    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              width: 125,
              height: 125,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: GlassmorphicContainer(
                width: 125,
                height: 125,
                borderRadius: 16,
                blur: 15,
                alignment: Alignment.center,
                border: 1.5,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.8),
                    color.withOpacity(0.3),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: color,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class EnhancedSpeechTailPainter extends CustomPainter {
  final Color color;
  final Color shadowColor;
  final Color glowColor;
  final bool isLeft;

  EnhancedSpeechTailPainter({
    required this.color,
    required this.shadowColor,
    required this.glowColor,
    required this.isLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    
    if (isLeft) {
      path.moveTo(size.width * 0.2, 0);
      path.quadraticBezierTo(
        0, size.height * 0.5,
        size.width * 0.5, size.height,
      );
      path.quadraticBezierTo(
        size.width, size.height * 0.5,
        size.width * 0.8, 0,
      );
    } else {
      path.moveTo(size.width * 0.8, 0);
      path.quadraticBezierTo(
        size.width, size.height * 0.5,
        size.width * 0.5, size.height,
      );
      path.quadraticBezierTo(
        0, size.height * 0.5,
        size.width * 0.2, 0,
      );
    }
    path.close();

    // Draw shadows
    final shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(path, shadowPaint);

    // Draw glow
    final glowPaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(path, glowPaint);

    // Draw main tail
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

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