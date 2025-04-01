import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/place.dart';
import '../services/places_service.dart';

part 'place_detail_provider.g.dart';

@riverpod
Future<Place> placeDetail(PlaceDetailRef ref, String placeId) async {
  final placesService = ref.watch(placesServiceProvider);
  return placesService.getPlaceById(placeId);
} 