import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/chatgpt_provider.dart';

class APITestWidget extends ConsumerStatefulWidget {
  const APITestWidget({super.key});

  @override
  ConsumerState<APITestWidget> createState() => _APITestWidgetState();
}

class _APITestWidgetState extends ConsumerState<APITestWidget> {
  bool? _isConnected;
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final chatGPTService = ref.read(chatGPTServiceProvider);
      final isConnected = await chatGPTService.testConnection();
      
      setState(() {
        _isConnected = isConnected;
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isConnected 
              ? '✅ API connection successful!' 
              : '❌ API connection failed. Please check your API key.',
          ),
          backgroundColor: isConnected ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      setState(() {
        _isConnected = false;
        _isLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'API Connection Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_isConnected == null)
              const Text('Not tested yet')
            else
              Icon(
                _isConnected! ? Icons.check_circle : Icons.error,
                color: _isConnected! ? Colors.green : Colors.red,
                size: 48,
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              child: const Text('Test Connection'),
            ),
          ],
        ),
      ),
    );
  }
} 