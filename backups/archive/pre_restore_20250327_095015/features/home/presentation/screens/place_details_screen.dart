import 'package:flutter/material.dart';
import 'package:wandermood/features/places/models/place.dart';
import 'package:share_plus/share_plus.dart';

class PlaceDetailsScreen extends StatelessWidget {
  final Place place;

  const PlaceDetailsScreen({
    Key? key,
    required this.place,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(place.name),
              background: Image.network(
                place.photos.isNotEmpty
                  ? place.photos.first
                  : 'assets/images/placeholder.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            Text(' ${place.rating ?? 'N/A'}'),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () {
                            Share.share('Check out ${place.name}!');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      place.description ?? 'No description available',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    if (place.address != null) ...[
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(place.address!),
                    ],
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
} 