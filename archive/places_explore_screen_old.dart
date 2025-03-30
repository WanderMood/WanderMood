import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wandermood/features/mood/providers/mood_recommendations_provider.dart';
import 'package:wandermood/features/places/widgets/place_card.dart';
import 'package:wandermood/features/places/screens/place_details_screen.dart';
import 'package:wandermood/features/places/models/place.dart';
import 'package:wandermood/features/location/providers/location_provider.dart';
import 'package:wandermood/features/location/presentation/widgets/location_dropdown.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wandermood/features/places/providers/explore_places_provider.dart';
import 'package:wandermood/features/places/services/places_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_google_maps_webservices/places.dart';

enum SortOption {
  distance,
  rating,
  name,
  popularity,
}

enum ViewMode {
  list,
  map,
}

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  SortOption _sortOption = SortOption.distance;
  ViewMode _viewMode = ViewMode.list;
  Position? _currentLocation;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _showSearchSuggestions = false;
  List<String> _filteredSuggestions = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMorePages = true;
  int _currentPage = 1;

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
    'Restaurants',
    'Attractions',
    'Hotels',
    'Shopping',
    'Entertainment',
    'Nature',
    'Culture',
  ];

  // Add new filter state variables
  RangeValues _priceRange = const RangeValues(1, 4);
  double _maxDistance = 10.0; // in kilometers
  double _minRating = 0.0;
  List<String> _selectedAmenities = [];
  bool _openNow = false;

  final List<String> _amenities = [
    'Parking',
    'Wheelchair Accessible',
    'Wi-Fi',
    'Outdoor Seating',
    'Pet Friendly',
    'Family Friendly',
    'Credit Cards Accepted',
    'Delivery',
    'Takeout',
    'Reservations',
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _fadeController.forward();
    _getCurrentLocation();
    _setupScrollListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _hasMorePages) {
        _loadMorePlaces();
      }
    });
  }

  Future<void> _loadMorePlaces() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final locationState = ref.read(locationProvider);
      final currentCity = locationState.value ?? 'Rotterdam';
      
      final morePlaces = await ref.read(explorePlacesProvider(city: currentCity).notifier)
          .fetchMorePlaces(_currentPage + 1);

      if (morePlaces.isNotEmpty) {
        _currentPage++;
      } else {
        _hasMorePages = false;
      }
    } catch (e) {
      debugPrint('Error loading more places: $e');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final location = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = location;
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(location.latitude, location.longitude),
                zoom: 12,
              ),
            ),
          );
        }
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _updateMarkers(List<Place> places) {
    setState(() {
      _markers = places.map((place) {
        return Marker(
          markerId: MarkerId(place.id),
          position: LatLng(
            place.location['lat']!,
            place.location['lng']!,
          ),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: place.address,
            onTap: () => context.push('/place/${place.id}'),
          ),
        );
      }).toSet();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _refreshRecommendations() async {
    _fadeController.reset();
    final location = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = location;
      _currentPage = 1;
      _hasMorePages = true;
    });
    
    final selectedMood = ref.read(moodRecommendationsProvider.notifier).availableMoods.first.name;
    
    await ref.read(moodRecommendationsProvider.notifier).clearCache();
    await ref.read(moodRecommendationsProvider.notifier).generateRecommendations(
      selectedMood,
      location,
    );
    _fadeController.forward();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      if (value.isEmpty) {
        _showSearchSuggestions = false;
        _filteredSuggestions = [];
      } else {
        _showSearchSuggestions = true;
        _filteredSuggestions = _searchSuggestions
            .where((suggestion) =>
                suggestion.toLowerCase().contains(value.toLowerCase()))
            .toList();
      }
    });
  }

  void _onSuggestionSelected(String suggestion) {
    _searchController.text = suggestion;
    setState(() {
      _searchQuery = suggestion;
      _showSearchSuggestions = false;
    });
  }

  List<Place> _filterAndSortPlaces(List<Place> places) {
    var filteredPlaces = places.where((place) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!place.name.toLowerCase().contains(query) &&
            !place.description.toLowerCase().contains(query) &&
            !place.address.toLowerCase().contains(query)) {
          return false;
        }
      }

      if (_selectedCategory != 'All') {
        return place.types.contains(_selectedCategory.toLowerCase());
      }

      return true;
    }).toList();

    filteredPlaces.sort((a, b) {
      switch (_sortOption) {
        case SortOption.distance:
          if (_currentLocation == null) return 0;
          final aDistance = Geolocator.distanceBetween(
            _currentLocation!.latitude,
            _currentLocation!.longitude,
            a.location['lat']!,
            a.location['lng']!,
          );
          final bDistance = Geolocator.distanceBetween(
            _currentLocation!.latitude,
            _currentLocation!.longitude,
            b.location['lat']!,
            b.location['lng']!,
          );
          return aDistance.compareTo(bDistance);
        case SortOption.rating:
          return (b.rating ?? 0).compareTo(a.rating ?? 0);
        case SortOption.name:
          return a.name.compareTo(b.name);
        case SortOption.popularity:
          return (b.bookingCount ?? 0).compareTo(a.bookingCount ?? 0);
      }
    });

    if (_viewMode == ViewMode.map) {
      _updateMarkers(filteredPlaces);
    }

    return filteredPlaces;
  }

  Widget _buildSearchBar() {
    return Stack(
      children: [
        TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Find hidden gems, vibes & bites...✨',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.tune),
              onPressed: _showFilterDialog,
              color: Colors.green,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          ),
        ),
        if (_showSearchSuggestions)
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ListView(
                shrinkWrap: true,
                children: [
                  if (_filteredSuggestions.isNotEmpty)
                    ..._filteredSuggestions.map(
                      (suggestion) => ListTile(
                        leading: const Icon(Icons.search),
                        title: Text(suggestion),
                        onTap: () => _onSuggestionSelected(suggestion),
                      ),
                    ),
                  if (_recentSearches.isNotEmpty && _searchQuery.isEmpty)
                    ..._recentSearches.map(
                      (recent) => ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(recent),
                        onTap: () => _onSuggestionSelected(recent),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = selected ? category : 'All';
                });
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.green[100],
              labelStyle: TextStyle(
                color: isSelected ? Colors.green[800] : Colors.black87,
              ),
            ),
          ).animate().fadeIn(
            duration: 300.ms,
            delay: Duration(milliseconds: 100 + (index * 50)),
          );
        },
      ),
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<SortOption>(
      icon: const Icon(Icons.sort),
      onSelected: (SortOption option) {
        setState(() {
          _sortOption = option;
        });
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(
          value: SortOption.distance,
          child: Text('Sort by Distance'),
        ),
        const PopupMenuItem(
          value: SortOption.rating,
          child: Text('Sort by Rating'),
        ),
        const PopupMenuItem(
          value: SortOption.name,
          child: Text('Sort by Name'),
        ),
        const PopupMenuItem(
          value: SortOption.popularity,
          child: Text('Sort by Popularity'),
        ),
      ],
    );
  }

  Widget _buildMapView(List<Place> places) {
    if (_currentLocation == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
        zoom: 12,
      ),
      onMapCreated: (controller) {
        _mapController = controller;
        _updateMarkers(places);
      },
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: true,
      compassEnabled: true,
      mapType: MapType.normal,
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildListView(List<Place> places) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8),
      itemCount: places.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == places.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final place = places[index];
        return PlaceCard(
          place: place,
          onTap: () => context.push('/place/${place.id}'),
          onShare: () {
            Share.share(
              'Check out ${place.name} on WanderMood!\n${place.description}',
              subject: 'WanderMood - ${place.name}',
            );
          },
        ).animate().fadeIn(
          duration: 300.ms,
          delay: Duration(milliseconds: 100 * index),
        );
      },
    );
  }

  Widget _buildFilterButton() {
    return IconButton(
      icon: const Icon(Icons.tune),
      onPressed: _showFilterDialog,
      tooltip: 'Filter options',
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Place',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = 'All';
                          });
                        },
                        child: Text(
                          'Clear all',
                          style: GoogleFonts.poppins(
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Category',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChip(
                            label: const Text('All Category'),
                            selected: _selectedCategory == 'All',
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = 'All';
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: Colors.green.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: _selectedCategory == 'All' 
                                  ? Colors.green.shade100 
                                  : Colors.grey.shade300,
                              ),
                            ),
                          ),
                          FilterChip(
                            label: const Text('House'),
                            selected: _selectedCategory == 'House',
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = 'House';
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: Colors.green.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: _selectedCategory == 'House' 
                                  ? Colors.green.shade100 
                                  : Colors.grey.shade300,
                              ),
                            ),
                          ),
                          FilterChip(
                            label: const Text('Hotels'),
                            selected: _selectedCategory == 'Hotels',
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = 'Hotels';
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: Colors.green.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: _selectedCategory == 'Hotels' 
                                  ? Colors.green.shade100 
                                  : Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Range Price',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RangeSlider(
                        values: _priceRange,
                        min: 1,
                        max: 4,
                        divisions: 3,
                        activeColor: Colors.green,
                        inactiveColor: Colors.grey.shade200,
                        labels: RangeLabels(
                          '\$' * _priceRange.start.round(),
                          '\$' * _priceRange.end.round(),
                        ),
                        onChanged: (values) {
                          setState(() {
                            _priceRange = values;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Facility Place',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.wifi, size: 16),
                                const SizedBox(width: 4),
                                const Text('Free Wifi'),
                              ],
                            ),
                            selected: _selectedAmenities.contains('wifi'),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedAmenities.add('wifi');
                                } else {
                                  _selectedAmenities.remove('wifi');
                                }
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: Colors.green.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: _selectedAmenities.contains('wifi')
                                  ? Colors.green.shade100 
                                  : Colors.grey.shade300,
                              ),
                            ),
                          ),
                          FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.kitchen, size: 16),
                                const SizedBox(width: 4),
                                const Text('Kitchen'),
                              ],
                            ),
                            selected: _selectedAmenities.contains('kitchen'),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedAmenities.add('kitchen');
                                } else {
                                  _selectedAmenities.remove('kitchen');
                                }
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: Colors.green.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: _selectedAmenities.contains('kitchen')
                                  ? Colors.green.shade100 
                                  : Colors.grey.shade300,
                              ),
                            ),
                          ),
                          FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.pool, size: 16),
                                const SizedBox(width: 4),
                                const Text('Pool'),
                              ],
                            ),
                            selected: _selectedAmenities.contains('pool'),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedAmenities.add('pool');
                                } else {
                                  _selectedAmenities.remove('pool');
                                }
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: Colors.green.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: _selectedAmenities.contains('pool')
                                  ? Colors.green.shade100 
                                  : Colors.grey.shade300,
                              ),
                            ),
                          ),
                          FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_parking, size: 16),
                                const SizedBox(width: 4),
                                const Text('Parking'),
                              ],
                            ),
                            selected: _selectedAmenities.contains('parking'),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedAmenities.add('parking');
                                } else {
                                  _selectedAmenities.remove('parking');
                                }
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: Colors.green.shade100,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: _selectedAmenities.contains('parking')
                                  ? Colors.green.shade100 
                                  : Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _refreshRecommendations();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Apply Filter',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recommendationsAsync = ref.watch(moodRecommendationsProvider);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.pink.shade100, Colors.pink.shade100],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Explore',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: LocationDropdown(),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildSearchBar(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildFilterChips(),
                ),
                Expanded(
                  child: recommendationsAsync.when(
                    data: (recommendations) {
                      if (recommendations.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No recommendations available',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(duration: 300.ms),
                        );
                      }

                      final filteredAndSortedPlaces = _filterAndSortPlaces(recommendations.places);

                      if (filteredAndSortedPlaces.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No places found for "$_searchQuery" in $_selectedCategory',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ).animate().fadeIn(duration: 300.ms),
                        );
                      }

                      return _viewMode == ViewMode.list
                          ? _buildListView(filteredAndSortedPlaces)
                          : _buildMapView(filteredAndSortedPlaces);
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${error.toString()}',
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ref.read(moodRecommendationsProvider.notifier).reset();
                            },
                            child: const Text('Try Again'),
                          ),
                        ],
                      ).animate().fadeIn(duration: 300.ms),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 