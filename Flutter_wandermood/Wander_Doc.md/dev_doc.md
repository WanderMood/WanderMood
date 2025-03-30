# WanderMood Development Documentation

## Project Overview
WanderMood is an AI-driven travel application that personalizes travel recommendations based on user moods and provides weather-adaptive suggestions.

## Technical Stack
- **Frontend**: Flutter (latest stable version)
- **Backend**: Supabase
- **Database**: PostgreSQL
- **State Management**: Riverpod
- **Animation**: flutter_animate
- **Testing**: Flutter Test, Mocktail
- **CI/CD**: GitHub Actions

## Architecture
### Frontend Architecture
- **Feature-first structure**
  - `/lib/features/` - Feature modules
  - `/lib/core/` - Shared functionality
  - `/lib/shared/` - UI components and utilities

### State Management
- Riverpod for dependency injection and state management
- Freezed for immutable state classes
- AsyncValue for managing asynchronous states

### Backend Configuration
#### Supabase Setup
- Project URL: `asxaybzfkslzbsqmpbjd.supabase.co`
- Authentication: JWT-based with anonymous key
- Real-time connections enabled
- Row Level Security (RLS) implemented
- Network Configuration:
  - IPv6 CIDR: `::/0` (all IPv6 addresses allowed)
  - IPv4 CIDR: `0.0.0.0/0` (all IPv4 addresses allowed)

#### Known Issues
- DNS Resolution: Currently experiencing DNS resolution issues in iOS simulators
- Workarounds implemented:
  - Retry mechanism with timeout for authentication
  - Manual DNS configuration in simulators (Google DNS: 8.8.8.8, 8.8.4.4)
  - Network restrictions adjusted in Supabase dashboard

#### Next Steps
1. Verify Supabase project status and credentials
2. Consider implementing IPv4 add-on if DNS issues persist
3. Implement proper error handling for network-related issues
4. Add network connectivity monitoring

### Data Layer
#### Supabase Integration
- Real-time database connections
- Row Level Security (RLS)
- Edge Functions for complex operations

## Features
### Mood Tracking
- [x] Basic CRUD operations for moods
- [x] Real-time updates
- [x] Mood statistics
- [x] Activity linking
- [x] Date filtering
- [ ] AI-driven analysis
- [ ] Weather correlation

### Activities
- [x] Predefined activities
- [x] Custom activities
- [x] Activity categories
- [ ] Activity recommendations

### Voice & Search Capabilities
- [x] Voice search in the Explore screen with mic icon
- [x] Voice commands for sorting in Trending Destinations
- [x] Animated microphone feedback (pulsing rings)
- [x] Visual feedback during listening state (red mic icon)
- [x] Search query execution on Enter key press 
- [x] Auto-scroll to matching results when searching
- [x] Result confirmation via SnackBar notifications
- [x] Smart filtering of results based on search terms
- [x] Category auto-selection based on search query
- [x] Smooth scroll animations to matched destinations

### Booking System
- [x] Ticket booking interface with date selection
- [x] Multiple ticket type options (Basic, Guided, VIP)
- [x] Quantity selector for number of tickets
- [x] Total price calculation
- [x] External booking site integration (redirects to partners)
- [x] Booking confirmation flow
- [x] QR code/Ticket barcode display on confirmation screen
- [ ] Supabase integration for booking records
- [ ] User booking history

### Explore Screen Updates
- [x] Redesigned header with "Explore" title on the left and location selector on the right
- [x] Search bar relocated below the header
- [x] Category filters updated with Rotterdam-specific categories
- [x] "Hot Picks" renamed to "🔥 Trending" with emoji indicator
- [x] Added 10 Rotterdam attractions including:
  - Hotel New York
  - Euromast Experience
  - Markthal Rotterdam
  - SS Rotterdam
  - Cube Houses
  - Erasmusbrug
  - Rotterdam Zoo
  - Kunsthal
  - Fenix Food Factory
  - Het Park
