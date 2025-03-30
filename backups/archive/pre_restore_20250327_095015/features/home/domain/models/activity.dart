class Activity {
  final String id;
  final String title;
  final String location;
  final String description;
  final String time;
  final String distance;
  final String weather;
  final double? cost;
  final List<String> moods;
  final String openingHours;
  final double rating;
  final List<String> photos;
  final String weatherForecast;
  final List<String> similarActivities;
  final String placeId;
  final double latitude;
  final double longitude;

  const Activity({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.time,
    required this.distance,
    required this.weather,
    this.cost,
    required this.moods,
    required this.openingHours,
    required this.rating,
    required this.photos,
    required this.weatherForecast,
    required this.similarActivities,
    required this.placeId,
    required this.latitude,
    required this.longitude,
  });

  Activity copyWith({
    String? id,
    String? title,
    String? location,
    String? description,
    String? time,
    String? distance,
    String? weather,
    double? cost,
    List<String>? moods,
    String? openingHours,
    double? rating,
    List<String>? photos,
    String? weatherForecast,
    List<String>? similarActivities,
    String? placeId,
    double? latitude,
    double? longitude,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      description: description ?? this.description,
      time: time ?? this.time,
      distance: distance ?? this.distance,
      weather: weather ?? this.weather,
      cost: cost ?? this.cost,
      moods: moods ?? this.moods,
      openingHours: openingHours ?? this.openingHours,
      rating: rating ?? this.rating,
      photos: photos ?? this.photos,
      weatherForecast: weatherForecast ?? this.weatherForecast,
      similarActivities: similarActivities ?? this.similarActivities,
      placeId: placeId ?? this.placeId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'description': description,
      'time': time,
      'distance': distance,
      'weather': weather,
      'cost': cost,
      'moods': moods,
      'openingHours': openingHours,
      'rating': rating,
      'photos': photos,
      'weatherForecast': weatherForecast,
      'similarActivities': similarActivities,
      'placeId': placeId,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      title: json['title'] as String,
      location: json['location'] as String,
      description: json['description'] as String,
      time: json['time'] as String,
      distance: json['distance'] as String,
      weather: json['weather'] as String,
      cost: json['cost'] as double?,
      moods: List<String>.from(json['moods']),
      openingHours: json['openingHours'] as String,
      rating: json['rating'] as double,
      photos: List<String>.from(json['photos']),
      weatherForecast: json['weatherForecast'] as String,
      similarActivities: List<String>.from(json['similarActivities']),
      placeId: json['placeId'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Activity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 