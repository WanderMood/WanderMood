import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandermood/features/mood/presentation/widgets/mood_history_widget.dart';

class MoodHistoryScreen extends ConsumerWidget {
  const MoodHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Stemmingsgeschiedenis',
          style: GoogleFonts.museoModerno(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4CAF50),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF4CAF50),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFDF5), // Warm cream yellow
              Color(0xFFFFF3E0), // Slightly darker warm yellow
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Je Stemmingen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(duration: 400.ms),
                
                const SizedBox(height: 8),
                
                Text(
                  'Hier vind je een overzicht van je geregistreerde stemmingen',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                
                const SizedBox(height: 24),
                
                // Filter options (kunnen later worden geïmplementeerd)
                // ...
                
                const SizedBox(height: 16),
                
                // Mood history list
                Expanded(
                  child: const MoodHistoryWidget().animate().fadeIn(delay: 300.ms, duration: 500.ms),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 