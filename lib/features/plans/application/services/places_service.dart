import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/place.dart';
import 'location_service.dart';

final placesServiceProvider = Provider((ref) => PlacesService(
  supabase: Supabase.instance.client,
));

class PlacesService {
  final SupabaseClient supabase;

  PlacesService({required this.supabase});

  Future<List<Place>> searchPlacesByMoods({
    required List<String> moods,
    required Location location,
  }) async {
    try {
      // Query places from Supabase based on moods and location
      final response = await supabase
        .from('places')
        .select()
        .containedBy('tags', moods)
        .filter('latitude', 'gte', location.latitude - 0.1)
        .filter('latitude', 'lte', location.latitude + 0.1)
        .filter('longitude', 'gte', location.longitude - 0.1)
        .filter('longitude', 'lte', location.longitude + 0.1)
        .order('rating', ascending: false)
        .limit(10);

      // Convert response to list of Place objects
      final places = (response as List).map((json) => Place.fromJson(json as Map<String, dynamic>)).toList();

      return places;
    } catch (e) {
      throw Exception('Failed to search places: $e');
    }
  }
} 