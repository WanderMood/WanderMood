import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandermood/features/home/presentation/widgets/moody_character.dart';
import 'package:wandermood/features/auth/providers/user_provider.dart';
import 'package:wandermood/core/domain/providers/location_notifier_provider.dart';
import 'package:wandermood/features/weather/providers/weather_provider.dart';
import 'package:wandermood/features/plans/presentation/screens/plan_loading_screen.dart';
import 'package:wandermood/features/plans/presentation/screens/plan_result_screen.dart';
import 'package:wandermood/features/home/presentation/screens/moody_conversation_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:wandermood/features/gamification/providers/gamification_provider.dart';

class MoodHomeScreen extends ConsumerStatefulWidget {
  const MoodHomeScreen({super.key});

  @override
  ConsumerState<MoodHomeScreen> createState() => _MoodHomeScreenState();
}

class _MoodHomeScreenState extends ConsumerState<MoodHomeScreen> {
  final Set<String> _selectedMoods = {};
  String _timeGreeting = '';
  String _timeEmoji = '';
  bool _showMoodyConversation = false;
  
  @override
  void initState() {
    super.initState();
    _updateGreeting();
  }
  
  void _updateGreeting() {
    final hour = DateTime.now().hour;
    setState(() {
      if (hour >= 5 && hour < 12) {
        _timeGreeting = 'Good morning';
        _timeEmoji = '☀️'; // Morning sun
      } else if (hour >= 12 && hour < 17) {
        _timeGreeting = 'Good afternoon';
        _timeEmoji = '🌤️'; // Sun with clouds
      } else if (hour >= 17 && hour < 21) {
        _timeGreeting = 'Good evening';
        _timeEmoji = '🌆'; // Evening cityscape
      } else {
        _timeGreeting = 'Hi night owl';
        _timeEmoji = '🌙'; // Moon
      }
    });
  }

  final List<MoodOption> _moods = [
    MoodOption(
      emoji: '⛰️',
      label: 'Adventure',
      color: const Color(0xFFFFC266),
    ),
    MoodOption(
      emoji: '😌',
      label: 'Relaxed',
      color: const Color(0xFF90CDF4),
    ),
    MoodOption(
      emoji: '❤️',
      label: 'Romantic',
      color: const Color(0xFFF48FB1),
    ),
    MoodOption(
      emoji: '⚡',
      label: 'Energetic',
      color: const Color(0xFFFFD54F),
    ),
    MoodOption(
      emoji: '🎉',
      label: 'Excited',
      color: const Color(0xFFCE93D8),
    ),
    MoodOption(
      emoji: '🎁',
      label: 'Surprise',
      color: const Color(0xFFF8B195),
    ),
    MoodOption(
      emoji: '🍎',
      label: 'Foody',
      color: const Color(0xFFFF8A65),
    ),
    MoodOption(
      emoji: '🎭',
      label: 'Festive',
      color: const Color(0xFF81C784),
    ),
    MoodOption(
      emoji: '☘️',
      label: 'Mindful',
      color: const Color(0xFF66BB6A),
    ),
    MoodOption(
      emoji: '👨‍👩‍👧‍👦',
      label: 'Family fun',
      color: const Color(0xFF7986CB),
    ),
    MoodOption(
      emoji: '💡',
      label: 'Creative',
      color: const Color(0xFFFFEE58),
    ),
    MoodOption(
      emoji: '👨‍👩‍👧',
      label: 'Freactives',
      color: const Color(0xFF4FC3F7),
    ),
    MoodOption(
      emoji: '💎',
      label: 'Luxurious',
      color: const Color(0xFF9575CD),
    ),
  ];

