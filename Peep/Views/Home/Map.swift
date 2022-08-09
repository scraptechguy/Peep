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
    @Binding var selectedPlace: Place?
    
    var locations:[MKPointAnnotation] {
        
        var annotations = [MKPointAnnotation]()
        
        var a = MKPointAnnotation()
        a.coordinate = CLLocationCoordinate2D(latitude: 37.773972, longitude: -122.431297)
        a.title = "San Francisco"
        
        annotations.append(a)
        
        return annotations
    }
    
    func makeUIView(context: Context) -> MKMapView {
        
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        // Show user on the map
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        
        return mapView
        
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
        // Remove all annotations
        uiView.removeAnnotations(uiView.annotations)
        
        // Add new ones based on the place you're at
        uiView.showAnnotations(self.locations, animated: true)
        
    }
    
    static func dismantleUIView(_ uiView: MKMapView, coordinator: ()) {
        
    }
    
    
    // MARK: Coordinator Class
    
    func makeCoordinator() -> Coordinator {
        
        return Coordinator(map: self)
        
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        var map: Map
        
        init(map: Map) {
            
            self.map = map
            
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            // Don't treat user as an annotation
            if annotation is MKUserLocation {
                return nil
            }
            
            // Check for reusable annotations
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "place")
            
            if annotationView == nil {
                
                // Create new annotation
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "place")
                
                annotationView!.canShowCallout = true
                annotationView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                
            } else {
                
                // Carry on with reusable annotation
                annotationView!.annotation = annotation
                
            }
            
            return annotationView
            
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            
            // TODO: User tapped on the annotation even handling
            
        }
        
    }
}
