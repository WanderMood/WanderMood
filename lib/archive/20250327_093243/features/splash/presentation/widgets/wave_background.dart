import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaveBackground extends StatefulWidget {
  const WaveBackground({super.key});

  @override
  State<WaveBackground> createState() => _WaveBackgroundState();
}

class _WaveBackgroundState extends State<WaveBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: WavePainter(
            animation: _controller,
            waveColor: const Color(0xFF4CAF50).withOpacity(0.05),
          ),
          child: Container(),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final Animation<double> animation;
  final Color waveColor;

  WavePainter({required this.animation, required this.waveColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final y = size.height * 0.8;
    
    path.moveTo(0, y);
    
    for (var i = 0.0; i < size.width; i++) {
      path.lineTo(
        i,
        y + math.sin((i / 30) - (animation.value * 2 * math.pi)) * 10,
      );
    }
    
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
} 