import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandermood/core/presentation/widgets/swirl_background.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wandermood/features/home/presentation/screens/main_screen.dart';
import 'package:wandermood/features/plans/domain/models/activity.dart';
import 'package:wandermood/features/plans/domain/enums/payment_type.dart';
import 'package:wandermood/features/plans/domain/enums/time_slot.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wandermood/features/plans/data/services/scheduled_activity_service.dart';
import 'package:go_router/go_router.dart';

class ConfirmPlanScreen extends ConsumerStatefulWidget {
  final List<Activity>? activities;

  const ConfirmPlanScreen({
    Key? key,
    this.activities,
  }) : super(key: key);

  @override
  ConsumerState<ConfirmPlanScreen> createState() => _ConfirmPlanScreenState();
}

class _ConfirmPlanScreenState extends ConsumerState<ConfirmPlanScreen> {
  late List<Activity> activities;
  late List<Activity> freeActivities;
  late List<Activity> bookingActivities;

  @override
  void initState() {
    super.initState();
    // Use the activities passed from PlanSummarySheet, or fall back to dummy data if none
    activities = widget.activities ?? _getDummyActivities();
    
    // Separate activities by payment type
    freeActivities = activities.where((activity) => activity.paymentType == PaymentType.free).toList();
    bookingActivities = activities.where((activity) => activity.paymentType != PaymentType.free).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Base swirl background with beige color
          const SwirlBackground(
            child: SizedBox.expand(),
          ),
          
          // Main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Confirm Your Plan',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Subtitle indicating selected activities
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Here are your selected activities',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                
                // Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      Text(
                        'Ready to Go',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (freeActivities.isEmpty)
                        _buildEmptyState("No free activities selected"),
                      ...freeActivities.map((activity) => _buildActivityCard(activity)).toList(),
                      
                      const SizedBox(height: 32),
                      Text(
                        'Requires Booking',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (bookingActivities.isEmpty)
                        _buildEmptyState("No booking activities selected"),
                      ...bookingActivities.map((activity) => _buildActivityCard(activity)).toList(),
                    ],
                  ),
                ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to My Day screen using a single navigation call
                            _navigateWithLoading(context, 'Booking your activities...', isConfirmed: true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Book Now',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            // Navigate to My Day screen using a single navigation call
                            _navigateWithLoading(context, 'Saving your plan...', isConfirmed: false);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4CAF50),
                            side: const BorderSide(color: Color(0xFF4CAF50)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Text(
                            'Book Later',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          // Navigate to My Day screen using a single navigation call
                          _navigateWithLoading(context, 'Finding free activities...', onlyFree: true);
                        },
                        child: Text(
                          'Start with Free Activities',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF4CAF50),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  // Helper method to format DateTime to a readable time string
  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
    return '$formattedHour:$minute $period';
  }

