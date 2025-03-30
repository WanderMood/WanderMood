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

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _hotels = [
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
  ];

  final List<Map<String, dynamic>> _trendingDestinations = [
    {
      'name': 'Bali',
      'emoji': '🌴',
      'image': 'assets/images/shifaaz-shamoon-qtbV_8P_Ksk-unsplash.jpg',
      'tag': 'Island Paradise'
    },
    {
      'name': 'Paris',
      'emoji': '🗼',
      'image': 'assets/images/dino-reichmuth-A5rCN8626Ck-unsplash.jpg',
      'tag': 'City of Love'
    },
    {
      'name': 'Iceland',
      'emoji': '❄️',
      'image': 'assets/images/A1FBE812-1D4B-41AD-BC65-483A00730AB6_4_5005_c.jpeg',
      'tag': 'Northern Lights'
    },
    {
      'name': 'Santorini',
      'emoji': '🏖️',
      'image': 'assets/images/shifaaz-shamoon-qtbV_8P_Ksk-unsplash.jpg',
      'tag': 'Mediterranean Gem'
    },
    {
      'name': 'Tokyo',
      'emoji': '🗾',
      'image': 'assets/images/dino-reichmuth-A5rCN8626Ck-unsplash.jpg',
      'tag': 'Urban Adventure'
    }
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
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    
    return locationState.when(
      data: (location) {
        if (location == null) {
          return const Center(child: Text('Location not available'));
        }
        
        return Container(
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
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const LocationDropdown(),
                          // Explore Text
                          Text(
                            'Explore',
                            style: GoogleFonts.museoModerno(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: Colors.black54,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Where to next? ✈️',
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.black54,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                                ),
                                style: GoogleFonts.poppins(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  // Add filter functionality here
                                  HapticFeedback.lightImpact();
                                },
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF12B347),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF12B347).withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.tune,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Category Filters
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            _buildCategoryChip('All', _selectedCategory == 'All'),
                            _buildCategoryChip('Nature', _selectedCategory == 'Nature'),
                            _buildCategoryChip('Culture', _selectedCategory == 'Culture'),
                            _buildCategoryChip('Adventure', _selectedCategory == 'Adventure'),
                            _buildCategoryChip('Relaxation', _selectedCategory == 'Relaxation'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Trending section header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text(
                            '🔥 Trending',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              // Handle see all
                            },
                            child: const Text(
                              'See All',
                              style: TextStyle(
                                color: Color(0xFF12B347),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Trending destinations list
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: _trendingDestinations.length,
                        itemBuilder: (context, index) {
                          return _buildTrendingDestination(_trendingDestinations[index]);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Hotel Listings
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredHotels.length,
                      itemBuilder: (context, index) {
                        return _buildHotelCard(filteredHotels[index]);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildHotelCard(Map<String, dynamic> hotel) {
    return Container(
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
                    // Image with brightness adjustment
                    ColorFiltered(
                      colorFilter: ColorFilter.matrix([
                        1.2, 0, 0, 0, 0.1, // Red channel
                        0, 1.2, 0, 0, 0.1, // Green channel
                        0, 0, 1.2, 0, 0.1, // Blue channel
                        0, 0, 0, 1, 0, // Alpha channel
                      ]),
                      child: Image.asset(
                        hotel['image'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
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
                          setState(() {
                            hotel['isFavorite'] = !hotel['isFavorite'];
                          });
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
                            hotel['isFavorite'] ? Icons.favorite : Icons.favorite_border,
                            color: hotel['isFavorite'] ? Colors.red : Colors.grey,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        hotel['name'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 18,
                          color: Color(0xFFFFD700),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hotel['rating'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  hotel['description'],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hotel['location'],
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hotel['flag'],
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    // Distance from current location
                    Row(
                      children: [
                        const Icon(
                          Icons.near_me,
                          size: 14,
                          color: Color(0xFF12B347),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hotel['distance'],
                          style: const TextStyle(
                            color: Color(0xFF12B347),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var activity in hotel['activities'])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildActivityTag(activity),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildTrendingDestination(Map<String, dynamic> destination) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      width: 120,
      child: Column(
        children: [
          // Story-like circle with image
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
                      image: AssetImage(destination['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // Trending fire icon
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
                  child: const Text(
                    '🔥',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Destination name and emoji
          Text(
            '${destination['name']} ${destination['emoji']}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          // Tag line
          Text(
            destination['tag'],
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