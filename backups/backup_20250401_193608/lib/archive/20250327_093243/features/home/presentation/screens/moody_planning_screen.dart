import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io' show Platform;
import 'dart:ui';
import '../widgets/moody_character.dart';
import '../widgets/moody_chat_bubble.dart';
import '../../services/conversation_service.dart';
import '../../../speech/presentation/widgets/voice_input_button.dart';
import '../../../speech/services/speech_service.dart';
import '../widgets/glass_chat_box.dart';
import 'package:flutter/rendering.dart';

class DayPart {
  final String title;
  final List<String> activities;
  final IconData icon;

  const DayPart({
    required this.title,
    required this.activities,
    required this.icon,
  });
}

class MoodyPlanningScreen extends ConsumerStatefulWidget {
  final String selectedMood;

  const MoodyPlanningScreen({
    super.key,
    required this.selectedMood,
  });

  @override
  ConsumerState<MoodyPlanningScreen> createState() => _MoodyPlanningScreenState();
}

class _MoodyPlanningScreenState extends ConsumerState<MoodyPlanningScreen> {
  late ConversationService _conversationService;
  bool _isLoading = true;
  bool _isThinking = false;
  bool _showChatBubble = false;
  String? _userMessage;
  String? _moodyResponse;
  late SpeechToText _speech;
  late FlutterTts _flutterTts;
  List<DayPart> _dayParts = [];
  Offset _moodyPosition = const Offset(16, 100);
  Map<String, List<String>> _selectedActivities = {
    'Morning': [],
    'Afternoon': [],
    'Evening': [],
  };
  bool _isListening = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _conversationService = ConversationService(widget.selectedMood);
    _initializeSpeech();
    _loadSuggestions();
  }

  Future<void> _initializeSpeech() async {
    _speech = SpeechToText();
    _flutterTts = FlutterTts();
    
    try {
      bool available = await _speech.initialize(
        onError: (error) {
          print('🎤 Speech recognition error: $error');
          _showErrorSnackBar('Speech recognition error: ${error.errorMsg}');
          setState(() {
            _isThinking = false;
          });
        },
        onStatus: (status) {
          print('🎤 Speech recognition status: $status');
          if (status == 'notListening') {
            setState(() {
              _isThinking = false;
            });
          } else if (status == 'listening') {
            setState(() {
              _isThinking = true;
              _showChatBubble = true;
            });
          }
        },
      );

      if (!available) {
        _showErrorSnackBar('Speech recognition not available on this device');
        return;
      }
    
    // Configure TTS for faster response
      print('🔊 Configuring Text-to-Speech...');
      
    await _flutterTts.setLanguage('en-US');
      print('🔊 TTS Language set to en-US');
      
    await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5); // Slower rate for better clarity
      await _flutterTts.setVolume(1.0);
      
      // Get available voices
      final voices = await _flutterTts.getVoices;
      print('🔊 Available TTS voices: $voices');
      
      // Try to set a specific voice
      try {
        await _flutterTts.setVoice({"name": "en-US-language", "locale": "en-US"});
        print('🔊 TTS voice set successfully');
      } catch (e) {
        print('🔊 Error setting TTS voice: $e');
      }
      
      _flutterTts.setStartHandler(() {
        print('🔊 TTS Started Speaking');
        setState(() {
          _isThinking = false;
        });
      });

      _flutterTts.setCompletionHandler(() {
        print('🔊 TTS Completed Speaking');
        if (mounted) {
          setState(() {
            _showChatBubble = false;
          });
        }
      });

      _flutterTts.setErrorHandler((error) {
        print('🔊 TTS Error: $error');
        _showErrorSnackBar('Error with text-to-speech');
      });

    } catch (e) {
      print('Error initializing speech and TTS: $e');
      _showErrorSnackBar('Failed to initialize speech recognition');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _startListening() async {
    if (!_speech.isAvailable) {
      _showErrorSnackBar('Speech recognition not available');
      return;
    }

    final hasPermission = await _speech.hasPermission;
    if (!hasPermission) {
      _showErrorSnackBar('Microphone permission not granted');
      return;
    }

    setState(() {
      _isThinking = true;
      _showChatBubble = true;
      _userMessage = null;
      _moodyResponse = null;
    });

    try {
    await _speech.listen(
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
        localeId: 'en_US',
        cancelOnError: false,
        listenMode: ListenMode.dictation,
      onResult: (result) {
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          final input = result.recognizedWords.toLowerCase();
            print('Recognized words: $input'); // Debug print
          
            setState(() {
              _isThinking = false;
              _userMessage = input;
            });
            
            if (input.contains('hey moody') || input.contains('hi moody') || 
                input.contains('hello moody') || _isThinking) {
            _processUserInput(input);
            }
          } else {
            // Show partial results
            setState(() {
              _userMessage = result.recognizedWords;
            });
          }
        },
        onSoundLevelChange: (level) {
          // Optional: Use sound level for visual feedback
          print('Sound level: $level');
        },
      );
    } catch (e) {
      print('Error starting speech recognition: $e');
      _showErrorSnackBar('Error starting speech recognition');
      setState(() {
        _isThinking = false;
      });
    }
  }

  Future<void> _processUserInput(String input) async {
    // Remove wake word from input for processing
    final cleanInput = input
        .replaceAll('hey moody', '')
        .replaceAll('hi moody', '')
        .replaceAll('hello moody', '')
        .trim();

    setState(() {
      _isThinking = true;
      _userMessage = input;
    });

    // Update conversation context based on input
    if (_conversationService.isRelevantToCurrentState(cleanInput.toLowerCase())) {
      final String response = await _determineResponse(cleanInput.toLowerCase());
      
      // Check if we should prompt for action
      if (_conversationService.shouldPromptForAction) {
        final actionPrompt = _conversationService.getPromptForAction();
        _conversationService.resetTurns();
        
        setState(() {
          _isThinking = false;
          _moodyResponse = "$response\n\n$actionPrompt";
        });
      } else {
        setState(() {
          _isThinking = false;
          _moodyResponse = response;
        });
      }

      // Stop any ongoing speech before starting new one
      await _flutterTts.stop();
      
      // Speak the response
      await _flutterTts.speak(_moodyResponse!);
    }
  }

  Future<String> _determineResponse(String input) async {
    // Update conversation state based on input
    if (input.contains('hello') || input.contains('hi') || input.contains('hey')) {
      _conversationService.transitionState(ConversationState.greeting);
      return "Hello! I'm Moody, your travel companion. How can I help you plan your ${widget.selectedMood} day in Rotterdam?";
    }

    if (input.contains('what') && (input.contains('do') || input.contains('activities'))) {
      _conversationService.transitionState(ConversationState.planning);
      final activities = _dayParts
          .expand((part) => part.activities)
          .take(3)
          .join(', ');
      return "Based on your ${widget.selectedMood} mood, I suggest: $activities";
    }

    if (input.contains('where') || input.contains('location') || input.contains('how to get')) {
      _conversationService.transitionState(ConversationState.locationInfo);
      // Extract location from input or use last discussed activity
      final location = _extractLocation(input) ?? _conversationService.context.lastDiscussedActivity;
      if (location != null) {
        _conversationService.setLocation(location);
        return "I can help you find $location. Would you like directions?";
      }
      return "Which place would you like to know more about?";
    }

    if (input.contains('weather') || input.contains('rain') || input.contains('sun')) {
      _conversationService.transitionState(ConversationState.weatherCheck);
      return "I can adapt our plans based on the weather. Would you like me to suggest indoor or outdoor activities?";
    }

    if (input.contains('bye') || input.contains('goodbye')) {
      _conversationService.transitionState(ConversationState.farewell);
      return "Have a great time exploring Rotterdam! Don't forget to check your selected activities in the plan.";
    }

    // Handle current state-specific responses
    switch (_conversationService.context.state) {
      case ConversationState.planning:
        if (input.contains('yes') || input.contains('sure') || input.contains('okay')) {
          return "Great! Tap on any activity to add it to your plan. You can also ask me about specific activities.";
        }
        break;
      case ConversationState.locationInfo:
        if (input.contains('yes') || input.contains('show') || input.contains('directions')) {
          return "I'll help you navigate to ${_conversationService.context.lastDiscussedLocation}. Would you like public transport or walking directions?";
        }
        break;
      case ConversationState.weatherCheck:
        if (input.contains('indoor')) {
          return "Here are some indoor activities that match your ${widget.selectedMood} mood: Museum Boijmans Van Beuningen, Markthal, Maritime Museum.";
        } else if (input.contains('outdoor')) {
          return "For outdoor activities, I suggest: Euromast observation deck, Harbor tour, or a walk along the Erasmusbrug.";
        }
        break;
      default:
        break;
    }

    // Default response with context awareness
    return "I understand you're interested in ${input.split(' ').take(3).join(' ')}... How can I help make your ${widget.selectedMood} day in Rotterdam better?";
  }

  String? _extractLocation(String input) {
    // Simple location extraction from input
    final locations = _dayParts
        .expand((part) => part.activities)
        .where((activity) => input.toLowerCase().contains(activity.toLowerCase()))
        .toList();
    
    return locations.isNotEmpty ? locations.first : null;
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isThinking = false;
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadSuggestions() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Customize suggestions based on mood
    final suggestions = _getMoodBasedSuggestions();
    
    setState(() {
      _dayParts = [
        DayPart(
          title: 'Morning',
          activities: suggestions['Morning']!,
          icon: Icons.wb_sunny_outlined,
        ),
        DayPart(
          title: 'Afternoon',
          activities: suggestions['Afternoon']!,
          icon: Icons.wb_sunny,
        ),
        DayPart(
          title: 'Evening',
          activities: suggestions['Evening']!,
          icon: Icons.nights_stay_outlined,
        ),
      ];
      _isLoading = false;
    });
  }

  Map<String, List<String>> _getMoodBasedSuggestions() {
    switch (widget.selectedMood.toLowerCase()) {
      case 'adventurous':
        return {
          'Morning': [
            'Visit Euromast 🗼',
            'Take a Spido Harbor Tour ⛴️',
            'Explore Erasmusbrug 🌉',
          ],
          'Afternoon': [
            'Try Water Taxi Adventure 🚤',
            'Visit Maritime Museum ⚓',
            'Explore Delfshaven Historic Harbor 🏛️',
          ],
          'Evening': [
            'Sunset at Euromast Restaurant 🌅',
            'Night Walk Along the Maas 🌙',
            'Visit Wereldmuseum 🌍',
          ],
        };
      case 'cultural':
        return {
          'Morning': [
            'Visit Museum Boijmans Van Beuningen 🎨',
            'Explore Kunsthal Rotterdam 🖼️',
            'Visit Maritime Museum ⚓',
          ],
          'Afternoon': [
            'Tour the Markthal 🏛️',
            'Visit Wereldmuseum 🌍',
            'Explore Historic Delfshaven 🏛️',
          ],
          'Evening': [
            'Evening Concert at De Doelen 🎵',
            'Theater Show at Luxor 🎭',
            'Cultural Dinner at Hotel New York 🍽️',
          ],
        };
      case 'relaxed':
        return {
          'Morning': [
            'Stroll in Arboretum Trompenburg 🌳',
            'Coffee at Hotel New York ☕',
            'Visit Kralingse Bos 🌲',
          ],
          'Afternoon': [
            'Picnic at Kralingse Plas 🧺',
            'Visit Japanese Garden 🍃',
            'Relax at Dakpark 🌸',
          ],
          'Evening': [
            'Sunset Harbor Walk 🌅',
            'Dinner Cruise ⛴️',
            'Spa Evening at Harbour Club 💆‍♂️',
          ],
        };
      default:
        return {
          'Morning': [
            'Visit Euromast 🗼',
            'Explore Markthal 🏛️',
            'Walk along Erasmusbrug 🌉',
          ],
          'Afternoon': [
            'Visit Maritime Museum ⚓',
            'Shop at Koopgoot 🛍️',
            'Tour Kunsthal 🎨',
          ],
          'Evening': [
            'Dinner at Hotel New York 🍽️',
            'Evening Harbor Tour ⛴️',
            'Walk in Kralingse Bos 🌳',
          ],
        };
    }
  }

  void _toggleActivity(String dayPart, String activity) {
    setState(() {
      if (_selectedActivities[dayPart]!.contains(activity)) {
        _selectedActivities[dayPart]!.remove(activity);
      } else {
        _selectedActivities[dayPart]!.add(activity);
      }
    });
  }

  bool get _hasSelectedActivities =>
      _selectedActivities.values.any((list) => list.isNotEmpty);

  Future<void> _handleVoiceInput(String text) async {
    print('🎤 Handling voice input: $text');
    
    setState(() {
      _userMessage = text;
      _isThinking = true;
      _moodyResponse = null;
      _isListening = false; // Make sure to update listening state
    });

    try {
      // Generate response
      final response = _generateMoodyResponse(text);
      print('🤖 Generated response: $response');
      
      // Update state with response
      setState(() {
        _moodyResponse = response;
      });

      // Speak the response
      await _speakResponse(response);
    } catch (e) {
      print('❌ Error handling voice input: $e');
      _showErrorSnackBar('Failed to process your request');
    } finally {
      setState(() {
        _isThinking = false;
      });
    }
  }

  String _generateMoodyResponse(String input) {
    final lowercaseInput = input.toLowerCase();
    
    if (lowercaseInput.contains('hello') || lowercaseInput.contains('hi')) {
      return "Hello! I'm Moody, your travel companion. How can I help you plan your day? 😊";
    } else if (lowercaseInput.contains('weather')) {
      return "I'll check the weather for you and suggest some suitable activities! ⛅";
    } else if (lowercaseInput.contains('activity') || lowercaseInput.contains('do')) {
      return "Based on your mood and the weather, I'd recommend some outdoor activities like hiking or visiting a local cafe! 🌳☕";
    } else if (lowercaseInput.contains('food') || lowercaseInput.contains('eat')) {
      return "I know some great places to eat nearby! Would you like me to suggest some restaurants? 🍽️";
    } else {
      return "I'm here to help you plan your perfect day! Feel free to ask about activities, weather, or places to visit. 🌟";
    }
  }

  Future<void> _speakResponse(String text) async {
    try {
      if (_flutterTts == null) {
        print('🔊 TTS not initialized, initializing now...');
        await _initializeSpeech();
      }

      print('🔊 Speaking response: $text');
      final result = await _flutterTts.speak(text);
      print('🔊 Speak result: $result');
    } catch (e) {
      print('🔊 Error speaking response: $e');
      _showErrorSnackBar('Failed to speak response: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A237E), // Deep blue
              Color(0xFF0D47A1), // Darker blue
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MoodyCharacter(
                    size: 120,
                    mood: _isThinking ? 'thinking' : 'default',
                  ).animate()
                    .fadeIn(duration: 800.ms)
                    .scale(delay: 200.ms),
                  const SizedBox(height: 32),
                  Text(
                    'Chat with Moody',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ).animate()
                    .fadeIn(delay: 400.ms)
                    .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Try saying:\n"Hello Moody!"\nor\n"What activities do you suggest?"',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ).animate()
                    .fadeIn(delay: 600.ms)
                    .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 32),
                  if (_userMessage != null || _isListening || _isThinking) ...[
                    GlassChatBox(
                      userMessage: _userMessage,
                      moodyResponse: _moodyResponse,
                      isListening: _isListening,
                      isProcessing: _isThinking,
                    ),
                    const SizedBox(height: 32),
                  ],
                  VoiceInputButton(
                    onTextRecognized: _handleVoiceInput,
                    onListeningStateChanged: (isListening) {
                      setState(() {
                        _isListening = isListening;
                      });
                    },
                    hintText: 'Tap to chat with Moody...',
                  ).animate()
                    .fadeIn(delay: 800.ms)
                    .scale(delay: 800.ms),
                  const SizedBox(height: 80), // Added padding for text input
                ],
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                            child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                              child: Row(
                                                children: [
                                                  Expanded(
                              child: TextField(
                                controller: _textController,
                                                      style: GoogleFonts.poppins(
                                  color: Colors.white,
                                                        fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Type your message...',
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.white60,
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                onSubmitted: (text) {
                                  if (text.isNotEmpty) {
                                    _handleVoiceInput(text);
                                    _textController.clear();
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send_rounded),
                              color: Colors.white70,
                              onPressed: () {
                                // Get the text from the controller and send
                                final text = _textController.text;
                                if (text.isNotEmpty) {
                                  _handleVoiceInput(text);
                                  _textController.clear();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 