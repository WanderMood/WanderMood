import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:wandermood/core/domain/providers/location_notifier_provider.dart';
import 'package:wandermood/features/location/presentation/widgets/location_dropdown.dart';
import 'package:wandermood/features/places/models/place.dart';
import 'package:wandermood/features/places/providers/explore_places_provider.dart';
import 'package:wandermood/features/places/providers/trending_destinations_provider.dart';
import 'package:wandermood/features/places/services/places_service.dart';
import 'dart:math' show min;
import 'package:share_plus/share_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wandermood/features/places/widgets/place_image.dart';
import 'package:wandermood/core/presentation/widgets/swirl_background.dart';
import 'dart:math';
import '../../../places/providers/filtered_places_provider.dart';
import '../../../places/providers/places_cache_provider.dart';
import '../../../mood/providers/current_mood_provider.dart';
import 'package:geolocator/geolocator.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

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
  bool _isListening = false;
  int _currentPage = 0;
  bool _isLoadingMore = false;
  
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

  final List<String> _categories = [
    'All',
    'Popular',
    'Accommodations',
    'Nature',
    'Culture',
    'Food',
    'Activities',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8 && !_isLoadingMore) {
      _loadMorePlaces();
    }
  }

  Future<void> _loadMorePlaces() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    // The filtered places provider will handle the actual loading
    await Future.delayed(const Duration(milliseconds: 500)); // Debounce

    setState(() {
      _isLoadingMore = false;
    });
  }

  // Updated to use places from API providers
  List<Map<String, dynamic>> get filteredItems {
    // Get places from providers
    final locationState = ref.watch(locationNotifierProvider);
    final city = locationState.city ?? 'Rotterdam';
    
    final trendingPlaces = ref.watch(trendingDestinationsProvider(city: city)).value ?? [];
    final explorePlaces = ref.watch(explorePlacesProvider(city: city)).value ?? [];
    
    // Convert Place objects to Map for consistency with existing code
    final List<Map<String, dynamic>> allItems = [
      ...trendingPlaces.map((place) => _convertPlaceToMap(place)).toList(),
      ...explorePlaces.map((place) => _convertPlaceToMap(place)).toList(),
    ];
    
    if (_selectedCategory == 'All') {
      return allItems;
    } else if (_selectedCategory == 'Accommodations') {
      return allItems.where((item) => 
        (item['categories'] as List?)?.contains('Accommodations') == true ||
        (item['types'] as List?)?.contains('lodging') == true
      ).toList();
    }
    
    return allItems.where((item) => 
      (item['categories'] as List?)?.contains(_selectedCategory) == true ||
      (item['types'] as List?)?.any((type) => type.toString().toLowerCase().contains(_selectedCategory.toLowerCase())) == true
    ).toList();
  }
  
  // Helper method to convert Place object to Map - optimized for performance
  Map<String, dynamic> _convertPlaceToMap(dynamic place) {
    if (place is Place) {
      final locationState = ref.read(locationNotifierProvider);
      String distance = '-- km';
      
      // Calculate distance if we have both coordinates
      if (locationState.hasLocation &&
          place.location != null) {
        final distanceInKm = Geolocator.distanceBetween(
          locationState.currentLatitude!,
          locationState.currentLongitude!,
          place.location.lat,
          place.location.lng
        ) / 1000; // Convert meters to kilometers
        
        // Round to 1 decimal place if less than 10km, otherwise round to whole number
        distance = distanceInKm < 10 
          ? '${distanceInKm.toStringAsFixed(1)} km'
          : '${distanceInKm.round()} km';
      }
      
      // Pre-populate activities for faster display
      final activities = _generateActivitiesFromTypes(place.types ?? []);
      
      // Extract city only once
      final locationName = _extractCityName(place.address);
      
      return {
        'name': place.name,
        'location': locationName, 
        'flag': '🇳🇱',
        'distance': distance,
        'rating': place.rating ?? 4.0,
        'place_id': place.id,
        'photos': place.photos ?? [],
        'categories': place.types ?? ['Other'],
        'types': place.types ?? [],
        'activities': activities,
        'description': place.description ?? 'Explore this amazing destination',
        'isFavorite': false,
        'latitude': place.location?.lat,
        'longitude': place.location?.lng,
      };
    } else if (place is Map) {
      return place as Map<String, dynamic>;
    } else {
      return {
        'name': 'Unknown Place',
        'location': 'Unknown',
        'flag': '🇳🇱',
        'distance': '-- km',
        'rating': 4.0,
        'photos': [],
        'categories': ['Other'],
        'activities': [{'name': 'Explore', 'icon': '🔍'}],
        'description': 'Discover this location',
        'isFavorite': false,
      };
    }
  }
  
  // Calculate distance between two coordinates in kilometers
  double _calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    ) / 1000; // Convert meters to kilometers
  }

  // Helper to generate activities from place types
  List<Map<String, dynamic>> _generateActivitiesFromTypes(List<String> types) {
    final activities = <Map<String, dynamic>>[];
    
    if (types.contains('restaurant') || types.contains('food')) {
      activities.add({'name': 'Dining', 'icon': '🍽️'});
    }
    if (types.contains('museum')) {
      activities.add({'name': 'Museum', 'icon': '🏛️'});
    }
    if (types.contains('park')) {
      activities.add({'name': 'Nature', 'icon': '🌳'});
    }
    if (types.contains('tourist_attraction')) {
      activities.add({'name': 'Tourist Spot', 'icon': '📸'});
    }
    if (types.contains('shopping_mall') || types.contains('store')) {
      activities.add({'name': 'Shopping', 'icon': '🛍️'});
    }
    if (types.contains('bar')) {
      activities.add({'name': 'Nightlife', 'icon': '🍸'});
    }
    if (types.contains('lodging') || types.contains('hotel')) {
      activities.add({'name': 'Hotel', 'icon': '🏨'});
    }
    
    // Add default activity if none were added
    if (activities.isEmpty) {
      activities.add({'name': 'Explore', 'icon': '🔍'});
    }
    
    return activities;
  }

  void _startVoiceSearch() {
    // TODO: Implement voice search
    setState(() {
      _isListening = !_isListening;
    });
  }

  void _performSearch(String query) {
    // TODO: Implement search functionality
    print('Searching for: $query');
  }

  List<TextSpan> _highlightMatches(String text, String query) {
    if (query.isEmpty) return [TextSpan(text: text)];

    List<TextSpan> spans = [];
    int start = 0;
    int indexOfQuery = text.toLowerCase().indexOf(query.toLowerCase());

    while (indexOfQuery != -1) {
      if (indexOfQuery > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfQuery)));
      }

      spans.add(
        TextSpan(
          text: text.substring(indexOfQuery, indexOfQuery + query.length),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF12B347),
          ),
        ),
      );

      start = indexOfQuery + query.length;
      indexOfQuery = text.toLowerCase().indexOf(query.toLowerCase(), start);
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationNotifierProvider);
    final currentMood = ref.watch(currentMoodProvider);
    
    if (locationState.isLoading) {
      return const SwirlBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    
    if (locationState.hasError) {
      return SwirlBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${locationState.error}'),
                ElevatedButton(
                  onPressed: () {
                    ref.read(locationNotifierProvider.notifier).retryLocationAccess();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    if (!locationState.hasCity) {
      return const SwirlBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: Text('No location selected')),
        ),
      );
    }
    
    // Get all places for the current city
    final explorePlaces = ref.watch(explorePlacesProvider(city: locationState.city!));
    
    return explorePlaces.when(
      loading: () => const SwirlBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => SwirlBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: Text('Error: $error')),
        ),
      ),
      data: (places) {
        if (places.isEmpty) {
          return SwirlBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Text('No places found for ${locationState.city}'),
              ),
            ),
          );
        }
        
        // Apply filtering here - much faster than in build()
        final filteredPlaces = _filterPlacesByMood(places, currentMood);
        
        // Convert places to map format for compatibility with existing code
        final items = filteredPlaces.map((place) => _convertPlaceToMap(place)).toList();
        
        return SwirlBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Explore',
                          style: GoogleFonts.museoModerno(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF12B347),
                          ),
                        ),
                        const LocationDropdown(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildSearchBar(),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Row(
                      children: _categories.map((category) => _buildCategoryChip(category)).toList(),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16.0),
                      itemCount: items.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= items.length) {
                          if (_isLoadingMore) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return null;
                        }
                        return _buildListItem(items[index], index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlacesList(List<Place> places) {
    return SwirlBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              title: Text(
                'Explore',
                style: GoogleFonts.museoModerno(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF12B347),
                ),
              ),
              actions: [
                const LocationDropdown(),
              ],
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= places.length) {
                    if (_isLoadingMore) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return null;
                  }

                  final place = places[index];
                  return _buildListItem(_convertPlaceToMap(place), index);
                },
                childCount: places.length + (_isLoadingMore ? 1 : 0),
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> item, int index) {
    bool isFavorite = item['isFavorite'] ?? false;
    final placesService = ref.read(placesServiceProvider.notifier);

    // Get photo reference directly from the item
    String? photoReference;
    if (item['photos'] != null && (item['photos'] as List).isNotEmpty) {
      final photoObject = (item['photos'] as List).first;
      if (photoObject is Map<String, dynamic> && photoObject['photo_reference'] != null) {
        photoReference = photoObject['photo_reference'].toString();
      } else if (photoObject is String) {
        photoReference = photoObject;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: photoReference != null
                      ? Image.network(
                          ref.read(placesServiceProvider.notifier).getPlacePhotoUrl(photoReference),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('❌ Error loading image: $error');
                            return Container(
                              height: 180,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, color: Colors.grey),
                            );
                          },
                        )
                      : Container(
                          height: 180,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                  ),
                  if (item['isOpen'] == true)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Open Now',
                          style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              item['isFavorite'] = !isFavorite;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: () {
                            Share.share('Check out ${item['name']} in ${item['location']}!');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['name'] ?? 'Unknown Place',
                            style: GoogleFonts.openSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item['rating'] != null)
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                item['rating'].toString(),
                                style: GoogleFonts.openSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '\$\$\$ • ',
                          style: GoogleFonts.openSans(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Expensive',
                          style: GoogleFonts.openSans(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          item['flag'] ?? '🇳🇱',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item['location'] ?? 'No address available',
                            style: GoogleFonts.openSans(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Color(0xFF12B347),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item['distance'] ?? '7 km',
                          style: GoogleFonts.openSans(
                            fontSize: 14,
                            color: Color(0xFF12B347),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['description'] ?? 'No description available',
                      style: GoogleFonts.openSans(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final type in (item['types'] as List<String>? ?? []).take(3))
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _formatTypeWithEmoji(type),
                              style: GoogleFonts.openSans(
                                fontSize: 12,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 600.ms, delay: Duration(milliseconds: index * 100))
      .slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: index * 100));
  }

  String _formatTypeWithEmoji(String type) {
    // Convert type to a more readable format and add emoji
    final formattedTypes = {
      'tourist_attraction': '🎯 Tourist Spot',
      'restaurant': '🍽️ Restaurant',
      'food': '🍳 Food',
      'museum': '🏛️ Museum',
      'park': '🌳 Park',
      'shopping_mall': '🛍️ Shopping',
      'store': '🏪 Store',
      'bar': '🍸 Bar',
      'lodging': '🏨 Hotel',
      'hotel': '🏨 Hotel',
      'cafe': '☕ Cafe',
      'art_gallery': '🎨 Art Gallery',
      'night_club': '🎉 Nightclub',
      'gym': '💪 Gym',
      'spa': '💆 Spa',
      'bakery': '🥖 Bakery',
      'church': '⛪ Church',
      'zoo': '🦁 Zoo',
      'aquarium': '🐠 Aquarium',
      'amusement_park': '🎡 Amusement Park',
      'library': '📚 Library',
      'stadium': '🏟️ Stadium',
      'historic': '🏺 Historic Site',
      'landmark': '🗽 Landmark',
    };

    // Remove underscores and capitalize each word
    String readable = type.replaceAll('_', ' ');
    readable = readable.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
    
    // Return formatted version if it exists, otherwise return capitalized version with a generic emoji
    return formattedTypes[type] ?? '🌟 $readable';
  }

  Widget _buildSearchBar() {
    return Stack(
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            style: GoogleFonts.poppins(color: Colors.black87),
            onTap: () {
              setState(() {
                _showSearchSuggestions = true;
              });
            },
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _filteredSuggestions = _searchSuggestions
                    .where((suggestion) =>
                        suggestion.toLowerCase().contains(value.toLowerCase()))
                    .toList();
              });
            },
            onSubmitted: (value) {
              if (value.isNotEmpty && !_recentSearches.contains(value)) {
                setState(() {
                  _recentSearches.insert(0, value);
                  if (_recentSearches.length > 3) {
                    _recentSearches.removeLast();
                  }
                  _showSearchSuggestions = false;
                });
              }
              
              if (value.isNotEmpty) {
                _performSearch(value);
              }
            },
            decoration: InputDecoration(
              hintText: 'Find hidden gems, vibes & bites...✨',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF12B347)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _showSearchSuggestions = false;
                        });
                      },
                    )
                  : IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? Colors.red : const Color(0xFF12B347),
                      ),
                      onPressed: _startVoiceSearch,
                    ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        if (_showSearchSuggestions) ...[
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_searchQuery.isEmpty) ... [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Recent Searches',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  ...List.generate(
                    _recentSearches.length,
                    (index) => ListTile(
                      leading: const Icon(Icons.history, color: Color(0xFF12B347)),
                      title: Text(_recentSearches[index]),
                      onTap: () {
                        if (index < _recentSearches.length) {
                          _searchController.text = _recentSearches[index];
                          setState(() {
                            final selected = _recentSearches[index];
                            _recentSearches.removeAt(index);
                            _recentSearches.insert(0, selected);
                            _showSearchSuggestions = false;
                          });
                          _performSearch(_recentSearches[index]);
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Suggested Searches',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  ...List.generate(
                    _searchSuggestions.length > 3 ? 3 : _searchSuggestions.length,
                    (index) => ListTile(
                      leading: const Icon(Icons.trending_up, color: Color(0xFF12B347)),
                      title: Text(_searchSuggestions[index]),
                      onTap: () {
                        if (index < _searchSuggestions.length) {
                          _searchController.text = _searchSuggestions[index];
                          setState(() {
                            if (!_recentSearches.contains(_searchSuggestions[index])) {
                              _recentSearches.insert(0, _searchSuggestions[index]);
                              if (_recentSearches.length > 3) {
                                _recentSearches.removeLast();
                              }
                            }
                            _showSearchSuggestions = false;
                          });
                          _performSearch(_searchSuggestions[index]);
                        }
                      },
                    ),
                  ),
                ] else if (_filteredSuggestions.isNotEmpty) ... [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Suggestions for "${_searchQuery}"',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  ...List.generate(
                    _filteredSuggestions.length > 10 ? 10 : _filteredSuggestions.length,
                    (index) => ListTile(
                      leading: const Icon(Icons.search, color: Color(0xFF12B347)),
                      title: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                          children: _highlightMatches(_filteredSuggestions[index], _searchQuery),
                        ),
                      ),
                      onTap: () {
                        if (index < _filteredSuggestions.length) {
                          _searchController.text = _filteredSuggestions[index];
                          setState(() {
                            if (!_recentSearches.contains(_filteredSuggestions[index])) {
                              _recentSearches.insert(0, _filteredSuggestions[index]);
                              if (_recentSearches.length > 3) {
                                _recentSearches.removeLast();
                              }
                            }
                            _showSearchSuggestions = false;
                          });
                          _performSearch(_filteredSuggestions[index]);
                        }
                      },
                    ),
                  ),
                ] else ... [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No results for "${_searchQuery}"',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF12B347) : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
          child: Text(
          category,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTrendingCard(Place place) {
    String? photoUrl;
    
    try {
      if (place.photos.isNotEmpty) {
        photoUrl = place.isAsset
            ? place.photos.first // Already an asset path
            : ref.read(placesServiceProvider.notifier).getPlacePhotoUrl(place.photos.first);
        if (photoUrl != null) {
          debugPrint('📸 Got photo URL for ${place.name}: ${photoUrl.substring(0, min(photoUrl.length, 30))}...');
        }
      } else {
        debugPrint('⚠️ No photos for ${place.name}');
      }
    } catch (e) {
      debugPrint('❌ Error getting photo URL: $e');
    }

    // Create a descriptive summary
    String description = place.address;
    
    // Ensure we have at least some activities based on types
    List<String> activities = [];
    if (place.types.isNotEmpty) {
      if (place.types.contains('tourist_attraction')) activities.add('Sightseeing');
      if (place.types.contains('museum')) activities.add('Museum');
      if (place.types.contains('park')) activities.add('Nature');
      if (place.types.contains('restaurant') || place.types.contains('food')) activities.add('Food');
      if (place.types.contains('shopping_mall') || place.types.contains('store')) activities.add('Shopping');
      // Default activities if none matched
      if (activities.isEmpty) activities = ['Sightseeing', 'Explore'];
    } else {
      activities = ['Sightseeing', 'Explore'];
    }
    
    // Create a proper Destination object from the Place
    final destinationObj = Destination(
      name: place.name,
      description: place.description ?? description,
      imageUrl: photoUrl ?? 'assets/images/tom-podmore-1zkHXas1GIo-unsplash.jpg',
      rating: place.rating,
      category: place.types.isNotEmpty ? place.types[0] : 'tourist_attraction',
      activities: activities,
      isAsset: place.isAsset || photoUrl == null,
    );

    return GestureDetector(
      onTap: () {
        context.push('/place/${place.id}');
      },
      child: Container(
        width: 120, 
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    destinationObj.isAsset
                        ? Image.asset(
                            destinationObj.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('❌ Error loading asset image: $error');
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported),
                              );
                            },
                          )
                        : CachedNetworkImage(
                            imageUrl: destinationObj.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              debugPrint('❌ Error loading network image: $error for URL: $url');
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              );
                            },
                          ),
                    // Rating indicator
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              destinationObj.rating.toStringAsFixed(1),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              destinationObj.name,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              destinationObj.description,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.black54,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationCard(Place place) {
    String? photoUrl;
    
    try {
      if (place.photos.isNotEmpty) {
        photoUrl = place.isAsset
            ? place.photos.first
            : ref.read(placesServiceProvider.notifier).getPlacePhotoUrl(place.photos.first);
      }
    } catch (e) {
      debugPrint('❌ Error getting photo URL for place: $e');
    }

    return GestureDetector(
      onTap: () {
        // When a popular destination card is tapped, navigate to the Place Detail screen
        debugPrint('🔍 Navigating to place detail: ${place.id} (${place.name})');
        context.push('/place/${place.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: photoUrl != null
                      ? PlaceImage(
                          photoReference: place.photos.isNotEmpty ? place.photos.first : null,
                          placeType: place.types.isNotEmpty ? place.types.first : 'default',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.grey),
                        ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12B347),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Open Now • Closes at 22:00',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.favorite_border, size: 20, color: Color(0xFF12B347)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.share, size: 20, color: Color(0xFF12B347)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 20, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        place.rating.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '\$\$\$ •',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Expensive',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Experience the beauty of Rotterdam with stunning architecture and local cuisine',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('🇳🇱', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        _extractCityName(place.address),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF12B347)),
                      const SizedBox(width: 4),
                      Text(
                        '7 km',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF12B347),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildActivityTag(Icons.hiking, 'Hiking'),
                        const SizedBox(width: 8),
                        _buildActivityTag(Icons.photo_camera, 'Sightseeing'),
                        const SizedBox(width: 8),
                        _buildActivityTag(Icons.restaurant, 'Food'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTag(dynamic icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF12B347).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF12B347).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon is IconData 
              ? Icon(icon, size: 16, color: const Color(0xFF12B347))
              : Text(icon.toString(), style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF12B347),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _extractCityName(String address) {
    // If address is empty, return Unknown
    if (address.trim().isEmpty) {
      return 'Unknown';
    }
    
    // Common patterns: "Street, City, State ZIP, Country" or "City, Country"
    final parts = address.split(',').map((part) => part.trim()).toList();
    
    if (parts.length >= 2) {
      // Try to get the city - check each part for known city names
      final locationState = ref.read(locationNotifierProvider);
      final currentCity = locationState.city?.toLowerCase() ?? '';
      
      // Check if any part contains the current city name (case insensitive)
      if (currentCity.isNotEmpty) {
        for (final part in parts) {
          if (part.toLowerCase().contains(currentCity)) {
            return part.trim();
          }
        }
      }
      
      // Fallback approach: try to get the city - typically the second-to-last element before country
      // or the first element if it's a short format
      return parts.length >= 3 ? parts[parts.length - 2] : parts[0];
    }
    
    // Fallback to just returning the first part or the whole address if no commas
    return parts.isNotEmpty ? parts[0] : address;
  }

  void _navigateToPlaceDetails(String placeId) {
    context.push('/place/$placeId');
  }

  Widget _buildEmptyStateMessage(String title, String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF12B347)),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading destinations...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a moment',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString().contains('timeout')
                  ? 'Connection timed out. Check your internet connection and try again.'
                  : 'We couldn\'t load destinations. Please try again later.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Force refresh providers
                ref.invalidate(trendingDestinationsProvider);
                ref.invalidate(explorePlacesProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF12B347),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Try Again',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccommodationCard(Map<String, dynamic> accommodation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and Rating
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  ref.read(placesServiceProvider.notifier).getPlacePhotoUrl(accommodation['photo_reference']),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('❌ Error loading accommodation image: $error');
                    return Image.network(
                      'https://picsum.photos/400/200?random=${accommodation['place_id'].hashCode}',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        accommodation['rating'].toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    accommodation['price_per_night'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Location
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        accommodation['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${accommodation['flag']} ${accommodation['location']}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  accommodation['description'],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                // Room Types
                Wrap(
                  spacing: 8,
                  children: (accommodation['room_types'] as List<String>).map((type) {
                    return Chip(
                      label: Text(
                        type,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.grey[200],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                // Amenities
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: (accommodation['amenities'] as List<Map<String, dynamic>>).map((amenity) {
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: Row(
                          children: [
                            Text(amenity['icon']),
                            const SizedBox(width: 4),
                            Text(
                              amenity['name'],
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Local filtering function to avoid provider dependency loop
  List<Place> _filterPlacesByMood(List<Place> allPlaces, String currentMood) {
    // Create a pre-filtered set of types for faster lookups
    final Map<String, Set<String>> moodToActivityTypes = {
      'Energetic': {'gym', 'park', 'stadium', 'amusement_park', 'sports_complex'},
      'Relaxed': {'spa', 'park', 'cafe', 'library', 'art_gallery'},
      'Cultural': {'museum', 'art_gallery', 'church', 'historic', 'landmark'},
      'Social': {'restaurant', 'bar', 'night_club', 'cafe', 'shopping_mall'},
      'Romantic': {'restaurant', 'park', 'art_gallery', 'cafe', 'tourist_attraction'},
      'Adventure': {'amusement_park', 'park', 'tourist_attraction', 'zoo', 'aquarium'},
      'Foodie': {'restaurant', 'cafe', 'bakery', 'food', 'bar'},
    };
    
    // Force default to Social if currentMood isn't found
    final relevantTypes = moodToActivityTypes[currentMood] ?? moodToActivityTypes['Social'] ?? {'restaurant'};
    
    // Early return if no places or no relevant types
    if (allPlaces.isEmpty || relevantTypes.isEmpty) {
      return allPlaces;
    }
    
    // Much faster filtering approach
    return allPlaces.where((place) {
      // Check if any place type (lowercase) is in the relevant types set
      for (final type in place.types) {
        if (relevantTypes.contains(type.toLowerCase())) {
          return true;
        }
      }
      return false;
    }).take(30).toList(); // Limit to 30 places for performance
  }
}

class DestinationCard extends StatefulWidget {
  final Destination destination;
  final VoidCallback onTap;

  const DestinationCard({
    Key? key,
    required this.destination,
    required this.onTap,
  }) : super(key: key);

  @override
  State<DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<DestinationCard> {
  bool _isLoading = true;
  Offset _offset = Offset.zero;
  
  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      if (widget.destination.isAsset) {
        await precacheImage(AssetImage(widget.destination.imageUrl), context);
      } else {
        await precacheImage(NetworkImage(widget.destination.imageUrl), context);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and opening hours banner
            Stack(
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : widget.destination.isAsset
                        ? Image.asset(
                            widget.destination.imageUrl,
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            imageUrl: widget.destination.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.error),
                            ),
                          ),
                  ),
                ),
                
                // Opening hours banner
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF12B347),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Open Now • Closes at 22:00',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Action buttons
                Positioned(
                  top: 16,
                  right: 16,
                  child: Row(
                    children: [
                      // Like button
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.favorite_border,
                            color: Color(0xFF12B347),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Share button
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.share,
                            color: Color(0xFF12B347),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and rating
                  Text(
                    widget.destination.name,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.destination.rating}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• \$\$\$ • Expensive',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Description
                  Text(
                    widget.destination.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  
                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 20,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_extractCity(widget.destination.description)}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '→ 7 km',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF12B347),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Activities row 
                  Row(
                    children: widget.destination.activities.take(3).map((activity) => 
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _getActivityIcon(activity),
                              const SizedBox(width: 6),
                              Text(
                                activity,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Icon _getActivityIcon(String activity) {
    switch (activity.toLowerCase()) {
      case 'hiking':
        return const Icon(Icons.directions_walk, size: 18);
      case 'sightseeing':
        return const Icon(Icons.camera_alt, size: 18);
      case 'food':
        return const Icon(Icons.restaurant, size: 18);
      case 'shopping':
        return const Icon(Icons.shopping_bag, size: 18);
      case 'museum':
        return const Icon(Icons.museum, size: 18);
      case 'nature':
        return const Icon(Icons.park, size: 18);
      case 'architecture':
        return const Icon(Icons.architecture, size: 18);
      case 'history':
        return const Icon(Icons.history, size: 18);
      case 'photography':
        return const Icon(Icons.photo_camera, size: 18);
      case 'explore':
        return const Icon(Icons.explore, size: 18);
      default:
        return const Icon(Icons.place, size: 18);
    }
  }
  
  String _extractCity(String address) {
    final parts = address.split(',');
    return parts.isNotEmpty ? parts[parts.length - 2].trim() : address;
  }
}

class Destination {
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final String category;
  final List<String> activities;
  final bool isAsset;

  Destination({
    required this.name,
    required this.description,
    required this.imageUrl,
    required double? rating,
    required this.category,
    required this.activities,
    this.isAsset = false,
  }) : rating = rating ?? 0.0;
} 