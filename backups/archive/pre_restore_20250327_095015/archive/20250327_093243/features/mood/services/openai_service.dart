import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wandermood/features/mood/models/mood_based_plan.dart';
import 'package:wandermood/features/places/models/place.dart';

class OpenAIService {
  final String apiKey;
  final String baseUrl = 'https://api.openai.com/v1/chat/completions';

  OpenAIService({required this.apiKey});

  Future<List<ActivitySuggestion>> getActivitiesForMood(String mood) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a travel advisor helping to suggest activities based on mood.',
            },
            {
              'role': 'user',
              'content': '''Suggest 5 types of activities for someone feeling $mood. 
                           Format as JSON array with fields: 
                           type, description, keywords (array), placeType (Google Places API type).
                           Keep descriptions concise and engaging.''',
            },
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final List<dynamic> suggestions = jsonDecode(content);
        
        return suggestions.map((json) => ActivitySuggestion(
          type: json['type'],
          description: json['description'],
          keywords: List<String>.from(json['keywords']),
          placeType: json['placeType'],
        )).toList();
      } else {
        throw Exception('Failed to get suggestions: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting activity suggestions: $e');
      // Return some fallback suggestions based on mood
      return _getFallbackSuggestions(mood);
    }
  }

  Future<String> generatePlaceDescription(Place place, String mood) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a travel writer creating engaging place descriptions.',
            },
            {
              'role': 'user',
              'content': '''Write a brief, engaging description of ${place.name} 
                           for someone feeling $mood. Include what makes it special 
                           and why it matches their mood. Keep it under 100 words.''',
            },
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to generate description: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error generating place description: $e');
      return place.description ?? 'A fascinating destination worth exploring.';
    }
  }

  List<ActivitySuggestion> _getFallbackSuggestions(String mood) {
    // Predefined fallback suggestions based on mood
    final suggestions = {
      'adventurous': [
        ActivitySuggestion(
          type: 'Outdoor Adventure',
          description: 'Exciting outdoor activities for thrill-seekers',
          keywords: ['adventure', 'outdoor', 'extreme'],
          placeType: 'park',
        ),
        ActivitySuggestion(
          type: 'Urban Exploration',
          description: 'Discover hidden gems in the city',
          keywords: ['urban', 'exploration', 'city'],
          placeType: 'point_of_interest',
        ),
      ],
      'relaxed': [
        ActivitySuggestion(
          type: 'Spa & Wellness',
          description: 'Relaxing spa treatments and wellness activities',
          keywords: ['spa', 'wellness', 'relaxation'],
          placeType: 'spa',
        ),
        ActivitySuggestion(
          type: 'Nature Walk',
          description: 'Peaceful walks in nature',
          keywords: ['nature', 'walk', 'peaceful'],
          placeType: 'park',
        ),
      ],
      // Add more mood-based fallback suggestions...
    };

    return suggestions[mood.toLowerCase()] ?? [
      ActivitySuggestion(
        type: 'Sightseeing',
        description: 'Explore popular attractions',
        keywords: ['sightseeing', 'tourist', 'attractions'],
        placeType: 'tourist_attraction',
      ),
    ];
  }
} 