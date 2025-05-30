//
//  Map.swift
//  Peep
//
//  Created by Rostislav Brož on 8/8/22.
//

import SwiftUI
import MapKit

struct Map: UIViewRepresentable {
    
    @EnvironmentObject var model: ContentModel
    @ObservedObject var data = FetchData()
    @Binding var selectedPlace: DataModel?
    
    // MARK: - getLocations()
    
    func getLocations(center: CLLocationCoordinate2D) -> [MKPointAnnotation] {
        
        var annotations = [MKPointAnnotation]()
        let annotationSpanIndex: Double = model.latlongDelta * 10 * 0.035
        
        // Loop through all places
        for place in data.dataList {
            if model.searchableAddresses.count < data.dataList.count {
                
                model.searchableAddresses.append(place.adresa ?? "")
                
            }
            
            // If the place does have lat and long, create an annotation
            if let lat = place.zsirka, let long = place.zdelka {
                
                // Create annotations only for places within a certain region
                if Double(lat)! >= center.latitude - annotationSpanIndex && Double(lat)! <= center.latitude + annotationSpanIndex && Double(long)! >= center.longitude - annotationSpanIndex && Double(long)! <= center.longitude + annotationSpanIndex {
                    
                    // Create an annotation
                    let a = MKPointAnnotation()
                    a.coordinate = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(long)!)
                    a.title = place.adresa ?? ""
                    
                    annotations.append(a)
                    
                }
                
            }
        }
        
