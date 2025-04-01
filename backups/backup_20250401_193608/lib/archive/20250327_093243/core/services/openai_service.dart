import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:wandermood/core/services/places_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wandermood/core/models/place.dart';

final openAIServiceProvider = Provider<OpenAIService>((ref) => OpenAIService());

class OpenAIService {
  static final OpenAIService _instance = OpenAIService._internal();
  factory OpenAIService() => _instance;
  OpenAIService._internal();

  final String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  
  Future<bool> testConnection() async {
    try {
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        debugPrint('❌ OpenAI Error: API key is missing or empty');
        return false;
      }

      // Clean and validate the API key
      final cleanApiKey = apiKey.trim();
      debugPrint('🤖 Testing OpenAI connection with service account...');
      debugPrint('🔑 API Key format: ${cleanApiKey.split('-')[0]}-${cleanApiKey.split('-')[1]}');
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanApiKey',
          'OpenAI-Beta': 'assistants=v1',  // Add support for service accounts
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': 'Say "Connection successful" if you can read this.'}
          ],
          'max_tokens': 20,
        }),
      );

      debugPrint('🤖 OpenAI Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? response.body;
        debugPrint('❌ OpenAI Error Response: $errorMessage');
        return false;
      }
      
      final responseBody = jsonDecode(response.body);
      final message = responseBody['choices']?[0]?['message']?['content'];
      debugPrint('✅ OpenAI Response: $message');
      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ OpenAI Error: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      return false;
    }
  }

  String _formatPlacesForPrompt(List<Place> places) {
    return places.map((place) {
      final rating = place.rating != null ? '(Rating: ${place.rating}/5)' : '';
      return '- ${place.name} ${rating} - ${place.vicinity ?? 'No address available'}';
    }).join('\n');
  }

  Future<String?> generatePlanSuggestions({
    required List<String> selectedMoods,
    required String timeOfDay,
    required List<Place> availablePlaces,
    String? weatherCondition,
    String? location = 'Rotterdam',
  }) async {
    try {
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        debugPrint('❌ OpenAI Error: API key is missing or empty');
        return null;
      }

      final cleanApiKey = apiKey.trim();
      final placesText = _formatPlacesForPrompt(availablePlaces);
      
      final prompt = '''As a local travel guide in Rotterdam, create a personalized plan based on:
Moods: ${selectedMoods.join(', ')}
Time: $timeOfDay
Weather: ${weatherCondition ?? 'Unknown'}
Available Places:
$placesText

Please suggest a plan that:
1. Matches the selected moods
2. Is suitable for the time of day
3. Considers the weather conditions
4. Includes 2-3 places from the available list
5. Suggests a logical order to visit them
6. Adds brief descriptions and tips

Format the response in a clear, friendly way with emojis.''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanApiKey',
          'OpenAI-Beta': 'assistants=v1',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': 'You are a knowledgeable and friendly local guide in Rotterdam.'},
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      debugPrint('🤖 OpenAI Response Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? response.body;
        debugPrint('❌ OpenAI Error Response: $errorMessage');
        return null;
      }
      
      final responseBody = jsonDecode(response.body);
      final suggestion = responseBody['choices']?[0]?['message']?['content'];
      debugPrint('✅ OpenAI Generated Plan: $suggestion');
      return suggestion;
    } catch (e, stackTrace) {
      debugPrint('❌ OpenAI Error: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      return null;
    }
  }

  Future<String?> refinePlan({
    required String currentPlan,
    required List<String> feedback,
    required List<Place> availablePlaces,
  }) async {
    try {
      final prompt = '''
Current plan:
$currentPlan

User feedback:
${feedback.join('\n')}

Available locations:
${availablePlaces.take(5).map((place) => '- ${place.name}').join('\n')}

Please refine the plan based on the user's feedback. Keep the same friendly, conversational tone.
''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${dotenv.env['OPENAI_API_KEY']}',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are Moody, a friendly AI travel companion. You refine travel plans based on user feedback while maintaining a conversational tone.'
            },
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        final errorData = jsonDecode(response.body);
        debugPrint('❌ OpenAI Error: ${errorData['error']['message']}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ OpenAI Error: $e');
      return null;
    }
  }
} 