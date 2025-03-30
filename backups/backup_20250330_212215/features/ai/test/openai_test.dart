import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  setUpAll(() async {
    await dotenv.load();
  });

  test('OpenAI API Key is configured', () {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    expect(apiKey, isNotNull);
    expect(apiKey, isNotEmpty);
    expect(apiKey!.startsWith('sk-'), isTrue);
  });

  test('OpenAI API Connection Test', () async {
    final apiKey = dotenv.env['OPENAI_API_KEY']!;
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'user', 'content': 'Say "Connection successful" if you can read this.'}
        ],
        'max_tokens': 20,
      }),
    );

    expect(response.statusCode, equals(200));
    final data = jsonDecode(response.body);
    expect(data['choices'], isNotEmpty);
    final content = data['choices'][0]['message']['content'] as String;
    expect(content.toLowerCase(), contains('connection successful'));
  });
} 