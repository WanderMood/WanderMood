import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/recommendation_card.dart';
import '../../application/recommendation_service.dart';
import '../../domain/models/travel_recommendation.dart';
import '../../../ai/presentation/widgets/api_test_widget.dart';

class RecommendationsPage extends ConsumerStatefulWidget {
  const RecommendationsPage({super.key});

  @override
  ConsumerState<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends ConsumerState<RecommendationsPage> {
  bool _isLoading = false;
  List<TravelRecommendation> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() => _isLoading = true);

    try {
      final recommendations = await ref
          .read(recommendationServiceProvider)
          .getRecommendations();
      setState(() => _recommendations = recommendations);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fout bij het laden van aanbevelingen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reisaanbevelingen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecommendations,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const APITestWidget(),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _recommendations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.travel_explore,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Geen aanbevelingen beschikbaar',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadRecommendations,
                              child: const Text('Opnieuw proberen'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _recommendations.length,
                        itemBuilder: (context, index) {
                          final recommendation = _recommendations[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: RecommendationCard(
                              recommendation: recommendation,
                              onTap: () {
                                // TODO: Implementeer navigatie naar detail pagina
                              },
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
} 