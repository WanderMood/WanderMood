import Flutter
import UIKit
import GoogleMaps
import CoreLocation

@main
@objc class AppDelegate: FlutterAppDelegate, CLLocationManagerDelegate {
  private let locationManager = CLLocationManager()
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyD1xeHw0QC09VLZjp1oxtb03UOohQJcOEM")
    
    // Setup location services for iOS 18 compatibility
    locationManager.delegate = self
    
    // Register plugins
    GeneratedPluginRegistrant.register(with: self)
    
    // Set custom user agent for iOS 18+ compatibility with web services
    if let userDefaults = UserDefaults(suiteName: "group.wandermood.app") {
      userDefaults.register(defaults: ["UserAgent": "WanderMood-iOS/1.0"])
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // MARK: - CLLocationManagerDelegate
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    // Handle authorization changes appropriately for iOS 14+
    let status = manager.authorizationStatus
    if status == .notDetermined {
      manager.requestWhenInUseAuthorization()
    }
  }
}
