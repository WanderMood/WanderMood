import 'package:flutter/material.dart';
import '../services/places_service.dart';
import '../services/places_cache_service.dart';
import 'package:intl/intl.dart';

class PlacesApiMonitor extends StatefulWidget {
  final PlacesService placesService;

  const PlacesApiMonitor({
    Key? key,
    required this.placesService,
  }) : super(key: key);

  @override
  State<PlacesApiMonitor> createState() => _PlacesApiMonitorState();
}

class _PlacesApiMonitorState extends State<PlacesApiMonitor> {
  late Timer _refreshTimer;
  Map<String, dynamic> _stats = {};
  double _estimatedCost = 0.0;

  @override
  void initState() {
    super.initState();
    _updateStats();
    // Refresh stats every minute
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) => _updateStats());
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  void _updateStats() {
    setState(() {
      _stats = widget.placesService.getApiUsageStats();
      _estimatedCost = widget.placesService.getEstimatedDailyCost();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Places API Monitor',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildStatRow('Daily Requests', _stats['dailyRequestCount']?.toString() ?? '0'),
            _buildStatRow(
              'Estimated Cost',
              '\$${_estimatedCost.toStringAsFixed(2)}',
              isHighlighted: _estimatedCost > 100, // Highlight if cost is high
            ),
            const Divider(),
            Text(
              'Endpoint Usage:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ..._buildEndpointUsageList(),
            const Divider(),
            Text(
              'Cache Stats:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildStatRow('Cache Entries', _stats['totalEntries']?.toString() ?? '0'),
            if (_stats['oldestEntry'] != null)
              _buildStatRow(
                'Oldest Entry',
                DateFormat('MMM d, HH:mm').format(_stats['oldestEntry']),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEndpointUsageList() {
    final endpointUsage = _stats['endpointUsage'] as Map<String, int>? ?? {};
    return endpointUsage.entries.map((entry) {
      final cost = PlacesApiCost.estimateCost(entry.key, entry.value);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${entry.key}:'),
            Text(
              '${entry.value} calls (\$${cost.toStringAsFixed(2)})',
              style: TextStyle(
                color: cost > 50 ? Colors.red : null,
                fontWeight: cost > 50 ? FontWeight.bold : null,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildStatRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              color: isHighlighted ? Colors.red : null,
              fontWeight: isHighlighted ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }
} 