- [x] Default location changed from San Francisco to Rotterdam
- [x] Added location details to attraction cards
- [x] Improved UI with consistent spacing and typography
- [x] Enhanced search functionality:
  - Dynamic search autocomplete with real-time filtering
  - Limited to 3 recent searches for improved focus
  - Only 3 suggested searches displayed at a time
  - Text matching highlight in green to show relevance
  - Integration with Google Places API for location-based results
  - Voice search capability with visual feedback
  - Updated search bar text to "Find hidden gems, vibes & bites...✨"
  - Search result confirmation via SnackBar notifications
- [x] Enhanced destination cards UI:
  - Semi-transparent cards with gradient overlay for better readability
  - Red heart icon toggle for favoriting places
  - Simplified location display with city name and country flag emoji
  - Added price range indicators (€, €€, €€€)
  - Added opening hours badges for each destination
  - Dynamic location updates based on city selection
  - Improved visual feedback for user interactions

### Weather Integration
- [ ] Weather API integration
- [ ] Weather-based suggestions
- [ ] Historical weather data analysis

## Database Schema
### Moods Table
```sql
CREATE TABLE moods (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  label VARCHAR NOT NULL,
  emoji VARCHAR,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  note TEXT,
  energy_level FLOAT,
  activities TEXT[],
  is_shared BOOLEAN DEFAULT FALSE,
  weather_data JSONB
);
```

### Activities Table
```sql
CREATE TABLE activities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR NOT NULL,
  emoji VARCHAR,
  category VARCHAR,
  description TEXT,
  is_custom BOOLEAN DEFAULT FALSE,
  last_used TIMESTAMP WITH TIME ZONE
);
```

### Places Table
```sql
CREATE TABLE places (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR NOT NULL,
  description TEXT,
  location POINT NOT NULL,
  address TEXT,
  city VARCHAR NOT NULL,
  country VARCHAR NOT NULL,
  images TEXT[],
  category VARCHAR,
  rating FLOAT,
  price_level INTEGER,
  tags TEXT[],
  booking_options JSONB,
  opening_hours JSONB,
  is_favorite BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Bookings Table
```sql
CREATE TABLE bookings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users NOT NULL,
  place_id UUID REFERENCES places(id) NOT NULL,
  booking_date DATE NOT NULL,
  quantity INTEGER NOT NULL,
  option_type VARCHAR NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  status VARCHAR NOT NULL,
  payment_id VARCHAR,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## Testing
### Unit Tests
- [x] Repository tests
- [x] Service tests
- [x] State management tests
- [ ] Model tests

### Widget Tests
- [x] Basic app rendering
- [x] Loading states
- [x] Error handling
- [x] Mood list display
- [x] Mood add/remove
- [x] Date filter functionality
- [ ] Activity selection
- [ ] Weather widget tests
- [ ] Booking interface tests
- [ ] Voice search functionality tests
- [ ] Search result navigation tests

### Integration Tests
- [ ] End-to-end flow tests
- [ ] API integration tests
- [ ] Offline functionality

## Security
- [x] Supabase authentication
- [x] Row Level Security policies
- [ ] API key management
- [ ] Data encryption

## Performance
### Optimizations
- [x] Smooth animations for microphone feedback
- [x] Optimized search result navigation
- [x] Semi-transparent UI elements for better visual hierarchy
- [x] Efficient state management with Riverpod provider families
- [x] Dynamic data loading based on location selection
- [ ] Lazy loading for historical data
- [ ] Caching strategy
- [ ] Image optimization
- [ ] Offline first architecture

## Supabase Integration
### Authentication
- [x] JWT-based authentication
- [x] Anonymous authentication support
- [x] Social login providers (Google, Apple)
- [x] Password reset functionality
- [x] Session management

### Database
- [x] PostgreSQL tables with RLS policies
- [x] Real-time subscriptions for data updates
- [x] Optimized query performance
- [x] JSON/JSONB support for complex data structures

### Storage
- [x] Image upload and management
- [x] Secure file access control
- [x] CDN distribution for faster loading

### Edge Functions
- [ ] Serverless function implementation
- [ ] Webhook integrations
- [ ] Scheduled jobs

