import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/explore_place.dart';
import '../../domain/usecases/get_nearby_places_usecase.dart';

final exploreProvider = StateNotifierProvider<ExploreNotifier, AsyncValue<List<ExplorePlace>>>((ref) {
  final getNearbyPlacesUseCase = ref.watch(getNearbyPlacesUseCaseProvider);
  return ExploreNotifier(getNearbyPlacesUseCase);
});

class ExploreNotifier extends StateNotifier<AsyncValue<List<ExplorePlace>>> {
  final GetNearbyPlacesUseCase _getNearbyPlacesUseCase;

  ExploreNotifier(this._getNearbyPlacesUseCase) : super(const AsyncValue.loading());

  Future<void> loadNearbyPlaces({
    required double latitude,
    required double longitude,
    required double radius,
    String? category,
  }) async {
    state = const AsyncValue.loading();
    try {
      final places = await _getNearbyPlacesUseCase(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        category: category,
      );
      state = AsyncValue.data(places);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
} 