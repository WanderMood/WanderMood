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
    {
      'name': 'Euromast Experience',
      'location': 'Rotterdam',
      'flag': '🇳🇱',
      'distance': '2.1 km',
      'rating': 4.7,
      'image': 'assets/images/pietro-de-grandi-T7K4aEPoGGk-unsplash.jpg',
      'categories': ['Adventure', 'Culture'],
      'activities': [
        {'name': 'Observation', 'icon': '🔭'},
        {'name': 'Fine Dining', 'icon': '🍽️'},
        {'name': 'Abseiling', 'icon': '🧗‍♂️'}
      ],
      'description': 'Iconic tower with panoramic city views',
      'isFavorite': false,
      'latitude': 51.9053,
      'longitude': 4.4669
    },
    {
      'name': 'Markthal Rotterdam',
      'location': 'Rotterdam',
      'flag': '🇳🇱',
      'distance': '1.5 km',
      'rating': 4.6,
      'image': 'assets/images/philipp-kammerer-6Mxb_mZ_Q8E-unsplash.jpg',
      'categories': ['Culture', 'Food'],
      'activities': [
        {'name': 'Food Tour', 'icon': '🍴'},
        {'name': 'Shopping', 'icon': '🛍️'},
        {'name': 'Architecture', 'icon': '🏗️'}
      ],
      'description': 'Stunning market hall with food stalls and apartments',
      'isFavorite': false,
      'latitude': 51.9200,
      'longitude': 4.4852
    },
    {
      'name': 'SS Rotterdam',
      'location': 'Rotterdam',
      'flag': '🇳🇱',
      'distance': '3.2 km',
      'rating': 4.5,
      'image': 'assets/images/tom-podmore-1zkHXas1GIo-unsplash.jpg',
      'categories': ['History', 'Relaxation'],
      'activities': [
        {'name': 'Ship Tour', 'icon': '🚢'},
        {'name': 'Hotel Stay', 'icon': '🛏️'},
        {'name': 'Fine Dining', 'icon': '🍽️'}
      ],
      'description': 'Historic cruise ship turned hotel and museum',
      'isFavorite': false,
      'latitude': 51.8984,
      'longitude': 4.4662
    },
    {
      'name': 'Cube Houses',
      'location': 'Rotterdam',
      'flag': '🇳🇱',
      'distance': '1.8 km',
      'rating': 4.4,
      'image': 'assets/images/diego-jimenez-A-NVHPka9Rk-unsplash.jpg',
      'categories': ['Architecture', 'Culture'],
      'activities': [
        {'name': 'Museum Visit', 'icon': '🏛️'},
        {'name': 'Photo Tour', 'icon': '📸'},
        {'name': 'Architecture', 'icon': '🏗️'}
      ],
      'description': 'Iconic tilted cube houses in city center',
      'isFavorite': false,
      'latitude': 51.9200,
      'longitude': 4.4897
    },
    {
      'name': 'Mountain Resort',
      'location': 'Swiss Alps',
      'flag': '🇨🇭',
      'distance': '1,234 km',
      'rating': 4.8,
      'image': 'assets/images/dino-reichmuth-A5rCN8626Ck-unsplash.jpg',
      'categories': ['Nature', 'Adventure', 'Relaxation'],
      'activities': [
        {'name': 'Hiking', 'icon': '🏃‍♂️'},
        {'name': 'Skiing', 'icon': '⛷️'},
        {'name': 'Spa', 'icon': '💆‍♂️'}
      ],
      'description': 'Experience the majestic Swiss Alps',
      'isFavorite': false
    },
    {
      'name': 'Cultural Heritage Hotel',
      'location': 'Kyoto',
      'flag': '🇯🇵',
      'distance': '3,456 km',
      'rating': 4.7,
      'image': 'assets/images/shifaaz-shamoon-qtbV_8P_Ksk-unsplash.jpg',
      'categories': ['Culture', 'Relaxation'],
      'activities': [
        {'name': 'Tea Ceremony', 'icon': '🍵'},
        {'name': 'Garden Visit', 'icon': '🍁'},
        {'name': 'Meditation', 'icon': '🧘‍♂️'}
      ],
      'description': 'Immerse yourself in Japanese culture',
      'isFavorite': false
    },
    {
      'name': 'Beach Paradise Resort',
      'location': 'Maldives',
      'flag': '🇲🇻',
      'distance': '5,678 km',
      'rating': 4.9,
      'image': 'assets/images/A1FBE812-1D4B-41AD-BC65-483A00730AB6_4_5005_c.jpeg',
      'categories': ['Nature', 'Relaxation'],
      'activities': [
        {'name': 'Swimming', 'icon': '🏊‍♂️'},
        {'name': 'Sunbathing', 'icon': '🌞'},
        {'name': 'Beach Sports', 'icon': '🏐'}
      ],
      'description': 'Relax at the beautiful ocean paradise',
      'isFavorite': false
    },
    {
      'name': 'Erasmusbrug',
      'location': 'Rotterdam',
      'flag': '🇳🇱',
      'distance': '1.2 km',
      'rating': 4.9,
      'image': 'assets/images/tom-podmore-3mEK924ZuTs-unsplash.jpg',
      'categories': ['Architecture', 'Culture', 'Photography'],
      'activities': [
        {'name': 'Bridge Walk', 'icon': '🚶‍♂️'},
        {'name': 'Night View', 'icon': '🌉'},
        {'name': 'Photo Spot', 'icon': '📸'}
      ],
      'description': 'Iconic swan-shaped bridge with stunning harbor views',
      'isFavorite': false
    },
    {
      'name': 'Rotterdam Zoo',
      'location': 'Rotterdam',
      'flag': '🇳🇱',
      'distance': '2.8 km',
      'rating': 4.7,
      'image': 'assets/images/shifaaz-shamoon-qtbV_8P_Ksk-unsplash.jpg',
      'categories': ['Nature', 'Family', 'Education'],
      'activities': [
        {'name': 'Animal Shows', 'icon': '🦁'},
        {'name': 'Aquarium', 'icon': '🐠'},
        {'name': 'Botanical Garden', 'icon': '🌺'}
      ],
      'description': 'One of Europe\'s oldest zoos with diverse wildlife',
      'isFavorite': false
    },
    {
      'name': 'Kunsthal',
      'location': 'Rotterdam',
      'flag': '🇳🇱',
      'distance': '2.5 km',
      'rating': 4.5,
      'image': 'assets/images/A1FBE812-1D4B-41AD-BC65-483A00730AB6_4_5005_c.jpeg',
      'categories': ['Culture', 'Art', 'Education'],
      'activities': [
        {'name': 'Exhibitions', 'icon': '🎨'},
        {'name': 'Workshops', 'icon': '✏️'},
        {'name': 'Guided Tours', 'icon': '👥'}
      ],
      'description': 'Contemporary art museum with rotating exhibitions',
      'isFavorite': false
    },
    {
      'name': 'Fenix Food Factory',
      'location': 'Rotterdam',
      'flag': '🇳🇱',
      'distance': '1.7 km',
      'rating': 4.6,
      'image': 'assets/images/mesut-kaya-eOcyhe5-9sQ-unsplash.jpg',
      'categories': ['Food', 'Culture', 'Social'],
      'activities': [
        {'name': 'Food Tasting', 'icon': '🍴'},
        {'name': 'Craft Beer', 'icon': '🍺'},
        {'name': 'Local Market', 'icon': '🏪'}
      ],
      'description': 'Trendy food hall in historic warehouse',
      'isFavorite': false
    },
    {
      'name': 'Het Park',
      'location': 'Rotterdam',
      'flag': '🇳🇱',
      'distance': '2.3 km',
      'rating': 4.4,
      'image': 'assets/images/pedro-lastra-Nyvq2juw4_o-unsplash.jpg',
      'categories': ['Nature', 'Relaxation', 'Sports'],
      'activities': [
        {'name': 'Picnic', 'icon': '🧺'},
        {'name': 'Jogging', 'icon': '🏃‍♂️'},
        {'name': 'Birdwatching', 'icon': '🦜'}
      ],
      'description': 'Beautiful park near Euromast with walking trails',
      'isFavorite': false
    },
  ];

  List<Map<String, dynamic>> get filteredHotels {
    if (_selectedCategory == 'All') {
      return _hotels;
    }
    return _hotels.where((hotel) => 
      hotel['categories'].contains(_selectedCategory)
    ).toList();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      
      // Invalidate providers to refresh data with the new category filter
      final locationState = ref.read(locationProvider);
      final currentCity = locationState.value ?? 'Rotterdam';
      
      // Refresh providers with new category filter
      ref.invalidate(explorePlacesProvider);
      ref.invalidate(trendingDestinationsProvider);
    });
    
    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filtering by: $_selectedCategory'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
    _loadInitialPlaces();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _scrollController.removeListener(_onScroll);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  bool _isListening = false;
  
  // Method to handle search functionality
  void _performSearch(String query) {
    if (query.isEmpty) return;
    
    // Show the search results snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for: "$query"'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: const Color(0xFF12B347),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () {
            // In a real app, this would navigate to search results
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
    
    // Add to recent searches
    if (!_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 3) {
          _recentSearches.removeLast();
        }
      });
    }
    
    // Filter hotels to show matching results
    setState(() {
      // Set matching category if the search term matches a category
      final lowercaseQuery = query.toLowerCase();
      final categories = ['All', 'Architecture', 'Culture', 'Food', 'Nature', 'History', 'Art', 'Family', 'Photography', 'Sports'];
      
      for (final category in categories) {
        if (category.toLowerCase().contains(lowercaseQuery)) {
          _selectedCategory = category;
          break;
        }
      }
      
      // Close search suggestions
      _showSearchSuggestions = false;
    });
    
    // Find hotel that might match the search term
    final lowercaseQuery = query.toLowerCase();
    final matchingHotels = _hotels.where((hotel) => 
      hotel['name'].toString().toLowerCase().contains(lowercaseQuery) ||
      hotel['description'].toString().toLowerCase().contains(lowercaseQuery) ||
      hotel['location'].toString().toLowerCase().contains(lowercaseQuery) ||
      (hotel['categories'] as List).any((category) => 
        category.toString().toLowerCase().contains(lowercaseQuery)
      )
    ).toList();
    
    // If we found matches, scroll to the first match after a short delay
    // to allow the UI to update
    if (matchingHotels.isNotEmpty) {
      // Find index of the first matching hotel in the filtered list
      final filteredHotels = _selectedCategory == 'All' 
        ? _hotels 
        : _hotels.where((hotel) => 
            hotel['categories'].contains(_selectedCategory)
          ).toList();
          
      for (int i = 0; i < filteredHotels.length; i++) {
        if (filteredHotels[i]['name'].toString().toLowerCase().contains(lowercaseQuery) ||
            filteredHotels[i]['description'].toString().toLowerCase().contains(lowercaseQuery)) {
          // Use a delayed future to scroll after the UI has updated
          Future.delayed(const Duration(milliseconds: 300), () {
            if (_scrollController.hasClients) {
              // Scroll to the position of the match with some padding at the top
              final destinationHeight = 350.0; // Approximate height of each destination card
              final offset = 270.0 + (i * destinationHeight); // Account for header heights
              
              _scrollController.animateTo(
                offset,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
          });
          break;
        }
      }
    }
  }
  
  // Voice search related variables
  final List<String> _voiceSearchPhrases = [
    'Show me attractions in Rotterdam',
    'Find restaurants nearby',
    'Best rated parks',
    'Cultural activities this weekend',
    'Hidden gems in the city center',
  ];

  void _startVoiceSearch() {
    setState(() {
      _isListening = true;
    });
    
    // Show voice search dialog
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  ...List.generate(3, (i) {
                    return Container(
                      width: 80.0 + (i * 20.0),
                      height: 80.0 + (i * 20.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF12B347).withOpacity(0.2 - (i * 0.05)),
                      ),
                    ).animate(
                      onPlay: (controller) => controller.repeat(),
                    ).scale(
                      duration: Duration(milliseconds: 1000 + (i * 200)),
                      begin: const Offset(0.6, 0.6),
                      end: const Offset(1.1, 1.1),
                    );
                  }),
                  const Icon(
                    Icons.mic,
                    color: Color(0xFF12B347),
                    size: 50,
                  ).animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  ).fade(
                    begin: 0.4,
                    end: 1.0,
                    duration: const Duration(milliseconds: 500),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                'Listening...',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Say something like "Find museums in Rotterdam"',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _isListening = false;
                  });
                },
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
      
    // Simulate voice recognition
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isListening = false;
      });
      
      // Get a random phrase from our sample phrases
      final randomIndex = math.Random().nextInt(_voiceSearchPhrases.length);
      final recognizedText = _voiceSearchPhrases[randomIndex];
      
      // Set the text field 
      setState(() {
        _searchController.text = recognizedText;
        _showSearchSuggestions = false;
      });
      
      // Add to recent searches
      if (!_recentSearches.contains(recognizedText)) {
        setState(() {
          _recentSearches.insert(0, recognizedText);
          if (_recentSearches.length > 3) {
            _recentSearches.removeLast();
          }
        });
      }
      
      // Close the dialog if it's still open
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.pop(context);
      }
      
      // Perform the search with recognized text
      _performSearch(recognizedText);
    });
  }
  
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredSuggestions = [];
        _showSearchSuggestions = true;
      } else {
        // Filter recent searches
        final recentMatches = _recentSearches
            .where((search) => search.toLowerCase().contains(query))
            .toList();
            
        // Filter predefined suggestions
        final suggestionMatches = _searchSuggestions
            .where((suggestion) => suggestion.toLowerCase().contains(query))
            .toList();
            
        // Generate dynamic suggestions based on attractions
        final attractionMatches = _hotels
            .where((hotel) => 
              hotel['name'].toString().toLowerCase().contains(query) ||
              hotel['description'].toString().toLowerCase().contains(query) ||
              (hotel['categories'] as List).any((category) => 
                category.toString().toLowerCase().contains(query)
              ) ||
              hotel['location'].toString().toLowerCase().contains(query)
            )
            .map((hotel) => hotel['name'].toString())
            .toList();
            
        // Combine all matches with recentMatches first, then attractionMatches, then suggestionMatches
        _filteredSuggestions = [
          ...recentMatches,
          ...attractionMatches,
          ...suggestionMatches,
        ].toSet().toList(); // Remove duplicates
        
        _showSearchSuggestions = true;
      }
    });
  }

  // Add filter-related state variables
  RangeValues _priceRange = const RangeValues(0, 500);
  RangeValues _distanceRange = const RangeValues(0, 50);
  double _minRating = 0.0;
  List<String> _selectedCategories = [];
  final List<String> _availableCategories = [
    'Restaurants',
    'Attractions',
    'Shopping',
    'Nightlife',
    'Culture',
    'Nature',
    'Sports',
    'Family'
  ];

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Filter Places',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Categories',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableCategories.map((category) {
                        final isSelected = _selectedCategories.contains(category);
                        return FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategories.add(category);
                              } else {
                                _selectedCategories.remove(category);
                              }
                            });
                          },
                          selectedColor: const Color(0xFF12B347).withOpacity(0.2),
                          checkmarkColor: const Color(0xFF12B347),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Minimum Rating',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Slider(
                      value: _minRating,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      label: _minRating.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          _minRating = value;
                        });
                      },
                      activeColor: const Color(0xFF12B347),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Distance (km)',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    RangeSlider(
                      values: _distanceRange,
                      min: 0,
                      max: 50,
                      divisions: 50,
                      labels: RangeLabels(
                        '${_distanceRange.start.round()} km',
                        '${_distanceRange.end.round()} km',
                      ),
                      onChanged: (values) {
                        setState(() {
                          _distanceRange = values;
                        });
                      },
                      activeColor: const Color(0xFF12B347),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Price Range (€)',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 500,
                      divisions: 50,
                      labels: RangeLabels(
                        '€${_priceRange.start.round()}',
                        '€${_priceRange.end.round()}',
                      ),
                      onChanged: (values) {
                        setState(() {
                          _priceRange = values;
                        });
                      },
                      activeColor: const Color(0xFF12B347),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Reset',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _applyFilters();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF12B347),
                  ),
                  child: Text(
                    'Apply',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _applyFilters() {
    setState(() {
      // Filter the places based on selected criteria
      final filteredPlaces = _hotels.where((place) {
        // Check categories
        if (_selectedCategories.isNotEmpty) {
          final placeCategories = place['categories'] as List;
          if (!_selectedCategories.any((cat) => placeCategories.contains(cat))) {
            return false;
          }
        }

        // Check rating
        final rating = place['rating'] as double;
        if (rating < _minRating) {
          return false;
        }

        // Check distance
        final distance = double.tryParse(place['distance'].toString().replaceAll(' km', '')) ?? 0;
        if (distance < _distanceRange.start || distance > _distanceRange.end) {
          return false;
        }

        return true;
      }).toList();

      // Update the UI with filtered results
      // You can update your state provider or local state here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Found ${filteredPlaces.length} places matching your filters'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF12B347),
        ),
      );
    });
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
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
              decoration: InputDecoration(
                hintText: 'Find hidden gems, vibes & bites...✨',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12B347),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _showFilterDialog,
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
                  _searchQuery = value.toLowerCase();
                });
              },
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
                          // Check if index is within bounds before accessing
                          if (index < _recentSearches.length) {
                            _searchController.text = _recentSearches[index];
                            // Move to top of recent searches
                            setState(() {
                              final selected = _recentSearches[index];
                              _recentSearches.removeAt(index);
                              _recentSearches.insert(0, selected);
                              _showSearchSuggestions = false;
                            });
                            
                            // Perform search with selected term
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
                          // Check if index is within bounds before accessing
                          if (index < _searchSuggestions.length) {
                            _searchController.text = _searchSuggestions[index];
                            // Add to recent searches
                            setState(() {
                              if (!_recentSearches.contains(_searchSuggestions[index])) {
                                _recentSearches.insert(0, _searchSuggestions[index]);
                                if (_recentSearches.length > 3) {
                                  _recentSearches.removeLast();
                                }
                              }
                              _showSearchSuggestions = false;
                            });
                            
                            // Perform search with selected suggestion
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
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                            children: _highlightMatches(_filteredSuggestions[index], _searchQuery),
                          ),
                        ),
                        onTap: () {
                          // Check if index is within bounds before accessing
                          if (index < _filteredSuggestions.length) {
                            _searchController.text = _filteredSuggestions[index];
                            // Add to recent searches
                            setState(() {
                              if (!_recentSearches.contains(_filteredSuggestions[index])) {
                                _recentSearches.insert(0, _filteredSuggestions[index]);
                                if (_recentSearches.length > 3) {
                                  _recentSearches.removeLast();
                                }
                              }
                              _showSearchSuggestions = false;
                            });
                            
                            // Perform search with selected filtered suggestion
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
      ),
    );
  }
  
  // Helper function to highlight matched text
  List<TextSpan> _highlightMatches(String text, String query) {
    final spans = <TextSpan>[];
    final lowercaseText = text.toLowerCase();
    final lowercaseQuery = query.toLowerCase();
    
    if (lowercaseText.contains(lowercaseQuery)) {
      int start = 0;
      while (start < text.length) {
        final index = lowercaseText.indexOf(lowercaseQuery, start);
        if (index == -1) {
          spans.add(TextSpan(text: text.substring(start)));
          break;
        }
        
        if (index > start) {
          spans.add(TextSpan(text: text.substring(start, index)));
        }
        
        spans.add(TextSpan(
          text: text.substring(index, index + query.length),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF12B347),
          ),
        ));
        
        start = index + query.length;
      }
    } else {
      spans.add(TextSpan(text: text));
    }
    
    return spans;
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final loadMoreThreshold = maxScroll * 0.9; // Load more when 90% scrolled
    
    if (currentScroll >= loadMoreThreshold && !_isLoadingMore && _hasMorePages) {
      _loadMorePlaces();
    }
  }

  Future<void> _loadMorePlaces() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      final notifier = ref.read(moodRecommendationsProvider.notifier);
      await notifier.loadMorePlaces();
      
      final state = ref.read(moodRecommendationsProvider);
      if (state.hasValue) {
        setState(() {
          _hasMorePages = state.value!.hasMorePlaces;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading more places: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  // Add this conversion method
  List<Place> _convertToPlaces(List<PlacesSearchResult> results) {
    return results.map((result) => Place(
      id: 'google_${result.placeId}',
      name: result.name,
      address: result.formattedAddress ?? '',
      description: result.vicinity ?? result.formattedAddress ?? '',
      rating: result.rating?.toDouble() ?? 0.0,
      photos: result.photos?.map((p) => p.photoReference).toList() ?? [],
      types: result.types ?? [],
      location: result.geometry?.location != null 
        ? PlaceLocation(
            lat: result.geometry!.location.lat.toDouble(),
            lng: result.geometry!.location.lng.toDouble(),
          )
        : PlaceLocation(lat: 51.9244, lng: 4.4777), // Default to Rotterdam coordinates
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    final recommendationsState = ref.watch(recommendationProvider);
    final explorePlacesState = ref.watch(explorePlacesProvider(city: _selectedCity, category: _selectedCategory));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFAFF4), // Pink at the top
              Color(0xFFFFF5AF), // Yellow at the bottom
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Fixed header elements
              _buildHeader(),
              _buildSearchBar(),
              
              // Category Filters - keep outside scrollable area
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _buildCategoryChip('All', _selectedCategory == 'All'),
                      _buildCategoryChip('Architecture', _selectedCategory == 'Architecture'),
                      _buildCategoryChip('Culture', _selectedCategory == 'Culture'),
                      _buildCategoryChip('Food', _selectedCategory == 'Food'),
                      _buildCategoryChip('Nature', _selectedCategory == 'Nature'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Scrollable content area
              Expanded(
                child: recommendationsState.when(
                  data: (recommendations) {
                    if (recommendations.isNotEmpty) {
                      return ListView.builder(
                        itemCount: recommendations.length,
                        itemBuilder: (context, index) {
                          final place = recommendations[index];
                          return PlaceCard(
                            place: place,
                            onTap: () {
                              context.go('/place/${place.id}');
                            },
                          );
                        },
                      );
                    }

                    // If no recommendations, show regular places
                    return explorePlacesState.when(
                      data: (places) {
                        if (places.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'No places found',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try changing your filters or location',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: places.length,
                          itemBuilder: (context, index) {
                            final place = Place.fromPlacesSearchResult(places[index]);
                            return PlaceCard(
                              place: place,
                              onTap: () {
                                context.go('/place/${place.id}');
                              },
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error loading places',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                ref.invalidate(explorePlacesProvider(city: _selectedCity, category: _selectedCategory));
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error loading recommendations',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(recommendationProvider);
                          },
                          child: const Text('Retry'),
                        ),
                      ],
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

  Widget _buildHeader() {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(_isMapView ? Icons.view_list : Icons.map),
                    onPressed: () {
                      setState(() {
                        _isMapView = !_isMapView;
                      });
                    },
                    tooltip: _isMapView ? 'Switch to List View' : 'Switch to Map View',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Positioned(
          top: 8,
          left: 16,
          child: SafeArea(
            child: LocationDropdown(),
          ),
        ),
      ],
    );
  }

  Widget _buildMapView(List<Place> places) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(51.9244, 4.4777), // Rotterdam coordinates
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

  void _updateMarkers(List<Place> places) {
    setState(() {
      _markers = places.map((place) {
        final location = place.location;
        return Marker(
          markerId: MarkerId(place.id),
          position: LatLng(
            location?.lat ?? 51.9244,
            location?.lng ?? 4.4777,
          ),
          infoWindow: InfoWindow(
            title: place.name,
            snippet: place.address ?? '',
          ),
        );
      }).toSet();
    });
  }

  Widget _buildCategoryChip(String category, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(
          category,
          style: GoogleFonts.poppins(
            color: isSelected ? Colors.white : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        backgroundColor: isSelected ? const Color(0xFF12B347) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
          ),
        ),
        onPressed: () => _onCategorySelected(category),
        elevation: isSelected ? 2 : 0,
        shadowColor: isSelected ? const Color(0xFF12B347).withOpacity(0.5) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Future<void> _loadInitialPlaces() async {
    try {
      await ref.read(explorePlacesProvider(city: _selectedCity, category: _selectedCategory).future);
    } catch (e) {
      debugPrint('Error loading initial places: $e');
    }
  }

  void _onCitySelected(String city) {
    setState(() {
      _selectedCity = city;
    });
    ref.invalidate(explorePlacesProvider);
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

class Particle {
  late double x;
  late double y;
  late double speed;
  late double radius;
  late Color color;
  final _random = math.Random();

  Particle() {
    reset(_random);
  }

  void reset(math.Random random) {
    x = random.nextDouble();
    y = random.nextDouble();
    speed = 0.2 + random.nextDouble() * 0.3;
    radius = 1 + random.nextDouble() * 2;
    color = Colors.white.withOpacity(0.1 + random.nextDouble() * 0.2);
  }
}

class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;
  final String selectedCategory;
  final List<String> categories;

  ParticlesPainter({
    required this.particles,
    required this.animation,
    required this.selectedCategory,
    required this.categories,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Draw particles
    for (var particle in particles) {
      final position = Offset(
        (particle.x + animation * particle.speed) % 1.0 * size.width,
        (particle.y + animation * particle.speed) % 1.0 * size.height,
      );
      paint.color = particle.color;
      canvas.drawCircle(position, particle.radius, paint);
    }

    // Draw neural connections
    if (selectedCategory != 'All') {
      final selectedIndex = categories.indexOf(selectedCategory);
      if (selectedIndex != -1) {
        paint.color = Colors.green.shade400.withOpacity(0.3);
        paint.strokeWidth = 1;
        paint.style = PaintingStyle.stroke;

        final categoryWidth = size.width / categories.length;
        final startX = categoryWidth * selectedIndex + categoryWidth / 2;
        final startY = 120.0; // Approximate category Y position

        for (var particle in particles) {
          final distance = (particle.x * size.width - startX).abs() +
              (particle.y * size.height - startY).abs();
          
          if (distance < 200) {
            final opacity = (1 - distance / 200) * 0.3;
            paint.color = Colors.green.shade400.withOpacity(opacity);
            canvas.drawLine(
              Offset(startX, startY),
              Offset(particle.x * size.width, particle.y * size.height),
              paint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) =>
      animation != oldDelegate.animation ||
      selectedCategory != oldDelegate.selectedCategory;
} 