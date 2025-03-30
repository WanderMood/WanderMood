import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/explore_provider.dart';
import '../widgets/explore_grid.dart';
import '../widgets/explore_search_bar.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  @override
  Widget build(BuildContext context) {
    final exploreState = ref.watch(exploreProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ExploreSearchBar(),
            Expanded(
              child: exploreState.when(
                data: (places) => ExploreGrid(places: places),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error: ${error.toString()}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 