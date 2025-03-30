import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/adventure.dart';

part 'adventure_repository.g.dart';

@riverpod
AdventureRepository adventureRepository(AdventureRepositoryRef ref) {
  return AdventureRepository(Supabase.instance.client);
}

class AdventureRepository {
  final SupabaseClient _client;

  AdventureRepository(this._client);

  Future<List<Adventure>> getAdventures({
    required String userId,
    DateTime? date,
  }) async {
    final query = _client
        .from('adventures')
        .select()
        .eq('user_id', userId);
    
    if (date != null) {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      query
        .gte('created_at', startOfDay.toIso8601String())
        .lt('created_at', endOfDay.toIso8601String());
    }

    final data = await query;
    return data.map((json) => Adventure.fromJson(json)).toList();
  }

  Future<void> toggleFavorite(String adventureId) async {
    final adventure = await _client
        .from('adventures')
        .select()
        .eq('id', adventureId)
        .single();
    
    await _client
        .from('adventures')
        .update({'is_favorite': !adventure['is_favorite']})
        .eq('id', adventureId);
  }
} 