import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wandermood/features/mood/models/mood.dart';

class OpenAIService {
  final String apiKey;
  final String baseUrl = 'https://api.openai.com/v1';

  OpenAIService({required this.apiKey});

  Future<List<String>> generateRecommendations({
    required String mood,
    required String location,
    required String timeOfDay,
    required String weather,
  }) async {
    try {
      final prompt = '''
        User is feeling $mood in $location during $timeOfDay. 
        Weather is currently $weather.
        Suggest 5-10 specific types of places or activities that would match this mood.
        For each suggestion, provide:
        - Activity type (e.g., hiking, museum, restaurant)
        - Brief description
        - Why it matches the mood
        Format as JSON array.
      ''';

      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a travel recommendation expert that provides specific, local activity suggestions based on mood and context.',
            },
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final suggestions = jsonDecode(data['choices'][0]['message']['content']);
        return List<String>.from(suggestions.map((s) => s['activity_type']));
      } else {
        throw Exception('Failed to generate recommendations: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error generating recommendations: $e');
      return [];
    }
  }
} 