# WanderMood 🌈

WanderMood is an AI-driven travel companion that personalizes your travel recommendations based on your mood and preferences. The app helps you discover amazing places and experiences that match your current state of mind.

## Features ✨

- **Mood-based Recommendations**: Get personalized travel suggestions based on how you're feeling
- **Interest Matching**: Find places and activities that align with your interests
- **Location-aware**: Discover nearby attractions and hidden gems
- **Smart Planning**: AI-powered trip planning that adapts to your preferences
- **Social Sharing**: Connect with other travelers and share experiences

## Tech Stack 🛠️

- **Frontend**: Flutter
- **Backend**: Supabase
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Authentication**: Supabase Auth
- **Database**: PostgreSQL (Supabase)
- **Storage**: Supabase Storage
- **APIs**:
  - Google Places API
  - Google Maps API
  - OpenWeatherMap API

## Getting Started 🚀

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- VS Code or Android Studio
- Git

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/wandermood.git
   cd wandermood
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Create a `.env` file in the root directory and add your API keys:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure 📁

```
lib/
├── core/
│   ├── config/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── storage/
│   ├── theme/
│   └── widgets/
├── features/
│   ├── auth/
│   ├── home/
│   ├── onboarding/
│   ├── profile/
│   ├── shared/
│   └── trips/
└── utils/
```

## Contributing 🤝

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License 📝

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments 🙏

- Thanks to all contributors who have helped shape WanderMood
- Special thanks to the Flutter and Supabase communities for their amazing tools and support
