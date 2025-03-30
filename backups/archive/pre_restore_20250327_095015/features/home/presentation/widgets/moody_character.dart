import 'package:flutter/material.dart';
import 'dart:math' as math;

class MoodyCharacter extends StatefulWidget {
  final double size;
  final String mood;
  final VoidCallback? onTap;
  
  const MoodyCharacter({
    super.key,
    this.size = 120,
    this.mood = 'idle',
    this.onTap,
  });

  @override
  State<MoodyCharacter> createState() => _MoodyCharacterState();
}

class _MoodyCharacterState extends State<MoodyCharacter> with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _blinkController;
  late final AnimationController _bounceController;
  late final AnimationController _wiggleController;
  late final Animation<double> _floatAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _blinkAnimation;
  late final Animation<double> _bounceAnimation;
  late final Animation<double> _wiggleAnimation;
  bool _isHovered = false;
  
  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _wiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    Future.delayed(const Duration(seconds: 2), () {
      _startBlinking();
    });
    
    _floatAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _blinkAnimation = Tween<double>(
      begin: 1.0,
      end: 0.2,
    ).animate(_blinkController);

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _wiggleAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _wiggleController,
      curve: Curves.easeInOut,
    ));

    // Start mood-specific animations
    if (widget.mood == 'celebrating' || widget.mood == 'excited') {
      _bounceController.repeat(reverse: true);
      _wiggleController.repeat(reverse: true);
    }
  }

  void _startBlinking() {
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 2 + math.Random().nextInt(4)));
      if (!mounted) return false;
      await _blinkController.forward();
      await _blinkController.reverse();
      return true;
    });
  }
  
  @override
  void dispose() {
    _floatController.dispose();
    _blinkController.dispose();
    _bounceController.dispose();
    _wiggleController.dispose();
    super.dispose();
  }

  Color _getMoodColor() {
    switch (widget.mood) {
      case 'speaking':
        return const Color(0xFF90CAF9); // Soft blue
      case 'thinking':
        return const Color(0xFFB39DDB); // Soft purple
      case 'listening':
        return const Color(0xFFA5D6A7); // Soft green
      case 'celebrating':
        return const Color(0xFFFFCC80); // Soft orange
      case 'excited':
        return const Color(0xFFFFAB91); // Soft coral
      case 'empathizing':
        return const Color(0xFFF8BBD0); // Soft pink
      case 'relaxed':
        return const Color(0xFF80DEEA); // Soft cyan
      case 'mindful':
        return const Color(0xFFE1BEE7); // Soft violet
      default:
        return const Color(0xFF90CAF9); // Soft blue as default
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _getMoodColor();
    final highlightColor = HSLColor.fromColor(baseColor).withLightness(0.85).toColor();
    final shadowColor = HSLColor.fromColor(baseColor).withLightness(0.6).toColor();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _floatAnimation, 
            _scaleAnimation, 
            _blinkAnimation,
            _bounceAnimation,
            _wiggleAnimation,
          ]),
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                _wiggleAnimation.value * widget.size,
                -_floatAnimation.value - _bounceAnimation.value,
              ),
              child: Transform.rotate(
                angle: _wiggleAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.2, 0.5, 0.8],
                        colors: [
                          highlightColor,
                          baseColor,
                          shadowColor,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Cute face features
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Cute eyes with mood variations
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildEye(true),
                                  SizedBox(width: widget.size * 0.15),
                                  _buildEye(false),
                                ],
                              ),
                              SizedBox(height: widget.size * 0.1),
                              // Mood-specific expressions
                              CustomPaint(
                                size: Size(widget.size * 0.5, widget.size * 0.25),
                                painter: CuteExpressionPainter(
                                  color: shadowColor,
                                  strokeWidth: widget.size * 0.04,
                                  mood: widget.mood,
                                  isHovered: _isHovered,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Mood-specific decorations
                        if (_shouldShowRosyCheeks())
                          ..._buildRosyCheeks(),
                        if (_isHovered || _shouldShowSparkles())
                          ..._buildSparkles(),
                        if (widget.mood == 'celebrating' || widget.mood == 'excited')
                          ..._buildStars(),
                        if (widget.mood == 'thinking')
                          ..._buildThoughtBubbles(),
                        if (widget.mood == 'mindful')
                          ..._buildZenCircles(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  bool _shouldShowRosyCheeks() {
    return widget.mood == 'celebrating' || 
           widget.mood == 'excited' || 
           widget.mood == 'empathizing';
  }

  bool _shouldShowSparkles() {
    return widget.mood == 'celebrating' || 
           widget.mood == 'excited';
  }

  Widget _buildEye(bool isLeft) {
    final moodSpecificEye = _getMoodSpecificEye();
    return Container(
      width: widget.size * 0.2,
      height: widget.size * 0.2 * _blinkAnimation.value,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: moodSpecificEye.shape,
        borderRadius: moodSpecificEye.borderRadius,
        border: Border.all(
          color: HSLColor.fromColor(_getMoodColor())
              .withLightness(0.3)
              .toColor(),
          width: widget.size * 0.02,
        ),
      ),
      child: Center(
        child: Container(
          width: widget.size * 0.1,
          height: widget.size * 0.1 * _blinkAnimation.value,
          decoration: BoxDecoration(
            color: HSLColor.fromColor(_getMoodColor())
                .withLightness(0.3)
                .toColor(),
            shape: moodSpecificEye.pupilShape,
            borderRadius: moodSpecificEye.pupilBorderRadius,
          ),
          child: Stack(
            children: [
              // Eye shine
              Positioned(
                top: widget.size * 0.02,
                left: widget.size * 0.02,
                child: Container(
                  width: widget.size * 0.03,
                  height: widget.size * 0.03,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Additional mood-specific eye details
              if (moodSpecificEye.extraDetails != null)
                ...moodSpecificEye.extraDetails!,
            ],
          ),
        ),
      ),
    );
  }

  MoodSpecificEye _getMoodSpecificEye() {
    switch (widget.mood) {
      case 'excited':
        return MoodSpecificEye(
          shape: BoxShape.circle,
          pupilShape: BoxShape.circle,
          extraDetails: [
            Positioned(
              bottom: widget.size * 0.02,
              right: widget.size * 0.02,
              child: Container(
                width: widget.size * 0.02,
                height: widget.size * 0.02,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );
      case 'thinking':
        return MoodSpecificEye(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(widget.size * 0.1),
          pupilShape: BoxShape.circle,
        );
      case 'relaxed':
        return MoodSpecificEye(
          shape: BoxShape.circle,
          pupilShape: BoxShape.circle,
          extraDetails: [
            Positioned(
              top: widget.size * 0.04,
              left: 0,
              right: 0,
              child: Container(
                height: widget.size * 0.02,
                decoration: BoxDecoration(
                  color: HSLColor.fromColor(_getMoodColor())
                      .withLightness(0.2)
                      .toColor(),
                ),
              ),
            ),
          ],
        );
      default:
        return MoodSpecificEye(
          shape: BoxShape.circle,
          pupilShape: BoxShape.circle,
        );
    }
  }

  List<Widget> _buildRosyCheeks() {
    return [
      Positioned(
        left: widget.size * 0.15,
        top: widget.size * 0.45,
        child: Container(
          width: widget.size * 0.15,
          height: widget.size * 0.1,
          decoration: BoxDecoration(
            color: Colors.pink.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
      ),
      Positioned(
        right: widget.size * 0.15,
        top: widget.size * 0.45,
        child: Container(
          width: widget.size * 0.15,
          height: widget.size * 0.1,
          decoration: BoxDecoration(
            color: Colors.pink.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildSparkles() {
    return List.generate(5, (index) {
      final angle = (index * 2 * math.pi / 5) + (_floatController.value * 2 * math.pi);
      final radius = widget.size * 0.6;
      return Positioned(
        left: widget.size / 2 + (radius * math.cos(angle)) - 10,
        top: widget.size / 2 + (radius * math.sin(angle)) - 10,
        child: Transform.rotate(
          angle: angle,
          child: Icon(
            Icons.star,
            size: 20,
            color: Colors.yellow[100],
          ),
        ),
      );
    });
  }

  List<Widget> _buildStars() {
    return List.generate(3, (index) {
      final angle = (index * 2 * math.pi / 3) + (_bounceController.value * 0.2);
      final radius = widget.size * 0.7;
      return Positioned(
        left: widget.size / 2 + (radius * math.cos(angle)) - 15,
        top: widget.size / 2 + (radius * math.sin(angle)) - 15,
        child: Icon(
          Icons.star,
          size: 30,
          color: Colors.yellow[200],
        ),
      );
    });
  }

  List<Widget> _buildThoughtBubbles() {
    return List.generate(3, (index) {
      return Positioned(
        right: widget.size * 0.1 + (index * 15),
        top: widget.size * 0.1 - (index * 10),
        child: Container(
          width: 10 + (index * 5),
          height: 10 + (index * 5),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }

  List<Widget> _buildZenCircles() {
    return List.generate(2, (index) {
      return Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: 0,
        child: Center(
          child: Container(
            width: widget.size * (0.8 - (index * 0.2)),
            height: widget.size * (0.8 - (index * 0.2)),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    });
  }
}

class MoodSpecificEye {
  final BoxShape shape;
  final BoxShape pupilShape;
  final BorderRadius? borderRadius;
  final BorderRadius? pupilBorderRadius;
  final List<Widget>? extraDetails;

  MoodSpecificEye({
    required this.shape,
    required this.pupilShape,
    this.borderRadius,
    this.pupilBorderRadius,
    this.extraDetails,
  });
}

class CuteExpressionPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final String mood;
  final bool isHovered;

  CuteExpressionPainter({
    required this.color,
    required this.strokeWidth,
    required this.mood,
    required this.isHovered,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    switch (mood) {
      case 'celebrating':
      case 'excited':
        // Big happy smile with teeth
        path.moveTo(size.width * 0.1, size.height * 0.3);
        path.quadraticBezierTo(
          size.width * 0.5,
          size.height * 1.2,
          size.width * 0.9,
          size.height * 0.3,
        );
        // Add simple teeth
        canvas.drawLine(
          Offset(size.width * 0.3, size.height * 0.6),
          Offset(size.width * 0.7, size.height * 0.6),
          paint,
        );
        break;
      case 'thinking':
        // Thoughtful expression
        path.moveTo(size.width * 0.2, size.height * 0.5);
        path.quadraticBezierTo(
          size.width * 0.5,
          size.height * 0.4,
          size.width * 0.8,
          size.height * 0.5,
        );
        break;
      case 'empathizing':
        // Gentle caring smile
        path.moveTo(size.width * 0.15, size.height * 0.4);
        path.quadraticBezierTo(
          size.width * 0.5,
          size.height * 0.7,
          size.width * 0.85,
          size.height * 0.4,
        );
        break;
      case 'relaxed':
        // Content smile
        path.moveTo(size.width * 0.2, size.height * 0.45);
        path.quadraticBezierTo(
          size.width * 0.5,
          size.height * 0.6,
          size.width * 0.8,
          size.height * 0.45,
        );
        break;
      case 'mindful':
        // Peaceful expression
        path.moveTo(size.width * 0.2, size.height * 0.5);
        path.quadraticBezierTo(
          size.width * 0.5,
          size.height * 0.55,
          size.width * 0.8,
          size.height * 0.5,
        );
        break;
      default:
        // Friendly smile
        path.moveTo(size.width * 0.15, size.height * 0.4);
        path.quadraticBezierTo(
          size.width * 0.5,
          size.height * 0.8,
          size.width * 0.85,
          size.height * 0.4,
        );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CuteExpressionPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      mood != oldDelegate.mood ||
      isHovered != oldDelegate.isHovered;
} 