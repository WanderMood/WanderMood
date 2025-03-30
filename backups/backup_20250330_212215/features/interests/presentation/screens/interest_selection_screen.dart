import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class InterestSelectionScreen extends StatefulWidget {
  const InterestSelectionScreen({super.key});

  @override
  State<InterestSelectionScreen> createState() => _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  final Set<String> _selectedInterests = {};
  final List<InterestOption> _interests = [
    InterestOption(
      icon: Icons.nature,
      label: 'Nature',
      color: const Color(0xFF2ECC71),
      description: 'Parks, hiking, and outdoor activities',
    ),
    InterestOption(
      icon: Icons.restaurant,
      label: 'Food',
      color: const Color(0xFFE67E22),
      description: 'Local cuisine and dining experiences',
    ),
    InterestOption(
      icon: Icons.museum,
      label: 'Culture',
      color: const Color(0xFF9B59B6),
      description: 'Museums, art, and historical sites',
    ),
    InterestOption(
      icon: Icons.shopping_bag,
      label: 'Shopping',
      color: const Color(0xFF3498DB),
      description: 'Markets, malls, and local crafts',
    ),
    InterestOption(
      icon: Icons.sports_esports,
      label: 'Entertainment',
      color: const Color(0xFFE74C3C),
      description: 'Events, shows, and nightlife',
    ),
    InterestOption(
      icon: Icons.fitness_center,
      label: 'Adventure',
      color: const Color(0xFF1ABC9C),
      description: 'Sports, activities, and thrills',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    'What interests you?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2A7BB3),
                    ),
                  ).animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.2, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Select multiple interests to get personalized recommendations',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ).animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.2, end: 0),
                ],
              ),
            ),
            // Interest Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _interests.length,
                itemBuilder: (context, index) {
                  final interest = _interests[index];
                  final isSelected = _selectedInterests.contains(interest.label);
                  return _buildInterestCard(interest, isSelected, index);
                },
              ),
            ),
            // Continue Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: _selectedInterests.isNotEmpty
                    ? () => context.go('/location')
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color(0xFF5BB32A),
                  foregroundColor: Colors.white,
                  elevation: 2,
                ),
                child: Text(
                  'Continue',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2, end: 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestCard(InterestOption interest, bool isSelected, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedInterests.remove(interest.label);
          } else {
            _selectedInterests.add(interest.label);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? interest.color : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? interest.color : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: interest.color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              interest.icon,
              size: 32,
              color: isSelected ? Colors.white : interest.color,
            ).animate()
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
              .then()
              .shake(duration: 300.ms),
            const SizedBox(height: 8),
            Text(
              interest.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              interest.description,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ).animate()
        .fadeIn(duration: 600.ms, delay: Duration(milliseconds: index * 100))
        .slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: index * 100)),
    );
  }
}

class InterestOption {
  final IconData icon;
  final String label;
  final Color color;
  final String description;

  InterestOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.description,
  });
} 