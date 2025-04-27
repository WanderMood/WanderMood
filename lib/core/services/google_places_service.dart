class GooglePlacesService {
  static String getPhotoUrl(String photoReference, int maxWidth) {
    // TODO: Replace with your actual Google Places API key
    const apiKey = 'YOUR_API_KEY';
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=$maxWidth&photo_reference=$photoReference&key=$apiKey';
  }
} 