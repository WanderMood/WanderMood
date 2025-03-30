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
import 'package:wandermood/features/home/presentation/widgets/trending_destinations_section.dart';
import 'package:wandermood/features/weather/presentation/widgets/location_selector.dart';
import 'package:wandermood/features/weather/domain/models/location.dart';
import 'package:go_router/go_router.dart';
import 'package:wandermood/features/places/providers/explore_places_provider.dart';
import 'package:flutter_google_maps_webservices/places.dart';

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
      'isFavorite': false
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
      'isFavorite': false
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
      'isFavorite': false
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
      'isFavorite': false
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
      'isFavorite': false
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
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Container(
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
            child: TextField(
              controller: _searchController,
              onTap: () {
                setState(() {
                  _showSearchSuggestions = true;
                });
              },
              onSubmitted: (value) {
                if (value.isNotEmpty && !_recentSearches.contains(value)) {
                  setState(() {
                    // Add to recent searches at the beginning
                    _recentSearches.insert(0, value);
                    // Keep only the 3 most recent searches
                    if (_recentSearches.length > 3) {
                      _recentSearches.removeLast();
                    }
                    _showSearchSuggestions = false;
                  });
                }
                
                // Perform the search
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

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    
    return locationState.when(
      data: (location) {
        if (location == null) {
          return const Center(child: Text('Location not available'));
        }
        
        // Watch providers with the current location
        final trendingDestinations = ref.watch(trendingDestinationsProvider(city: location));
        final explorePlaces = ref.watch(explorePlacesProvider(city: location));
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _showSearchSuggestions = false;
            });
          },
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFAFF4),
                  Color(0xFFFFF5AF),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Title and Location Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Explore Title
                        Text(
                          'Explore',
                          style: GoogleFonts.museoModerno(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF12B347),
                          ),
                        ),
                        
                        // Location Selector
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => LocationSelector(
                                  onLocationSelected: (location) {
                                    // Handle location selection
                                    ref.read(locationProvider.notifier).setLocation(location.name);
                                    // Refresh data based on the new location
                                    ref.invalidate(explorePlacesProvider);
                                    ref.invalidate(trendingDestinationsProvider);
                                    setState(() {
                                      // Update UI with new location
                                    });
                                    // Navigator.pop is already called in LocationSelector
                                  },
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  location ?? 'Rotterdam',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Search Bar
                  _buildSearchBar(),
                  
                  // Remaining Content
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Filters
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
                                  _buildCategoryChip('History', _selectedCategory == 'History'),
                                  _buildCategoryChip('Art', _selectedCategory == 'Art'),
                                  _buildCategoryChip('Family', _selectedCategory == 'Family'),
                                  _buildCategoryChip('Photography', _selectedCategory == 'Photography'),
                                  _buildCategoryChip('Sports', _selectedCategory == 'Sports'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          trendingDestinations.when(
                            data: (destinations) => TrendingDestinationsSection(
                              destinations: destinations,
                            ),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (error, stack) => Center(
                              child: Text('Error: $error'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Text(
                                  'Discover Places',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          explorePlaces.when(
                            data: (places) => ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: places.length,
                              itemBuilder: (context, index) {
                                return _buildPlaceCard(places[index]);
                              },
                            ),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (error, stack) => Center(
                              child: Text('Error: $error'),
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
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildPlaceCard(PlacesSearchResult place) {
    // Get the current location from the provider
    final locationState = ref.watch(locationProvider);
    final currentCity = locationState.value ?? 'Rotterdam';
    
    return GestureDetector(
      onTap: () {
        final placeId = place.placeId;
        context.push('/place/$placeId');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Image with gradient overlay
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Stack(
                    children: [
                      // Image from Google Places API
                      if (place.photos?.isNotEmpty ?? false)
                        Image.network(
                          ref.read(explorePlacesProvider(city: currentCity).notifier).getPhotoUrl(place.photos!.first.photoReference),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.image, size: 50, color: Colors.grey),
                          ),
                        ),
                      // Gradient overlay
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.4),
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Favorite and Share buttons
                Positioned(
                  top: 16,
                  right: 16,
                  child: Row(
                    children: [
                      // Share button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            // Add share functionality
                          },
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.share,
                              color: Colors.grey,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Favorite button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                          },
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.favorite_border,
                              color: Colors.grey,
                              size: 24,
                            ),
                          ),
                        ),
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
                  // Place name
                  Text(
                    place.name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Place location and rating
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        currentCity,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.flag,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '🇳🇱',
                        style: TextStyle(fontSize: 14),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        place.rating?.toStringAsFixed(1) ?? 'N/A',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Place type
                  if (place.types?.isNotEmpty ?? false)
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            place.types!.first.replaceAll('_', ' '),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade700,
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
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _onCategorySelected(label);
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected 
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.green[700] : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTag(Map<String, dynamic> activity) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF12B347).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF12B347).withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF12B347).withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                activity['icon'],
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                activity['name'],
                style: const TextStyle(
                  color: Color(0xFF12B347),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ).animate(
        onPlay: (controller) => controller.repeat(reverse: true),
      ).shimmer(
        duration: const Duration(seconds: 4),
        color: const Color(0xFF12B347).withOpacity(0.2),
      ).scale(
        begin: const Offset(1, 1),
        end: const Offset(1.02, 1.02),
        duration: const Duration(seconds: 2),
        curve: Curves.easeInOut,
      ),
    );
  }

  Widget _buildTrendingDestination(Place destination) {
    // Get the current location from the provider
    final locationState = ref.watch(locationProvider);
    final currentCity = locationState.value ?? 'Rotterdam';
    
    String photoUrl = '';
    if (destination.photos.isNotEmpty) {
      photoUrl = ref.read(trendingDestinationsProvider(city: currentCity).notifier)
          .getPhotoUrl(destination.photos.first);
    }

    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: 120,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF12B347),
                      const Color(0xFF12B347).withOpacity(0.5),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    image: DecorationImage(
                      image: destination.photos.isNotEmpty && photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl) as ImageProvider
                          : const AssetImage('assets/images/placeholder.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    destination.emoji ?? '🔥',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            destination.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            destination.tag ?? destination.types.firstOrNull?.toUpperCase() ?? '',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: const Duration(milliseconds: 500))
      .scale(
        begin: const Offset(0.8, 0.8),
        end: const Offset(1, 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_offset.dy * 0.01)
          ..rotateY(_offset.dx * -0.01),
        alignment: FractionalOffset.center,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _offset += details.delta;
              _offset = Offset(
                _offset.dx.clamp(-20.0, 20.0),
                _offset.dy.clamp(-20.0, 20.0),
              );
            });
          },
          onPanEnd: (details) {
            setState(() {
              _offset = Offset.zero;
            });
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: -5,
                    ),
                    BoxShadow(
                      color: Colors.green.shade400.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: -10,
                      offset: _offset,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            if (_isLoading)
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ).animate(
                                onPlay: (controller) => controller.repeat(reverse: true),
                              ).custom(
                                duration: 1.5.seconds,
                                builder: (context, value, child) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white.withOpacity(0.1),
                                          Colors.white.withOpacity(0.2 * value),
                                          Colors.white.withOpacity(0.1),
                                        ],
                                      ),
                                    ),
                                    child: child,
                                  );
                                },
                              ),
                            Hero(
                              tag: 'destination_image_${widget.destination.name}',
                              child: Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  image: DecorationImage(
                                    image: widget.destination.isAsset
                                        ? AssetImage(widget.destination.imageUrl) as ImageProvider
                                        : NetworkImage(widget.destination.imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.destination.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.green.shade400,
                                        size: 20,
                                      ).animate(
                                        onPlay: (controller) => controller.repeat(reverse: true),
                                      ).scale(
                                        duration: 2.seconds,
                                        begin: const Offset(1, 1),
                                        end: const Offset(1.2, 1.2),
                                        curve: Curves.easeInOut,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.destination.rating.toString(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.green.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.destination.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: widget.destination.activities.map((activity) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.green.shade400.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      activity,
                                      style: TextStyle(
                                        color: Colors.green.shade500,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ).animate(
                                    onPlay: (controller) => controller.repeat(reverse: true),
                                  ).scale(
                                    duration: 3.seconds,
                                    begin: const Offset(1, 1),
                                    end: const Offset(1.05, 1.05),
                                    curve: Curves.easeInOut,
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
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