  // Helper method to show loading and navigate after delay
  void _navigateWithLoading(BuildContext context, String loadingMessage, {bool isConfirmed = false, bool onlyFree = false}) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                ),
                const SizedBox(height: 20),
                Text(
                  loadingMessage,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
    
    try {
      debugPrint('Starting _navigateWithLoading process');
      
      // Get the scheduled activity service
      final scheduledActivityService = ref.read(scheduledActivityServiceProvider);
      
      // Filter activities if only free is selected
      final activitiesToSave = onlyFree ? freeActivities : activities;
      
      debugPrint('About to save ${activitiesToSave.length} activities to Supabase');
      
      try {
        // Save activities to Supabase
        debugPrint('Activities to save: ${activitiesToSave.map((a) => a.name).join(', ')}');
        for (final activity in activitiesToSave) {
          debugPrint('Activity: ${activity.name}, StartTime: ${activity.startTime}, Type: ${activity.paymentType}');
        }
        await scheduledActivityService.saveScheduledActivities(activitiesToSave, isConfirmed: isConfirmed);
        debugPrint('Activities saved successfully');
        
        // Force a reload of the activities in the MyDayScreen
        ref.invalidate(scheduledActivityServiceProvider);
      } catch (serviceError) {
        debugPrint('Warning: Error saving activities: $serviceError');
        debugPrint('Stack trace: ${StackTrace.current}');
        // Continue with navigation despite service error
      }
      
      // Delay for a bit to show the loading indicator
      await Future.delayed(const Duration(seconds: 1));
      
      // Handle navigation safely
      if (!mounted) {
        debugPrint('Widget is no longer mounted after delay');
        return;
      }
      
      // Close the dialog first using Navigator.pop if context is still valid
      if (context.mounted) {
        Navigator.pop(context); // Pop the dialog
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Your activities have been saved successfully! Navigating to My Day...',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        
        // IMPORTANT: Try different navigation approach for reliability
        try {
          // First try the GoRouter approach with the tab parameter
          context.goNamed('main', queryParameters: {'tab': '0'});
        } catch (navError) {
          debugPrint('GoRouter navigation attempt failed: $navError');
          
          // Fallback to direct navigation method
          try {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const MainScreen(initialTabIndex: 0),
              ),
              (route) => false,
            );
          } catch (pushError) {
            debugPrint('Fallback navigation attempt failed: $pushError');
            
            // Last resort - try simple push
            if (context.mounted) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MainScreen(initialTabIndex: 0),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Outer error in _navigateWithLoading: $e');
      
      // Close the dialog first if it's showing
      if (context.mounted) {
        try {
          Navigator.pop(context);
        } catch (navError) {
          debugPrint('Error popping dialog: $navError');
        }
      }
      
      // Show error dialog
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Error',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Failed to save your activities. Please try again.\n\nError: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _buildActivityCard(Activity activity) {
    final startTime = activity.startTime;
    final endTime = startTime.add(Duration(minutes: activity.duration));
    final timeString = '${_formatTime(startTime)} - ${_formatTime(endTime)} (${activity.duration}min)';
    final status = activity.paymentType == PaymentType.free
        ? 'Free Activity'
        : activity.paymentType == PaymentType.reservation
            ? 'Reservation Required'
            : 'Ticket Required';
    final statusColor = activity.paymentType == PaymentType.free
        ? const Color(0xFF2E7D32)  // Dark green for free activities
        : const Color(0xFF2196F3); // Blue for paid activities
    final bgColor = activity.paymentType == PaymentType.free
        ? const Color(0xFFDCF3DC)  // Light green for free activities
        : const Color(0xFFE3F2FD); // Light blue for paid activities

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF5EE), // Light green background for all cards
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              activity.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeString,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                if (status != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: activity.paymentType == PaymentType.free
                        ? const Color(0xFFDCF3DC) // Light green background for free
                        : const Color(0xFFFFECCC), // Light orange for paid
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                    status,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: activity.paymentType == PaymentType.free
                          ? const Color(0xFF2E7D32) // Dark green text for free
                          : const Color(0xFFE65100), // Dark orange for paid
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate()
     .fade(duration: 350.ms, delay: 50.ms, curve: Curves.easeOut)
     .moveY(begin: 5, duration: 300.ms, delay: 50.ms, curve: Curves.easeOutQuad);
  }
  
  // This is a fallback for testing purposes only
  List<Activity> _getDummyActivities() {
    // Create a list of sample activities in case none are passed
    final now = DateTime.now();
    return [
      Activity(
        id: 'morning-yoga-001',
        name: 'Morning Yoga in the Park',
        description: 'Start your day with a refreshing yoga session in the beautiful city park. Perfect for all skill levels.',
        startTime: DateTime(now.year, now.month, now.day, 8, 30),
        duration: 60,
        imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b',
        tags: ['Wellness 🧘‍♀️', 'Outdoor 🌿', 'Active 💪'],
        rating: 4.8,
        timeSlot: 'morning',
        timeSlotEnum: TimeSlot.morning,
        location: const LatLng(52.3676, 4.9041), // Sample location in Amsterdam
        paymentType: PaymentType.free,
      ),
      Activity(
        id: 'jazz-cocktails-001',
        name: 'Jazz & Cocktails Evening',
        description: 'End your day with smooth jazz and expertly crafted cocktails.',
        startTime: DateTime(now.year, now.month, now.day, 21, 30),
        duration: 90,
        imageUrl: 'https://images.unsplash.com/photo-1545128485-c400e7702796',
        tags: ['Music 🎷', 'Drinks 🍸', 'Night 🌙'],
        rating: 4.9,
        timeSlot: 'evening',
        timeSlotEnum: TimeSlot.evening,
        location: const LatLng(52.3676, 4.9041), // Sample location in Amsterdam
        paymentType: PaymentType.free,
      ),
      Activity(
        id: 'breakfast-cafe-001',
        name: 'Romantic Breakfast at Café Fleur',
        description: 'Enjoy a delightful breakfast with fresh pastries and artisanal coffee.',
        startTime: DateTime(now.year, now.month, now.day, 10, 30),
        duration: 60,
        imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085',
        tags: ['Food 🍳', 'Romantic ❤️', 'Cozy ☕'],
        rating: 4.6,
        timeSlot: 'morning',
        timeSlotEnum: TimeSlot.morning,
        location: const LatLng(52.3676, 4.9041), // Sample location in Amsterdam
        paymentType: PaymentType.reservation,
      ),
      Activity(
        id: 'cooking-class-001',
        name: "Couple's Cooking Class",
        description: 'Learn to cook together in this fun and interactive cooking class.',
        startTime: DateTime(now.year, now.month, now.day, 15, 30),
        duration: 120,
        imageUrl: 'https://images.unsplash.com/photo-1556910103-1c02745aae4d',
        tags: ['Food 🍳', 'Learning 📚', 'Indoor 🏠'],
        rating: 4.7,
        timeSlot: 'afternoon',
        timeSlotEnum: TimeSlot.afternoon,
        location: const LatLng(52.3676, 4.9041), // Sample location in Amsterdam
        paymentType: PaymentType.reservation,
      ),
    ];
  }
} 