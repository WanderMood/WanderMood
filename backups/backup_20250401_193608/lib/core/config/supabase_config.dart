import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static String get url => dotenv.env['SUPABASE_URL'] ?? '';
  static String get anonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      debug: false, // Set to true for development
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }
  
  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
  
  // Database references
  static String get usersTable => 'users';
  static String get moodsTable => 'moods';
  static String get activitiesTable => 'activities';
  static String get recommendationsTable => 'recommendations';
  static String get weatherDataTable => 'weather_data';
  
  // Storage buckets
  static String get profileImagesBucket => 'profile_images';
  static String get activityImagesBucket => 'activity_images';
  
  // RLS Policies
  static const String authenticatedUserPolicy = 'authenticated_user';
  static const String ownerOnlyPolicy = 'owner_only';
  
  // Functions
  static String get getCurrentWeatherFunction => 'get_current_weather';
  static String get getRecommendationsFunction => 'get_recommendations';
} 