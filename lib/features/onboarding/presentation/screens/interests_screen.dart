import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/providers/preferences_provider.dart';
import 'package:travel_app/utils/swirling_gradient_painter.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({Key? key}) : super(key: key);

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final List<Map<String, dynamic>> _interests = [
    {'name': 'Art', 'emoji': '🎨', 'color': Colors.pink},
    {'name': 'Food', 'emoji': '🍴', 'color': Colors.orange},
    {'name': 'History', 'emoji': '🏛', 'color': Colors.blue},
    {'name': 'Nature', 'emoji': '🌿', 'color': Colors.green},
    {'name': 'Adventure', 'emoji': '🤠', 'color': Colors.purple},
    {'name': 'Culture', 'emoji': '🌍', 'color': Colors.teal},
    {'name': 'Beach', 'emoji': '🏖', 'color': Colors.lightBlue},
    {'name': 'City', 'emoji': '🏙', 'color': Colors.brown},
  ];

  final List<String> _selectedInterests = [];
  final maxInterestSelections = 5;

  void _toggleInterestSelection(String interest) {
    if (_selectedInterests.contains(interest)) {
      setState(() {
        _selectedInterests.remove(interest);
      });
      ref.read(preferencesProvider.notifier).updateTravelInterests(_selectedInterests.toList());
    } else {
      if (_selectedInterests.length < maxInterestSelections) {
        setState(() {
          _selectedInterests.add(interest);
        });
        ref.read(preferencesProvider.notifier).updateTravelInterests(_selectedInterests.toList());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(preferencesProvider);
    final selectedInterests = preferences.travelInterests;

    return Scaffold(
      body: CustomPaint(
        painter: SwirlingGradientPainter(),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Title and description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      'What interests you most\nwhile traveling?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ).animate()
                     .fadeIn(duration: 600.ms)
                     .slideY(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 10),
                    
                    Text(
                      'Choose up to 5 interests that excite you',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ).animate()
                     .fadeIn(duration: 600.ms, delay: 200.ms)
                     .slideY(begin: -0.2, end: 0),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Interest grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: _interests.length,
                  itemBuilder: (context, index) {
                    final interest = _interests[index];
                    final isSelected = selectedInterests.contains(interest['name']);
                    
                    return GestureDetector(
                      onTap: () => _toggleInterestSelection(interest['name']),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? interest['color'].withOpacity(0.9)
                            : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              interest['emoji'],
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              interest['name'],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ).animate()
                       .fadeIn(duration: 600.ms, delay: (100 * index).ms)
                       .slideY(begin: 0.2, end: 0),
                    );
                  },
                ),
              ),
              
              // Continue button
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: selectedInterests.isNotEmpty
                    ? () => context.go('/preferences/travel-style')
                    : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5BB32A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ).animate()
                 .fadeIn(duration: 600.ms, delay: 400.ms)
                 .slideY(begin: 0.2, end: 0),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 