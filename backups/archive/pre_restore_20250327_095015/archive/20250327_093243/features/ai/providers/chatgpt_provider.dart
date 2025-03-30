import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wandermood/core/providers/cache_provider.dart';
import '../services/chatgpt_service.dart';

final chatGPTServiceProvider = Provider<ChatGPTService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ChatGPTService(prefs);
}); 