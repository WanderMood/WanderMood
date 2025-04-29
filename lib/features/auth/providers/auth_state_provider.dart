import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/config/supabase_config.dart';
 
/// Provider that exposes the Supabase auth state changes stream
final authStateProvider = StreamProvider<User?>((ref) {
  return SupabaseConfig.auth.onAuthStateChange.map((event) => event.session?.user);
}); 