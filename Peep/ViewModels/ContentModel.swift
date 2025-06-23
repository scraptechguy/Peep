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

class ContentModel: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    // MARK: - State vars
    
    @AppStorage("didShowOnboarding") var didShowOnboarding = false
    @AppStorage("devLogOn") var devLogOn = false
    @AppStorage("isLightMode") var isLightMode = false
    @AppStorage("showCompass") var showCompass: Bool = false
    @AppStorage("useOfflineDatabase") var useOfflineDatabase = false
    @AppStorage("latlogDelta") var latlongDelta: Double = 0.15
    @AppStorage("cachedSearchableAddresses") private var _cachedAddressesData: Data?
    
    @Published var finishedLoading = false
    
    @Published var devLog = "Launching the app"
    @Published var didLongPressed = false
    
    @Published var currentHeight: CGFloat = UIScreen.main.bounds.height / 10.2
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
    
    @Published var annotationSelected = false
    @Published var shouldDeselectAnnotations = false
    @Published var previousSpan = MKCoordinateSpan.init(latitudeDelta: 2, longitudeDelta: 2)
    @Published var previousCoordinate = CLLocationCoordinate2D.init(latitude: 0, longitude: 0)
    @Published var goToLocation = false
    @Published var isOnLocation = true
    @Published var shouldCheckIsOnLocation = false
    @Published var didClickOnLocationButtonWhenLocationOff = false
    
    @Published var compassOffset: CGFloat = 0
    @Published var locationButtonSize: CGFloat = 0
    
    @Published var searchableAddresses: [String] = []
    
    // MARK: - Location
    
    var locationManager = CLLocationManager()

    @Published var authorizationState: CLAuthorizationStatus
    @Published var placemark: CLPlacemark?
    
    override init() {
        self.authorizationState = locationManager.authorizationStatus
        
        // Init method of NSObject
        super.init()
        
        // Make ContentModel the delegate of the location manager
        locationManager.delegate = self
        loadCachedSearchableAddresses()
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
            
            // Stop updating location after received once
            locationManager.stopUpdatingLocation()
            
            // Get the placemark of the user
            let geoCoder = CLGeocoder()
            
            geoCoder.reverseGeocodeLocation(userLocation!) { (placemarks, error) in
                
                // Check for errors
                if error == nil && placemarks != nil {
                    
                    self.placemark = placemarks?.first
                    
                }
            }
            
        }
        
    }
    
    // Load the last-saved addresses from disk into memory
    func loadCachedSearchableAddresses() {
        guard let data = _cachedAddressesData else { return }
        if let addresses = try? JSONDecoder().decode([String].self, from: data) {
            searchableAddresses = addresses
        }
    }

    // Save current in-memory addresses out to disk
    func persistSearchableAddresses() {
        if let data = try? JSONEncoder().encode(searchableAddresses) {
            _cachedAddressesData = data
        }
    }

    // Populate from your FetchData and then persist
    func loadSearchableAddresses(from data: FetchData) {
        DispatchQueue.global(qos: .background).async {
            let addresses = data.dataList.compactMap { $0.adresa }
            DispatchQueue.main.async {
                self.searchableAddresses = addresses
                self.persistSearchableAddresses()
            }
        }
    }
}
