# WanderMood Development Documentation

## Project Overview
WanderMood is an AI-driven travel application that personalizes travel recommendations based on user moods and preferences. The app features dynamic time-based interactions and location-aware suggestions.

## Technical Stack

### Frontend
- **Framework**: Flutter (Latest stable version)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **UI Libraries**:
  - flutter_animate
  - google_fonts
  - animated_text_kit
  - flutter_svg
  - lottie
  - simple_animations

### Backend
- **Platform**: Supabase
- **Database**: PostgreSQL
- **Authentication**: Supabase Auth with PKCE flow
- **Storage**: Supabase Storage
- **Real-time**: Supabase Realtime
- **Serverless**: Supabase Edge Functions
- **Security**: Row Level Security (RLS)

### External APIs
- **Places**: Google Places API
- **Weather**: OpenWeatherMap API
- **Maps**: Google Maps API
- **Geocoding**: Geocoding API

## Core Features

### 1. Time-Based Interactions
- **Morning Mode** (7 AM - 12 PM)
  - Personalized morning greetings
  - Daily mood selection
  - Weather-aware suggestions
  
- **Day Mode** (12 PM - 12 AM)
  - Full feature access
  - Location-based recommendations
  - Social interactions
  
- **Night Mode** (12 AM - 7 AM)
  - Sleep-friendly interface
  - Wake-up mood selection
  - Next day planning

### 2. Mood-Based Planning
- **Mood Categories**:
  - Energetic ⚡
  - Peaceful 🌅
  - Adventurous 🚀
  - Creative 🎨
  - Relaxed 😌

- **Planning Algorithm**:
  - Weather consideration
  - Time of day adaptation
  - Location proximity
  - User preferences
  - Historical data

### 3. Location Services
- Real-time location tracking
- Place suggestions based on:
  - Current mood
  - Weather conditions
  - Time of day
  - User preferences
  - Previous visits

### 4. Data Persistence
- **Local Storage**:
  - SharedPreferences for user preferences
  - Hive for offline data
  - Secure storage for sensitive data

- **Cloud Storage (Supabase)**:
  - User profiles in PostgreSQL tables
  - Mood history with real-time updates
  - Favorite places with RLS policies
  - Travel plans with geospatial queries

## Architecture

### Directory Structure
```
lib/
├── core/
│   ├── router/
│   ├── theme/
│   ├── utils/
│   ├── config/
│   ├── providers/
│   └── constants/
├── features/
│   ├── auth/
│   ├── home/
│   ├── mood/
│   ├── places/
│   └── weather/
└── shared/
    ├── widgets/
    └── models/
```

### Key Components

#### 1. Router Configuration
- GoRouter for declarative routing
- Path-based navigation
- Deep linking support
- Authentication guards with Supabase session

#### 2. State Management
- Riverpod providers for:
  - Authentication state (`supabaseClientProvider`)
  - User preferences
  - Mood selection
  - Location data
  - Weather information

#### 3. UI Components
- Custom animated widgets
- Mood selection grid
- Location cards
- Weather displays
- Planning interface

## API Integration

### 1. Supabase Setup
```dart
// Initialize Supabase in main.dart
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL'] ?? '',
  anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  debug: false, // Set to true for development
  authOptions: const FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce,
  ),
);

// Access client anywhere in the app
final supabase = Supabase.instance.client;

// Using with Riverpod
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});
```

### 2. Authentication
```dart
// Sign in with email and password
final response = await supabase.auth.signInWithPassword(
  email: email,
  password: password,
);

// Sign up
final response = await supabase.auth.signUp(
  email: email,
  password: password,
  data: {'name': name},
);

// Social login
final response = await supabase.auth.signInWithOAuth(
  Provider.google,
  redirectTo: 'io.supabase.wandermood://login-callback/',
);

// Sign out
await supabase.auth.signOut();
```

