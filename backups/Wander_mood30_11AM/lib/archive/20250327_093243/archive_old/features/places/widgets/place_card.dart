import 'package:flutter/material.dart';
import 'package:wandermood/features/places/models/place.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback? onTap;

  const PlaceCard({
    super.key,
    required this.place,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 8),
                  _buildDescription(),
                  const SizedBox(height: 12),
                  _buildDetails(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: place.photos.isNotEmpty
          ? Image.network(
              place.photos.first,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
            )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.photo,
          size: 48,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        if (place.emoji != null) ...[
          Text(
            place.emoji!,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (place.address != null) ...[
                const SizedBox(height: 4),
                Text(
                  place.address!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (place.rating != null) ...[
          const Icon(Icons.star, color: Colors.amber, size: 20),
          const SizedBox(width: 4),
          Text(
            place.rating!.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDescription() {
    if (place.description == null) return const SizedBox.shrink();
    
    return Text(
      place.description!,
      style: const TextStyle(
        fontSize: 14,
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (place.priceLevel != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF12B347).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getPriceLevel(place.priceLevel!),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF12B347),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _getPriceLevelText(place.priceLevel!),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (place.openingHours != null) ...[
              Text(
                place.isOpen ? 'Open' : 'Closed',
                style: TextStyle(
                  fontSize: 14,
                  color: place.isOpen ? Colors.green : Colors.red,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _getPriceLevel(int priceLevel) {
    switch (priceLevel) {
      case 1:
        return '\$';
      case 2:
        return '\$\$';
      case 3:
        return '\$\$\$';
      case 4:
        return '\$\$\$\$';
      default:
        return '\$';
    }
  }

  String _getPriceLevelText(int priceLevel) {
    switch (priceLevel) {
      case 1:
        return 'Inexpensive';
      case 2:
        return 'Moderate';
      case 3:
        return 'Expensive';
      case 4:
        return 'Very Expensive';
      default:
        return 'Inexpensive';
    }
  }

  String _getOpeningStatus(Map<String, dynamic> openingHours) {
    final now = DateTime.now();
    final weekday = now.weekday - 1; // 0 = Monday, 6 = Sunday
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    if (openingHours['open_now'] == true) {
      return 'Open now';
    } else if (openingHours['open_now'] == false) {
      return 'Closed';
    } else {
      return 'Hours vary';
    }
  }

  bool _isOpen(Map<String, dynamic> openingHours) {
    return openingHours['open_now'] == true;
  }
} 