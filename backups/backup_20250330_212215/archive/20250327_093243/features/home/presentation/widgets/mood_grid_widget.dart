import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class MoodGridWidget extends StatefulWidget {
  final Set<String> selectedMoods;
  final Function(String) onMoodSelected;
  final Function() onGeneratePress;

  const MoodGridWidget({
    super.key,
    required this.selectedMoods,
    required this.onMoodSelected,
    required this.onGeneratePress,
  });

  @override
  _MoodGridWidgetState createState() => _MoodGridWidgetState();
}

class _MoodGridWidgetState extends State<MoodGridWidget> {
  String? _hoveredMood;

  void _handleMoodTap(String mood) {
    widget.onMoodSelected(mood);
  }

  void _handleGeneratePlan() {
    if (widget.selectedMoods.isNotEmpty) {
      widget.onGeneratePress();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Text(
            'How are you feeling today?',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildMoodTile('Adventurous', '⛺️'),
            _buildMoodTile('Energetic', '⚡'),
            _buildMoodTile('Excited', '🤩'),
            _buildMoodTile('Festive', '🎉'),
            _buildMoodTile('Relaxed', '🧘‍♂️'),
            _buildMoodTile('Cozy', '☕'),
            _buildMoodTile('Mind full', '🧠'),
            _buildMoodTile('Cultural', '🌍'),
            _buildMoodTile('Romantic', '💗'),
            _buildMoodTile('Family fun', '👨‍👩‍👧‍👦'),
            _buildMoodTile('Foody', '🍽️'),
            _buildMoodTile('Surprise', '😲'),
          ],
        ),

        if (widget.selectedMoods.isNotEmpty) ...[
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _handleGeneratePlan,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF34A853),  // Green
                    Color(0xFF28864F),  // Darker green
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF34A853).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Shine effect
                  if (widget.selectedMoods.isNotEmpty)
                    Positioned(
                      right: -50,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.white.withOpacity(0),
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0),
                            ],
                          ),
                        ),
                      ),
                    ).animate(
                      onPlay: (controller) => controller.repeat(),
                    ).moveX(
                      begin: -100,
                      end: 200,
                      duration: 2.seconds,
                      curve: Curves.easeInOut,
                    ),
                  
                  // Button content
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Generate Plan',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate()
             .fadeIn(duration: 400.ms)
             .scale(
               begin: const Offset(0.8, 0.8),
               end: const Offset(1, 1),
               duration: 400.ms,
               curve: Curves.elasticOut,
             ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                '${widget.selectedMoods.length}/3 moods selected',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms),
        ],
      ],
    );
  }

  Widget _buildMoodTile(String label, String emoji) {
    final isSelected = widget.selectedMoods.contains(label);
    final style = moodStyles[label]!;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredMood = label),
      onExit: (_) => setState(() => _hoveredMood = null),
      child: GestureDetector(
        onTap: () => _handleMoodTap(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: style['bg'] as Color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (style['text'] as Color).withOpacity(_hoveredMood == label ? 0.2 : 0.1),
                blurRadius: _hoveredMood == label ? 8 : 4,
                offset: Offset(0, _hoveredMood == label ? 4 : 2),
              ),
            ],
          ),
          transform: Matrix4.identity()
            ..translate(0.0, _hoveredMood == label ? -4.0 : 0.0),
          child: Stack(
            children: [
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: style['text'] as Color,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check,
                        size: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      emoji,
                      style: TextStyle(
                        fontSize: isSelected ? 32 : 28,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: style['text'] as Color,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate()
     .fadeIn(duration: 200.ms)
     .scale(
       begin: const Offset(0.8, 0.8),
       end: const Offset(1, 1),
       duration: 200.ms,
     );
  }

  // Define mood colors and styles
  static const moodStyles = {
    'Adventurous': {
      'bg': Color(0xFFF0F7F0),
      'text': Color(0xFF4CAF50),
    },
    'Energetic': {
      'bg': Color(0xFFFFF8E7),
      'text': Color(0xFFFFB300),
    },
    'Excited': {
      'bg': Color(0xFFF3E5FF),
      'text': Color(0xFF9C27B0),
    },
    'Festive': {
      'bg': Color(0xFFE3F2FD),
      'text': Color(0xFF2196F3),
    },
    'Relaxed': {
      'bg': Color(0xFFE3F2FD),
      'text': Color(0xFF2196F3),
    },
    'Cozy': {
      'bg': Color(0xFFFFEBEE),
      'text': Color(0xFFE57373),
    },
    'Mind full': {
      'bg': Color(0xFFF3E5FF),
      'text': Color(0xFF9C27B0),
    },
    'Cultural': {
      'bg': Color(0xFFE0F2F1),
      'text': Color(0xFF009688),
    },
    'Romantic': {
      'bg': Color(0xFFFFEBEE),
      'text': Color(0xFFE91E63),
    },
    'Family fun': {
      'bg': Color(0xFFF0F7F0),
      'text': Color(0xFF4CAF50),
    },
    'Foody': {
      'bg': Color(0xFFFFF8E7),
      'text': Color(0xFFFFB300),
    },
    'Surprise': {
      'bg': Color(0xFFEFEBE9),
      'text': Color(0xFF795548),
    },
  };
} 