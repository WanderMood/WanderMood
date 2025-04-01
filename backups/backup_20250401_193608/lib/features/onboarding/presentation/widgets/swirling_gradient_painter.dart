import 'package:flutter/material.dart';
import 'dart:math' as math;

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
    for (var i = 0; i < 3; i++) {
      final waveHeight = size.height * 0.2;
      final frequency = math.pi * (1 + i * 0.5) / size.width;
      final phase = i * math.pi / 2;
      
      mainWavePath.reset();
      mainWavePath.moveTo(0, size.height);
      
      for (var x = 0.0; x <= size.width; x += 5) {
        final y = size.height - waveHeight * math.sin(frequency * x + phase);
        mainWavePath.lineTo(x, y);
      }
      
      mainWavePath.lineTo(size.width, size.height);
      mainWavePath.close();
      
      canvas.drawPath(mainWavePath, wavePaint);
    }

    // Create accent waves with different phase and frequency
    for (var i = 0; i < 2; i++) {
      final waveHeight = size.height * 0.15;
      final frequency = math.pi * (1.5 + i * 0.5) / size.width;
      final phase = i * math.pi / 3 + math.pi;
      
      accentWavePath.reset();
      accentWavePath.moveTo(0, size.height);
      
      for (var x = 0.0; x <= size.width; x += 5) {
        final y = size.height - waveHeight * math.sin(frequency * x + phase);
        accentWavePath.lineTo(x, y);
      }
      
      accentWavePath.lineTo(size.width, size.height);
      accentWavePath.close();
      
      canvas.drawPath(accentWavePath, accentPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
} 