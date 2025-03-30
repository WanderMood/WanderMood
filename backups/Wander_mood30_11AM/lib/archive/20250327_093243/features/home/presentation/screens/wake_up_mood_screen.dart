import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class WakeUpMoodScreen extends StatefulWidget {
  const WakeUpMoodScreen({super.key});

  @override
  State<WakeUpMoodScreen> createState() => _WakeUpMoodScreenState();
}

class _WakeUpMoodScreenState extends State<WakeUpMoodScreen> {
  final List<String> _wakeUpMoods = [
    'Energetic ⚡',
    'Peaceful 🌅',
    'Adventurous 🚀',
    'Creative 🎨',
    'Relaxed 😌',
  ];

  String? _selectedMood;

  @override
  void initState() {
    super.initState();
    _loadSelectedMood();
  }

  Future<void> _loadSelectedMood() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedMood = prefs.getString('wake_up_mood');
    });
  }

  Future<void> _saveSelectedMood(String mood) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wake_up_mood', mood);
    setState(() {
      _selectedMood = mood;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A237E),
              Color(0xFF0D47A1),
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Set Wake-up Mood',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _wakeUpMoods.length,
                  itemBuilder: (context, index) {
                    final mood = _wakeUpMoods[index];
                    final isSelected = _selectedMood == mood;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: 0,
                        color: isSelected ? Colors.white : Colors.white24,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => _saveSelectedMood(mood),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    mood,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: isSelected ? const Color(0xFF1A237E) : Colors.white,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF1A237E),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ).animate()
                        .fadeIn(delay: Duration(milliseconds: index * 100))
                        .slideX(
                          begin: 0.2,
                          end: 0,
                          delay: Duration(milliseconds: index * 100),
                          curve: Curves.easeOutQuad,
                        ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Moody will greet you with this mood\nwhen you wake up! 🌅',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
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