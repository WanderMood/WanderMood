import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../mood/domain/models/mood.dart';
import '../../weather/domain/models/weather_data.dart';
import '../domain/models/recommendation.dart';
import 'package:uuid/uuid.dart';
import '../data/repositories/supabase_recommendation_repository.dart';
import 'ai_model_service.dart';

part 'ai_recommendation_service.g.dart';

@riverpod
class AIRecommendationService extends _$AIRecommendationService {
  final _uuid = const Uuid();
  
  @override
  Future<List<Recommendation>> build() async {
    final repository = ref.watch(supabaseRecommendationRepositoryProvider);
    return repository.getRecommendations();
  }

  Future<List<Recommendation>> generateRecommendations({
    required Mood? currentMood,
    required WeatherData? currentWeather,
    required List<Mood> moodHistory,
    required List<WeatherData> weatherHistory,
  }) async {
    try {
      final aiModel = ref.read(aIModelServiceProvider.notifier);
      final repository = ref.read(supabaseRecommendationRepositoryProvider);
      final recommendations = <Recommendation>[];
      final now = DateTime.now();

      // Genereer aanbeveling via AI model
      final aiResult = await aiModel.generateRecommendation(
        currentMood: currentMood,
        currentWeather: currentWeather,
        moodHistory: moodHistory,
        weatherHistory: weatherHistory,
      );

      // Verwerk AI resultaten
      final activities = aiResult['recommended_activities'] as List<dynamic>;
      final contextFactors = aiResult['context_factors'] as Map<String, dynamic>;
      final personalizationFactors = aiResult['personalization_factors'] as Map<String, dynamic>;

      for (final activity in activities) {
        final recommendation = Recommendation(
          id: _uuid.v4(),
          title: activity['title'],
          description: activity['description'],
          category: activity['category'],
          confidence: _calculateFinalConfidence(
            activity['confidence'],
            contextFactors,
            personalizationFactors,
          ),
          tags: List<String>.from(activity['tags']),
          createdAt: now,
          currentMood: currentMood,
          currentWeather: currentWeather,
        );

        recommendations.add(recommendation);
        
        // Sla aanbeveling op in database
        await repository.saveRecommendation(recommendation);
      }

      // Update state met nieuwe aanbevelingen
      state = AsyncData(recommendations);
      return recommendations;
    } catch (e) {
      throw Exception('Fout bij het genereren van aanbevelingen: $e');
    }
  }

  double _calculateFinalConfidence(
    double baseConfidence,
    Map<String, dynamic> contextFactors,
    Map<String, dynamic> personalizationFactors,
  ) {
    double finalConfidence = baseConfidence;

    // Pas confidence aan op basis van context
    if (contextFactors['time_appropriate'] == true) finalConfidence *= 1.1;
    if (contextFactors['weather_suitable'] == true) finalConfidence *= 1.1;
    finalConfidence *= (contextFactors['mood_impact'] as double);
    finalConfidence *= (contextFactors['seasonal_relevance'] as double);

    // Pas confidence aan op basis van personalisatie
    finalConfidence *= (personalizationFactors['user_history_match'] as double);
    finalConfidence *= (personalizationFactors['preference_alignment'] as double);
    finalConfidence *= (personalizationFactors['previous_success_rate'] as double);

    return finalConfidence.clamp(0.0, 1.0);
  }

  Future<void> markAsCompleted(String recommendationId) async {
    final repository = ref.read(supabaseRecommendationRepositoryProvider);
    await repository.markAsCompleted(recommendationId);
    
    // Update lokale state
    state = AsyncData(
      state.value?.map((rec) {
        if (rec.id == recommendationId) {
          return rec.copyWith(isCompleted: true);
        }
        return rec;
      }).toList() ?? [],
    );
  }

  Future<void> refreshRecommendations() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(supabaseRecommendationRepositoryProvider);
      final recommendations = await repository.getRecommendations();
      state = AsyncData(recommendations);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }

  Stream<List<Recommendation>> watchRecommendations() {
    final repository = ref.read(supabaseRecommendationRepositoryProvider);
    return repository.watchRecommendations();
  }
} 