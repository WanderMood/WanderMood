import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class MoodyScreen extends StatelessWidget {
  const MoodyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFAFF4), // Pink
            Color(0xFFFFF5AF), // Light yellow
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Moody',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            
            // Placeholder for AI interaction
            Expanded(
              child: Center(
                child: Text(
                  'Chat with Moody',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 