import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wandermood/core/presentation/widgets/swirl_background.dart';
import 'package:wandermood/features/home/presentation/screens/mood_home_screen.dart';
import 'package:wandermood/features/home/presentation/screens/explore_screen.dart';
import 'package:wandermood/features/profile/presentation/screens/profile_screen.dart';
import 'package:wandermood/core/domain/providers/location_notifier_provider.dart';
import 'package:wandermood/features/auth/providers/user_provider.dart';
import 'package:wandermood/features/weather/providers/weather_provider.dart';
import 'package:wandermood/features/profile/presentation/widgets/profile_drawer.dart';
import 'package:wandermood/core/domain/entities/location.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wandermood/features/plans/data/services/scheduled_activity_service.dart';
import 'package:wandermood/features/plans/domain/models/activity.dart';
import 'package:intl/intl.dart';
import 'package:wandermood/features/home/presentation/screens/daily_schedule_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:wandermood/features/home/domain/providers/main_tab_provider.dart';
import 'package:wandermood/features/gamification/providers/gamification_provider.dart';

// Create a Provider for the tab controller
final mainTabProvider = StateProvider<int>((ref) => 0);

// Placeholder screens for other sections
class MyDayScreen extends ConsumerStatefulWidget {
  const MyDayScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MyDayScreen> createState() => _MyDayScreenState();
}

