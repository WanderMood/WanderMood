import '../entities/explore_place.dart';
import '../../data/repositories/explore_repository.dart';

class GetNearbyPlacesUseCase {
  final ExploreRepository repository;

  GetNearbyPlacesUseCase(this.repository);

  Future<List<ExplorePlace>> call({
    required double latitude,
    required double longitude,
    required double radius,
    String? category,
  }) async {
    final places = await repository.getPlacesByLocation(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      category: category,
    );
    
    return places.map((place) => ExplorePlace(
      id: place.id,
      name: place.name,
      description: place.description,
      latitude: place.latitude,
      longitude: place.longitude,
      photos: place.photos,
      rating: place.rating,
      reviewCount: place.reviewCount,
      address: place.address,
      categories: place.categories,
      additionalInfo: place.additionalInfo,
    )).toList();
  }
} 