import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatGPTService {
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  static const int _maxRequestsPerMinute = 60;
  static const String _lastRequestKey = 'last_chatgpt_request';
  final String _apiKey;
  final SharedPreferences _prefs;

  ChatGPTService(this._prefs) : _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  Future<bool> testConnection() async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content': 'Test connection',
            },
          ],
          'temperature': 0.7,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> _checkRateLimit() async {
    final lastRequest = _prefs.getInt(_lastRequestKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final timeSinceLastRequest = now - lastRequest;
    
    if (timeSinceLastRequest < (60000 ~/ _maxRequestsPerMinute)) {
      throw Exception('Rate limit exceeded. Please wait before making another request.');
    }
    
    await _prefs.setInt(_lastRequestKey, now);
  }

  Future<String> generateResponse(String prompt) async {
    try {
      await _checkRateLimit();
      
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            },
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to generate response: ${response.body}');
      }

      final data = jsonDecode(response.body);
      final completion = data['choices'][0]['message']['content'];
      return completion;
    } catch (e) {
      throw Exception('Error generating response: $e');
    }
  }

  Future<String> generateTravelRecommendation({
    required String location,
    required List<String> interests,
    required String mood,
  }) async {
    final prompt = '''
      As a travel expert, provide personalized recommendations for visiting $location.
      The traveler is feeling $mood and is interested in: ${interests.join(', ')}.
      Please suggest specific activities, places, and experiences that match these preferences.
      Keep the response concise and engaging.
    ''';

    return generateResponse(prompt);
  }
} 