import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/activity.dart';
import 'package:wandermood/core/services/places_service.dart';
import 'package:wandermood/core/services/weather_service.dart';

final activityServiceProvider = StateNotifierProvider<ActivityService, AsyncValue<List<Activity>>>((ref) {
  final placesService = ref.watch(placesServiceProvider.notifier);
  final weatherService = ref.watch(weatherServiceProvider.notifier);
  return ActivityService(placesService: placesService, weatherService: weatherService);
});

class ActivityService extends StateNotifier<AsyncValue<List<Activity>>> {
  final PlacesService _placesService;
  final WeatherService _weatherService;

  ActivityService({
    required PlacesService placesService,
    required WeatherService weatherService,
  })  : _placesService = placesService,
        _weatherService = weatherService,
        super(const AsyncValue.data([]));

  // Keep track of shown activities to avoid duplicates
  final Map<String, Set<String>> _shownActivityIds = {
    'morning': {},
    'afternoon': {},
    'evening': {},
    'night': {},
  };

  // Helper method to get time period for an activity
  String _getTimePeriod(String time) {
    try {
      // Handle time strings with AM/PM
      final timeWithoutPeriod = time.replaceAll(RegExp(r'[AaPp][Mm]'), '').trim();
      final parts = timeWithoutPeriod.split(':');
      
      if (parts.length != 2) return 'morning'; // Default to morning if parsing fails
      
      final hour = int.tryParse(parts[0]);
      if (hour == null) return 'morning'; // Default to morning if parsing fails
      
      // Convert to 24-hour format if needed
      final isPM = time.toLowerCase().contains('pm');
      final hour24 = isPM && hour != 12 ? hour + 12 : hour;
      
      if (hour24 >= 5 && hour24 < 12) return 'morning';
      if (hour24 >= 12 && hour24 < 17) return 'afternoon';
      if (hour24 >= 17 && hour24 < 22) return 'evening';
      return 'night';
    } catch (e) {
      return 'morning'; // Default to morning if any error occurs
    }
  }

  // Method to generate alternative activity
  Future<Activity> generateAlternativeActivity({
    required String currentActivityId,
    required String time,
    required String mood,
    required String location,
  }) async {
    // Get the time period for the current activity
    final timePeriod = _getTimePeriod(time);
    
    // Get all possible activities for this time period
    final List<Activity> allActivities = await _getAllPossibleActivities(timePeriod);
    
    // Filter out already shown activities
    final shownIds = _shownActivityIds[timePeriod] ?? {};
    final availableActivities = allActivities.where((activity) => 
      !shownIds.contains(activity.id) && 
      activity.id != currentActivityId
    ).toList();

    if (availableActivities.isEmpty) {
      // If no more unique activities, create a new variation
      return _createVariationActivity(time, timePeriod);
    }

    // Select a random activity from available ones
    final newActivity = availableActivities[DateTime.now().millisecondsSinceEpoch % availableActivities.length];
    
    // Add the new activity to shown activities
    _shownActivityIds[timePeriod]?.add(newActivity.id);
    
    return newActivity;
  }

