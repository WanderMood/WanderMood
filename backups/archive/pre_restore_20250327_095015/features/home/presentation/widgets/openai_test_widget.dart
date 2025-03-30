import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wandermood/core/models/place.dart';
import 'package:wandermood/core/services/openai_service.dart';
import 'package:wandermood/core/services/places_service.dart';
import 'package:wandermood/core/services/weather_service.dart';

class OpenAITestWidget extends ConsumerStatefulWidget {
  const OpenAITestWidget({super.key});

  @override
  ConsumerState<OpenAITestWidget> createState() => _OpenAITestWidgetState();
}

class _OpenAITestWidgetState extends ConsumerState<OpenAITestWidget> {
  String _testResult = 'Not tested yet';
  bool _isLoading = false;
  bool _isLoadingPlaces = false;
  List<Place> _places = [];
  String? _weatherCondition;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingPlaces = true;
      _testResult = 'Loading places and weather data...';
    });

    try {
      // Load places
      final placesService = ref.read(placesServiceProvider.notifier);
      final places = await placesService.getPlaces();
      if (!mounted) return;
      setState(() {
        _places = places;
        _testResult = 'Places loaded successfully! (${places.length} places found)';
      });

      // Load weather
      final weatherService = ref.read(weatherServiceProvider.notifier);
      final weather = await weatherService.getCurrentWeather();
      if (!mounted) return;
      setState(() {
        _weatherCondition = weather.condition;
        _testResult += '\nWeather data loaded successfully!';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _testResult = 'Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingPlaces = false);
      }
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing OpenAI connection...';
    });

    try {
      final success = await ref.read(openAIServiceProvider).testConnection();
      if (!mounted) return;
      setState(() {
        _testResult = success ? 'Connection successful! ✅' : 'Connection failed ❌\nPlease check your API key and try again.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _testResult = 'Error testing connection: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _testPlanGeneration() async {
    if (_places.isEmpty) {
      setState(() => _testResult = 'No places loaded yet. Please wait...');
      await _loadData();
      return;
    }

    setState(() {
      _isLoading = true;
      _testResult = 'Generating plan...';
    });

    try {
      final suggestion = await ref.read(openAIServiceProvider).generatePlanSuggestions(
        selectedMoods: ['happy', 'energetic'],
        timeOfDay: DateTime.now().hour < 12 ? 'morning' : 
                   DateTime.now().hour < 17 ? 'afternoon' : 'evening',
        availablePlaces: _places,
        weatherCondition: _weatherCondition,
      );

      if (!mounted) return;
      setState(() => _testResult = suggestion ?? 'Failed to generate plan');
    } catch (e) {
      if (!mounted) return;
      setState(() => _testResult = 'Error generating plan: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'OpenAI Integration Test',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (_isLoadingPlaces)
              const Center(child: CircularProgressIndicator())
            else ...[
              ElevatedButton(
                onPressed: _isLoading ? null : _testConnection,
                child: Text(_isLoading ? 'Testing...' : 'Test Connection'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _testPlanGeneration,
                child: Text(_isLoading ? 'Generating...' : 'Test Plan Generation'),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              _testResult,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
} 