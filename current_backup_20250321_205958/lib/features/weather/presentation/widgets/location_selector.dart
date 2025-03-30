import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      final position = await Geolocator.getCurrentPosition();
      final location = Location(
        id: 'current',
        latitude: position.latitude,
        longitude: position.longitude,
        name: 'Huidige locatie',
      );
      widget.onLocationSelected(location);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kon huidige locatie niet ophalen'),
          backgroundColor: Colors.red,
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
      // Hier zou je normaal gesproken een geocoding service gebruiken
      // Voor nu simuleren we resultaten
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _searchResults = [
          Location(
            id: 'amsterdam',
            latitude: 52.3676,
            longitude: 4.9041,
            name: 'Amsterdam',
          ),
          Location(
            id: 'utrecht',
            latitude: 52.0907,
            longitude: 5.1214,
            name: 'Utrecht',
          ),
          Location(
            id: 'rotterdam',
            latitude: 51.9244,
            longitude: 4.4777,
            name: 'Rotterdam',
          ),
        ].where((loc) => 
          loc.name.toLowerCase().contains(query.toLowerCase())
        ).toList();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Zoek een locatie...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: _searchLocations,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.my_location),
              tooltip: 'Gebruik huidige locatie',
            ),
          ],
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        if (_searchResults.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final location = _searchResults[index];
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(location.name),
                  onTap: () {
                    widget.onLocationSelected(location);
                    _searchController.clear();
                    setState(() => _searchResults = []);
                  },
                );
              },
            ),
          ),
        if (widget.selectedLocation != null) ...[
          const SizedBox(height: 8),
          Chip(
            label: Text(widget.selectedLocation!.name),
            onDeleted: () {
              widget.onLocationSelected(
                Location(
                  id: 'amsterdam',
                  latitude: 52.3676,
                  longitude: 4.9041,
                  name: 'Amsterdam',
                ),
              );
            },
            deleteIcon: const Icon(Icons.close),
          ),
        ],
      ],
    );
  }
} 