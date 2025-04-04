import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/router/router.dart';
import 'core/theme/app_theme.dart';
import 'core/config/supabase_config.dart';
import 'app.dart';
import 'features/home/presentation/screens/main_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/auth/providers/user_provider.dart';
import 'core/domain/providers/location_notifier_provider.dart';

// Provider to initialize app data on startup
final appInitializerProvider = FutureProvider<bool>((ref) async {
  // Start listening to auth state changes 
  ref.watch(authStateChangesProvider);
  
  // Initialize location
  if (Supabase.instance.client.auth.currentUser != null) {
    await ref.read(locationNotifierProvider.notifier).getCurrentLocation();
  }
  
  return true;
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Load environment variables
    await dotenv.load(fileName: '.env');
    
    // Initialize Supabase with loaded environment variables
    await SupabaseConfig.initialize();
    
    runApp(const ProviderScope(child: MyApp()));
  } catch (e) {
    debugPrint('Error initializing app: $e');
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error initializing app: $e'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    // Start app initialization
    ref.watch(appInitializerProvider);
    
    return MaterialApp(
      title: 'WanderMood',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5BB32A)),
        useMaterial3: true,
        textTheme: GoogleFonts.museoModernoTextTheme(),
      ),
      home: const MainScreen(),
    );
  }
}

class WanderMoodApp extends ConsumerWidget {
  const WanderMoodApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'WanderMood',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
