#!/bin/bash

# Create fallbacks directory if it doesn't exist
mkdir -p assets/images/fallbacks

# Download fallback images from Unsplash
curl "https://source.unsplash.com/800x600/?restaurant" -o assets/images/fallbacks/restaurant.jpg
curl "https://source.unsplash.com/800x600/?cafe" -o assets/images/fallbacks/cafe.jpg
curl "https://source.unsplash.com/800x600/?bar" -o assets/images/fallbacks/bar.jpg
curl "https://source.unsplash.com/800x600/?museum" -o assets/images/fallbacks/museum.jpg
curl "https://source.unsplash.com/800x600/?park" -o assets/images/fallbacks/park.jpg
curl "https://source.unsplash.com/800x600/?hotel" -o assets/images/fallbacks/hotel.jpg
curl "https://source.unsplash.com/800x600/?landmark" -o assets/images/fallbacks/default.jpg

echo "✅ Downloaded fallback images successfully" 