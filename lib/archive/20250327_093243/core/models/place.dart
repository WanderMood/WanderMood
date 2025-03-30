class Place {
  final String name;
  final String placeId;
  final double latitude;
  final double longitude;
  final String? vicinity;
  final List<String>? types;
  final double? rating;
  final int? userRatingsTotal;
  final String? photoReference;

  Place({
    required this.name,
    required this.placeId,
    required this.latitude,
    required this.longitude,
    this.vicinity,
    this.types,
    this.rating,
    this.userRatingsTotal,
    this.photoReference,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    // Handle numeric conversions
    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    final lat = parseDouble(json['geometry']['location']['lat']);
    final lng = parseDouble(json['geometry']['location']['lng']);
    final rating = parseDouble(json['rating']);

    if (lat == null || lng == null) {
      throw FormatException('Invalid location data in place JSON: $json');
    }

    return Place(
      name: json['name'] as String,
      placeId: json['place_id'] as String,
      latitude: lat,
      longitude: lng,
      vicinity: json['vicinity'] as String?,
      types: (json['types'] as List<dynamic>?)?.cast<String>(),
      rating: rating,
      userRatingsTotal: json['user_ratings_total'] as int?,
      photoReference: json['photos']?[0]?['photo_reference'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'place_id': placeId,
      'geometry': {
        'location': {
          'lat': latitude,
          'lng': longitude,
        },
      },
      'vicinity': vicinity,
      'types': types,
      'rating': rating,
      'user_ratings_total': userRatingsTotal,
      'photos': photoReference != null
          ? [
              {
                'photo_reference': photoReference,
              }
            ]
          : null,
    };
  }
} 