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
    'Nature',
    'Culture',
    'Food',
    'Activities',
  ];

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
    // Watch the location state for changes
    final locationState = ref.watch(locationNotifierProvider);
    final currentLocation = locationState.value ?? 'Rotterdam';
    
    // More aggressive invalidation approach
    ref.listen(locationNotifierProvider, (previous, next) {
      if (previous?.value != next.value && next.value != null) {
        debugPrint('🌍 Location changed from ${previous?.value} to ${next.value}, forcing refresh');
        
        // Force clear all caches
        ref.invalidate(trendingDestinationsProvider);
        ref.invalidate(explorePlacesProvider);
        
        // Give visual feedback that we're updating
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loading destinations for ${next.value}...'),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF12B347),
          ),
        );
      }
    });
    
    // Pass the current location to the providers to ensure they use the right city
    final trendingDestinations = ref.watch(trendingDestinationsProvider(city: currentLocation));
    final explorePlaces = ref.watch(explorePlacesProvider(city: currentLocation));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFAF9F6), // Light cream/off-white background color
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Location and Title
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Explore',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF12B347),
                      ),
                    ),
                    const LocationDropdown(),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
              
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildSearchBar(),
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: -0.2, end: 0),
              
              // Category Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Row(
                  children: _categories.map((category) => _buildCategoryChip(category)).toList(),
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideX(begin: -0.2, end: 0),
              
              // Content Area
              Expanded(
                child: trendingDestinations.when(
                  data: (trending) => explorePlaces.when(
                    data: (places) => ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        // Trending Section
                        _buildSectionTitle('Trending Now'),
                        const SizedBox(height: 12),
                        trending.isEmpty
                            ? _buildEmptyStateMessage('No trending places found', 'Try changing your location or check back later.')
                            : SizedBox(
                                height: 180,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: trending.length,
                                  itemBuilder: (context, index) => _buildTrendingCard(trending[index])
                                      .animate(delay: Duration(milliseconds: 100 * index))
                                      .fadeIn(duration: 600.ms)
                                      .slideX(begin: 0.2, end: 0),
                                ),
                              ),
                        
                        const SizedBox(height: 24),
                        
                        // Popular Destinations
                        _buildSectionTitle('Popular Destinations'),
                        const SizedBox(height: 12),
                        places.isEmpty
                            ? _buildEmptyStateMessage('No popular destinations found', 'Try changing your search filters.')
                            : Column(
                                children: places.map((place) => _buildDestinationCard(place)
                                    .animate()
                                    .fadeIn(duration: 600.ms)
                                    .slideY(begin: 0.2, end: 0)).toList(),
                              ),
                      ],
                    ),
                    loading: () => _buildLoadingState(),
                    error: (error, stack) => _buildErrorState(error),
                  ),
                  loading: () => _buildLoadingState(),
                  error: (error, stack) => _buildErrorState(error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
            : ref.read(placesServiceProvider.notifier).getPhotoUrl(place.photos.first);
        debugPrint('📸 Got photo URL for ${place.name}: ${photoUrl.substring(0, min(photoUrl.length, 30))}...');
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
        photoUrl = ref.read(placesServiceProvider.notifier).getPhotoUrl(place.photos.first);
      }
    } catch (e) {
      debugPrint('❌ Error getting photo URL for place: $e');
    }

    return GestureDetector(
      onTap: () => context.push('/place/${place.id}'),
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
                      ? Image.network(
                          photoUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            debugPrint('❌ Error loading place image: $error');
                            // Use a fixed fallback image from picsum
                            return Image.network(
                              'https://picsum.photos/400/200?random=${place.id.hashCode}',
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
                        )
                      : Image.network(
                          'https://picsum.photos/400/200?random=${place.hashCode}',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
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

  Widget _buildActivityTag(IconData icon, String label) {
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
          Icon(icon, size: 16, color: const Color(0xFF12B347)),
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
    // Common patterns: "Street, City, State ZIP, Country" or "City, Country"
    final parts = address.split(',').map((part) => part.trim()).toList();
    
    if (parts.length >= 2) {
      // Try to get the city - typically the second-to-last element before country
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
    required this.rating,
    required this.category,
    required this.activities,
    this.isAsset = false,
  });
} 