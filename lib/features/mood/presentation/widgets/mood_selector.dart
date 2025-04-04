import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class MoodSelector extends ConsumerStatefulWidget {
  final Function(Set<String>) onMoodsSelected;

  const MoodSelector({
    super.key,
    required this.onMoodsSelected,
  });

  @override
  ConsumerState<MoodSelector> createState() => _MoodSelectorState();
}

class _MoodSelectorState extends ConsumerState<MoodSelector> {
  final Set<String> _selectedMoods = {};
  static const int maxMoodSelections = 3;
  static const int minMoodSelections = 1;

  final List<Map<String, dynamic>> _firstRowMoods = [
    {
      'icon': '🏕️',
      'label': 'Adventurous',
      'color': Colors.blue,
      'description': 'Ready for thrilling experiences',
    },
    {
      'icon': '🧖‍♀️',
      'label': 'Relaxed',
      'color': Colors.purple,
      'description': 'Time to unwind and recharge',
    },
    {
      'icon': '💖',
      'label': 'Romantic',
      'color': Colors.pink,
      'description': 'In the mood for love and charm',
    },
    {
      'icon': '⚡',
      'label': 'Energetic',
      'color': Colors.yellow,
      'description': 'Full of vigor and excitement',
    },
    {
      'icon': '🤩',
      'label': 'Excited',
      'color': Colors.green,
      'description': 'Thrilled about what\'s ahead',
    },
  ];

  final List<Map<String, dynamic>> _secondRowMoods = [
    {
      'icon': '😲',
      'label': 'Surprise',
      'color': Colors.orange,
      'description': 'Open to unexpected delights',
    },
    {
      'icon': '🍽️',
      'label': 'Foody',
      'color': Colors.red,
      'description': 'Craving culinary adventures',
    },
    {
      'icon': '🎉',
      'label': 'Festive',
      'color': Colors.indigo,
      'description': 'Ready to celebrate and party',
    },
    {
      'icon': '🧠',
      'label': 'Mind full',
      'color': Colors.teal,
      'description': 'Seeking intellectual stimulation',
    },
    {
      'icon': '👨‍👩‍👧‍👦',
      'label': 'Family fun',
      'color': Colors.deepPurple,
      'description': 'Perfect for family activities',
    },
    {
      'icon': '🎨',
      'label': 'Creative',
      'color': Colors.amber,
      'description': 'Feeling artsy and inspired',
    },
    {
      'icon': '💎',
      'label': 'Luxurious',
      'color': Colors.blueGrey,
      'description': 'In the mood for high-end moments',
    },
  ];

  void _toggleMood(String mood) {
    setState(() {
      if (_selectedMoods.contains(mood)) {
        _selectedMoods.remove(mood);
      } else if (_selectedMoods.length < maxMoodSelections) {
        _selectedMoods.add(mood);
      } else {
        // Show snackbar when trying to select more than max moods
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You can select up to $maxMoodSelections moods',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    });

    // Notify parent about mood selection changes
    widget.onMoodsSelected(_selectedMoods);
  }

  void _generatePlan() {
    if (_selectedMoods.length >= minMoodSelections && 
        _selectedMoods.length <= maxMoodSelections) {
      // Navigate to plan generation screen
      context.push('/generate-plan', extra: _selectedMoods.toList());
    }
  }

  Widget _buildMoodTile(Map<String, dynamic> mood) {
    final isSelected = _selectedMoods.contains(mood['label']);
    final baseColor = mood['color'] as MaterialColor;
    
    // Calculate deeper shades for the colors
    final deeperBaseColor = baseColor[700] ?? baseColor;
    final backgroundColor = isSelected 
        ? deeperBaseColor.withOpacity(0.3)
        : deeperBaseColor.withOpacity(0.2);
    
    return GestureDetector(
      onTap: () => _toggleMood(mood['label']),
      onLongPress: () {
        // Show tooltip on long press
        final RenderBox box = context.findRenderObject() as RenderBox;
        final Offset position = box.localToGlobal(Offset.zero);
        
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(
            position.dx,
            position.dy,
            position.dx + box.size.width,
            position.dy + box.size.height,
          ),
          items: [
            PopupMenuItem(
              enabled: false,
              child: Text(
                mood['description'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: deeperBaseColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? deeperBaseColor : deeperBaseColor.withOpacity(0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: deeperBaseColor.withOpacity(0.4),  // Increased from 0.3 to 0.4
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Stack(
          children: [
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: deeperBaseColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      mood['icon'],
                      style: const TextStyle(
                        fontSize: 32,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      mood['label'],
                      style: GoogleFonts.openSans(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? deeperBaseColor : deeperBaseColor.withOpacity(0.8),
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canGeneratePlan = _selectedMoods.length >= minMoodSelections && 
                                _selectedMoods.length <= maxMoodSelections;

    // Combine all moods into a single list
    final allMoods = [
      ..._firstRowMoods,
      ..._secondRowMoods,
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected moods indicator
          if (_selectedMoods.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Selected moods: ',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _selectedMoods.join(', '),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Grid of mood tiles
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.0,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: allMoods.length,
            itemBuilder: (context, index) => _buildMoodTile(allMoods[index]),
          ),

          const SizedBox(height: 16),

          // Message above button
          if (canGeneratePlan)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Center(
                child: Text(
                  'Let\'s create your perfect plan! 🎯',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // Generate Plan Button
          Container(
            width: double.infinity,
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: canGeneratePlan ? _generatePlan : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canGeneratePlan 
                    ? const Color(0xFF4CAF50)
                    : Colors.grey[300],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: Text(
                canGeneratePlan
                    ? 'Generate Plan'
                    : 'Select 1-3 moods',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Add extra bottom padding to ensure button visibility
          const SizedBox(height: 32),
        ],
      ),
    );
  }
} 