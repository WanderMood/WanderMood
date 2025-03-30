import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandermood/features/location/providers/location_provider.dart';
import 'package:wandermood/features/location/services/location_service.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LocationDropdown extends ConsumerStatefulWidget {
  const LocationDropdown({Key? key}) : super(key: key);

  @override
  ConsumerState<LocationDropdown> createState() => _LocationDropdownState();
}

class _LocationDropdownState extends ConsumerState<LocationDropdown> {
  String? _countryCode;
  List<String> _popularCities = [];
  late final GoogleMapsPlaces _places;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _places = GoogleMapsPlaces(apiKey: dotenv.env['GOOGLE_PLACES_API_KEY']);
    _initializeCountryAndCities();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeCountryAndCities() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        final countryCode = placemarks.first.isoCountryCode?.toLowerCase();
        setState(() {
          _countryCode = countryCode;
          _popularCities = _getPopularCitiesForCountry(countryCode);
        });
      }
    } catch (e) {
      setState(() {
        _countryCode = 'nl';
        _popularCities = _getPopularCitiesForCountry('nl');
      });
    }
  }

  List<String> _getPopularCitiesForCountry(String? countryCode) {
    switch (countryCode) {
      case 'nl':
        return ['Amsterdam', 'Rotterdam', 'The Hague', 'Utrecht'];
      case 'be':
        return ['Brussels', 'Antwerp', 'Ghent', 'Bruges'];
      case 'de':
        return ['Berlin', 'Hamburg', 'Munich', 'Cologne'];
      case 'fr':
        return ['Paris', 'Lyon', 'Marseille', 'Toulouse'];
      case 'gb':
        return ['London', 'Manchester', 'Birmingham', 'Edinburgh'];
      case 'es':
        return ['Madrid', 'Barcelona', 'Valencia', 'Seville'];
      case 'it':
        return ['Rome', 'Milan', 'Naples', 'Turin'];
      default:
        return ['Amsterdam', 'Rotterdam', 'The Hague', 'Utrecht'];
    }
  }

  Future<List<PlacesSearchResult>> _searchPlaces(String query) async {
    if (query.length < 2) return [];
    
    try {
      final response = await _places.searchByText(
        query,
        type: 'locality',
        region: _countryCode ?? 'nl',
        language: 'en',
      );
      
      // Return all results since we're already filtering by region
      return response.results;
    } catch (e) {
      debugPrint('Error searching places: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);

    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () async {
            if (locationState.hasError) {
              final error = locationState.error.toString();
              if (error.contains('Location services are disabled')) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Location Services Disabled'),
                    content: const Text('Please enable location services in your device settings to use this feature.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          LocationService.openLocationSettings();
                        },
                        child: const Text('Open Settings'),
                      ),
                    ],
                  ),
                );
              } else if (error.contains('permission')) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Location Permission Required'),
                    content: const Text('Please enable location permission in app settings to use this feature.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          LocationService.openAppSettings();
                        },
                        child: const Text('Open Settings'),
                      ),
                    ],
                  ),
                );
              }
              return;
            }

            final selectedLocation = await showDialog<String>(
              context: context,
              builder: (BuildContext context) {
                List<PlacesSearchResult> searchResults = [];
                bool isSearching = false;

                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: Text(
                        'Choose Location',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                      content: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 400,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search any city...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onChanged: (value) async {
                                setState(() => isSearching = true);
                                final results = await _searchPlaces(value);
                                setState(() {
                                  searchResults = results;
                                  isSearching = false;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            
                            ListTile(
                              leading: const Icon(Icons.my_location, color: Color(0xFF12B347)),
                              title: Text(
                                'Use Current Location',
                                style: GoogleFonts.poppins(),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                ref.read(locationProvider.notifier).getCurrentLocation();
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                            
                            const Divider(height: 32),
                            
                            Text(
                              searchResults.isNotEmpty ? 'Search Results' : 'Popular Cities Nearby',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            Expanded(
                              child: isSearching
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        ...searchResults.isNotEmpty
                                          ? searchResults.take(4).map((result) => ListTile(
                                              leading: const Icon(Icons.location_on),
                                              title: Text(
                                                result.name,
                                                style: GoogleFonts.poppins(),
                                              ),
                                              subtitle: Text(
                                                result.formattedAddress ?? '',
                                                style: GoogleFonts.poppins(fontSize: 12),
                                              ),
                                              contentPadding: EdgeInsets.zero,
                                              onTap: () {
                                                ref.read(locationProvider.notifier).setLocation(result.name);
                                                Navigator.pop(context, result.name);
                                              },
                                            ))
                                          : _popularCities.map((city) => ListTile(
                                              leading: const Icon(Icons.location_city),
                                              title: Text(city, style: GoogleFonts.poppins()),
                                              contentPadding: EdgeInsets.zero,
                                              onTap: () {
                                                ref.read(locationProvider.notifier).setLocation(city);
                                                Navigator.pop(context, city);
                                              },
                                            )),
                                      ],
                                    ),
                                  ),
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
                            'Cancel',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );

            if (selectedLocation != null) {
              ref.read(locationProvider.notifier).setLocation(selectedLocation);
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on,
                color: locationState.hasError ? Colors.red : Colors.black87,
                size: 18,
              ),
              const SizedBox(width: 4),
              locationState.when(
                data: (location) => Text(
                  location ?? 'Select Location',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                loading: () => SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                  ),
                ),
                error: (error, _) => Text(
                  'Enable Location',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                color: locationState.hasError ? Colors.red : Colors.black87,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 