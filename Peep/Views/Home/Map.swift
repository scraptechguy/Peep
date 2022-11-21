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
    
    func getLocations(center: CLLocationCoordinate2D) -> [MKPointAnnotation] {
        
        var annotations = [MKPointAnnotation]()
        
        // Loop through all places
        for place in data.dataList {
            
            // If the place does have lat and long, create an annotation
            if let lat = place.zsirka, let long = place.zdelka {
                
                // Create annotations only for places within a certain region
                if Double(lat)! >= center.latitude - 0.035 && Double(lat)! <= center.latitude + 0.035 && Double(long)! >= center.longitude - 0.035 && Double(long)! <= center.longitude + 0.035 {
                    
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
    
    func makeUIView(context: Context) -> MKMapView {
        
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        mapView.showsUserLocation = true // Show user on the map
        mapView.userTrackingMode = .followWithHeading // Follow user when moving
        mapView.showsCompass = false // Disable compass indicator
        
        let span = MKCoordinateSpan.init(latitudeDelta: 10, longitudeDelta: 10)
        let coordinate = CLLocationCoordinate2D.init(latitude: mapView.userLocation.coordinate.latitude, longitude: mapView.userLocation.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        return mapView
        
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
        // Remove all annotations
        // uiView.removeAnnotations(uiView.annotations)
        
        // Add new ones
        // uiView.showAnnotations(self.locations, animated: true)
        
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
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            
            if mapView.region.span.latitudeDelta < 0.1 && mapView.region.span.longitudeDelta < 0.1 {
                        
                if !model.annotationSelected {
                    
                    mapView.removeAnnotations(mapView.annotations)
                    mapView.addAnnotations(map.getLocations(center: mapView.region.center))
                    
                }
                
            } else {
                
                mapView.removeAnnotations(mapView.annotations)
                
            }
            
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            
            // User tapped on the annotation...
            
            // Loop through places to look for a match
            for place in map.data.dataList {
                
                if place.adresa == view.annotation?.title {
                    
                    map.selectedPlace = place
                    model.annotationSelected = true
                    
                    withAnimation {
                        model.currentHeight = 400
                    }
                    
                    // Center the map on the selected annotation
                    if let lat = place.zsirka, let long = place.zdelka {
                        
                        let span = MKCoordinateSpan.init(latitudeDelta: 0.02, longitudeDelta:
                                                            0.02)
                        let coordinate = CLLocationCoordinate2D.init(latitude: Double(lat)!, longitude: Double(long)!)
                        let region = MKCoordinateRegion.init(center: coordinate, span: span)
                        mapView.setRegion(region, animated: true)
                        
                    }
                    
                    return
                    
                }
            }
        }
        
    }
}

