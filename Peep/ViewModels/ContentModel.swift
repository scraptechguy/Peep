//
//  ContentModel.swift
//  Peep
//
//  Created by Rostislav Brož on 8/8/22.
//

import Foundation
import SwiftUI
import Combine
import CoreLocation
import MapKit

/// Root app state for map/location features and UI coordination.
/// Owns a single shared `MKMapView` (so UIKit delegates are centralized) and
/// exposes published properties that SwiftUI views bind to.
class ContentModel: NSObject, CLLocationManagerDelegate, MKMapViewDelegate, ObservableObject {
    // MARK: - Persisted user defaults (survive app restarts)
    
    /// Whether onboarding has been shown before; prevents repeated display.
    @AppStorage("didShowOnboarding") var didShowOnboarding = false
    
    /// User's preference for light/dark mode toggle.
    @AppStorage("isLightMode") var isLightMode = false
    
    
    // MARK: - App/UI state (in-memory)
    /// `true` once initial database/data loading completes.
    @Published var finishedLoading = false
    
    /// `true` once the map has centered on the user's region for the first time.
    @Published var initialRegionCentered = false
    
    /// Tracks whether a long-press gesture has occurred (used for gestures in UI).
    @Published var didLongPressed = false
    
    /// Current height of the bottom sheet.
    @Published var currentHeight: CGFloat = UIScreen.main.bounds.height / 11
    
    /// Shows the gallery overlay.
    @Published var showingGallery = false
    
    /// Shows the settings screen.
    @Published var showingSettings = false
    
    /// Shows the search overlay.
    @Published var showingSearch = false
    
    /// Tracks if the search keyboard is focused.
    @Published var searchKeyboardIsFocused = false
    
    /// Shows the directions panel/map route UI.
    @Published var showingDirections = false
    
    /// Shows the sundial type detail view.
    @Published var showingType = false
    
    /// Shows the sundial pointer detail view.
    @Published var showingPointer = false
    
    /// Shows the sundial dial detail view.
    @Published var showingDial = false
    
    /// Shows the sundial state detail view.
    @Published var showingState = false
    
    /// Index to open the right image after clicking one in a smaller image scroll view.
    @Published var index: Int = 0
    
    /// `true` to trigger a search after the user clicks on a search result and visible map region changes.
    @Published var shouldSearchAfterRegionChange = false
    
    /// Holds a place (clicked search result) to be selected after the user clicks on it and visible map region changes (e.g., pending UI state).
    @Published var pendingSelectionPlace: DataModel?
    
    /// `true` if an annotation is selected on the map.
    @Published var annotationSelected = false
    
    /// Signals that all map annotations should be deselected.
    @Published var shouldDeselectAnnotations = false
    
    /// Triggers a programmatic jump to the user's location.
    @Published var goToLocation = false
    
    /// `true` if the current map center is near the user’s location.
    @Published var isOnLocation = true
    
    /// Holds information about the heading of the map.
    @Published var mapHeading: CLLocationDirection = 0
    
    /// Tells the coordinator to re-check whether the map is centered on the user.
    @Published var shouldCheckIsOnLocation = false
    
    /// `true` when the user taps “locate me” but location permissions are off.
    @Published var didClickOnLocationButtonWhenLocationOff = false
    
    /// Full list of places available for searching (from database or cache).
    @Published var searchablePlaces: [DataModel] = []
    
    
    // MARK: - Location
    
    /// Shared MKMapView instance for the app (keeps delegate work centralized).
    @Published var mapView: MKMapView
    
    /// Core Location manager for permissions and updates.
    @Published var locationManager: CLLocationManager
    
    /// Current location authorization state.
    @Published var authorizationState: CLAuthorizationStatus = .notDetermined
    
    /// Reverse-geocoded placemark for the user’s location.
    @Published var placemark: CLPlacemark?
    
    
    // MARK: - Init
        
    /// Creates a new `ContentModel` and loads any cached searchable places.
    /// - Note: `mapView` and `locationManager` delegates are set here.
    override init() {
        // precondition(Thread.isMainThread, "ContentModel must be initialized on the main thread")
        self.mapView = MKMapView()
        self.locationManager = CLLocationManager()
        
        super.init()
        
        self.authorizationState = self.locationManager.authorizationStatus
        
        self.mapView.delegate = self
        self.locationManager.delegate = self
        
        loadCachedSearchablePlaces()
    }
    
    
    // MARK: - Permissions
    
