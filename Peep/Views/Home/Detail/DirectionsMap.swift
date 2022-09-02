//
//  DirectionsMap.swift
//  Peep
//
//  Created by Rostislav Brož on 8/31/22.
//

import SwiftUI
import MapKit

struct DirectionsMap: UIViewRepresentable {
    
    @EnvironmentObject var model: ContentModel
    
    var place: DataModel
    
    var start: CLLocationCoordinate2D {
        
        // Return user's location, if not found, return blank CLLocationcoordinate2D
        return model.locationManager.location?.coordinate ?? CLLocationCoordinate2D()
        
    }
    
    var end: CLLocationCoordinate2D {
        
        if let lat = place.zsirka, let long = place.zdelka {
            
            return CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(long)!)
            
        } else {
            
            return CLLocationCoordinate2D()
            
        }
        
    }
    
    func makeUIView(context: Context) -> MKMapView {
        
        // Create map view
        let map = MKMapView()
        map.delegate = context.coordinator
        map.showsUserLocation = true
        map.userTrackingMode = .followWithHeading
        
        // Route
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
        
        // Directions object
        let directions = MKDirections(request: request)
        
        // Calculate route
        directions.calculate { (response, error) in
            
            if error == nil && response != nil {
                
                for route in response!.routes {
                    
                    // Display route
                    map.addOverlay(route.polyline)
                    
                    map.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
                    
                }
                
            }
            
        }
        
        // Annotation at the end
        let annotation = MKPointAnnotation()
        annotation.coordinate = end
        annotation.title = place.adresa ?? ""
        map.addAnnotation(annotation)
        
        return map
        
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
    
    static func dismantleUIView(_ uiView: MKMapView, coordinator: ()) {
        
        uiView.removeAnnotations(uiView.annotations)
        uiView.removeOverlays(uiView.overlays)
        
    }
    
    
    // MARK: Coordinator Class
    
    func makeCoordinator() -> Coordinator {
        
        return Coordinator()
        
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            
            let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            renderer.strokeColor = .red
            renderer.lineWidth = 5
            
            return renderer
            
        }
        
    }
    
}