  // Helper method to create a variation of an activity when no more unique ones are available
  Activity _createVariationActivity(String time, String timePeriod) {
    final variations = {
      'morning': [
        Activity(
          id: 'var_morning_1',
          title: '🚴‍♂️ Rotterdam Bike Tour',
          location: '📍 Rotterdam Centraal',
          description: '🌅 Start your day with an energizing bike tour through Rotterdam\'s highlights! 🏙️',
          time: time,
          distance: '5.0 km • 20 min by bike 🚲',
          weather: '☀️ 20°C',
          cost: 25.00,
          moods: ['Active', 'Adventurous'],
          openingHours: '8:00 AM - 6:00 PM',
          rating: 4.6,
          photos: ['https://example.com/biketour1.jpg'],
          weatherForecast: 'Perfect morning for cycling 🌤️',
          similarActivities: ['City Walking Tour'],
          placeId: 'ChIJX6sY_Zw0xEcRkTbX9JQkqLQ',
          latitude: 51.9225,
          longitude: 4.4791,
        ),
      ],
      'afternoon': [
        Activity(
          id: 'var_afternoon_1',
          title: '🎨 Street Art Walking Tour',
          location: '⭐️ Rotterdam West',
          description: '🎨 Discover amazing murals and urban art in Rotterdam\'s creative districts! 🖼️',
          time: time,
          distance: '2.5 km • 30 min walk 🚶‍♂️',
          weather: '☀️ 22°C',
          cost: 15.00,
          moods: ['Creative', 'Cultural'],
          openingHours: 'Always open',
          rating: 4.7,
          photos: ['https://example.com/streetart1.jpg'],
          weatherForecast: 'Great weather for exploring 🌤️',
          similarActivities: ['Photography Tour'],
          placeId: 'ChIJX6sY_Zw0xEcRkTbX9JQkqLQ',
          latitude: 51.9171,
          longitude: 4.4745,
        ),
      ],
      'evening': [
        Activity(
          id: 'var_evening_1',
          title: '🌅 Rooftop Sunset Lounge',
          location: '📌 City Center',
          description: '✨ Enjoy spectacular sunset views with craft cocktails at this trendy rooftop bar! 🍸',
          time: time,
          distance: '1.8 km • 20 min walk 🚶‍♂️',
          weather: '🌅 19°C',
          cost: 30.00,
          moods: ['Romantic', 'Social'],
          openingHours: '4:00 PM - 1:00 AM',
          rating: 4.8,
          photos: ['https://example.com/rooftop1.jpg'],
          weatherForecast: 'Perfect sunset viewing weather 🌆',
          similarActivities: ['Cocktail Workshops'],
          placeId: 'ChIJX6sY_Zw0xEcRkTbX9JQkqLQ',
          latitude: 51.9171,
          longitude: 4.4745,
        ),
      ],
      'night': [
        Activity(
          id: 'var_night_1',
          title: '🎵 Live Music Café',
          location: '⭐️ Cool District',
          description: '🎸 Experience Rotterdam\'s local music scene with live performances! 🎺',
          time: time,
          distance: '1.2 km • 15 min walk 🚶‍♂️',
          weather: '🌙 17°C',
          cost: 10.00,
          moods: ['Social', 'Cultural'],
          openingHours: '8:00 PM - 2:00 AM',
          rating: 4.5,
          photos: ['https://example.com/musiccafe1.jpg'],
          weatherForecast: 'Cozy night for live music ✨',
          similarActivities: ['Jazz Clubs'],
          placeId: 'ChIJX6sY_Zw0xEcRkTbX9JQkqLQ',
          latitude: 51.9171,
          longitude: 4.4745,
        ),
      ],
    };

    final activityVariations = variations[timePeriod] ?? [];
    return activityVariations[DateTime.now().millisecondsSinceEpoch % activityVariations.length];
  }

  // Helper method to get all possible activities for a time period
  Future<List<Activity>> _getAllPossibleActivities(String timePeriod) async {
    // This would typically fetch from an API or database
    // For now, we'll return our mock data
    final allActivities = await generatePlan(
      mood: 'any',
      location: 'Rotterdam',
      date: DateTime.now(),
    );

    // Filter activities by time period
    return allActivities.where((activity) {
      final activityPeriod = _getTimePeriod(activity.time);
      return activityPeriod == timePeriod;
    }).toList();
  }

