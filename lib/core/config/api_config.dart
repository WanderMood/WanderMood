class ApiConfig {
  // Get a free API key from: https://home.openweathermap.org/api_keys
  static const String openWeatherMapKey = 'e7f5d9e5c6c9c0c6c9c0c6c9c0c6c9c0'; // New API key
  static const String openWeatherMapBaseUrl = 'https://api.openweathermap.org/data/2.5';
  
  // Weather API endpoints
  static String currentWeatherEndpoint(double lat, double lon) => 
    '$openWeatherMapBaseUrl/weather?lat=$lat&lon=$lon&appid=$openWeatherMapKey&units=metric';
  
  static String forecastEndpoint(double lat, double lon) => 
    '$openWeatherMapBaseUrl/forecast?lat=$lat&lon=$lon&appid=$openWeatherMapKey&units=metric';
    
  static String oneCallEndpoint(double lat, double lon) =>
    'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&appid=$openWeatherMapKey&units=metric&exclude=minutely';
} 