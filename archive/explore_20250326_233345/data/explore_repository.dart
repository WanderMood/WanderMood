import '../models/explore_place_model.dart';

abstract class ExploreRepository {
  Future<List<ExplorePlaceModel>> getPlacesByLocation({
    required double latitude,
    required double longitude,
    required double radius,
    String? category,
  });

  Future<ExplorePlaceModel> getPlaceDetails(String placeId);

  Future<List<String>> getPlacePhotos(String placeId);

  Future<List<ExplorePlaceModel>> searchPlaces(String query);
} 