    /// Requests location permission from the user.
    /// - Important: Call from the UI layer in response to user action.
    func requestGeolocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    
    // MARK: - Location Manager Delegate Methods
    
    /// Called when location permission changes.
    /// - Updates `authorizationState`.
    /// - Starts location updates if allowed.
    /// - Marks onboarding as shown once a decision is made.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationState = locationManager.authorizationStatus
        
        DispatchQueue.main.async {
            if self.locationManager.authorizationStatus == .authorizedAlways || self.locationManager.authorizationStatus == .authorizedWhenInUse {
                self.locationManager.startUpdatingLocation()
                self.didShowOnboarding = true
            } else if self.locationManager.authorizationStatus == .denied {
                self.didShowOnboarding = true
            }
        }
    }
    
    /// Called when the location manager delivers location updates.
    /// - Sets `initialRegionCentered` so the map can center only once.
    /// - Stops continuous location updates to save battery.
    /// - Reverse-geocodes the location into `placemark` for localized search defaults.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.first
        
        if userLocation != nil {
            // Mark that the map is centered
            DispatchQueue.main.async {
                self.initialRegionCentered = true
            }
            
            // Stop updating location after received once
            locationManager.stopUpdatingLocation()
            
            // Reverse geocode to get user’s city/locality for search defaults
            let geoCoder = CLGeocoder()
            let locale = Locale.current
            geoCoder.reverseGeocodeLocation(userLocation!, preferredLocale: locale) { placemarks, error in
                guard let pm = placemarks?.first, error == nil else { return }
                self.placemark = pm
            }
        }
    }
    
    
    // MARK: – Cache Management
    
    /// Lazily creates (if needed) and returns the cache directory URL for Peep’s data.
    private lazy var cacheDir: URL = {
        let fm = FileManager.default
        
        // Get the system Caches directory for your sandbox:
        let caches = fm.urls(for: .cachesDirectory, in: .userDomainMask).first!
        
        // Append a new folder name:
        let dir = caches.appendingPathComponent("PeepCache", isDirectory: true)
        
        // Create it if it doesn’t exist:
        if !fm.fileExists(atPath: dir.path) {
            do {
                try fm.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
                
                #if DEBUG
                print("Created PeepCache at:", dir.path)
                #endif
            } catch {
                #if DEBUG
                print("Failed to create PeepCache:", error)
                #endif
            }
        }
        
        return dir
    }()
    
    /// File path for the `searchablePlaces` JSON cache.
    private var cacheURL: URL {
        cacheDir.appendingPathComponent("searchablePlaces.json")
    }
    
    /// Loads cached `DataModel` places from disk into `searchablePlaces`, if present.
    /// - Prints diagnostics in DEBUG mode if the cache is missing or corrupt.
    func loadCachedSearchablePlaces() {
        let path = cacheURL.path
        
        guard FileManager.default.fileExists(atPath: path) else {
            // No cache file, that’s fine on first launch
            #if DEBUG
            print("No cache file at \(path).")
            #endif
            
            return
        }
        
        do {
            let raw = try Data(contentsOf: cacheURL)
            searchablePlaces = try JSONDecoder().decode([DataModel].self, from: raw)
            
            #if DEBUG
            print("Loaded \(searchablePlaces.count) places from cache")
            #endif
        }
        catch {
            // If file doesn’t exist or decode fails, just start empty
            #if DEBUG
            print("No cache to load or failed decode:", error)
            #endif
        }
    }
    
    /// Writes the current `searchablePlaces` array to disk on a background queue.
    /// - Uses `.atomic` to prevent partial writes.
    func persistSearchablePlaces() {
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try JSONEncoder().encode(self.searchablePlaces)
                try data.write(to: self.cacheURL, options: .atomic)
                
                #if DEBUG
                print("Persisted \(self.searchablePlaces.count) places to cache")
                #endif
            } catch {
                #if DEBUG
                print("Failed to write cache:", error)
                #endif
            }
        }
    }
    
    /// Updates `searchablePlaces` from a `FetchData` instance and persists them.
    /// - Parameter fetcher: The `FetchData` instance containing fresh places.
    /// - Runs encoding/writing in the background.
    func loadSearchablePlaces(from fetcher: FetchData) {
        DispatchQueue.global(qos: .background).async {
            let places = fetcher.dataList   // grab full models
            DispatchQueue.main.async {
                self.searchablePlaces = places
                self.persistSearchablePlaces()
            }
        }
    }
}
