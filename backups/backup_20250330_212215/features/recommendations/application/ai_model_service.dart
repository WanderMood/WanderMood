import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../mood/domain/models/mood.dart';
import '../../weather/domain/models/weather_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'ai_model_service.g.dart';

@riverpod
class AIModelService extends _$AIModelService {
  static const String _baseUrl = 'YOUR_AI_MODEL_ENDPOINT'; // TODO: Update met echte endpoint

  @override
  Future<void> build() async {}

  Future<Map<String, dynamic>> generateRecommendation({
    required Mood? currentMood,
    required WeatherData? currentWeather,
    required List<Mood> moodHistory,
    required List<WeatherData> weatherHistory,
  }) async {
    try {
      // Voorbereid de input data voor het AI model
      final inputData = {
        'current_mood': currentMood?.toJson(),
        'current_weather': currentWeather?.toJson(),
        'mood_history': moodHistory.map((m) => m.toJson()).toList(),
        'weather_history': weatherHistory.map((w) => w.toJson()).toList(),
        'user_preferences': await _getUserPreferences(),
        'time_of_day': DateTime.now().hour,
        'day_of_week': DateTime.now().weekday,
      };

      // Stuur request naar AI model
      final response = await http.post(
        Uri.parse('$_baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(inputData),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to generate recommendation: ${response.body}');
      }

      // Verwerk de response
      final result = json.decode(response.body);
      
      // Voeg extra context toe aan de aanbeveling
      return {
        ...result,
        'confidence_score': _calculateConfidenceScore(result, inputData),
        'context_factors': _analyzeContextFactors(inputData),
        'personalization_factors': await _getPersonalizationFactors(),
      };
    } catch (e) {
      throw Exception('Error generating AI recommendation: $e');
    }
  }

  Future<Map<String, dynamic>> _getUserPreferences() async {
    // TODO: Implementeer gebruikersvoorkeuren ophalen
    return {
      'preferred_activities': ['wandelen', 'lezen', 'sporten'],
      'indoor_outdoor_preference': 0.7, // 0 = binnen, 1 = buiten
      'social_preference': 0.6, // 0 = alleen, 1 = sociaal
      'activity_level_preference': 0.5, // 0 = rustig, 1 = actief
    };
  }

  double _calculateConfidenceScore(
    Map<String, dynamic> aiResult,
    Map<String, dynamic> inputData,
  ) {
    double baseConfidence = aiResult['base_confidence'] ?? 0.7;
    
    // Pas confidence aan op basis van data kwaliteit
    if (inputData['current_mood'] == null) baseConfidence *= 0.8;
    if (inputData['current_weather'] == null) baseConfidence *= 0.9;
    if (inputData['mood_history'].isEmpty) baseConfidence *= 0.95;
    
    // Pas confidence aan op basis van context match
    final timeOfDay = inputData['time_of_day'] as int;
    if (timeOfDay >= 9 && timeOfDay <= 18) baseConfidence *= 1.1;
    
    return baseConfidence.clamp(0.0, 1.0);
  }

  Map<String, dynamic> _analyzeContextFactors(Map<String, dynamic> inputData) {
    return {
      'time_appropriate': _isTimeAppropriate(inputData['time_of_day']),
      'weather_suitable': _isWeatherSuitable(inputData['current_weather']),
      'mood_impact': _analyzeMoodImpact(inputData['current_mood']),
      'seasonal_relevance': _calculateSeasonalRelevance(),
    };
  }

  bool _isTimeAppropriate(int hour) {
    // Check of de activiteit geschikt is voor het tijdstip
    if (hour >= 22 || hour < 6) return false;
    if (hour >= 9 && hour <= 18) return true;
    return hour > 6 && hour < 22;
  }

  bool _isWeatherSuitable(Map<String, dynamic>? weather) {
    if (weather == null) return true;
    
    final conditions = weather['conditions'].toString().toLowerCase();
    final temperature = weather['temperature'] as double;
    final precipitation = weather['precipitation'] as double;
    
    if (precipitation > 5) return false;
    if (temperature < 5 || temperature > 30) return false;
    if (conditions.contains('storm')) return false;
    
    return true;
  }

  double _analyzeMoodImpact(Map<String, dynamic>? mood) {
    if (mood == null) return 0.5;
    
    final label = mood['label'].toString().toLowerCase();
    
    if (label.contains('blij')) return 0.8;
    if (label.contains('verdrietig')) return 0.3;
    if (label.contains('gestrest')) return 0.4;
    
    return 0.5;
  }

  double _calculateSeasonalRelevance() {
    final now = DateTime.now();
    final month = now.month;
    
    // Seizoensgebonden relevantie (0-1)
    switch (month) {
      case 12:
      case 1:
      case 2:
        return 0.7; // Winter
      case 3:
      case 4:
      case 5:
        return 0.9; // Lente
      case 6:
      case 7:
      case 8:
        return 1.0; // Zomer
      case 9:
      case 10:
      case 11:
        return 0.8; // Herfst
      default:
        return 0.5;
    }
  }

  Future<Map<String, dynamic>> _getPersonalizationFactors() async {
    // TODO: Implementeer personalisatiefactoren ophalen
    return {
      'user_history_match': 0.8,
      'preference_alignment': 0.7,
      'previous_success_rate': 0.85,
    };
  }
} 