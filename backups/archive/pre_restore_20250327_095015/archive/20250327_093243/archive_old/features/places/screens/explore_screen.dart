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
import 'package:go_router/go_router.dart';

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
  String _searchQuery = '';
  String _selectedCategory = 'All';
  SortOption _sortOption = SortOption.distance;
  ViewMode _viewMode = ViewMode.list;
  Position? _currentLocation;
  GoogleMapController? _mapController;
  Map<String, Marker> _markers = {};
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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

  void _updateMarkers(Place place) {
    final marker = Marker(
      markerId: MarkerId(place.id),
      position: LatLng(
        place.location.lat,
        place.location.lng,
      ),
      infoWindow: InfoWindow(
        title: place.name,
        snippet: place.address,
        onTap: () {
          // Navigate to place details
          context.pushNamed('placeDetails', extra: place);
        },
      ),
    );
    setState(() {
      _markers[place.id] = marker;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _refreshRecommendations() async {
    _fadeController.reset();
    final location = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = location;
    });
    final selectedMood = ref.read(moodRecommendationsProvider.notifier).availableMoods.first.name;
    
    await ref.read(moodRecommendationsProvider.notifier).clearCache();
    await ref.read(moodRecommendationsProvider.notifier).generateRecommendations(
      selectedMood,
      location,
    );
    _fadeController.forward();
  }

  double _calculateDistance(Place a, Place b) {
    return Geolocator.distanceBetween(
      a.location.lat,
      a.location.lng,
      b.location.lat,
      b.location.lng,
    );
  }

  List<Place> _sortByDistance(List<Place> places, Position userLocation) {
    places.sort((a, b) {
      final distanceA = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        a.location.lat,
        a.location.lng,
      );
      final distanceB = Geolocator.distanceBetween(
        userLocation.latitude,
        userLocation.longitude,
        b.location.lat,
        b.location.lng,
      );
      return distanceA.compareTo(distanceB);
    });
    return places;
  }

  List<Place> _filterAndSortPlaces(List<Place> places) {
    // First filter
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

    // Then sort
    filteredPlaces.sort((a, b) {
      switch (_sortOption) {
        case SortOption.distance:
          if (_currentLocation == null) return 0;
          final aDistance = Geolocator.distanceBetween(
            _currentLocation!.latitude,
            _currentLocation!.longitude,
            a.location.lat,
            a.location.lng,
          );
          final bDistance = Geolocator.distanceBetween(
            _currentLocation!.latitude,
            _currentLocation!.longitude,
            b.location.lat,
            b.location.lng,
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

    // Update markers if in map view
    if (_viewMode == ViewMode.map) {
      for (var place in filteredPlaces) {
        _updateMarkers(place);
      }
    }

    return filteredPlaces;
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
        // Update markers when map is created
        for (var place in places) {
          _updateMarkers(place);
        }
      },
      markers: _markers.values.toSet(),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: true,
      compassEnabled: true,
      mapType: MapType.normal,
      buildingsEnabled: true,
      trafficEnabled: true,
      indoorViewEnabled: true,
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildListView(List<Place> places) {
    return RefreshIndicator(
      onRefresh: _refreshRecommendations,
      child: ListView.builder(
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return PlaceCard(
            place: place,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PlaceDetailsScreen(place: place),
                ),
              );
            },
          ).animate().fadeIn(
            duration: 300.ms,
            delay: Duration(milliseconds: index * 100),
          ).slideY(begin: 0.2, end: 0);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recommendationsAsync = ref.watch(moodRecommendationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_viewMode == ViewMode.list ? Icons.map : Icons.list),
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == ViewMode.list ? ViewMode.map : ViewMode.list;
              });
            },
            tooltip: _viewMode == ViewMode.list ? 'Switch to Map View' : 'Switch to List View',
          ),
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (SortOption option) {
              setState(() {
                _sortOption = option;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: SortOption.distance,
                child: Row(
                  children: [
                    Icon(Icons.location_on),
                    SizedBox(width: 8),
                    Text('Distance'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SortOption.rating,
                child: Row(
                  children: [
                    Icon(Icons.star),
                    SizedBox(width: 8),
                    Text('Rating'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SortOption.name,
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha),
                    SizedBox(width: 8),
                    Text('Name'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SortOption.popularity,
                child: Row(
                  children: [
                    Icon(Icons.trending_up),
                    SizedBox(width: 8),
                    Text('Popularity'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.green.shade200, Colors.blue.shade200],
                  ),
                ),
              ),
              Column(
                children: [
                  // Location Selector
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _refreshRecommendations,
                          tooltip: 'Refresh recommendations',
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0),
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Find hidden gems, vibes & bites...✨',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.tune,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              // TODO: Implement filter functionality
                            },
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: -0.2, end: 0),
                  // Category Chips
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                                _selectedCategory = category;
                              });
                            },
                            backgroundColor: Colors.grey[200],
                            selectedColor: Colors.green[100],
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.green[800] : Colors.black87,
                            ),
                          ),
                        ).animate().fadeIn(
                          duration: 300.ms,
                          delay: Duration(milliseconds: 200 + (index * 50)),
                        ).slideX(begin: 0.2, end: 0);
                      },
                    ),
                  ),
                ],
              ),
              const Positioned(
                top: 0,
                right: 16,
                child: SafeArea(
                  child: LocationDropdown(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: recommendationsAsync.when(
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
                    style: const TextStyle(
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
                    style: const TextStyle(
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
                style: const TextStyle(color: Colors.red),
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
    );
  }
} 