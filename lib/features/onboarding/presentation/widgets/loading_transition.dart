import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingTransition extends StatelessWidget {
  const LoadingTransition({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Card(
          color: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5BB32A)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Getting everything ready...',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate()
                  .fadeIn(duration: 600.ms)
                  .scale(),
              ],
            ),
          ),
        ).animate()
          .scale(duration: 400.ms, curve: Curves.easeOut)
          .fadeIn(duration: 300.ms),
      ),
    );
  }
} 
 
 
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingTransition extends StatelessWidget {
  const LoadingTransition({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Card(
          color: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5BB32A)),
                ),
                const SizedBox(height: 16),
                Text(
                  'Getting everything ready...',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate()
                  .fadeIn(duration: 600.ms)
                  .scale(),
              ],
            ),
          ),
        ).animate()
          .scale(duration: 400.ms, curve: Curves.easeOut)
          .fadeIn(duration: 300.ms),
      ),
    );
  }
} 
 
 