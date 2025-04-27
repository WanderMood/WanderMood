import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class PlanStorageService {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<Map<String, dynamic>> savePlan(Map<String, dynamic> plan) async {
    try {
      final response = await _client
          .from('plans')
          .insert({
            ...plan,
            'user_id': _client.auth.currentUser!.id,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();
      
      return response;
    } catch (e) {
      throw Exception('Failed to save plan: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSavedPlans() async {
    try {
      final response = await _client
          .from('plans')
          .select()
          .eq('user_id', _client.auth.currentUser!.id)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to get saved plans: $e');
    }
  }

  Future<void> deletePlan(String planId) async {
    try {
      await _client
          .from('plans')
          .delete()
          .eq('id', planId)
          .eq('user_id', _client.auth.currentUser!.id);
    } catch (e) {
      throw Exception('Failed to delete plan: $e');
    }
  }

  Future<Map<String, dynamic>> updatePlan(String planId, Map<String, dynamic> updates) async {
    try {
      final response = await _client
          .from('plans')
          .update(updates)
          .eq('id', planId)
          .eq('user_id', _client.auth.currentUser!.id)
          .select()
          .single();
      
      return response;
    } catch (e) {
      throw Exception('Failed to update plan: $e');
    }
  }
} 