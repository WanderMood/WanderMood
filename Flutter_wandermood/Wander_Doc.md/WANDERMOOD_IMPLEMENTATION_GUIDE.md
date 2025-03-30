# WanderMood - Implementatie Document

> Een AI-gedreven reisapplicatie die reisaanbevelingen personaliseert op basis van stemming en voorkeuren.

## 1. Technische Specificaties

### 1.1 Ontwikkelomgeving
- Flutter SDK: laatste stabiele versie
- Dart: 3.x
- Minimum OS versies:
  - iOS: 13.0+
  - Android: API level 23 (Android 6.0)+
- IDE: VS Code / Android Studio

### 1.2 Architectuur
- **Frontend**: Flutter met Clean Architecture
  - Presentation Layer
  - Domain Layer
  - Data Layer
- **Backend**: Supabase
  - Real-time Database
  - Authentication
  - Storage
  - Edge Functions
- **State Management**: Riverpod
- **Database**: PostgreSQL (via Supabase)
- **Authentication**: Supabase Auth

## 2. Project Structuur

```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── auth/
│   ├── mood_tracking/
│   ├── recommendations/
│   ├── weather/
│   ├── social/
│   └── booking/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── domain/
│   ├── entities/
│   └── repositories/
└── presentation/
    ├── screens/
    ├── widgets/
    └── controllers/
```

## 3. Core Features Implementatie

### 3.1 Authenticatie Module (Supabase Auth)
```dart
// Belangrijkste klassen:
- SupabaseAuthRepository
- UserEntity
- AuthenticationController
- LoginScreen
- RegisterScreen
```

### 3.2 Stemmings Module
```dart
// Kern componenten:
- MoodTrackingRepository
- MoodEntity
- MoodController
- MoodSelectionScreen
- MoodHistoryScreen
```

### 3.3 Aanbevelingen Engine
```dart
// Hoofdcomponenten:
- RecommendationService
- PlaceEntity
- RecommendationController
- RecommendationsScreen
```

### 3.4 Locatie & Explore Module
```dart
// Kern componenten:
- LocationService
- PlacesService
- LocationSelector
- ExploreScreen
```

#### Locatie Default Instellingen
De standaard locatie van de applicatie is gewijzigd van San Francisco naar Rotterdam:

```dart
// Default locatie configuratie in LocationService
final Map<String, dynamic> defaultLocation = {
  'latitude': 51.9244,  // Rotterdam coördinaten
  'longitude': 4.4777,
  'name': 'Rotterdam'
};

// LocationSelector fallback
final rotterdamLocation = Location(
  id: 'rotterdam',
  latitude: 51.9244,
  longitude: 4.4777,
  name: 'Rotterdam'
);

// Explore screen kaarten
Alle attractiekaarten zijn geüpdatet om Rotterdam te weerspiegelen als hoofdlocatie
```

## 4. Database Schema (PostgreSQL)

### 4.1 Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  display_name TEXT,
  preferences JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 4.2 Moods Table
```sql
CREATE TABLE moods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  mood_type TEXT NOT NULL,
  intensity INTEGER CHECK (intensity BETWEEN 1 AND 10),
  notes TEXT,
  weather JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 4.3 Places Table
```sql
CREATE TABLE places (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  location POINT NOT NULL,
  mood_tags TEXT[],
  weather_suitability TEXT[],
  activities TEXT[],
  photos TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 5. API Integraties

### 5.1 Supabase Setup
```dart
dependencies:
  supabase_flutter: ^latest_version
  
// Initialisatie
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

### 5.2 Weer API
- OpenWeatherMap API
- Endpoints voor:
  - Huidige weer
  - Weersvoorspelling
  - Historische weerdata

### 5.3 Places API
- Google Places API
- Foursquare API
- Endpoints voor:
  - Locatie zoeken
  - Place details
  - Foto's
  - Reviews

## 6. UI/UX Specificaties

### 6.1 Kleurenschema
```dart
// Primaire kleuren
primary: #5C6BC0
secondary: #81C784
accent: #FFB74D

// Stemmingskleuren
happy: #FFD700
relaxed: #98FB98
energetic: #FF4500
melancholic: #4682B4
```

### 6.2 Typografie
```dart
// Font families
headings: 'Poppins'
body: 'Roboto'

// Font sizes
h1: 24.0
h2: 20.0
body: 16.0
caption: 14.0
```

## 7. Security Maatregelen

### 7.1 Supabase Security
- Row Level Security (RLS) Policies
```sql
-- Voorbeeld RLS voor users tabel
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only view their own data"
ON users FOR SELECT
USING (auth.uid() = id);
```

### 7.2 API Security
- API key beveiliging in .env files
- Rate limiting via Supabase Edge Functions
- Data encryptie voor gevoelige informatie

## 8. Testing Strategie

### 8.1 Unit Tests
```dart
// Voorbeeld test structuur
test('MoodRepository should save mood', () async {
  final repository = MoodRepository(supabase);
  // Test implementatie
});
```

### 8.2 Widget Tests
- Core widgets
- Screen widgets
- Custom components

### 8.3 Integration Tests
- User flows
- API integraties
- Database operaties

## 9. Performance Optimalisatie

### 9.1 Caching Strategie
- Lokale database met Hive
- Supabase offline caching
- Image caching

### 9.2 Lazy Loading
- Infinite scroll voor lijsten
- Image lazy loading
- On-demand data fetching

## 10. Deployment Pipeline

### 10.1 Development
- GitHub voor versiebeheer
- GitHub Actions voor CI/CD
- Automated testing

### 10.2 Release Proces
- Beta testing via TestFlight/Internal Testing
- Staged rollouts
- Automated versioning

---

*Laatste update: [Huidige Datum]*

## Contact
Voor vragen over de implementatie, neem contact op met het ontwikkelteam. 