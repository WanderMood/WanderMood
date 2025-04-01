import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../widgets/activity_card.dart';
import '../../domain/models/activity.dart';
import '../../services/activity_service.dart';

class PlanScreen extends ConsumerStatefulWidget {
  final List<String> selectedMoods;

  const PlanScreen({
    super.key,
    required this.selectedMoods,
  });

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  List<Activity> _activities = [];
  Set<String> _selectedActivityIds = {}; // Track selected activities by ID
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final activities = await ref.read(activityServiceProvider.notifier).generatePlan(
      mood: widget.selectedMoods.join(','),
      location: 'Rotterdam',
      date: DateTime.now(),
    );
    
    if (mounted) {
      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    }
  }

  void _toggleActivitySelection(Activity activity) {
    setState(() {
      if (_selectedActivityIds.contains(activity.id)) {
        _selectedActivityIds.remove(activity.id);
      } else {
        _selectedActivityIds.add(activity.id);
      }
    });
  }

  void _handleActivityDismissed(Activity activity, DismissDirection direction) {
    setState(() {
      _activities.remove(activity);
      if (direction == DismissDirection.endToStart) {
        _selectedActivityIds.remove(activity.id);
      } else {
        _selectedActivityIds.add(activity.id);
      }
    });
  }

  void _handleActivityTap(Activity activity) {
    context.push('/activity/${activity.id}');
  }

  void _handleRefresh() async {
    setState(() {
      _isLoading = true;
    });
    await _loadActivities();
  }

  void _handleSavePlan() async {
    final selectedActivities = _activities.where((a) => _selectedActivityIds.contains(a.id)).toList();
    await ref.read(activityServiceProvider.notifier).savePlan(selectedActivities);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Plan saved successfully!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
    }
  }

  void _handleSharePlan() async {
    final selectedActivities = _activities.where((a) => _selectedActivityIds.contains(a.id)).toList();
    await ref.read(activityServiceProvider.notifier).sharePlan(selectedActivities);
  }

  Future<void> _handleSwapActivity(Activity activity) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final newActivity = await ref.read(activityServiceProvider.notifier).generateAlternativeActivity(
        currentActivityId: activity.id,
        time: activity.time,
        mood: widget.selectedMoods.join(','),
        location: 'Rotterdam',
      );

      setState(() {
        final index = _activities.indexWhere((a) => a.id == activity.id);
        if (index != -1) {
          _activities[index] = newActivity;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to swap activity. Please try again.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildLoadingState() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFAFF4), Color(0xFFFFF5AF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Selected moods display
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: widget.selectedMoods.map((mood) =>
                    Chip(
                      label: Text(
                        mood,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF1A4A24),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: const Color(0xFFE8F5E9),
                    ),
                  ).toList(),
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  "Blending your moods...",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A4A24),
                  ),
                ).animate().fadeIn(),
                
                const SizedBox(height: 16),
                
                Text(
                  "Finding the perfect balance of activities for your day",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                
                const SizedBox(height: 32),
                
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A4A24)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    return WillPopScope(
      onWillPop: () async {
        context.go('/home');
        return false;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF1A4A24),
              size: 20,
            ),
            onPressed: () {
              if (_isLoading) {
                setState(() {
                  _isLoading = false;
                });
              }
              context.go('/home');
            },
          ),
          centerTitle: true,
          title: Text(
            'Your Perfect Day',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A4A24),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: Color(0xFF1A4A24), size: 20),
              onPressed: _handleRefresh,
            ),
            IconButton(
              icon: Icon(Icons.share, color: Color(0xFF1A4A24), size: 20),
              onPressed: _handleSharePlan,
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFAFF4),
                Color(0xFFFFF5AF),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60), // Add space for AppBar
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildTimeBlock('Morning', _activities.where((a) => a.time.contains('AM') && int.parse(a.time.split(':')[0]) >= 5 && int.parse(a.time.split(':')[0]) < 12).toList()),
                      _buildTimeBlock('Afternoon', _activities.where((a) => a.time.contains('PM') && int.parse(a.time.split(':')[0]) < 5).toList()),
                      _buildTimeBlock('Evening', _activities.where((a) => a.time.contains('PM') && int.parse(a.time.split(':')[0]) >= 5 && int.parse(a.time.split(':')[0]) < 9).toList()),
                      _buildTimeBlock('Night', _activities.where((a) => 
                        (a.time.contains('PM') && int.parse(a.time.split(':')[0]) >= 9) ||
                        (a.time.contains('AM') && int.parse(a.time.split(':')[0]) < 5)
                      ).toList()),
                    ],
                  ),
                ),

                // Bottom action bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_selectedActivityIds.length} activities selected',
                          style: GoogleFonts.poppins(
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _selectedActivityIds.isNotEmpty ? _handleSavePlan : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Save Plan',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeBlock(String title, List<Activity> activities) {
    if (activities.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort activities by time
    activities.sort((a, b) {
      final aTime = _parseTime(a.time);
      final bTime = _parseTime(b.time);
      return aTime.compareTo(bTime);
    });

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                title: Row(
                  children: [
                    Icon(
                      title == 'Morning' ? Icons.wb_sunny
                      : title == 'Afternoon' ? Icons.wb_cloudy
                      : title == 'Evening' ? Icons.nightlight_round
                      : Icons.bedtime,
                      color: const Color(0xFF4CAF50),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A4A24),
                            ),
                          ),
                          Text(
                            'We found ${activities.length} great activities for you',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                children: [
                  const SizedBox(height: 16),
                  ...activities.map((activity) {
                    final isSelected = _selectedActivityIds.contains(activity.id);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFFE0E0E0),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _handleActivityTap(activity),
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () => _toggleActivitySelection(activity),
                                            child: Icon(
                                              isSelected ? Icons.check_circle : Icons.circle_outlined,
                                              color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFFE0E0E0),
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              activity.title,
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF1A4A24),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        activity.time,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: const Color(0xFF4CAF50),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (activity.description.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 36),
                                    child: Text(
                                      activity.description,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: const Color(0xFF666666),
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.only(left: 36),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Distance info
                                      Expanded(
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.location_on_outlined,
                                              color: Color(0xFF666666),
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                activity.distance,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: const Color(0xFF666666),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Swap button
                                      IconButton(
                                        icon: Transform.scale(
                                          scale: 0.9,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.swap_horiz_rounded,
                                              color: Color(0xFF4CAF50),
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                        onPressed: () => _handleSwapActivity(activity),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        tooltip: 'Swap for another activity',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to parse time string into comparable DateTime
  DateTime _parseTime(String timeStr) {
    final now = DateTime.now();
    final isPM = timeStr.contains('PM');
    final timeParts = timeStr.replaceAll(RegExp(r'[AP]M'), '').trim().split(':');
    var hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    if (isPM && hour != 12) {
      hour += 12;
    } else if (!isPM && hour == 12) {
      hour = 0;
    }
    
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
} 