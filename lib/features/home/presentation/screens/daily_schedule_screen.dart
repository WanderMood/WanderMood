import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:wandermood/core/presentation/widgets/swirl_background.dart';
import 'package:wandermood/features/plans/data/services/scheduled_activity_service.dart';
import 'package:wandermood/features/plans/domain/models/activity.dart';

class DailyScheduleScreen extends ConsumerStatefulWidget {
  const DailyScheduleScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DailyScheduleScreen> createState() => _DailyScheduleScreenState();
}

class _DailyScheduleScreenState extends ConsumerState<DailyScheduleScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Activity>? _scheduledActivities;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScheduledActivities();
  }

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

  void _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF12B347),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      // Reload activities for the selected date
      _loadScheduledActivities();
    }
  }

  String _getFormattedDate() {
    if (_isToday(_selectedDate)) {
      return 'Today, ${DateFormat('d MMMM').format(_selectedDate)}';
    } else if (_isTomorrow(_selectedDate)) {
      return 'Tomorrow, ${DateFormat('d MMMM').format(_selectedDate)}';
    } else {
      return DateFormat('EEEE, d MMMM').format(_selectedDate);
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1), // Light beige background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Daily Schedule',
          style: GoogleFonts.museoModerno(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF12B347),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Colors.black),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date selector
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: () => _selectDate(context),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF12B347),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getFormattedDate(),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF12B347)),
                    ),
                  )
                : _scheduledActivities == null || _scheduledActivities!.isEmpty
                    ? _buildEmptyState()
                    : _buildScheduleList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 72,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No activities scheduled',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to explore activities',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to explore page
                Navigator.pop(context);
                // To be implemented: navigate to explore tab
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF12B347),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.explore),
              label: Text(
                'Explore Activities',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleList() {
    // Group activities by time of day
    final Map<String, List<Activity>> groupedActivities = {
      'Morning': [],
      'Afternoon': [],
      'Evening': [],
    };

    // Sort activities by start time
    final sortedActivities = List<Activity>.from(_scheduledActivities!)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    // Group activities
    for (final activity in sortedActivities) {
      final hour = activity.startTime.hour;
      if (hour >= 5 && hour < 12) {
        groupedActivities['Morning']!.add(activity);
      } else if (hour >= 12 && hour < 17) {
        groupedActivities['Afternoon']!.add(activity);
      } else {
        groupedActivities['Evening']!.add(activity);
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (groupedActivities['Morning']!.isNotEmpty)
          _buildTimeSection('Morning', groupedActivities['Morning']!),
        if (groupedActivities['Afternoon']!.isNotEmpty)
          _buildTimeSection('Afternoon', groupedActivities['Afternoon']!),
        if (groupedActivities['Evening']!.isNotEmpty)
          _buildTimeSection('Evening', groupedActivities['Evening']!),
      ],
    );
  }

  Widget _buildTimeSection(String title, List<Activity> activities) {
    String emoji;
    switch (title) {
      case 'Morning':
        emoji = '🌅';
        break;
      case 'Afternoon':
        emoji = '☀️';
        break;
      case 'Evening':
        emoji = '🌙';
        break;
      default:
        emoji = '⏰';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Row(
            children: [
              Text(
                '$emoji ',
                style: const TextStyle(fontSize: 22),
              ),
              Text(
                title,
                style: GoogleFonts.museoModerno(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF12B347),
                ),
              ),
            ],
          ),
        ),
        ...activities.map((activity) => _buildActivityCard(activity)).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActivityCard(Activity activity) {
    final formattedTime = DateFormat('h:mm a').format(activity.startTime);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Activity image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.network(
              activity.imageUrl,
              width: 100,
              height: 120,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 100,
                height: 120,
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.image,
                  color: Colors.grey.shade400,
                  size: 40,
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF12B347).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Confirmed',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF12B347),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formattedTime,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activity.name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.black45, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          activity.location.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
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
                      const Icon(Icons.access_time, color: Colors.black45, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${activity.duration} minutes',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
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
      ),
    );
  }
} 