## Recent Updates
### City-Based Content
- [x] Trending destinations now filtered by selected city
- [x] Dynamic provider invalidation on location change
- [x] Adapted UI elements to reflect current location
- [x] Improved provider architecture with parameter support

### UI Enhancements
- [x] Consistent use of semi-transparent cards for better visual hierarchy
- [x] Interactive favorite buttons with color change feedback
- [x] Simplified address display with country flag emojis
- [x] Price range indicators to help users make informed decisions
- [x] Opening hours badges for improved user planning
- [x] Visual feedback for user interactions

## Deployment
- [ ] CI/CD pipeline setup
- [ ] Automated tests in pipeline
- [ ] Staging environment
- [ ] Production deployment checklist

## TODO
### High Priority
1. Integrate weather data with Supabase
2. Implement proper error handling for network requests
3. Add network connectivity monitoring
4. Setup CI/CD pipeline for automated testing
5. Complete booking system integration with Supabase
6. Enhance offline capabilities with local storage
7. Optimize image loading and caching

### Medium Priority
1. Add offline functionality
2. Implement caching strategy
3. Add more widget tests
4. Implement end-to-end tests
5. Add proper voice recognition integration

### Low Priority
1. Add analytics
2. Implement deep linking
3. Add more animations
4. Improve error messaging

## Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^1.14.0
  riverpod: ^2.4.9
  flutter_riverpod: ^2.4.9
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  connectivity_plus: ^5.0.2  # For network monitoring
  google_maps_webservice: ^0.0.20  # For Google Places API integration
  geolocator: ^10.1.0  # For user location services
  geocoding: ^2.1.1  # For converting coordinates to addresses
  http: ^1.1.2  # For API requests
  intl: ^0.18.1  # For date formatting
  url_launcher: ^6.2.2  # For launching external URLs
  google_fonts: ^6.1.0  # For custom typography
  flutter_animate: ^4.5.0  # For smooth animations
  simple_animations: ^5.0.2  # For custom animation effects
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.7
  freezed: ^2.4.5
  json_serializable: ^6.7.1
  mocktail: ^1.0.1
