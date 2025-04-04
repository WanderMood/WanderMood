import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandermood/features/home/presentation/widgets/moody_character.dart';

class PlanResultScreen extends ConsumerStatefulWidget {
  final List<String> selectedMoods;
  final String moodString;

  const PlanResultScreen({
    super.key,
    required this.selectedMoods,
    required this.moodString,
  });

  @override
  ConsumerState<PlanResultScreen> createState() => _PlanResultScreenState();
}

class _PlanResultScreenState extends ConsumerState<PlanResultScreen> {
  // Mock data for places - in a real app this would come from a Places API call
  final List<Map<String, dynamic>> _places = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _fetchPlaces();
  }
  
  // Simulate API call to get places
  Future<void> _fetchPlaces() async {
    // In a real app, this would be an actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _places.addAll([
        {
          'name': 'Central Park Morning Walk',
          'description': 'Start your day with a peaceful walk through Central Park\'s scenic trails.',
          'image': 'https://images.unsplash.com/photo-1596276020587-8044fe049813',
          'rating': 4.8,
          'hours': '6:00 AM - 1:00 AM',
          'tags': ['Outdoor', 'Relaxing', 'Nature'],
        },
        {
          'name': 'The Metropolitan Museum',
          'description': 'Explore world-class art collections and cultural exhibits.',
          'image': 'https://images.unsplash.com/photo-1582126891881-a7cbc1f4390b',
          'rating': 4.9,
          'hours': '10:00 AM - 5:00 PM',
          'tags': ['Cultural', 'Indoor', 'Educational'],
        },
        {
          'name': 'Rooftop Garden Café',
          'description': 'Enjoy lunch with breathtaking city views in this trendy rooftop spot.',
          'image': 'https://images.unsplash.com/photo-1593696954577-ab3d39317b97',
          'rating': 4.6,
          'hours': '11:00 AM - 9:00 PM',
          'tags': ['Food', 'Views', 'Social'],
        },
        {
          'name': 'Brooklyn Bridge Sunset Walk',
          'description': 'Take in stunning sunset views of the Manhattan skyline.',
          'image': 'https://images.unsplash.com/photo-1568515045052-f9a854d70bfd',
          'rating': 4.7,
          'hours': 'Open 24 hours',
          'tags': ['Romantic', 'Views', 'Walking'],
        },
        {
          'name': 'Jazz Club Evening',
          'description': 'End your day with live jazz music and craft cocktails.',
          'image': 'https://images.unsplash.com/photo-1602274251350-14a0d9a4a1ab',
          'rating': 4.5,
          'hours': '7:00 PM - 2:00 AM',
          'tags': ['Music', 'Nightlife', 'Social'],
        },
      ]);
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with mood information
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF4CAF50),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Your ${widget.moodString} Plan',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF66BB6A),
                      const Color(0xFF4CAF50),
                      const Color(0xFF388E3C),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Image.network(
                          'https://www.transparenttextures.com/patterns/cubes.png',
                          repeat: ImageRepeat.repeat,
                        ),
                      ),
                    ),
                    
                    // Mood chips
                    Positioned(
                      bottom: 70,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: widget.selectedMoods.map((mood) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              mood,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Plan introduction
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Plan intro with Moody
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Moody character
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 0.8,
                            colors: [
                              const Color(0xFFB3E5FC).withOpacity(0.6),
                              const Color(0xFFE3F2FD).withOpacity(0.3),
                              const Color(0xFFE3F2FD).withOpacity(0.0),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                        child: const MoodyCharacter(
                          size: 50,
                          mood: 'happy',
                          currentFeature: MoodyFeature.none,
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Plan description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Here\'s your personalized plan!',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF388E3C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _generatePlanDescription(),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[800],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Today's date
                  Text(
                    _getFormattedDate(),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF388E3C),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Places section title
                  Text(
                    'Your Day Plan',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Places list
          _isLoading
              ? SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(
                        color: const Color(0xFF4CAF50),
                        backgroundColor: Colors.green.withOpacity(0.2),
                      ),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final place = _places[index];
                      return _buildPlaceCard(place, index);
                    },
                    childCount: _places.length,
                  ),
                ),
          
          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      
      // Floating action button to book all activities
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 16),
        child: FloatingActionButton.extended(
          onPressed: () {
            // Show booking confirmation
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'All activities booked for today!',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: const Color(0xFF388E3C),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          backgroundColor: const Color(0xFF4CAF50),
          icon: const Icon(Icons.check_circle),
          label: Text(
            'Book All Activities',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPlaceCard(Map<String, dynamic> place, int index) {
    // Calculate time based on position in list
    final startTime = DateTime.now().add(Duration(hours: index * 2 + 8));
    final endTime = startTime.add(const Duration(hours: 2));
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: Color(0xFF388E3C),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_formatTime(startTime)} - ${_formatTime(endTime)}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF388E3C),
                  ),
                ),
              ],
            ),
          ),
          
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                '${place['image']}?auto=format&fit=crop&w=800&q=80',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Place details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        place['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[900],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Color(0xFFFFC107),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          place['rating'].toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Description
                Text(
                  place['description'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Hours
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      place['hours'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (place['tags'] as List).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF4CAF50).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF388E3C),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4CAF50),
                          side: const BorderSide(
                            color: Color(0xFF4CAF50),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Directions',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Book Now',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 400.ms, delay: (index * 200).ms).slide(
      begin: const Offset(0, 0.1),
      end: const Offset(0, 0),
      duration: 400.ms,
      delay: (index * 200).ms,
      curve: Curves.easeOut,
    );
  }
  
  String _generatePlanDescription() {
    // Generate a description based on selected moods
    final List<String> descriptions = [
      'Based on your mood, I\'ve created a personalized itinerary that\'s perfect for a ${widget.moodString} day.',
      'This plan combines activities that match your ${widget.moodString} preferences with local favorites.',
      'I\'ve selected places that are highly rated and align with your ${widget.moodString} mood today.',
    ];
    
    return descriptions[DateTime.now().millisecond % descriptions.length];
  }
  
  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }
  
  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:00 $period';
  }
} 