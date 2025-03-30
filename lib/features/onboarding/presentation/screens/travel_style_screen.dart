import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../home/presentation/widgets/moody_character.dart';

class TravelStyleScreen extends ConsumerStatefulWidget {
  const TravelStyleScreen({super.key});

  @override
  ConsumerState<TravelStyleScreen> createState() => _TravelStyleScreenState();
}

class _TravelStyleScreenState extends ConsumerState<TravelStyleScreen> with TickerProviderStateMixin {
  late final AnimationController _moodyController;
  late final AnimationController _messageController;
  late final FlutterTts _flutterTts;
  final Set<String> _selectedStyles = {};

  final List<Map<String, dynamic>> _travelStyles = [
    {
      'name': 'Spontaneous',
      'description': 'Go with the flow, embrace surprises',
      'color': const Color(0xFFFF9800),
    },
    {
      'name': 'Planned',
      'description': 'Organized itineraries, scheduled visits',
      'color': const Color(0xFF2196F3),
    },
    {
      'name': 'Local Experience',
      'description': 'Live like a local, authentic spots',
      'color': const Color(0xFF4CAF50),
    },
    {
      'name': 'Tourist Highlights',
      'description': 'Must-see attractions, popular spots',
      'color': const Color(0xFF9C27B0),
    },
    {
      'name': 'Off the Beaten Path',
      'description': 'Hidden gems, unique experiences',
      'color': const Color(0xFFF44336),
    },
  ];

  @override
  void initState() {
    super.initState();
    _moodyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _messageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _initializeTts();
    _startAnimation();
  }

  void _initializeTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setVoice({
      "name": "com.apple.ttsbundle.Moira-compact",
      "locale": "en-US"
    });
    await _flutterTts.setSpeechRate(0.9);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _moodyController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _messageController.forward();
    _speakMessage();
  }

  Future<void> _speakMessage() async {
    const message = "Last but not least, what's your travel style";
    await _flutterTts.speak(message);
  }

  void _toggleStyle(String style) {
    setState(() {
      if (_selectedStyles.contains(style)) {
        _selectedStyles.remove(style);
      } else {
        _selectedStyles.add(style);
      }
    });
    _speakStyleMessage(style);
  }

  Future<void> _speakStyleMessage(String style) async {
    String message;
    switch (style) {
      case 'Spontaneous':
        message = "Love it! Let's keep things exciting and go where the wind takes us!";
        break;
      case 'Planned':
        message = "Great choice! I'll help you create the perfect itinerary with all the details!";
        break;
      case 'Local Experience':
        message = "Awesome! I know some amazing local spots that tourists rarely find!";
        break;
      case 'Tourist Highlights':
        message = "Perfect! We'll make sure you don't miss any of the must-see attractions!";
        break;
      case 'Off the Beaten Path':
        message = "Adventure awaits! Let's discover some hidden treasures together!";
        break;
      default:
        return;
    }
    
    if (_selectedStyles.length >= 2) {
      message = "Nice mix! We'll create a perfect blend of experiences just for you!";
    }
    
    await _flutterTts.speak(message);
  }

  @override
  void dispose() {
    _moodyController.dispose();
    _messageController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFAFF4), // Pink
              Color(0xFFFFF5AF), // Yellow
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Progress indicator
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(4, (index) => Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5BB32A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    )),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5BB32A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 80),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.2),
                        end: Offset.zero,
                      ).animate(_messageController),
                      child: FadeTransition(
                        opacity: _messageController,
                        child: Text(
                          'Last but not least! 🌟',
                          style: GoogleFonts.museoModerno(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5BB32A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.2),
                        end: Offset.zero,
                      ).animate(_messageController),
                      child: FadeTransition(
                        opacity: _messageController,
                        child: Text(
                          'What\'s your travel style?',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _travelStyles.length,
                        itemBuilder: (context, index) {
                          final style = _travelStyles[index];
                          final isSelected = _selectedStyles.contains(style['name']);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: InkWell(
                              onTap: () => _toggleStyle(style['name']),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSelected
                                    ? style['color'].withOpacity(0.15)
                                    : Colors.white.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                      ? style['color']
                                      : Colors.grey.withOpacity(0.3),
                                    width: isSelected ? 2.5 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                        ? style['color'].withOpacity(0.4)
                                        : Colors.black.withOpacity(0.1),
                                      blurRadius: isSelected ? 15 : 12,
                                      spreadRadius: isSelected ? 2 : 0,
                                      offset: Offset(0, isSelected ? 2 : 4),
                                    ),
                                    if (isSelected)
                                      BoxShadow(
                                        color: style['color'].withOpacity(0.2),
                                        blurRadius: 20,
                                        spreadRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              style['name'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: isSelected
                                                  ? style['color']
                                                  : Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              style['description'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 200),
                                        child: isSelected
                                          ? Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: style['color'],
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            )
                                          : const SizedBox(width: 24),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate(
                                onPlay: (controller) => controller.repeat(),
                              ).shimmer(
                                duration: const Duration(seconds: 2),
                                color: isSelected ? style['color'].withOpacity(0.3) : Colors.transparent,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedStyles.isNotEmpty
                          ? () => context.go('/preferences/summary')
                          : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5BB32A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                        ),
                        child: Text(
                          'Start Exploring',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Moody character
              Positioned(
                right: 20,
                bottom: MediaQuery.of(context).size.height * 0.08,
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: 0.5,
                    end: 1.0,
                  ).animate(_moodyController),
                  child: const MoodyCharacter(
                    size: 120,
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