### 3. Database Operations
```dart
// Insert data
final response = await supabase
  .from('moods')
  .insert({
    'user_id': supabase.auth.currentUser!.id,
    'mood_type': 'happy',
    'intensity': 8,
    'notes': 'Feeling great today!',
    'weather': {'temp': 22, 'condition': 'sunny'},
  });

// Query data
final response = await supabase
  .from('places')
  .select('id, name, location, mood_tags, rating')
  .eq('mood_tags', 'peaceful')
  .order('rating', ascending: false)
  .limit(10);

// Update data
final response = await supabase
  .from('users')
  .update({'preferences': newPreferences})
  .eq('id', supabase.auth.currentUser!.id);

// Delete data
final response = await supabase
  .from('user_places')
  .delete()
  .eq('place_id', placeId)
  .eq('user_id', supabase.auth.currentUser!.id);
```

### 4. Real-time Subscriptions
```dart
// Listen to changes in the moods table
final subscription = supabase
  .from('moods')
  .stream(primaryKey: ['id'])
  .eq('user_id', supabase.auth.currentUser!.id)
  .listen((List<Map<String, dynamic>> data) {
    // Handle real-time updates
  });

// Remember to cancel subscription when not needed
subscription.cancel();
```

### 5. Storage
```dart
// Upload a file
final response = await supabase
  .storage
  .from('profile_images')
  .upload(
    'public/${supabase.auth.currentUser!.id}.jpg',
    file,
    fileOptions: const FileOptions(
      cacheControl: '3600',
      upsert: true,
    ),
  );

// Get a public URL
final url = supabase
  .storage
  .from('profile_images')
  .getPublicUrl('public/${supabase.auth.currentUser!.id}.jpg');

// Download a file
final bytes = await supabase
  .storage
  .from('profile_images')
  .download('public/${supabase.auth.currentUser!.id}.jpg');
```

### 6. Edge Functions
```dart
// Invoke an Edge Function
final response = await supabase
  .functions
  .invoke(
    'generate_recommendations',
    body: {
      'mood': currentMood,
      'weather': currentWeather,
      'location': userLocation,
    },
  );
```

### 7. Places API
- Search radius: 5km
- Result limit: 20 places
- Categories:
  - Attractions
  - Restaurants
  - Activities
  - Cultural sites

### 8. Weather API
- Hourly forecasts
- 5-day predictions
- Weather conditions
- Temperature
- Precipitation

## Security

### Supabase Security
- **Row Level Security (RLS)**: Enforced at the database level to ensure users can only access appropriate data
- **Policies**:
  ```sql
  -- Example: Users can only read their own data
  CREATE POLICY "Users can only access own data"
  ON moods
  FOR SELECT
  USING (auth.uid() = user_id);
  
  -- Example: Users can only insert their own data
  CREATE POLICY "Users can insert own data"
  ON moods
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);
  ```

### Authentication
- PKCE flow for secure OAuth
- JWT token management
- Session handling
- Refresh token rotation

### Data Protection
- Encrypted storage
- Secure API calls
- Rate limiting with Supabase Edge Functions
- Input validation

## Performance Optimization

### Caching Strategy
- Place data caching with PostgreSQL
- Image caching with Supabase Storage CDN
- Weather data caching
- Offline support with Hive

### Memory Management
- Image optimization
- Lazy loading
- Resource cleanup
- Background process management

### Query Optimization
- Selective column selection
- Pagination with `range()`
- Indexing important columns
- Efficient joins using relationships

## Testing

### Unit Tests
- Business logic
- Data models
- Supabase API services
- Utils

### Widget Tests
- UI components
- Navigation
- State management
- User interactions

### Integration Tests
- End-to-end flows
- Supabase integration
- Database operations with mocked Supabase client

## Deployment

### Supabase Setup
1. Create Supabase project via dashboard
2. Set up database schema (tables, RLS, etc.)
3. Create storage buckets
4. Deploy Edge Functions
5. Configure authentication providers

### Release Process
1. Version bump
2. Changelog update
3. Asset optimization
4. Build generation
5. Store submission

### Environment Configuration
- Development
  - Local Supabase instance or dev project
  - Debug flags enabled
  - Test data
- Staging
  - Staging Supabase project
  - Release candidate testing
