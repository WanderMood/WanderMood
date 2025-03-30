import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../domain/models/location.dart';

class LocationSelector extends ConsumerStatefulWidget {
  final Location? selectedLocation;
  final Function(Location) onLocationSelected;

  const LocationSelector({
    super.key,
    this.selectedLocation,
    required this.onLocationSelected,
  });

  @override
  ConsumerState<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends ConsumerState<LocationSelector> {
  final TextEditingController _searchController = TextEditingController();
  List<Location> _searchResults = [];
  bool _isLoading = false;
  String _currentCountry = 'Netherlands'; // Default country
  final List<String> _popularCities = [
    'Rotterdam',
    'Amsterdam',
    'Utrecht',
    'The Hague',
    'Eindhoven',
    'Groningen',
    'Maastricht',
    'Tilburg',
  ];

  @override
  void initState() {
    super.initState();
    _detectCurrentCountry();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _detectCurrentCountry() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      if (placemarks.isNotEmpty && placemarks.first.country != null) {
        setState(() {
          _currentCountry = placemarks.first.country!;
        });
      }
    } catch (e) {
      // Keep default country if detection fails
      debugPrint('Error detecting country: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      final position = await Geolocator.getCurrentPosition();
      
      // Get actual location name using reverse geocoding
      final placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude
      );
      
      final city = placemarks.isNotEmpty && placemarks.first.locality != null && placemarks.first.locality!.isNotEmpty
          ? placemarks.first.locality!
          : 'Current Location';
          
      final country = placemarks.isNotEmpty && placemarks.first.country != null 
          ? placemarks.first.country! 
          : _currentCountry;
          
      setState(() {
        _currentCountry = country;
      });
          
      final location = Location(
        id: 'current',
        latitude: position.latitude,
        longitude: position.longitude,
        name: city,
        country: country,
      );
      widget.onLocationSelected(location);
      Navigator.pop(context);
    } catch (e) {
      // Default to Rotterdam when location access fails
      final rotterdamLocation = Location(
        id: 'rotterdam',
        latitude: 51.9244,
        longitude: 4.4777,
        name: 'Rotterdam',
        country: 'Netherlands',
      );
      widget.onLocationSelected(rotterdamLocation);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Locatie ingesteld op Rotterdam'),
          backgroundColor: Colors.blue,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchLocations(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Use forward geocoding to find locations by name
      final locations = await locationFromAddress(
        "$query, $_currentCountry", 
        localeIdentifier: "en_US"
      );

      if (locations.isNotEmpty) {
        final results = <Location>[];
        
        for (final location in locations) {
          try {
            // Reverse geocode to get city name
            final placemarks = await placemarkFromCoordinates(
              location.latitude, 
              location.longitude
            );
            
            if (placemarks.isNotEmpty) {
              final placemark = placemarks.first;
              final cityName = placemark.locality ?? placemark.subAdministrativeArea ?? query;
              final countryName = placemark.country ?? _currentCountry;
              
              // Only include results in the current country
              if (countryName == _currentCountry && cityName.isNotEmpty) {
                final uniqueId = '${cityName.toLowerCase()}_${location.latitude}_${location.longitude}';
                
                // Check if we already have this city
                if (!results.any((loc) => loc.name.toLowerCase() == cityName.toLowerCase())) {
                  results.add(Location(
                    id: uniqueId,
                    latitude: location.latitude,
                    longitude: location.longitude,
                    name: cityName,
                    country: countryName,
                  ));
                }
              }
            }
          } catch (e) {
            debugPrint('Error reverse geocoding: $e');
          }
        }
        
        setState(() {
          _searchResults = results;
        });
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    } catch (e) {
      debugPrint('Error geocoding: $e');
      setState(() {
        _searchResults = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        backgroundColor: Colors.white,
      ),
      body: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search bar with location button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                          hintText: 'Zoek een locatie...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: _searchLocations,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF12B347),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: _getCurrentLocation,
                        icon: const Icon(Icons.my_location, color: Colors.white),
                        tooltip: 'Gebruik huidige locatie',
                      ),
                    ),
                  ],
                ),
              ),
              
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
                
              // Search results
              if (_searchResults.isNotEmpty)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final location = _searchResults[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on, color: Color(0xFF12B347)),
                          title: Text(
                            location.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: location.country != null ? Text(location.country!) : null,
                          onTap: () {
                            widget.onLocationSelected(location);
                            _searchController.clear();
                            setState(() => _searchResults = []);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                )
              else if (_searchController.text.isNotEmpty && !_isLoading)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No locations found',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                
              // Popular locations section
              if (_searchResults.isEmpty && _searchController.text.isEmpty && !_isLoading)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Popular Locations',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.separated(
                            itemCount: _popularCities.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final city = _popularCities[index];
                              return _buildPopularLocationTile(
                                city,
                                _currentCountry,
                                0.0, // Will be populated during search
                                0.0, // Will be populated during search
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPopularLocationTile(String name, String country, double lat, double lng) {
    return ListTile(
      leading: const Icon(Icons.location_city, color: Color(0xFF12B347)),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(country),
      onTap: () async {
        // For popular cities, we get coordinates on demand
        try {
          setState(() => _isLoading = true);
          
          // Get coordinates for this city
          final locations = await locationFromAddress(
            "$name, $country", 
            localeIdentifier: "en_US"
          );
          
          if (locations.isNotEmpty) {
            final location = Location(
              id: name.toLowerCase(),
              name: name,
              latitude: locations.first.latitude,
              longitude: locations.first.longitude,
              country: country,
            );
            
            widget.onLocationSelected(location);
            Navigator.pop(context);
          } else {
            throw Exception('No coordinates found');
          }
        } catch (e) {
          debugPrint('Error getting coordinates for $name: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading location for $name'),
              backgroundColor: Colors.red,
            ),
          );
        } finally {
          setState(() => _isLoading = false);
        }
      },
    );
  }
} 