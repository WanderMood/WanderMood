import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:simple_animations/simple_animations.dart';
import 'dart:math' as math;
import 'package:wandermood/features/location/providers/location_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wandermood/features/location/presentation/widgets/location_dropdown.dart';
import 'package:wandermood/features/places/models/place.dart';
import 'package:wandermood/features/places/providers/trending_destinations_provider.dart';
import 'package:wandermood/features/home/presentation/widgets/trending_section.dart';
import 'package:wandermood/features/weather/presentation/widgets/location_selector.dart';
import 'package:wandermood/features/weather/domain/models/location.dart';
import 'package:go_router/go_router.dart';
import 'package:wandermood/features/places/providers/explore_places_provider.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wandermood/features/places/services/places_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wandermood/features/home/presentation/screens/place_details_screen.dart';
import 'package:wandermood/features/mood/providers/mood_recommendations_provider.dart';
import 'package:wandermood/features/home/presentation/widgets/place_card.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wandermood/features/location/services/location_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wandermood/features/recommendations/providers/recommendation_provider.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'All';
  bool _showSearchSuggestions = false;
  String _searchQuery = '';
  List<String> _filteredSuggestions = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMorePages = true;
  int _currentPage = 1;
  bool _isMapView = false;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  String _selectedCity = 'Rotterdam';
  
  final List<String> _recentSearches = [
    'Restaurants near Markthal',
    'Euromast tickets',
    'Rotterdam harbor tour',
  ];

  final List<String> _searchSuggestions = [
    'Best photo spots',
    'Family activities',
    'Historical sites',
    'Local food markets',
    'Walking tours',
    'Cube houses',
    'Erasmusbrug',
    'Rotterdam Zoo',
    'Maritime Museum',
    'Fenix Food Factory',
    'Hotel New York',
    'Markthal restaurants',
    'Kunsthal exhibitions',
    'Witte de Withstraat',
    'Boat tours Rotterdam',
    'Rotterdam architecture',
    'Rooftop bars',
    'Shopping in Rotterdam',
    'Coffee shops Rotterdam',
    'Street art Rotterdam',
  ];

  final List<Map<String, dynamic>> _hotels = [
    {
      'name': 'Hotel New York',
      'location': 'Rotterdam',
      'flag': '🇳🇱',
      'distance': '0 km',
      'rating': 4.8,
      'image': 'assets/images/fredrik-ohlander-fCW1hWq2nq0-unsplash.jpg',
      'categories': ['Culture', 'History', 'Relaxation'],
      'activities': [
        {'name': 'Fine Dining', 'icon': '🍽️'},
        {'name': 'Harbor View', 'icon': '🚢'},
        {'name': 'Heritage Tour', 'icon': '🏛️'}
      ],
      'description': 'Historic hotel in former Holland America Line headquarters',
      'isFavorite': false,
      'latitude': 51.9054,
      'longitude': 4.4822
    },
    // ... Add more hotels here
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final location = await LocationService.getCurrentLocation();
      await _loadNearbyPlaces(
        latitude: location.latitude,
        longitude: location.longitude,
      );
    } catch (e) {
      debugPrint('Error loading initial data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadNearbyPlaces({
    required double latitude,
    required double longitude,
    String? category,
  }) async {
    if (!_hasMorePages) return;
    
    setState(() => _isLoadingMore = true);
    try {
      final places = await ref.read(explorePlacesProvider.notifier).getNearbyPlaces(
        latitude: latitude,
        longitude: longitude,
        category: category,
        page: _currentPage,
      );
      
      setState(() {
        _markers = places.map((place) => Marker(
          markerId: MarkerId(place.id),
          position: LatLng(place.latitude, place.longitude),
          infoWindow: InfoWindow(title: place.name),
        )).toSet();
      });
    } catch (e) {
      debugPrint('Error loading nearby places: $e');
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMorePlaces();
    }
  }

  Future<void> _loadMorePlaces() async {
    if (_isLoadingMore || !_hasMorePages) return;
    
    setState(() {
      _currentPage++;
      _isLoadingMore = true;
    });
    
    try {
      final location = await LocationService.getCurrentLocation();
      await _loadNearbyPlaces(
        latitude: location.latitude,
        longitude: location.longitude,
        category: _selectedCategory == 'All' ? null : _selectedCategory,
      );
    } catch (e) {
      debugPrint('Error loading more places: $e');
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  void _filterSuggestions(String query) {
    setState(() {
      _searchQuery = query;
      _filteredSuggestions = _searchSuggestions
          .where((suggestion) => suggestion.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _showSearchSuggestions = query.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final exploreState = ref.watch(explorePlacesProvider);
    final trendingDestinations = ref.watch(trendingDestinationsProvider);
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            if (_showSearchSuggestions) _buildSearchSuggestions(),
            Expanded(
              child: _isMapView
                  ? _buildMapView()
                  : _buildListView(exploreState, trendingDestinations),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildViewToggleButton(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search places...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: _filterSuggestions,
              onTap: () => setState(() => _showSearchSuggestions = true),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showCategoryFilter,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _filteredSuggestions.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.search),
            title: Text(_filteredSuggestions[index]),
            onTap: () {
              _searchController.text = _filteredSuggestions[index];
              setState(() => _showSearchSuggestions = false);
              // TODO: Implement search functionality
            },
          );
        },
      ),
    );
  }

  Widget _buildMapView() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(51.9244, 4.4777), // Rotterdam coordinates
        zoom: 12,
      ),
      markers: _markers,
      onMapCreated: (controller) => _mapController = controller,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: true,
    );
  }

  Widget _buildListView(
    AsyncValue<List<Place>> exploreState,
    AsyncValue<List<Place>> trendingDestinations,
  ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadInitialData,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          if (trendingDestinations.hasValue) ...[
            TrendingSection(
              places: trendingDestinations.value!,
              onPlaceTap: (place) => _navigateToPlaceDetails(place),
            ),
            const SizedBox(height: 24),
          ],
          if (exploreState.hasValue) ...[
            ...exploreState.value!.map((place) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PlaceCard(
                place: place,
                onTap: () => _navigateToPlaceDetails(place),
              ),
            )),
            if (_isLoadingMore)
              const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }

  Widget _buildViewToggleButton() {
    return FloatingActionButton(
      onPressed: () {
        setState(() => _isMapView = !_isMapView);
      },
      child: Icon(_isMapView ? Icons.list : Icons.map),
    );
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Category',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCategoryChip('All'),
                _buildCategoryChip('Restaurants'),
                _buildCategoryChip('Attractions'),
                _buildCategoryChip('Hotels'),
                _buildCategoryChip('Shopping'),
                _buildCategoryChip('Nightlife'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    return FilterChip(
      label: Text(category),
      selected: _selectedCategory == category,
      onSelected: (selected) {
        setState(() => _selectedCategory = category);
        Navigator.pop(context);
        _loadInitialData();
      },
    );
  }

  void _navigateToPlaceDetails(Place place) {
    context.push('/place/${place.id}', extra: place);
  }
} 