- Production
  - Production Supabase project
  - Optimized performance
  - Real data

## Maintenance

### Monitoring
- Error tracking
- Usage analytics
- Performance metrics
- Supabase health checks
- Edge Functions monitoring

### Updates
- Regular dependency updates
- Security patches
- Feature additions
- Bug fixes
- Supabase migrations

## Supabase Migration Guide

### Migrating from Firebase
1. **Authentication**:
   - Use Supabase Auth with similar providers
   - Implement PKCE flow for OAuth
   - Update UI to handle Supabase auth responses

2. **Database**:
   - Convert Firestore collections to PostgreSQL tables
   - Implement RLS policies for security
   - Use JOINs instead of nested document queries

3. **Storage**:
   - Move files to Supabase Storage
   - Update storage references throughout the app
   - Implement RLS for Supabase Storage buckets

4. **Functions**:
   - Convert Firebase Cloud Functions to Supabase Edge Functions
   - Update function invocation code
   - Test and validate function responses

5. **Real-time**:
   - Replace Firebase listeners with Supabase real-time subscriptions
   - Test real-time performance and reliability
   - Implement appropriate error handling

### Database Migration Checklist
- ✅ Schema creation
- ✅ Data migration
- ✅ Index creation
- ✅ RLS policy implementation
- ✅ Function/trigger creation
- ✅ Testing queries
- ✅ Performance validation

## Future Enhancements
1. Geospatial queries for better location-based recommendations
2. Social features with shared RLS policies
3. Advanced PostgreSQL features (Full Text Search, PostGIS)
4. Supabase Edge Functions for AI processing
5. Realtime collaborative features

## Known Issues
1. Some places not found in Places API (Hotel New York, Witte Huis)
2. Occasional weather data refresh delays
3. Location accuracy in dense urban areas
4. Supabase real-time subscription reconnection needs improvement
5. Initial authentication can be slow on first app launch

## Supabase Specific Considerations

### Rate Limits
- Be aware of Supabase Free tier limitations:
  - Database: 500MB storage
  - Auth: 50K MAU
  - Storage: 1GB total
  - Edge Functions: 500K invocations/month
  - Realtime: 2 concurrent connections

### Best Practices
1. **Database**:
   - Use prepared statements for better security
   - Keep RLS policies simple for performance
   - Index frequently queried columns
   - Use views for complex queries

2. **Authentication**:
   - Implement proper error handling for auth state changes
   - Use JWT claims for additional user permissions
   - Test social auth flows thoroughly on all platforms

3. **Storage**:
   - Optimize image sizes before upload
   - Use CDN caching for better performance
   - Implement proper error handling for uploads/downloads

4. **Edge Functions**:
   - Keep functions small and focused
   - Cache expensive calculations
   - Implement proper error handling and retries
   - Use typed responses for better developer experience

## Quick Start Guide

### Setup
1. Clone the repository
2. Run `flutter pub get`
3. Create `.env` file with required API keys:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key
   OPENWEATHER_API_KEY=your_openweather_api_key
   ```
4. Run `flutter run`

### Supabase CLI
For local development and migrations:
```bash
# Install Supabase CLI
npm install -g supabase

# Login
supabase login

# Initialize project
supabase init

# Start local development
supabase start

# Create a migration
supabase migration new create_tables

# Apply migrations
supabase db push

# Generate TypeScript types
supabase gen types typescript --local > lib/types/supabase.ts
```

### Troubleshooting
1. **Authentication issues**:
   - Verify Supabase URL and anon key
   - Check for proper redirects in OAuth flows
   - Validate RLS policies

2. **Database query issues**:
   - Check for proper column names
   - Verify RLS policies allow the operation
   - Test queries in Supabase dashboard

3. **Real-time issues**:
   - Verify table has `REPLICA IDENTITY FULL`
   - Check subscription format
   - Test with Supabase dashboard

## Support
- GitHub Issues
- Supabase Discord community
- Documentation
- Community forums
- Email support

## Technical Resources
- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart/installing)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Flutter Documentation](https://docs.flutter.dev/)