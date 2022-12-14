//
//  ContentModel.swift
//  Peep
//
//  Created by Rostislav Brož on 8/8/22.
//

import Foundation
import SwiftUI
import CoreLocation
import MapKit

class ContentModel: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    // MARK: - State vars
    
    @AppStorage("devLogOn") var devLogOn = false
    @AppStorage("isLightMode") var isLightMode = false
    @AppStorage("useOfflineDatabase") var useOfflineDatabase = false
    @AppStorage("latlogDelta") var latlongDelta: Double = 0.15
    
    @Published var finishedLoading = false
    
    @Published var devLog = "Launching the app"
    @Published var didLongPressed = false
    
    @Published var currentHeight: CGFloat = UIScreen.main.bounds.height / 10.2
    @Published var showingGallery = false
    @Published var showingSettings = false
    @Published var showingDirections = false
    @Published var showingType = false
    @Published var showingPointer = false
    @Published var showingDial = false
    @Published var showingState = false
    @Published var index: Int = 0
    
    @Published var annotationSelected = false
    @Published var previousSpan = MKCoordinateSpan.init(latitudeDelta: 2, longitudeDelta: 2)
    @Published var previousCoordinate = CLLocationCoordinate2D.init(latitude: 0, longitude: 0)
    @Published var goToLocation = false
    @Published var isOnLocation = true
    
    // MARK: - Location
    
    var locationManager = CLLocationManager()

    @Published var authorizationState = CLAuthorizationStatus.notDetermined
    @Published var placemark: CLPlacemark?
    
    override init() {
        
        // Init method of NSObject
        super.init()
        
        // Make ContentModel the delegate of the location manager
        locationManager.delegate = self
        
    }
    
    // Request permission
    func requestGeolocationPermission() {
        
        locationManager.requestWhenInUseAuthorization()
        
    }
    
    // MARK - Location Manager Delegate Methods
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        authorizationState = locationManager.authorizationStatus
        
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            
            locationManager.startUpdatingLocation()
            
        } else if locationManager.authorizationStatus == .denied {
            
            
            
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
}