  Future<List<Activity>> generatePlan({
    required String mood,
    required String location,
    required DateTime date,
  }) async {
    // TODO: Implement actual plan generation with API calls
    // For now, return mock data with multiple activities per time period
    return [
      // Morning Activities (3 options)
      Activity(
        id: '1',
        title: '🗼 Visit Euromast',
        location: '📍 Parkhaven 20, 3016 GM Rotterdam',
        description: '✨ Experience breathtaking views of Rotterdam from the iconic Euromast tower. Perfect for panoramic city photos! 📸',
        time: '10:00 AM',
        distance: '2.5 km • 30 min walk 🚶‍♂️',
        weather: '☀️ 22°C',
        cost: 17.50,
        moods: ['Adventurous', 'Excited'],
        openingHours: '9:30 AM - 10:00 PM',
        rating: 4.5,
        photos: ['https://example.com/euromast1.jpg'],
        weatherForecast: 'Sunny with light clouds ⛅️',
        similarActivities: ['Rotterdam Harbour Tour'],
        placeId: 'ChIJTY7aLps0xEcR2DpPoYMXqFg',
        latitude: 51.9054,
        longitude: 4.4668,
      ),
      Activity(
        id: '2',
        title: '🦁 Rotterdam Zoo',
        location: '📌 Blijdorplaan 8, 3041 JG Rotterdam',
        description: '🐘 Start your day with amazing wildlife at Rotterdam Zoo! Meet friendly animals and enjoy nature 🌿',
        time: '9:00 AM',
        distance: '3.0 km • 15 min by tram 🚊',
        weather: '☀️ 21°C',
        cost: 24.50,
        moods: ['Family', 'Nature'],
        openingHours: '9:00 AM - 5:00 PM',
        rating: 4.6,
        photos: ['https://example.com/zoo1.jpg'],
        weatherForecast: 'Perfect morning for animal watching 🌤️',
        similarActivities: ['Plaswijckpark'],
        placeId: 'ChIJX6sY_Zw0xEcRkTbX9JQkqLQ',
        latitude: 51.9284,
        longitude: 4.4589,
      ),
      Activity(
        id: '3',
        title: '🌳 Kralingse Bos Morning Walk',
        location: '⭐️ Kralingse Plaslaan, Rotterdam',
        description: '🌅 Peaceful morning walk around the lake. Start your day with fresh air and nature! 🍃',
        time: '8:00 AM',
        distance: '4.2 km • 50 min walk 🚶‍♂️',
        weather: '⛅️ 19°C',
        cost: 0,
        moods: ['Peaceful', 'Nature'],
        openingHours: 'Always open',
        rating: 4.7,
        photos: ['https://example.com/kralingse1.jpg'],
        weatherForecast: 'Fresh morning air 🌿',
        similarActivities: ['Vroesenpark'],
        placeId: 'ChIJY6sY_Zw0xEcRkTbX9JQkqLQ',
        latitude: 51.9320,
        longitude: 4.5062,
      ),

      // Afternoon Activities (3 options)
      Activity(
        id: '4',
        title: '🏛️ Market Hall Rotterdam',
        location: '📍 Dominee Jan Scharpstraat 298',
        description: '🍲 Explore the stunning Market Hall with its colorful ceiling and diverse food stalls. A feast for your eyes and taste buds! 🎨',
        time: '1:00 PM',
        distance: '1.2 km • 15 min walk 🚶‍♂️',
        weather: '☀️ 24°C',
        cost: 0,
        moods: ['Foody', 'Cultural'],
        openingHours: '10:00 AM - 8:00 PM',
        rating: 4.7,
        photos: ['https://example.com/markethall1.jpg'],
        weatherForecast: 'Perfect for indoor exploring 🌤️',
        similarActivities: ['Cube Houses'],
        placeId: 'ChIJY6sY_Zw0xEcRkTbX9JQkqLQ',
        latitude: 51.9201,
        longitude: 4.4853,
      ),
      Activity(
        id: '5',
        title: '🎨 Museum Boijmans Depot',
        location: '📌 Museumpark, Rotterdam',
        description: '✨ Visit the world\'s first publicly accessible art depot. A unique cultural experience! 🖼️',
        time: '2:00 PM',
        distance: '1.8 km • 8 min by bike 🚲',
        weather: '☀️ 25°C',
        cost: 20.00,
        moods: ['Cultural', 'Creative'],
        openingHours: '11:00 AM - 6:00 PM',
        rating: 4.8,
        photos: ['https://example.com/depot1.jpg'],
        weatherForecast: 'Perfect for art viewing 🎪',
        similarActivities: ['Kunsthal'],
        placeId: 'ChIJY6sY_Zw0xEcRkTbX9JQkqLQ',
        latitude: 51.9141,
        longitude: 4.4736,
      ),
      Activity(
        id: '6',
        title: '⛴️ Water Taxi Adventure',
        location: '⭐️ Hotel New York, Rotterdam',
        description: '💦 Exciting water taxi ride across the Maas river. Feel the breeze and enjoy the views! 🌊',
        time: '3:00 PM',
        distance: '2.1 km • 10 min by metro 🚇',
        weather: '☀️ 23°C',
        cost: 8.50,
        moods: ['Adventurous', 'Excited'],
        openingHours: '10:00 AM - 6:00 PM',
        rating: 4.6,
        photos: ['https://example.com/watertaxi1.jpg'],
        weatherForecast: 'Perfect boating weather 🌤️',
        similarActivities: ['Spido Tour'],
        placeId: 'ChIJY6sY_Zw0xEcRkTbX9JQkqLQ',
        latitude: 51.9165,
        longitude: 4.4773,
      ),

      // Evening Activities (3 options)
      Activity(
        id: '7',
        title: '🚢 SS Rotterdam Dinner',
        location: '📍 3e Katendrechtse Hoofd 25',
        description: '✨ Elegant dinner aboard the historic SS Rotterdam. Experience maritime luxury! 🍽️',
        time: '7:00 PM',
        distance: '3.5 km • 12 min by taxi 🚕',
        weather: '🌙 20°C',
        cost: 45.00,
        moods: ['Romantic', 'Luxurious'],
        openingHours: '5:00 PM - 10:00 PM',
        rating: 4.6,
        photos: ['https://example.com/ssrotterdam1.jpg'],
        weatherForecast: 'Perfect evening for dining 🌟',
        similarActivities: ['Hotel New York Restaurant'],
        placeId: 'ChIJX6sY_Zw0xEcRkTbX9JQkqLQ',
        latitude: 51.8984,
        longitude: 4.4789,
      ),
      Activity(
        id: '8',
        title: '🌅 Euromast Sunset Dinner',
        location: '⭐️ Parkhaven 20',
        description: '✨ Dinner with panoramic sunset views. Romance at Rotterdam\'s highest point! 🍷',
        time: '6:30 PM',
        distance: '2.5 km • 30 min walk 🚶‍♂️',
        weather: '🌅 19°C',
        cost: 55.00,
        moods: ['Romantic', 'Scenic'],
        openingHours: '5:00 PM - 11:00 PM',
        rating: 4.7,
        photos: ['https://example.com/euromast_dinner1.jpg'],
        weatherForecast: 'Beautiful sunset views 🌆',
        similarActivities: ['Restaurant De Jong'],
        placeId: 'ChIJX6sY_Zw0xEcRkTbX9JQkqLQ',
        latitude: 51.9054,
        longitude: 4.4668,
      ),
      Activity(
        id: '9',
        title: '🍽️ Fenix Food Factory',
        location: '📌 Veerlaan 19D',
        description: '🍺 Evening food and drinks at this creative hotspot. Local flavors and great vibes! 🎵',
        time: '6:00 PM',
        distance: '2.8 km • 20 min by tram 🚊',
        weather: '🌅 18°C',
        cost: 25.00,
        moods: ['Social', 'Foody'],
        openingHours: '12:00 PM - 11:00 PM',
        rating: 4.5,
        photos: ['https://example.com/fenix1.jpg'],
        weatherForecast: 'Perfect evening for food tasting 🌟',
        similarActivities: ['Foodhallen'],
        placeId: 'ChIJX6sY_Zw0xEcRkTbX9JQkqLQ',
        latitude: 51.8984,
        longitude: 4.4789,
      ),

      // Night Activities (3 options)
      Activity(
        id: '10',
        title: '🌟 Witte de Withstraat Nightlife',
        location: '📍 Witte de Withstraat',
        description: '🎵 Experience Rotterdam\'s vibrant nightlife. Dance, drink, and enjoy the city lights! 🍸',
        time: '10:00 PM',
        distance: '1.8 km • 8 min by taxi 🚕',
        weather: '🌙 18°C',
        cost: 0,
        moods: ['Energetic', 'Social'],
        openingHours: '8:00 PM - 3:00 AM',
        rating: 4.4,
        photos: ['https://example.com/wittedewith1.jpg'],
        weatherForecast: 'Perfect night for partying ✨',
        similarActivities: ['Oude Haven Bars'],
        placeId: 'ChIJX6sY_Zw0xEcRkTbX9JQkqLQ',
        latitude: 51.9165,
        longitude: 4.4773,
      ),
      Activity(
        id: '11',
        title: '🎷 BIRD Jazz Club',
        location: '⭐️ Raampoortstraat 26',
        description: '🎵 Live jazz music in a cozy atmosphere. Let the smooth tunes carry you away! 🎺',
        time: '9:30 PM',
        distance: '2.2 km • 25 min walk 🚶‍♂️',
        weather: '🌙 17°C',
        cost: 15.00,
        moods: ['Relaxed', 'Cultural'],
        openingHours: '8:00 PM - 2:00 AM',
        rating: 4.6,
        photos: ['https://example.com/bird1.jpg'],
        weatherForecast: 'Cozy jazz night ahead 🌟',
        similarActivities: ['LantarenVenster'],
        placeId: 'ChIJX6sY_Zw0xEcRkTbX9JQkqLQ',
        latitude: 51.9165,
        longitude: 4.4773,
      ),
      Activity(
        id: '12',
        title: '🍺 Biergarten Rotterdam',
        location: '📌 Schiestraat 18',
        description: '🌟 Open-air night venue with great atmosphere. Enjoy drinks under the stars! 🌙',
        time: '9:00 PM',
        distance: '1.5 km • 18 min walk 🚶‍♂️',
        weather: '🌙 18°C',
        cost: 0,
        moods: ['Social', 'Relaxed'],
        openingHours: '4:00 PM - 1:00 AM',
        rating: 4.5,
        photos: ['https://example.com/biergarten1.jpg'],
        weatherForecast: 'Perfect for outdoor drinks ✨',
        similarActivities: ['Annabel'],
        placeId: 'ChIJX6sY_Zw0xEcRkTbX9JQkqLQ',
        latitude: 51.9165,
        longitude: 4.4773,
      ),
    ];
  }

