import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/adventure_repository.dart';
import '../domain/models/adventure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'adventure_service.g.dart';

@riverpod
class AdventureService extends _$AdventureService {
  @override
  Future<List<Adventure>> build() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final repository = ref.watch(adventureRepositoryProvider);
    return repository.getAdventures(userId: userId, date: DateTime.now());
  }

  Future<void> toggleFavorite(String adventureId) async {
    final repository = ref.read(adventureRepositoryProvider);
    await repository.toggleFavorite(adventureId);
    ref.invalidateSelf();
  }
} 