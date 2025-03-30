import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MoodyThinkingWidget extends StatelessWidget {
  const MoodyThinkingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Moody character
        Container(
          width: 150,
          height: 150,
          child: CustomPaint(
            painter: MoodyThinkingPainter(),
          ),
        ).animate(
          onPlay: (controller) => controller.repeat(),
        ).scale(
          duration: 2.seconds,
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.05, 1.05),
          curve: Curves.easeInOut,
        ),

        // Thought bubbles
        ...List.generate(3, (index) {
          final offset = Offset(100 + (index * 15).toDouble(), 30 - (index * 10).toDouble());
          return Positioned(
            right: offset.dx,
            top: offset.dy,
            child: Container(
              width: 10 + (index * 2).toDouble(),
              height: 10 + (index * 2).toDouble(),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ).animate(
              onPlay: (controller) => controller.repeat(),
            ).scale(
              delay: (index * 200).milliseconds,
              duration: 1.seconds,
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.2, 1.2),
              curve: Curves.easeInOut,
            ).fadeIn(
              duration: 500.milliseconds,
            ),
          );
        }),
      ],
    );
  }
}

class MoodyThinkingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF12B347) // Moody's base green color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Draw Moody's body (circle)
    canvas.drawCircle(center, radius, paint);

    // Draw eyes (slightly raised and more oval for thinking expression)
    final eyePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Left eye (more squinted)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx - radius * 0.4, center.dy - radius * 0.1),
        width: radius * 0.4,
        height: radius * 0.25,
      ),
      eyePaint,
    );

    // Right eye (more squinted)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.4, center.dy - radius * 0.1),
        width: radius * 0.4,
        height: radius * 0.25,
      ),
      eyePaint,
    );

    // Draw pupils (looking up and to the side)
    final pupilPaint = Paint()
      ..color = const Color(0xFF1A4A24)
      ..style = PaintingStyle.fill;

    // Left pupil
    canvas.drawCircle(
      Offset(center.dx - radius * 0.45, center.dy - radius * 0.15),
      radius * 0.08,
      pupilPaint,
    );

    // Right pupil
    canvas.drawCircle(
      Offset(center.dx + radius * 0.35, center.dy - radius * 0.15),
      radius * 0.08,
      pupilPaint,
    );

    // Draw thinking mouth (smaller, slightly curved)
    final mouthPath = Path()
      ..moveTo(center.dx - radius * 0.2, center.dy + radius * 0.3)
      ..quadraticBezierTo(
        center.dx,
        center.dy + radius * 0.4,
        center.dx + radius * 0.2,
        center.dy + radius * 0.3,
      );

    final mouthPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawPath(mouthPath, mouthPaint);

    // Draw eyebrows (raised and curved for thinking expression)
    final eyebrowPaint = Paint()
      ..color = const Color(0xFF0A8034)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Left eyebrow
    final leftEyebrowPath = Path()
      ..moveTo(center.dx - radius * 0.6, center.dy - radius * 0.3)
      ..quadraticBezierTo(
        center.dx - radius * 0.4,
        center.dy - radius * 0.5,
        center.dx - radius * 0.2,
        center.dy - radius * 0.3,
      );

    // Right eyebrow
    final rightEyebrowPath = Path()
      ..moveTo(center.dx + radius * 0.2, center.dy - radius * 0.3)
      ..quadraticBezierTo(
        center.dx + radius * 0.4,
        center.dy - radius * 0.5,
        center.dx + radius * 0.6,
        center.dy - radius * 0.3,
      );

    canvas.drawPath(leftEyebrowPath, eyebrowPaint);
    canvas.drawPath(rightEyebrowPath, eyebrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 