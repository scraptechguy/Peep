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

class ContentModel: NSObject, CLLocationManagerDelegate, MKMapViewDelegate, ObservableObject {
    // Define a Codable “hit” type for annotations
    struct AnnotationHit: Codable {
        let key: String
        let latitude: Double
        let longitude: Double
        let title: String?
    }
    
    // MARK: - State vars
    
    @AppStorage("didShowOnboarding") var didShowOnboarding = false
    @AppStorage("isLightMode") var isLightMode = false
    
    @Published var finishedLoading = false
    @Published var initialRegionCentered = false
    @Published var didLongPressed = false
    
    @Published var currentHeight: CGFloat = UIScreen.main.bounds.height / 11
    @Published var showingGallery = false
    @Published var showingSettings = false
    @Published var showingSearch = false
    @Published var searchKeyboardIsFocused = false
    @Published var showingDirections = false
    @Published var showingType = false
    @Published var showingPointer = false
    @Published var showingDial = false
    @Published var showingState = false
    @Published var index: Int = 0
    
    @Published var shouldShowAreaSearchButton = false
    @Published var shouldSearchAfterRegionChange = false
    @Published var pendingSelectionPlace: DataModel?
    @Published var annotationSelected = false
    @Published var shouldDeselectAnnotations = false
    @Published var previousSpan = MKCoordinateSpan.init(latitudeDelta: 2, longitudeDelta: 2)
    @Published var previousCoordinate = CLLocationCoordinate2D.init(latitude: 0, longitude: 0)
    @Published var goToLocation = false
    @Published var isOnLocation = true
    @Published var shouldCheckIsOnLocation = false
    @Published var didClickOnLocationButtonWhenLocationOff = false
    
    @Published var searchablePlaces: [DataModel] = []
    
    // MARK: - Location
    
    @Published var mapView: MKMapView
    @Published var locationManager: CLLocationManager
    
    @Published var authorizationState: CLAuthorizationStatus = .notDetermined
    @Published var placemark: CLPlacemark?
    
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
    
    // Request permission
    func requestGeolocationPermission() {
        
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    // MARK - Location Manager Delegate Methods
    
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.first
        
        if userLocation != nil {
            
            DispatchQueue.main.async {
                self.initialRegionCentered = true
            }
            
            // Stop updating location after received once
            locationManager.stopUpdatingLocation()
            
            // Get the placemark of the user
            let geoCoder = CLGeocoder()
            let locale = Locale.current
            geoCoder.reverseGeocodeLocation(userLocation!, preferredLocale: locale) { placemarks, error in
                guard let pm = placemarks?.first, error == nil else { return }
                self.placemark = pm
            }
            
        }
        
    }
    
    // MARK: – Cache places
    
    // Build (and create) cache folder at runtime
    private lazy var cacheDir: URL = {
        let fm = FileManager.default
        
        // a) Get the system Caches directory for your sandbox:
        let caches = fm.urls(for: .cachesDirectory, in: .userDomainMask).first!
        
        // b) Append your own folder name:
        let dir = caches.appendingPathComponent("PeepCache", isDirectory: true)
        
        // c) Create it if it doesn’t exist:
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
    
    // File URL in Application Support
    private var cacheURL: URL {
        cacheDir.appendingPathComponent("searchablePlaces.json")
    }
    
    // Load cached DataModels from disk (if any)
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
    
    // Persist current DataModels out to disk
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
    
    // Populate from your FetchData, then persist
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