```

## Environment Variables
```
SUPABASE_URL=https://asxaybzfkslzbsqmpbjd.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFzeGF5Ynpma3NsemJzcW1wYmpkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIzOTQ1NzYsImV4cCI6MjA1Nzk3MDU3Nn0.dTKzBLI_-kNAAkPFf8_MCvB5lUmwpuwjxJHYZsUYJKM
OPENWEATHERMAP_API_KEY=your_openweathermap_key
GOOGLE_PLACES_API_KEY=your_google_places_key  # Required for location search and autocomplete
FOURSQUARE_API_KEY=your_foursquare_key 
```

## Contributing
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## Development Phases

### Phase 1: Basic Implementation (Completed)
- [x] Project setup and architecture
- [x] Basic CRUD operations for moods
- [x] Authentication with Supabase
- [x] Basic UI components
- [x] Unit and widget tests

### Phase 2: UI Enhancement & Search Features (Completed)
- [x] Redesigned Explore screen
- [x] Enhanced search functionality with highlighting
- [x] Voice search implementation with animations
- [x] Booking confirmation screen with QR code
- [x] Location-based search with Google Places API

### Phase 3: Network & Error Handling (Current)
#### In Development
- [ ] Network Connectivity
  - Implement connectivity monitoring
  - Add offline mode support
  - Implement retry mechanisms
  
- [ ] Error Handling
  - Network error handling
  - DNS resolution fixes
  - User-friendly error messages

#### Technical Tasks
1. Network Monitoring Service
   ```dart
   class NetworkService {
     Stream<bool> get connectivityStream;
     Future<bool> checkConnectivity();
     Future<bool> checkSupabaseConnection();
   }
   ```

2. Error Handling Service
   ```dart
   class ErrorHandlingService {
     Future<void> handleNetworkError(Exception error);
     Future<void> handleAuthError(AuthException error);
     Future<void> handleDatabaseError(PostgrestException error);
   }
   ```

3. Retry Mechanism
   ```dart
   class RetryService {
     Future<T> withRetry<T>({
       required Future<T> Function() operation,
       int maxAttempts = 3,
       Duration delay = const Duration(seconds: 2),
     });
   }
   ```

4. Search Service Implementation
   ```dart
   class SearchService {
     // Search data management
     final TextEditingController searchController;
     final List<String> recentSearches; // Limited to 3 items
     final List<String> searchSuggestions;
     List<String> filteredSuggestions = [];
     bool showSearchSuggestions = false;
     
     // Search functionality
     void onSearchChanged(String query);
     void addToRecentSearches(String search);
     Widget highlightMatches(String text, String query); // For UI highlighting
     void performSearch(String query); // Execute search and navigate to results
     
     // Voice search functionality
     bool isListening = false;
     void startVoiceSearch(); 
     void processVoiceCommand(String recognizedText);
     
     // Places API integration
     Future<List<PlaceDetails>> searchPlaces(String query);
     Future<PlaceDetails> getPlaceDetails(String placeId);
   }
   ```

5. Booking System Implementation
   ```dart
   class BookingService {
     // Booking data management
     Future<List<BookingOption>> getBookingOptions(String placeId);
     Future<bool> createBooking(Booking booking);
     Future<List<Booking>> getUserBookings(String userId);
     
     // External booking integration
     Future<String> getExternalBookingUrl(String placeId, String optionId);
     Future<void> trackBookingRedirect(String placeId, String optionId);
   }
   ```

### Phase 4: Weather & AI Integration (Planned)
- [ ] Weather API integration
- [ ] AI-driven analysis
- [ ] Recommendations engine

### Phase 5: Social Features (Planned)
- [ ] Social interactions
- [ ] Friends system
- [ ] Group activities

### Phase 6: Performance & Polish (Planned)
- [ ] Performance optimizations
- [ ] UI/UX improvements
- [ ] Analytics integration

## Milestone Planning

### Milestone 1: Search & Voice Features (Completed)
- Week 1: Enhanced search UI with highlighting
- Week 2: Voice search implementation with animations
- Week 3: Smart search result navigation and feedback

### Milestone 2: Booking System Implementation (Completed)
- Week 1: Basic booking UI and external redirects
- Week 2: Ticket confirmation screen with QR code

### Milestone 3: Supabase Integration (1 week)
- Week 1: Supabase integration for booking records and user history

### Milestone 4: Weather Integration (2 weeks)
- Week 1: Weather API integration
- Week 2: Weather data visualization and tests

### Milestone 5: AI Features (3 weeks)
- Week 1: AI service implementation
- Week 2: Recommendations engine
- Week 3: Testing and optimization

### Milestone 6: Offline Mode (2 weeks)
- Week 1: Local database setup
- Week 2: Synchronization mechanism

## Performance Metrics
### Goals
- App startup time: < 2 seconds
- API responses: < 500ms
- Animations: 60fps
- Voice search response time: < 1 second
- Offline availability: 100% core functionality
- First contentful paint: < 1 second
- Search results: < 300ms response time
- Supabase query performance: < 200ms

### UI/UX Improvements
- Voice interaction with visual feedback (pulsing animations, color changes)
- Simplified search experience with focused results (3 recent, 3 suggested)
- Visual highlighting of matched text in search results
- Search results navigation with smooth scrolling to matches
- Voice search capability for hands-free interaction
- Location-aware search with Rotterdam as default location
- Clear visual feedback with green highlighting of matches
- Intuitive icons (clock for recent searches, trending for suggestions)
- Expressive search bar text ("Find hidden gems, vibes & bites...✨")
- Smooth booking experience with clear pricing and options
- Search result confirmation via SnackBar notifications

### Monitoring
- Supabase monitoring dashboard
- Custom analytics for user interactions
- Error tracking and reporting
- Google Places API usage tracking
- Voice search usage metrics

## Security Checklist
- [ ] API key rotation system
- [ ] End-to-end encryption for user data
- [ ] Rate limiting for API calls
- [ ] Secure storage for sensitive data
- [ ] Input validation and sanitization
- [ ] Security headers configuration
- [ ] Supabase RLS policies for all tables

## Quality Control
### Code Review Guidelines
- Unit test coverage > 80%
- Widget test coverage > 60%
- Compliance with Flutter best practices
- Performance impact analysis
- Security review for sensitive features

### Documentation
- API documentation with OpenAPI/Swagger
- Internal code documentation
- User guide
- Deployment guide

## Known Issues & Fixes
1. **Material Ancestor Issue in LocationSelector**
   - Problem: TextField in LocationSelector lacks Material ancestor
   - Fix: Add Material widget as parent in the LocationSelector widget

2. **Animation Curve Issue in All Trending Destinations Screen**
   - Problem: No named parameter 'curve' in animate method
   - Fix: Move 'curve' parameter from animate() to scale() method

3. **Range Error in Search Suggestions**
   - Problem: RangeError when accessing filtered suggestions
   - Fix: Check array bounds before accessing elements

## Contact
For questions or suggestions, contact the development team. 

flutter pub run build_runner build --delete-conflicting-outputs 

lib/
├── core/
│   ├── config/
│   ├── database/
│   ├── errors/
│   ├── network/
│   └── utils/
├── features/
│   ├── auth/
│   ├── mood/
│   ├── weather/
│   ├── recommendations/
│   ├── places/
│   ├── booking/
│   └── social/
└── main.dart 

## Moody Character Implementation

### Character Design
The Moody character is implemented as a dynamic, mood-responsive UI element with the following features:

#### Visual Components
- **Base Shape**: Circular design with gradient coloring
- **Facial Features**:
  - Mood-specific eye shapes and expressions
  - Dynamic smile variations
  - Decorative elements (rosy cheeks, sparkles, etc.)
- **Color Palette**:
  - Speaking: Soft blue (0xFF90CAF9)
  - Thinking: Soft purple (0xFFB39DDB)
  - Listening: Soft green (0xFFA5D6A7)
  - Celebrating: Soft orange (0xFFFFCC80)
  - Excited: Soft coral (0xFFFFAB91)
  - Empathizing: Soft pink (0xFFF8BBD0)
  - Relaxed: Soft cyan (0xFF80DEEA)
  - Mindful: Soft violet (0xFFE1BEE7)

#### Animations
1. **Core Animations**:
   - Natural blinking (random intervals)
   - Gentle floating motion
   - Smooth scaling effects
   - Mood-specific bouncing and wiggling

2. **Mood-Specific Animations**:
   - Celebrating/Excited: Bouncy movement with star effects
   - Thinking: Thought bubble animations
   - Mindful: Zen circle ripples
   - Relaxed: Gentle swaying

3. **Interactive Effects**:
   - Hover state sparkles
   - Touch feedback
   - Smooth mood transitions

### Implementation Details

#### Animation Controllers
```dart
_floatController: 2000ms duration, continuous
_blinkController: 150ms duration, random intervals
_bounceController: 500ms duration, mood-dependent
_wiggleController: 300ms duration, mood-dependent
```

#### Mood-Specific Features
1. **Eye Variations**:
   - Excited: Circle with extra highlights
   - Thinking: Rectangular with rounded corners
   - Relaxed: Half-lidded effect
   - Default: Standard circular

2. **Expression Types**:
   - Celebrating: Big smile with teeth
   - Thinking: Thoughtful curved line
   - Empathizing: Gentle caring smile
   - Relaxed: Content expression
   - Mindful: Peaceful line
   
3. **Special Effects**:
   - Rosy cheeks for happy emotions
   - Floating sparkles for excitement
   - Thought bubbles for thinking state
   - Zen circles for mindful state

### Usage Guidelines

To implement the Moody character in a new screen:

```dart
MoodyCharacter(
  size: 120.0,  // Adjustable size
  mood: 'excited',  // Current mood state
  onTap: () => handleTap(),  // Optional tap handler
)
```

### Performance Considerations
- Animations are optimized using `AnimationController`
- Effects are conditionally rendered based on mood
- Smooth transitions between states
- Memory-efficient asset usage

### Future Enhancements
- [ ] Add sound effects for mood changes
- [ ] Implement more complex emotional states
- [ ] Add particle effects for special moods
- [ ] Create mood combination animations
- [ ] Enhance accessibility features