  void _toggleMood(MoodOption mood) {
    setState(() {
      if (_selectedMoods.contains(mood.label)) {
        _selectedMoods.remove(mood.label);
      } else if (_selectedMoods.length < 3) {
        _selectedMoods.add(mood.label);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You can select up to 3 moods',
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
  }

  void _generatePlan() {
    if (_selectedMoods.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PlanLoadingScreen(
            selectedMoods: _selectedMoods.toList(),
            onLoadingComplete: () {
              // Navigate to plan result screen after loading
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => PlanResultScreen(
                    selectedMoods: _selectedMoods.toList(),
                    moodString: _selectedMoods.join(" & "),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  // Show weather details dialog
  void _showWeatherDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Location and date
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'San Francisco',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Today, ${DateTime.now().day} ${_getMonthName(DateTime.now().month)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Current weather
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '22°',
                      style: GoogleFonts.poppins(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFB300),
                      ),
                    ),
                    Text(
                      'Sunny',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Hourly forecast
            Text(
              'Hourly Forecast',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildHourlyWeather('Now', '22°', Icons.wb_sunny),
                  _buildHourlyWeather('11 AM', '23°', Icons.wb_sunny),
                  _buildHourlyWeather('12 PM', '24°', Icons.wb_sunny),
                  _buildHourlyWeather('1 PM', '24°', Icons.wb_cloudy),
                  _buildHourlyWeather('2 PM', '23°', Icons.wb_cloudy),
                  _buildHourlyWeather('3 PM', '22°', Icons.wb_cloudy),
                  _buildHourlyWeather('4 PM', '21°', Icons.wb_cloudy),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Additional info
            Text(
              'Additional Information',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherInfo('Humidity', '68%', Icons.water_drop),
                _buildWeatherInfo('Wind', '8 km/h', Icons.air),
                _buildWeatherInfo('Feels Like', '23°', Icons.thermostat),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper function for month names
  String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June', 
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }
  
  // Build hourly weather widget
  Widget _buildHourlyWeather(String time, String temp, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Icon(
            icon,
            color: const Color(0xFFFFB300),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            temp,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
  
  // Build weather info widget
  Widget _buildWeatherInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF12B347),
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // Show location selection dialog
  void _showLocationDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              'Select Location',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // Current location button
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF12B347).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.my_location,
                  color: Color(0xFF12B347),
                ),
              ),
              title: Text(
                'Current Location',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Using GPS',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              onTap: () {
                // Close the dialog
                Navigator.pop(context);
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Using current location'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            
            const Divider(height: 32),
            
            // Recent locations
            Text(
              'Recent Locations',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            
            // Location list
            _buildLocationItem('San Francisco', Icons.location_city),
            _buildLocationItem('New York', Icons.location_city),
            _buildLocationItem('Los Angeles', Icons.location_city),
            
            const Spacer(),
            
            // Add new location button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Show search dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Search location feature coming soon'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add New Location'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: const Color(0xFF12B347).withOpacity(0.5)),
                  foregroundColor: const Color(0xFF12B347),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build location item widget
  Widget _buildLocationItem(String name, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF12B347)),
      title: Text(
        name,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        // Show selected location
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected location: $name'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  // Show dialog for talking to Moody
  void _showMoodyTalkDialog(BuildContext context) {
    // Instead of showing a bottom sheet, set state to show conversation overlay
    setState(() {
      _showMoodyConversation = true;
    });
  }
  
  // Add method to hide the conversation
  void _hideMoodyConversation() {
    setState(() {
      _showMoodyConversation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(locationNotifierProvider);
    final userData = ref.watch(userDataProvider);
    final weatherAsync = ref.watch(weatherProvider);
    
    return Stack(
      children: [
        Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFFDF5),  // Warm cream
              Color(0xFFFFF3E0),  // Warm yellow
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with user avatar and location
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF12B347),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'U',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: const Color(0xFF12B347),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Location dropdown - now clickable
                    Expanded(
                      child: InkWell(
                        onTap: () => _showLocationDialog(context, ref),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Color(0xFF12B347),
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'San Francisco',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Weather button - now clickable
                    InkWell(
                      onTap: () {
                        // Show weather details dialog
                        _showWeatherDetails(context);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.wb_sunny,
                              color: Color(0xFFFFB300),
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '22°',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Greeting and Moody
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                    userData.when(
                                data: (data) {
                                  String firstName = '';
                                  if (data != null && data.containsKey('name') && data['name'] != null) {
                          firstName = data['name'].toString().split(' ')[0];
                                  } else {
                                    firstName = 'explorer';
                                  }
                                  return Center(
                                    child: Text(
                                      "$_timeGreeting $firstName $_timeEmoji",
                                      style: GoogleFonts.poppins(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                },
                                loading: () => Center(
                                  child: Text(
                                    "$_timeGreeting explorer $_timeEmoji",
                                    style: GoogleFonts.poppins(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                error: (_, __) => Center(
                                  child: Text(
                                    "$_timeGreeting explorer $_timeEmoji",
                                    style: GoogleFonts.poppins(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'How are you feeling today?',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Moody Character
              Center(
                child: GestureDetector(
                  onTap: () {
                        // Show conversation screen when tapping on Moody
                    _showMoodyTalkDialog(context);
                  },
                  child: MoodyCharacter(
                    size: 120,
                    mood: _selectedMoods.isEmpty ? 'default' : 'happy',
                  ),
                ),
              ),

              const SizedBox(height: 24),
              
                  // Update Talk to Moody input field
              GestureDetector(
                onTap: () {
                      // Show conversation screen when tapping on input field
                  _showMoodyTalkDialog(context);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Talk to me or select moods for your daily plan',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.mic,
                        color: const Color(0xFF12B347).withOpacity(0.7),
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Put mood tiles and button in a single scrollable container
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selected moods indicator
                      if (_selectedMoods.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Selected moods: ',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  color: Colors.black54,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  _selectedMoods.join(', '),
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: const Color(0xFF4CAF50),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Grid of mood tiles
                      GridView.count(
                        crossAxisCount: 4,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(), // Disable grid's own scrolling
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.0, // Enforce square aspect ratio
                        children: _moods.map((mood) {
                          final isSelected = _selectedMoods.contains(mood.label);
                          return GestureDetector(
                            onTap: () => _toggleMood(mood),
                            child: Container(
                              // Fixed size constraints to prevent overflow
                              constraints: const BoxConstraints(
                                minWidth: 80,
                                maxWidth: 80,
                                minHeight: 80,
                                maxHeight: 80,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    mood.color.withOpacity(1.0),
                                    mood.color.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected 
                                    ? mood.color.withOpacity(0.9) 
                                    : mood.color.withOpacity(0.4),
                                  width: isSelected ? 2.5 : 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected 
                                      ? mood.color.withOpacity(0.6)
                                      : mood.color.withOpacity(0.3),
                                    blurRadius: isSelected ? 10 : 5,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                                  child: Stack(
                                    children: [
                                      // Main content with emoji and label
                                      Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    mood.emoji,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 70, // Constrain text width
                                    child: Text(
                                      mood.label,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11, // Slightly smaller font
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1, // Limit to single line
                                      overflow: TextOverflow.ellipsis, // Handle long text
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Checkmark indicator (only shown when selected)
                                      if (isSelected)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            width: 18,
                                            height: 18,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: mood.color.withOpacity(0.8),
                                                width: 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.1),
                                                  blurRadius: 2,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.check,
                                                size: 12,
                                                color: Color(0xFF12B347),
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      // CTA Button directly below grid in the same scroll view
                      Container(
                        width: double.infinity,
                        height: 56,
                        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 30, top: 8),
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
                          onPressed: _selectedMoods.isEmpty ? null : _generatePlan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedMoods.isEmpty 
                                ? const Color(0xFFD0D0D0) // Light gray for inactive state
                                : const Color(0xFF12B347), // Green for active state
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            "Let's create your perfect plan! 🎯",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
        ),
        
        // Add the MoodyConversationScreen overlay when active
        if (_showMoodyConversation)
          MoodyConversationScreen(
            onClose: _hideMoodyConversation,
          ),
      ],
    );
  }
}

class MoodOption {
  final String emoji;
  final String label;
  final Color color;

  const MoodOption({
    required this.emoji,
    required this.label,
    required this.color,
  });
} 