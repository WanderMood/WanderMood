import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class BookingService {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<Map<String, dynamic>> bookActivity(String activityId, DateTime date) async {
    try {
      final response = await _client
          .from('bookings')
          .insert({
            'activity_id': activityId,
            'user_id': _client.auth.currentUser!.id,
            'date': date.toIso8601String(),
            'status': 'confirmed'
          })
          .select()
          .single();
      
      return response;
    } catch (e) {
      throw Exception('Failed to book activity: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserBookings() async {
    try {
      final response = await _client
          .from('bookings')
          .select('*, activities(*)')
          .eq('user_id', _client.auth.currentUser!.id)
          .order('date', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get user bookings: $e');
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _client
          .from('bookings')
          .update({'status': 'cancelled'})
          .eq('id', bookingId);
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }
} 