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
    
    var locations:[MKPointAnnotation] {
        
        var annotations = [MKPointAnnotation]()
        
        for place in data.dataList {
            
            // If the place does have lat and long, create an annotation
            if let lat = place.zsirka, let long = place.zdelka { 
                
                // Create an annotation
                let a = MKPointAnnotation()
                a.coordinate = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(long)!)
                a.title = place.adresa ?? ""
                
                annotations.append(a)
                
            }
        }
        
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
        
        uiView.removeAnnotations(uiView.annotations)
        
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
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.annotationReusedId)
            
            if annotationView == nil {
                
                // Create new annotation
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: Constants.annotationReusedId)
                
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
            
            for place in map.data.dataList {
                
                if place.adresa == view.annotation?.title {
                    
                    map.selectedPlace = place
                    return
                    
                }
            }
        }
        
    }
}

