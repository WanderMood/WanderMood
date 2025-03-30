import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chatgpt_service.dart';

class ChatGPTTest extends StatefulWidget {
  @override
  _ChatGPTTestState createState() => _ChatGPTTestState();
}

class _ChatGPTTestState extends State<ChatGPTTest> {
  final ChatGPTService _chatGPTService = ChatGPTService(Supabase.instance.client);
  String _response = '';
  bool _isLoading = false;

  Future<void> _testAIRecommendation() async {
    setState(() {
      _isLoading = true;
      _response = 'Loading...';
    });

    try {
      final recommendation = await _chatGPTService.generateTravelRecommendation(
        location: 'Rotterdam',
        interests: ['art', 'food', 'architecture'],
        mood: 'adventurous',
      );

      setState(() {
        _response = recommendation;
      });
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatGPT Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testAIRecommendation,
              child: Text(_isLoading ? 'Loading...' : 'Test AI Recommendation'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_response),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 