class _MyDayScreenState extends ConsumerState<MyDayScreen> {
  final PageController _timelineController = PageController(viewportFraction: 0.9);
  List<Activity>? _scheduledActivities;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadScheduledActivities();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to tab changes and reload activities when returning to this tab
    final selectedTab = ref.watch(mainTabProvider);
    if (selectedTab == 0) { // When MyDay tab is selected
      _loadScheduledActivities();
    }
  }
  
  // Add the missing greeting text method
  String _getGreetingText(int hour) {
    if (hour < 12) {
      return 'Good morning! Here\'s your day ahead.';
    } else if (hour < 17) {
      return 'Good afternoon! Here\'s what\'s coming up.';
    } else {
      return 'Good evening! Here\'s your schedule.';
    }
  }
  
  // Load scheduled activities from Supabase
  Future<void> _loadScheduledActivities() async {
    // Only set loading if we don't have activities yet
    if (_scheduledActivities == null || _scheduledActivities!.isEmpty) {
      setState(() {
        _isLoading = true;
      });
    }
    
    try {
      print('MyDayScreen: Loading scheduled activities...');
      final scheduledActivityService = ref.read(scheduledActivityServiceProvider);
      final activities = await scheduledActivityService.getScheduledActivities();
      
      print('MyDayScreen: Loaded ${activities.length} activities');
      if (activities.isNotEmpty) {
        activities.forEach((activity) {
          print('Activity: ${activity.name}, Time: ${activity.startTime}, Location: ${activity.location}');
        });
      } else {
        print('MyDayScreen: No activities found');
      }
      
      if (mounted) {
        setState(() {
          _scheduledActivities = activities;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading scheduled activities: $e');
      print('Stack trace: ${StackTrace.current}');
      if (mounted) {
        setState(() {
          _scheduledActivities = [];
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _timelineController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greetingText = _getGreetingText(now.hour);
    
    return SwirlBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Day',
                            style: GoogleFonts.museoModerno(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF12B347),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Row(
                            children: [
                              // Achievements button
                              IconButton(
                                icon: const Icon(
                                  Icons.emoji_events_outlined,
                                  color: Color(0xFF12B347),
                                ),
                                onPressed: () => context.push('/gamification'),
                                tooltip: 'Achievements',
                              ),
                              // Refresh button
                              IconButton(
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Color(0xFF12B347),
                                ),
                                onPressed: () => _refreshData(),
                                tooltip: 'Refresh',
                              ),
                              _buildWeatherButton(),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        greetingText,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Current activity or next up
              SliverToBoxAdapter(
                child: Container(
                  height: 220,
                  margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Left green highlight
                      Container(
                        width: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF12B347),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            bottomLeft: Radius.circular(24),
                          ),
                        ),
                      ),
                      // Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF12B347).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Now',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF12B347),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  // Show current time if available
                                  Text(
                                    _getCurrentOrNextActivityTime(),
                                    style: GoogleFonts.poppins(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _getCurrentOrNextActivityName(),
                                style: GoogleFonts.museoModerno(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, color: Colors.black54, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getCurrentOrNextActivityLocation(),
                                    style: GoogleFonts.poppins(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: _getCurrentOrNextActivityTags().map((tag) => 
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: _buildFeaturedTag(tag, _getTagColor(tag)),
                                  )
                                ).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Daily schedule header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daily Schedule',
                        style: GoogleFonts.museoModerno(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const DailyScheduleScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF12B347),
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'View All',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF12B347),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Loading indicator
              if (_isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF12B347)),
                      ),
                    ),
                  ),
                ),
              
              // No activities message
              if (!_isLoading && (_scheduledActivities == null || _scheduledActivities!.isEmpty))
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_note_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No activities scheduled yet',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start exploring to find activities',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to explore page
                              ref.read(mainTabProvider.notifier).state = 1; // Switch to Explore tab
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF12B347),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Explore Activities',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
              // Activity cards
              if (!_isLoading && _scheduledActivities != null && _scheduledActivities!.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= _scheduledActivities!.length) return null;
                      
                      final activity = _scheduledActivities![index];
                      final formattedStartTime = _formatTime(activity.startTime);
                      
                      return _buildActivityCard(
                        time: formattedStartTime,
                        title: activity.name,
                        location: activity.location.toString(), // Simplified for now
                        duration: '${activity.duration}min',
                        isConfirmed: true, // Hardcoded for now, should be activity.isConfirmed in real data
                        imagePath: activity.imageUrl,
                      );
                    },
                    childCount: _scheduledActivities?.length ?? 0,
                  ),
                ),
              
              // Add Moody suggestion card
              if (_shouldShowMoodySuggestion())
                SliverToBoxAdapter(
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to Moody screen when tapped
                      ref.read(mainTabProvider.notifier).state = 2; // Switch to Moody tab
                    },
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFAED),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            // Text content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "How was your day? ",
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const Text(
                                        "✨",
                                        style: TextStyle(
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "You have free time after 7 PM —\nwant a new suggestion?",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Moody character
                            Container(
                              width: 70,
                              height: 70,
                              decoration: const BoxDecoration(
                                color: Color(0xFFA6CBFF),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/images/moody_face.svg',
                                  width: 60,
                                  height: 60,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper method to format time
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
    return '$formattedHour:$minute $period';
  }
  
  // Get current activity or next upcoming activity time
  String _getCurrentOrNextActivityTime() {
    if (_scheduledActivities == null || _scheduledActivities!.isEmpty) {
      return '10:00 AM'; // Default time if no activities
    }
    
    // Sort activities by start time
    final sortedActivities = List<Activity>.from(_scheduledActivities!)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    
    // Get the current time
    final now = DateTime.now();
    
    // First check if there's a current activity in progress
    for (final activity in sortedActivities) {
      // Calculate end time of activity
      final endTime = activity.startTime.add(Duration(minutes: activity.duration));
      
      // If current time is between activity start and end time, this is the current activity
      if (now.isAfter(activity.startTime) && now.isBefore(endTime)) {
        return _formatTime(activity.startTime);
      }
    }
    
    // If no current activity, find the next upcoming one
    for (final activity in sortedActivities) {
      if (activity.startTime.isAfter(now)) {
        return _formatTime(activity.startTime);
      }
    }
    
    // If all activities have already finished, return the time of the last one
    return _formatTime(sortedActivities.last.startTime);
  }
  
  // Get current activity or next upcoming activity name
  String _getCurrentOrNextActivityName() {
    if (_scheduledActivities == null || _scheduledActivities!.isEmpty) {
      return 'Explore Golden Gate Park'; // Default name if no activities
    }
    
    // Sort activities by start time
    final sortedActivities = List<Activity>.from(_scheduledActivities!)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    
    // Get the current time
    final now = DateTime.now();
    
    // First check if there's a current activity in progress
    for (final activity in sortedActivities) {
      // Calculate end time of activity
      final endTime = activity.startTime.add(Duration(minutes: activity.duration));
      
      // If current time is between activity start and end time, this is the current activity
      if (now.isAfter(activity.startTime) && now.isBefore(endTime)) {
        return activity.name;
      }
    }
    
    // If no current activity, find the next upcoming one
    for (final activity in sortedActivities) {
      if (activity.startTime.isAfter(now)) {
        return activity.name;
      }
    }
    
    // If all activities have already finished, return the name of the last one
    return sortedActivities.last.name;
  }
  
  // Get current activity or next upcoming activity location
  String _getCurrentOrNextActivityLocation() {
    if (_scheduledActivities == null || _scheduledActivities!.isEmpty) {
      return 'Golden Gate Park, San Francisco'; // Default location if no activities
    }
    
    // Sort activities by start time
    final sortedActivities = List<Activity>.from(_scheduledActivities!)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    
    // Get the current time
    final now = DateTime.now();
    
    // First check if there's a current activity in progress
    for (final activity in sortedActivities) {
      // Calculate end time of activity
      final endTime = activity.startTime.add(Duration(minutes: activity.duration));
      
      // If current time is between activity start and end time, this is the current activity
      if (now.isAfter(activity.startTime) && now.isBefore(endTime)) {
        // Format the location for display
        return _formatLocation(activity.location.toString());
      }
    }
    
    // If no current activity, find the next upcoming one
    for (final activity in sortedActivities) {
      if (activity.startTime.isAfter(now)) {
        // Format the location for display
        return _formatLocation(activity.location.toString());
      }
    }
    
    // If all activities have already finished, return the location of the last one
    return _formatLocation(sortedActivities.last.location.toString());
  }
  
  // Get tags for current or upcoming activity
  List<String> _getCurrentOrNextActivityTags() {
    if (_scheduledActivities == null || _scheduledActivities!.isEmpty) {
      return ['Outdoor', 'Nature']; // Default tags if no activities
    }
    
    // Sort activities by start time
    final sortedActivities = List<Activity>.from(_scheduledActivities!)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    
    // Get the current time
    final now = DateTime.now();
    
    // First check if there's a current activity in progress
    for (final activity in sortedActivities) {
      // Calculate end time of activity
      final endTime = activity.startTime.add(Duration(minutes: activity.duration));
      
      // If current time is between activity start and end time, this is the current activity
      if (now.isAfter(activity.startTime) && now.isBefore(endTime)) {
        // Return first 2 tags or fewer if not enough tags
        return activity.tags.length > 2 
            ? activity.tags.sublist(0, 2) 
            : activity.tags;
      }
    }
    
    // If no current activity, find the next upcoming one
    for (final activity in sortedActivities) {
      if (activity.startTime.isAfter(now)) {
        // Return first 2 tags or fewer if not enough tags
        return activity.tags.length > 2 
            ? activity.tags.sublist(0, 2) 
            : activity.tags;
      }
    }
    
    // If all activities have already finished, return tags of the last one
    final lastActivity = sortedActivities.last;
    return lastActivity.tags.length > 2 
        ? lastActivity.tags.sublist(0, 2) 
        : lastActivity.tags;
  }
  
  // Get color for tag
  Color _getTagColor(String tag) {
    // Map specific keywords to colors
    if (tag.toLowerCase().contains('outdoor') || tag.toLowerCase().contains('nature')) {
      return Colors.green;
    } else if (tag.toLowerCase().contains('food') || tag.toLowerCase().contains('dining')) {
      return Colors.orange;
    } else if (tag.toLowerCase().contains('art') || tag.toLowerCase().contains('museum')) {
      return Colors.purple;
    } else if (tag.toLowerCase().contains('shopping') || tag.toLowerCase().contains('market')) {
      return Colors.blue;
    } else if (tag.toLowerCase().contains('wellness') || tag.toLowerCase().contains('spa')) {
      return Colors.teal;
    } else if (tag.toLowerCase().contains('night') || tag.toLowerCase().contains('drink')) {
      return Colors.indigo;
    }
    
    // Default color
    return Colors.blueGrey;
  }
  
  // Helper to check if an activity start time is in the past
  bool _isActivityTimeInPast(DateTime activityTime) {
    final now = DateTime.now();
    return activityTime.isBefore(now);
  }
  
  // Helper to format location string
  String _formatLocation(String location) {
    // Convert LatLng to a readable location name
    if (location.contains('LatLng')) {
      // If the string is a LatLng object representation
      print('Formatting location: $location');
      
      // Extract latitude and longitude if possible
      final regex = RegExp(r'LatLng\(([^,]+),\s*([^)]+)\)');
      final match = regex.firstMatch(location);
      
      if (match != null) {
        final lat = double.tryParse(match.group(1) ?? '0');
        final lng = double.tryParse(match.group(2) ?? '0');
        print('Extracted lat: $lat, lng: $lng');
      }
      
      // For now, use a friendly default
      return 'Golden Gate Park, San Francisco';
    }
    return location;
  }
  
  // Helper to get a color for a tag
  Color _getMyDayTagColor(String tag) {
    final tagColors = {
      'Outdoor': Colors.green,
      'Nature': Colors.blue,
      'Food': Colors.orange,
      'Art': Colors.purple,
      'Shopping': Colors.pink,
      'Entertainment': Colors.amber,
      'Fitness': Colors.teal,
      'Culture': Colors.indigo,
    };
    
    // Check if the tag contains any of the keywords
    for (final entry in tagColors.entries) {
      if (tag.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    
    // Default color if no match
    return Colors.blueGrey;
  }
  
  // Build weather button
  Widget _buildWeatherButton() {
    return GestureDetector(
      onTap: () => _showWeatherDropdown(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.wb_sunny_rounded,
              color: Color(0xFFFFA000),
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              '32°',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Show weather dropdown from top
  void _showWeatherDropdown(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) => AlertDialog(
        title: Text('Weather', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Weather details will be shown here', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins()),
          )
        ],
      ),
    );
  }
  
  // Build a featured tag widget
  Widget _buildFeaturedTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  // Build activity card widget
  Widget _buildActivityCard({
    required String time,
    required String title,
    required String location,
    required String duration,
    required bool isConfirmed,
    required String imagePath,
  }) {
    // Format the location to be more readable
    String formattedLocation = location;
    if (location.contains('LatLng')) {
      formattedLocation = 'Golden Gate Park, San Francisco';
    }
    
    // Determine activity type icon based on title or tags
    IconData activityIcon = Icons.local_activity;
    if (title.toLowerCase().contains('yoga') || title.toLowerCase().contains('fitness')) {
      activityIcon = Icons.fitness_center;
    } else if (title.toLowerCase().contains('hike') || title.toLowerCase().contains('walk')) {
      activityIcon = Icons.hiking;
    } else if (title.toLowerCase().contains('food') || title.toLowerCase().contains('dinner') || title.toLowerCase().contains('lunch')) {
      activityIcon = Icons.restaurant;
    } else if (title.toLowerCase().contains('museum') || title.toLowerCase().contains('art')) {
      activityIcon = Icons.museum;
    } else if (title.toLowerCase().contains('tour') || title.toLowerCase().contains('explore')) {
      activityIcon = Icons.travel_explore;
    }
    
    // Card contents for front and back
    final frontCard = Row(
      children: [
        // Activity image - LARGER now (120 vs 90 previously)
        Hero(
          tag: 'activity_image_$title',
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: Image.network(
              imagePath,
              width: 120,
              height: 130,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 120,
                height: 130,
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.image,
                  color: Colors.grey.shade400,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
        
        // Activity details
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isConfirmed 
                          ? const Color(0xFF12B347).withOpacity(0.1) 
                          : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: isConfirmed ? const Color(0xFF12B347).withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                            blurRadius: 4,
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Text(
                        isConfirmed ? 'Confirmed' : 'Pending',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isConfirmed ? const Color(0xFF12B347) : Colors.orange,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      time,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(activityIcon, color: const Color(0xFF12B347), size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.black45, size: 15),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        formattedLocation,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: Colors.black45, size: 15),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
    
    final backCard = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(activityIcon, color: const Color(0xFF12B347), size: 24),
              const SizedBox(width: 8),
              Text(
                _getActivityTypeFromTitle(title),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.black45, size: 18),
              const SizedBox(width: 8),
              Text(
                time,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.access_time_rounded, color: Colors.black45, size: 18),
              const SizedBox(width: 8),
              Text(
                duration,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.black45, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  formattedLocation,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF12B347)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tap again to return to overview',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    
    return StatefulBuilder(
      builder: (context, setState) {
        bool isFlipped = false;
        bool isPressed = false;
        
        // Handler for card tap
        void handleTap() {
          setState(() {
            if (isFlipped) {
              isFlipped = false;
            } else {
              isPressed = true;
              Future.delayed(const Duration(milliseconds: 150), () {
                if (mounted) {
                  setState(() {
                    isPressed = false;
                    isFlipped = true;
                  });
                }
              });
            }
          });
        }
        
        return GestureDetector(
          onTap: handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            transform: isPressed ? (Matrix4.identity()..scale(0.98)) : Matrix4.identity(),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: isFlipped 
                ? Container(
                    key: const ValueKey('back'),
                    height: 180,
                    child: backCard,
                  )
                : Container(
                    key: const ValueKey('front'),
                    child: frontCard,
                  ),
            ),
          ),
        );
      }
    );
  }

  // Helper to determine activity type from title
  String _getActivityTypeFromTitle(String title) {
    final title_lower = title.toLowerCase();
    if (title_lower.contains('yoga') || title_lower.contains('fitness')) {
      return 'Fitness Activity';
    } else if (title_lower.contains('hike') || title_lower.contains('walk')) {
      return 'Outdoor Adventure';
    } else if (title_lower.contains('food') || title_lower.contains('dinner') || title_lower.contains('lunch')) {
      return 'Dining Experience';  
    } else if (title_lower.contains('museum') || title_lower.contains('art')) {
      return 'Cultural Visit';
    } else if (title_lower.contains('tour') || title_lower.contains('explore')) {
      return 'Guided Experience';
    }
    return 'Scheduled Activity';
  }

  bool _shouldShowMoodySuggestion() {
    // Don't show if there are no activities
    if (_scheduledActivities == null || _scheduledActivities!.isEmpty) {
      return false;
    }
    
    final now = DateTime.now();
    final hour = now.hour;
    
    // Sort activities by start time
    final sortedActivities = List<Activity>.from(_scheduledActivities!)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    
    // Get the last activity end time (start time + duration)
    final lastActivity = sortedActivities.last;
    final lastActivityEndTime = lastActivity.startTime.add(Duration(minutes: lastActivity.duration));
    
    // Show suggestion if:
    // 1. It's evening (after 5 PM)
    // 2. AND it's either:
    //    a. After the last activity's end time, OR
    //    b. After 7 PM
    return hour >= 17 && (now.isAfter(lastActivityEndTime) || hour >= 19);
  }

  // Refresh data method
  void _refreshData() {
    // Force refresh activities
    print('Manual refresh requested');
    setState(() {
      _scheduledActivities = null;
      _isLoading = true;
    });
    _loadScheduledActivities();
    
    // Update gamification state
    try {
      ref.read(gamificationProvider.notifier).recordAppVisit();
    } catch (e) {
      print('Error recording app visit: $e');
    }
  }
}

class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  final PageController _timelineController = PageController(viewportFraction: 0.9);
  List<Activity>? _scheduledActivities;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadScheduledActivities();
  }
  
  // Add the missing greeting text method
  String _getGreetingText(int hour) {
    if (hour < 12) {
      return 'Good morning! Here\'s your day ahead.';
    } else if (hour < 17) {
      return 'Good afternoon! Here\'s what\'s coming up.';
    } else {
      return 'Good evening! Here\'s your schedule.';
    }
  }
  
  // Load scheduled activities from Supabase
  Future<void> _loadScheduledActivities() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final scheduledActivityService = ref.read(scheduledActivityServiceProvider);
      final activities = await scheduledActivityService.getScheduledActivities();
      
      setState(() {
        _scheduledActivities = activities;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading scheduled activities: $e');
      setState(() {
        _scheduledActivities = [];
        _isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    _timelineController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greetingText = _getGreetingText(now.hour);
    
    return SwirlBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'My Day',
                            style: GoogleFonts.museoModerno(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF12B347),
                              letterSpacing: 0.5,
                            ),
                          ),
                          _buildWeatherButton(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        greetingText,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Current activity or next up
              SliverToBoxAdapter(
                child: Container(
                  height: 220,
                  margin: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Left green highlight
                      Container(
                        width: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF12B347),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            bottomLeft: Radius.circular(24),
                          ),
                        ),
                      ),
                      // Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF12B347).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Now',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF12B347),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  // Show current time if available
                                  Text(
                                    _getCurrentOrNextActivityTime(),
                                    style: GoogleFonts.poppins(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _getCurrentOrNextActivityName(),
                                style: GoogleFonts.museoModerno(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, color: Colors.black54, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getCurrentOrNextActivityLocation(),
                                    style: GoogleFonts.poppins(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: _getCurrentOrNextActivityTags().map((tag) => 
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: _buildFeaturedTag(tag, _getTagColor(tag)),
                                  )
                                ).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Daily schedule header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daily Schedule',
                        style: GoogleFonts.museoModerno(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const MoodHomeScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF12B347),
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(50, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'View All',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF12B347),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Loading indicator
              if (_isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF12B347)),
                      ),
                    ),
                  ),
                ),
              
              // No activities message
              if (!_isLoading && (_scheduledActivities == null || _scheduledActivities!.isEmpty))
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_note_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No activities scheduled yet',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start exploring to find activities',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to explore page
                              ref.read(mainTabProvider.notifier).state = 1; // Switch to Explore tab
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF12B347),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Explore Activities',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
              // Activity cards
              if (!_isLoading && _scheduledActivities != null && _scheduledActivities!.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= _scheduledActivities!.length) return null;
                      
                      final activity = _scheduledActivities![index];
                      final formattedStartTime = _formatTime(activity.startTime);
                      
                      return _buildActivityCard(
                        time: formattedStartTime,
                        title: activity.name,
                        location: activity.location.toString(), // Simplified for now
                        duration: '${activity.duration}min',
                        isConfirmed: true, // Hardcoded for now, should be activity.isConfirmed in real data
                        imagePath: activity.imageUrl,
                      );
                    },
                    childCount: _scheduledActivities?.length ?? 0,
                  ),
                ),
                
              // Add some bottom spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Helper method to format time
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
    return '$formattedHour:$minute $period';
  }
  
  // Get current activity or next upcoming activity time
  String _getCurrentOrNextActivityTime() {
    if (_scheduledActivities == null || _scheduledActivities!.isEmpty) {
      return '10:00 AM'; // Default time if no activities
    }
    
    // Sort activities by start time
    final sortedActivities = List<Activity>.from(_scheduledActivities!)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    
    // Get the current time
    final now = DateTime.now();
    
    // First check if there's a current activity in progress
    for (final activity in sortedActivities) {
      // Calculate end time of activity
      final endTime = activity.startTime.add(Duration(minutes: activity.duration));
      
      // If current time is between activity start and end time, this is the current activity
      if (now.isAfter(activity.startTime) && now.isBefore(endTime)) {
        return _formatTime(activity.startTime);
      }
    }
    
    // If no current activity, find the next upcoming one
    for (final activity in sortedActivities) {
      if (activity.startTime.isAfter(now)) {
        return _formatTime(activity.startTime);
      }
    }
    
    // If all activities have already finished, return the time of the last one
    return _formatTime(sortedActivities.last.startTime);
  }
  
  // Get current activity or next upcoming activity name
  String _getCurrentOrNextActivityName() {
    if (_scheduledActivities == null || _scheduledActivities!.isEmpty) {
      return 'Explore Golden Gate Park'; // Default name if no activities
    }
    
    // Sort activities by start time
    final sortedActivities = List<Activity>.from(_scheduledActivities!)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    
    // Get the current time
    final now = DateTime.now();
    
    // First check if there's a current activity in progress
    for (final activity in sortedActivities) {
      // Calculate end time of activity
      final endTime = activity.startTime.add(Duration(minutes: activity.duration));
      
      // If current time is between activity start and end time, this is the current activity
      if (now.isAfter(activity.startTime) && now.isBefore(endTime)) {
        return activity.name;
      }
    }
    
    // If no current activity, find the next upcoming one
    for (final activity in sortedActivities) {
      if (activity.startTime.isAfter(now)) {
        return activity.name;
      }
    }
    
    // If all activities have already finished, return the name of the last one
    return sortedActivities.last.name;
  }
  
  // Get current activity or next upcoming activity location
  String _getCurrentOrNextActivityLocation() {
    if (_scheduledActivities == null || _scheduledActivities!.isEmpty) {
      return 'Golden Gate Park, San Francisco'; // Default location if no activities
    }
    
    // Sort activities by start time
    final sortedActivities = List<Activity>.from(_scheduledActivities!)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    
    // Get the current time
    final now = DateTime.now();
    
    // First check if there's a current activity in progress
    for (final activity in sortedActivities) {
      // Calculate end time of activity
      final endTime = activity.startTime.add(Duration(minutes: activity.duration));
      
      // If current time is between activity start and end time, this is the current activity
      if (now.isAfter(activity.startTime) && now.isBefore(endTime)) {
        // Format the location for display
        return _formatLocation(activity.location.toString());
      }
    }
    
    // If no current activity, find the next upcoming one
    for (final activity in sortedActivities) {
      if (activity.startTime.isAfter(now)) {
        // Format the location for display
        return _formatLocation(activity.location.toString());
      }
    }
    
    // If all activities have already finished, return the location of the last one
    return _formatLocation(sortedActivities.last.location.toString());
  }
  
  // Get tags for current or upcoming activity
  List<String> _getCurrentOrNextActivityTags() {
    if (_scheduledActivities == null || _scheduledActivities!.isEmpty) {
      return ['Outdoor', 'Nature']; // Default tags if no activities
    }
    
    // Sort activities by start time
    final sortedActivities = List<Activity>.from(_scheduledActivities!)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    
    // Get the current time
    final now = DateTime.now();
    
    // First check if there's a current activity in progress
    for (final activity in sortedActivities) {
      // Calculate end time of activity
      final endTime = activity.startTime.add(Duration(minutes: activity.duration));
      
      // If current time is between activity start and end time, this is the current activity
      if (now.isAfter(activity.startTime) && now.isBefore(endTime)) {
        // Return first 2 tags or fewer if not enough tags
        return activity.tags.length > 2 
            ? activity.tags.sublist(0, 2) 
            : activity.tags;
      }
    }
    
    // If no current activity, find the next upcoming one
    for (final activity in sortedActivities) {
      if (activity.startTime.isAfter(now)) {
        // Return first 2 tags or fewer if not enough tags
        return activity.tags.length > 2 
            ? activity.tags.sublist(0, 2) 
            : activity.tags;
      }
    }
    
    // If all activities have already finished, return tags of the last one
    final lastActivity = sortedActivities.last;
    return lastActivity.tags.length > 2 
        ? lastActivity.tags.sublist(0, 2) 
        : lastActivity.tags;
  }
  
  // Get color for tag
  Color _getTagColor(String tag) {
    // Map specific keywords to colors
    if (tag.toLowerCase().contains('outdoor') || tag.toLowerCase().contains('nature')) {
      return Colors.green;
    } else if (tag.toLowerCase().contains('food') || tag.toLowerCase().contains('dining')) {
      return Colors.orange;
    } else if (tag.toLowerCase().contains('art') || tag.toLowerCase().contains('museum')) {
      return Colors.purple;
    } else if (tag.toLowerCase().contains('shopping') || tag.toLowerCase().contains('market')) {
      return Colors.blue;
    } else if (tag.toLowerCase().contains('wellness') || tag.toLowerCase().contains('spa')) {
      return Colors.teal;
    } else if (tag.toLowerCase().contains('night') || tag.toLowerCase().contains('drink')) {
      return Colors.indigo;
    }
    
    // Default color
    return Colors.blueGrey;
  }
  
  // Helper to check if an activity start time is in the past
  bool _isActivityTimeInPast(DateTime activityTime) {
    final now = DateTime.now();
    return activityTime.isBefore(now);
  }
  
  // Helper to get a color for a tag
  Color _getMyDayTagColor(String tag) {
    final tagColors = {
      'Outdoor': Colors.green,
      'Nature': Colors.blue,
      'Food': Colors.orange,
      'Art': Colors.purple,
      'Shopping': Colors.pink,
      'Entertainment': Colors.amber,
      'Fitness': Colors.teal,
      'Culture': Colors.indigo,
    };
    
    // Check if the tag contains any of the keywords
    for (final entry in tagColors.entries) {
      if (tag.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    
    // Default color if no match
    return Colors.blueGrey;
  }
  
  // Build weather button
  Widget _buildWeatherButton() {
    return GestureDetector(
      onTap: () => _showWeatherDropdown(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.wb_sunny_rounded,
              color: Color(0xFFFFA000),
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              '32°',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Show weather dropdown from top
  void _showWeatherDropdown(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) => AlertDialog(
        title: Text('Weather', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Weather details will be shown here', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins()),
          )
        ],
      ),
    );
  }
  
  // Build a featured tag widget
  Widget _buildFeaturedTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  // Helper to format location string
  String _formatLocation(String location) {
    // Convert LatLng to a readable location name
    if (location.contains('LatLng')) {
      // If the string is a LatLng object representation
      print('AgendaScreen: Formatting location: $location');
      
      // Extract latitude and longitude if possible
      final regex = RegExp(r'LatLng\(([^,]+),\s*([^)]+)\)');
      final match = regex.firstMatch(location);
      
      if (match != null) {
        final lat = double.tryParse(match.group(1) ?? '0');
        final lng = double.tryParse(match.group(2) ?? '0');
        print('AgendaScreen: Extracted lat: $lat, lng: $lng');
      }
      
      // For now, use a friendly default
      return 'Golden Gate Park, San Francisco';
    }
    return location;
  }

  // Build activity card widget
  Widget _buildActivityCard({
    required String time,
    required String title,
    required String location,
    required String duration,
    required bool isConfirmed,
    required String imagePath,
  }) {
    // Format the location to be more readable
    String formattedLocation = location;
    if (location.contains('LatLng')) {
      formattedLocation = 'Golden Gate Park, San Francisco';
    }
    
    // Determine activity type icon based on title or tags
    IconData activityIcon = Icons.local_activity;
    if (title.toLowerCase().contains('yoga') || title.toLowerCase().contains('fitness')) {
      activityIcon = Icons.fitness_center;
    } else if (title.toLowerCase().contains('hike') || title.toLowerCase().contains('walk')) {
      activityIcon = Icons.hiking;
    } else if (title.toLowerCase().contains('food') || title.toLowerCase().contains('dinner') || title.toLowerCase().contains('lunch')) {
      activityIcon = Icons.restaurant;
    } else if (title.toLowerCase().contains('museum') || title.toLowerCase().contains('art')) {
      activityIcon = Icons.museum;
    } else if (title.toLowerCase().contains('tour') || title.toLowerCase().contains('explore')) {
      activityIcon = Icons.travel_explore;
    }
    
    // Card contents for front and back
    final frontCard = Row(
      children: [
        // Activity image - LARGER now (120 vs 90 previously)
        Hero(
          tag: 'activity_image_$title',
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: Image.network(
              imagePath,
              width: 120,
              height: 130,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 120,
                height: 130,
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.image,
                  color: Colors.grey.shade400,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
        
        // Activity details
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isConfirmed 
                          ? const Color(0xFF12B347).withOpacity(0.1) 
                          : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: isConfirmed ? const Color(0xFF12B347).withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                            blurRadius: 4,
                            spreadRadius: 0,
                          )
                        ],
                      ),
                      child: Text(
                        isConfirmed ? 'Confirmed' : 'Pending',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isConfirmed ? const Color(0xFF12B347) : Colors.orange,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      time,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(activityIcon, color: const Color(0xFF12B347), size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.black45, size: 15),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        formattedLocation,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: Colors.black45, size: 15),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
    
    final backCard = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(activityIcon, color: const Color(0xFF12B347), size: 24),
              const SizedBox(width: 8),
              Text(
                _getActivityTypeFromTitle(title),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.black45, size: 18),
              const SizedBox(width: 8),
              Text(
                time,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.access_time_rounded, color: Colors.black45, size: 18),
              const SizedBox(width: 8),
              Text(
                duration,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.black45, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  formattedLocation,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF12B347)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tap again to return to overview',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    
    return StatefulBuilder(
      builder: (context, setState) {
        bool isFlipped = false;
        bool isPressed = false;
        
        // Handler for card tap
        void handleTap() {
          setState(() {
            if (isFlipped) {
              isFlipped = false;
            } else {
              isPressed = true;
              Future.delayed(const Duration(milliseconds: 150), () {
                if (mounted) {
                  setState(() {
                    isPressed = false;
                    isFlipped = true;
                  });
                }
              });
            }
          });
        }
        
        return GestureDetector(
          onTap: handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            transform: isPressed ? (Matrix4.identity()..scale(0.98)) : Matrix4.identity(),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: isFlipped 
                ? Container(
                    key: const ValueKey('back'),
                    height: 180,
                    child: backCard,
                  )
                : Container(
                    key: const ValueKey('front'),
                    child: frontCard,
                  ),
            ),
          ),
        );
      }
    );
  }

  // Helper to determine activity type from title
  String _getActivityTypeFromTitle(String title) {
    final title_lower = title.toLowerCase();
    if (title_lower.contains('yoga') || title_lower.contains('fitness')) {
      return 'Fitness Activity';
    } else if (title_lower.contains('hike') || title_lower.contains('walk')) {
      return 'Outdoor Adventure';
    } else if (title_lower.contains('food') || title_lower.contains('dinner') || title_lower.contains('lunch')) {
      return 'Dining Experience';  
    } else if (title_lower.contains('museum') || title_lower.contains('art')) {
      return 'Cultural Visit';
    } else if (title_lower.contains('tour') || title_lower.contains('explore')) {
      return 'Guided Experience';
    }
    return 'Scheduled Activity';
  }
}

class MainScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;
  
  // Provider accessor for external control
  static StateProvider<int> get tabControllerProvider => mainTabProvider;
  
  const MainScreen({
    Key? key, 
    this.initialTabIndex = 0,
  }) : super(key: key);

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  void initState() {
    super.initState();
    // Set the initial tab index in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mainTabProvider.notifier).state = widget.initialTabIndex;
    });
  }
  
  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the tab provider if initialTabIndex changes
    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      ref.read(mainTabProvider.notifier).state = widget.initialTabIndex;
    }
  }
  
  // Screens in the bottom navigation
  final List<Widget> screens = [
    const MyDayScreen(),  // My Day is now first
    const ExploreScreen(),
    const MoodHomeScreen(),  // Moody is in the center
    const AgendaScreen(),
    const ProfileScreen(),
  ];
  
  @override
  Widget build(BuildContext context) {
    // Watch the tab provider
    final selectedIndex = ref.watch(mainTabProvider);
    
    return SwirlBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: selectedIndex,
          children: screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.calendar_today, 'My Day', selectedIndex == 0),
                  _buildNavItem(1, Icons.explore_outlined, 'Explore', selectedIndex == 1),
                  _buildNavItem(2, Icons.mood, 'Moody', selectedIndex == 2),
                  _buildNavItem(3, Icons.event_note_outlined, 'Agenda', selectedIndex == 3),
                  _buildNavItem(4, Icons.person_outline, 'Profile', selectedIndex == 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildNavItem(int index, IconData icon, String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        ref.read(mainTabProvider.notifier).state = index;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF12B347).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? const Color(0xFF12B347) : Colors.grey.shade600,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF12B347) : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 