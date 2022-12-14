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
    
    // MARK: - getLocationsToRemove()
    /*
    
    func getLocationsToRemove(center: CLLocationCoordinate2D) -> [MKPointAnnotation] {
        
        var annotationsToRemove = [MKPointAnnotation]()
        let annotationSpanIndex: Double = model.latlongDelta * 10 * 0.035
        
        // Loop through all places
        for annotation in MKMapView().annotations {
                
            // Create annotations only for places within a certain region
            if annotation.coordinate.latitude <= center.latitude - annotationSpanIndex && annotation.coordinate.latitude >= center.latitude + annotationSpanIndex && annotation.coordinate.longitude <= center.longitude - annotationSpanIndex && annotation.coordinate.longitude >= center.longitude + annotationSpanIndex {
                
                annotationsToRemove.append(MKPointAnnotation(__coordinate: annotation as! CLLocationCoordinate2D))
                
            }
                
        }
        
        return annotationsToRemove
        
    }
    */
    
    // MARK: - makeUIView()
    
    func makeUIView(context: Context) -> MKMapView {
        
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        mapView.showsUserLocation = true // Show user on the map
        mapView.userTrackingMode = .follow // Follow user
        mapView.showsCompass = false // Disable compass indicator
        
        let span = MKCoordinateSpan.init(latitudeDelta: 10, longitudeDelta: 10)
        let coordinate = CLLocationCoordinate2D.init(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        return mapView
        
    }
    
    // MARK: - updateUIView() & dismantleUIView()
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
        if !model.annotationSelected {
            
            uiView.selectedAnnotations = []
            
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
        
        // TODO: #32
        
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
            
            // Check for reusable annotations
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.annotationReusedId)
            
            // If none found, create a new one
            if annotationView == nil {
                
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: Constants.annotationReusedId)
                
                annotationView!.canShowCallout = true
                annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                
            } else {
                
                // Carry on with reusable annotation
                annotationView!.annotation = annotation
                
            }
            
            return annotationView
            
        }
        
        // MARK: - mapView(regionDidChangeAnimated:)
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            
            if mapView.region.span.latitudeDelta < model.latlongDelta && mapView.region.span.longitudeDelta < model.latlongDelta {
                        
                if !model.annotationSelected {
                    
                    mapView.removeAnnotations(mapView.annotations)
                    mapView.addAnnotations(map.getLocations(center: mapView.region.center))
                    
                    DispatchQueue.main.async { [self] in
                        model.devLog = "Sufficient zoom, showing annotations"
                    }
                    
                }
                
            } else {
                
                mapView.removeAnnotations(mapView.annotations)
                
                DispatchQueue.main.async { [self] in
                    model.devLog = "Insufficient zoom, not showing annotations"
                }
                
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
        
        // MARK: - mapView(calloutAccessoryControlTapped)
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            
            // User tapped on the annotation...
            
            // Loop through places to look for a match
            for place in map.data.dataList {
                
                if place.adresa == view.annotation?.title {
                    
                    map.selectedPlace = place
                    model.annotationSelected = true
                    model.devLog = "Annotation selected"
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