        return annotations
        
    }
    
    // MARK: - makeUIView()
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: Constants.annotationReusedId)
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "cluster")
        mapView.delegate = context.coordinator
        
        mapView.showsCompass = false // Required to use MKCompassButton manually
        
        // Delay the compass setup to avoid preview crashes
        DispatchQueue.main.async {
            let compass = MKCompassButton(mapView: mapView)
            compass.compassVisibility = model.showCompass ? .visible : .hidden
            compass.translatesAutoresizingMaskIntoConstraints = false
            compass.transform = CGAffineTransform(scaleX: model.locationButtonSize / 40, y: model.locationButtonSize / 40)
            
            mapView.addSubview(compass)
            context.coordinator.compassButton = compass
            
            NSLayoutConstraint.activate([
                compass.bottomAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.bottomAnchor, constant: -model.compassOffset),
                compass.trailingAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                compass.widthAnchor.constraint(equalToConstant: 40),
                compass.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
        
        if model.authorizationState == .authorizedAlways || model.authorizationState == .authorizedWhenInUse {
            
            mapView.showsUserLocation = true // Show user on the map
            mapView.userTrackingMode = .follow // Follow user if location is enabled
            
            let span = MKCoordinateSpan.init(latitudeDelta: 10, longitudeDelta: 10)
            let coordinate = CLLocationCoordinate2D.init(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
            let region = MKCoordinateRegion.init(center: coordinate, span: span)
            mapView.setRegion(region, animated: true)
            
            let initialAnnotations = getLocations(center: coordinate)
            mapView.addAnnotations(initialAnnotations)
        }
        
        return mapView
        
    }
    
    // MARK: - updateUIView() & dismantleUIView()
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.compassButton?.compassVisibility = model.showCompass ? .visible : .hidden
        }
        
        if model.authorizationState == .authorizedAlways || model.authorizationState == .authorizedWhenInUse {
         
            uiView.showsUserLocation = true // Show user on the map
            
        }
        
        // - TODO: Add onChange here too... #46
        
        if model.shouldDeselectAnnotations {
            
            uiView.selectedAnnotations = []
            
            DispatchQueue.main.async {
                model.shouldDeselectAnnotations = false
            }
            
        }
        
        if model.annotationSelected {
            
            if uiView.selectedAnnotations.count == 0 {
                
                DispatchQueue.main.async {
                    withAnimation {
                        model.annotationSelected = false
                        model.currentHeight = UIScreen.main.bounds.height / 10.2
                    }
                }
                
            }
            
        }
        
        if model.authorizationState == .authorizedAlways || model.authorizationState == .authorizedWhenInUse {
            
            if model.goToLocation {
                
                let span = MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
                let coordinate = CLLocationCoordinate2D.init(latitude: uiView.userLocation.coordinate.latitude, longitude: uiView.userLocation.coordinate.longitude)
                let region = MKCoordinateRegion.init(center: coordinate, span: span)
                uiView.setRegion(region, animated: true)
                
                DispatchQueue.main.async {
                    withAnimation {
                        model.goToLocation = false
                    }
                }
                
            }
            
        }
        
        if model.shouldCheckIsOnLocation {
            
            if model.authorizationState == .authorizedAlways || model.authorizationState == .authorizedWhenInUse {
                
                if uiView.region.center.latitude >= uiView.userLocation.coordinate.latitude - 0.005 && uiView.region.center.latitude <= uiView.userLocation.coordinate.latitude + 0.005 && uiView.region.center.longitude >= uiView.userLocation.coordinate.longitude - 0.005 && uiView.region.center.longitude <= uiView.userLocation.coordinate.longitude + 0.005 {
                    
                    DispatchQueue.main.async { [self] in
                        withAnimation {
                            model.isOnLocation = true
                        }
                    }
                    
                } else {
                    
                    DispatchQueue.main.async { [self] in
                        withAnimation {
                            model.isOnLocation = false
                        }
                    }
                    
                }
                
            }
            
            DispatchQueue.main.async {
                model.shouldCheckIsOnLocation = false
            }
            
        }
        
        // TODO: - #32
        
        /*
        onChange(of: model.annotationSelected) { newValue in
            if !newValue {
                
                let span = MKCoordinateSpan.init(latitudeDelta: model.previousSpan.latitudeDelta, longitudeDelta:
                                                    model.previousSpan.longitudeDelta)
                let coordinate = CLLocationCoordinate2D.init(latitude: model.previousCoordinate.latitude, longitude: model.previousCoordinate.longitude)
                let region = MKCoordinateRegion.init(center: coordinate, span: span)
                uiView.setRegion(region, animated: true)
                
            }
        }
        */
        
    }
    
    static func dismantleUIView(_ uiView: MKMapView, coordinator: ()) {
        
        uiView.removeAnnotations(uiView.annotations)
        
    }
    
    
    // MARK: Coordinator Class
    
    func makeCoordinator() -> Coordinator {
        
        return Coordinator(model: self.model, map: self)
        
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        var region = MKCoordinateRegion.self
        var model: ContentModel
        var map: Map
        var compassButton: MKCompassButton?
        
        private var regionChangeWorkItem: DispatchWorkItem?
        private var annotationCache = [String: MKPointAnnotation]()
        
        init(model: ContentModel, map: Map) {
            
            self.model = model
            self.map = map
            
        }
        
        // MARK: - mapView(viewFor annotation:)
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            // Don't treat user as an annotation
            if annotation is MKUserLocation {
                
                return nil
                
            }
            
            if let cluster = annotation as? MKClusterAnnotation {
                
                // dequeue the “cluster” view we registered above
                let clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: "cluster", for: cluster) as! MKMarkerAnnotationView
                clusterView.markerTintColor = .systemRed
                clusterView.glyphText = "\(cluster.memberAnnotations.count)"
                
                return clusterView
            }
            
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.annotationReusedId, for: annotation) as! MKMarkerAnnotationView
            annotationView.clusteringIdentifier = "place"
            annotationView.canShowCallout = true
            
            let detailLabel = UILabel()
            detailLabel.text = String(localized: "annotationCalloutLabel")
            detailLabel.font = UIFont.systemFont(ofSize: 12)
            detailLabel.textColor = UIColor.secondaryLabel
            annotationView.detailCalloutAccessoryView = detailLabel
            
            let detailButton = UIButton(type: .detailDisclosure)
            detailButton.tintColor = UIColor.label
            annotationView.rightCalloutAccessoryView = detailButton
            
            return annotationView
            
        }
        
        // MARK: - mapView(regionDidChangeAnimated:)
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            guard mapView.region.span.latitudeDelta < model.latlongDelta && mapView.region.span.longitudeDelta < model.latlongDelta else {
                mapView.removeAnnotations(mapView.annotations)
                // nothing to do if zoom is out-of-range
                DispatchQueue.main.async { [self] in
                    model.devLog = String(localized: "insufficientZoom")
                }
                
                return
            }
                        
            if !model.annotationSelected {
                regionChangeWorkItem?.cancel()
                        
                // 3) Create a new one
                let workItem = DispatchWorkItem { [weak self] in
                    guard let self = self else { return }
                    let center = mapView.region.center
                    let spanIndex = self.model.latlongDelta * 10 * 0.035
                    
                    // 4) Do heavy filtering OFF the main thread
                    struct Hit { let key: String; let lat: Double; let lon: Double; let title: String? }
                    let hits: [Hit] = self.map.data.dataList.compactMap { place in
                        guard let latS = place.zsirka,
                              let lonS = place.zdelka,
                              let lat = Double(latS),
                              let lon = Double(lonS) else { return nil }
                        guard abs(lat - center.latitude)  <= spanIndex,
                              abs(lon - center.longitude) <= spanIndex else { return nil }
                        let key = place.adresa ?? UUID().uuidString
                        return Hit(key: key, lat: lat, lon: lon, title: place.adresa)
                    }
                    
                    // 5) Now *back* on the main thread to mutate MapKit/UI
                    DispatchQueue.main.async {
                        var newAnnotations: [MKPointAnnotation] = []
                        
                        for hit in hits {
                            let annotation: MKPointAnnotation
                            if let cached = self.annotationCache[hit.key] {
                                annotation = cached
                                // safe to update coordinate on main thread
                                annotation.coordinate = CLLocationCoordinate2D(latitude: hit.lat,
                                                                             longitude: hit.lon)
                            } else {
                                let a = MKPointAnnotation()
                                a.coordinate = CLLocationCoordinate2D(latitude: hit.lat,
                                                                      longitude: hit.lon)
                                a.title = hit.title
                                self.annotationCache[hit.key] = a
                                annotation = a
                            }
                            newAnnotations.append(annotation)
                        }
                        
                        // Diff against what's on the map now
                        let current = mapView.annotations.compactMap { $0 as? MKPointAnnotation }
                        let toRemove = current.filter { old in !newAnnotations.contains(where: { $0 === old }) }
                        let toAdd    = newAnnotations.filter { new in !current.contains(where: { $0 === new }) }
                        
                        mapView.removeAnnotations(toRemove)
                        mapView.addAnnotations(toAdd)
                        
                        self.model.devLog = "sufficientZoom"
                    }
                }
                
                // 6) Debounce at 0.2s
                regionChangeWorkItem = workItem
                DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.2, execute: workItem)
            }
            
            if model.annotationSelected {
                
                if mapView.selectedAnnotations.count == 0 {
                    
                    DispatchQueue.main.async { [self] in
                        withAnimation {
                            model.annotationSelected = false
                            model.currentHeight = UIScreen.main.bounds.height / 10.2
                        }
                    }
                    
                }
                
            }
                
            if model.authorizationState == .authorizedAlways || model.authorizationState == .authorizedWhenInUse {
                
                if mapView.region.center.latitude >= mapView.userLocation.coordinate.latitude - 0.005 && mapView.region.center.latitude <= mapView.userLocation.coordinate.latitude + 0.005 && mapView.region.center.longitude >= mapView.userLocation.coordinate.longitude - 0.005 && mapView.region.center.longitude <= mapView.userLocation.coordinate.longitude + 0.005 {
                    
                    DispatchQueue.main.async { [self] in
                        withAnimation {
                            model.isOnLocation = true
                        }
                    }
                    
                } else {
                    
                    DispatchQueue.main.async { [self] in
                        withAnimation {
                            model.isOnLocation = false
                        }
                    }
                    
                }
                
            }
                
        }
        // MARK: - mapView(didSelect)
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let cluster = view.annotation as? MKClusterAnnotation else { return }
            
            // compute a tighter region centered on the cluster
            let newSpan = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta  / 2, longitudeDelta: mapView.region.span.longitudeDelta / 2)
            let zoomRegion = MKCoordinateRegion(center: cluster.coordinate, span: newSpan)
            mapView.setRegion(zoomRegion, animated: true)
        
            // deselect so the cluster pin goes away immediately
            mapView.deselectAnnotation(cluster, animated: false)
        }
        
        // MARK: - mapView(calloutAccessoryControlTapped)
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            
            // User tapped on the annotation...
            
            // Loop through places to look for a match
            for place in map.data.dataList {
                
                if place.adresa == view.annotation?.title {
                    
                    map.selectedPlace = place
                    model.annotationSelected = true
                    model.devLog = String(localized: "annotationSelected")
                    model.previousSpan = MKCoordinateSpan.init(latitudeDelta: mapView.region.span.latitudeDelta, longitudeDelta: mapView.region.span.longitudeDelta)
                    model.previousCoordinate = CLLocationCoordinate2D.init(latitude: mapView.region.center.latitude, longitude: mapView.region.center.longitude)
                    
                    withAnimation {
                        model.currentHeight = 400
                    }
                    
                    // Center the map on the selected annotation (with - 0.006 lat offset)
                    if let lat = place.zsirka, let long = place.zdelka {
                        
                        let span = MKCoordinateSpan.init(latitudeDelta: 0.02, longitudeDelta:
                                                            0.02)
                        let coordinate = CLLocationCoordinate2D.init(latitude: Double(lat)! - 0.006, longitude: Double(long)!)
                        let region = MKCoordinateRegion.init(center: coordinate, span: span)
                        mapView.setRegion(region, animated: true)
                        
                    }
                    
                    return
                    
                }
            }
        }
        
    }
}