  Future<Activity> getActivityDetails(String id) async {
    // TODO: Implement actual API call to get activity details
    // For now, return mock data
    return Activity(
      id: id,
      title: 'Visit Euromast',
      location: 'Parkhaven 20, 3016 GM Rotterdam',
      description: 'Experience breathtaking views of Rotterdam from the iconic Euromast tower.',
      time: '10:00 AM',
      distance: '2.5 km',
      weather: '☀️ 22°C',
      cost: 17.50,
      moods: ['Adventurous', 'Excited'],
      openingHours: '9:30 AM - 10:00 PM',
      rating: 4.5,
      photos: [
        'https://example.com/euromast1.jpg',
        'https://example.com/euromast2.jpg',
      ],
      weatherForecast: 'Sunny with light clouds, perfect visibility',
      similarActivities: [
        'Rotterdam Harbour Tour',
        'Cube Houses',
        'Market Hall',
      ],
      placeId: 'ChIJTY7aLps0xEcR2DpPoYMXqFg',
      latitude: 51.9054,
      longitude: 4.4668,
    );
  }

  Future<void> saveActivity(String activityId) async {
    // TODO: Implement saving activity to user's saved activities
  }

  Future<void> savePlan(List<Activity> activities) async {
    // TODO: Implement saving entire plan to user's saved plans
  }

  Future<void> sharePlan(List<Activity> activities) async {
    // TODO: Implement plan sharing functionality
  }
} 