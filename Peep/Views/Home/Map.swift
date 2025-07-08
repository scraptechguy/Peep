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
    @EnvironmentObject var data: FetchData
    @Binding var selectedPlace: DataModel?
    
    // MARK: - makeUIView()
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = model.mapView
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: Constants.annotationReusedId)
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
        
        }
        
        let overlay = PointOverlay(dataPoints: model.searchablePlaces)
        mapView.addOverlay(overlay)
        
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
        var pointOverlay: PointOverlay?
        
        private var regionChangeWorkItem: DispatchWorkItem?
        
        init(model: ContentModel, map: Map) {
            
            self.model = model
            self.map = map
            
        }
        
        // MARK: - mapView(viewFor annotation:)
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            // Don't treat user as an annotation
            if annotation is MKUserLocation { return nil }
            
            if let cluster = annotation as? MKClusterAnnotation {
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier, for: cluster) as! MKMarkerAnnotationView
                view.markerTintColor = .systemRed
                view.glyphText = "\(cluster.memberAnnotations.count)"
                view.displayPriority = .defaultLow
                
                return view
            }

            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.annotationReusedId, for: annotation) as! MKMarkerAnnotationView

            // Enable native clustering by assigning an identifier
            annotationView.clusteringIdentifier = "place"
            annotationView.canShowCallout = true
            annotationView.displayPriority = .defaultLow
            
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
            if model.shouldSearchAfterRegionChange {
                
                model.shouldSearchAfterRegionChange = false
                
                // Filter & show only those pins
                model.searchCurrentMapArea()

                // If we stored a pending place, select its annotation
                if let place = model.pendingSelectionPlace {
                    
                    if let annotation = mapView.annotations.compactMap({ $0 as? MKPointAnnotation }).first(where: { $0.title == place.adresa }) {
                        
                        mapView.selectAnnotation(annotation, animated: true)
                        
                    }
                    
                }

                // Clear out the pending place
                model.pendingSelectionPlace = nil
                
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
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let ov = overlay as? PointOverlay {
                
                return PointOverlayRenderer(overlay: ov)
                
            }
            
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

// Overlay that holds your DataModel items
class PointOverlay: NSObject, MKOverlay {
    let dataPoints: [DataModel]

    // Cover the whole world (or you can compute a tighter rect)
    var boundingMapRect: MKMapRect = .world

    // Required by MKOverlay, but we don’t use it for positioning
    var coordinate: CLLocationCoordinate2D = .init(latitude: 0, longitude: 0)

    init(dataPoints: [DataModel]) {
        self.dataPoints = dataPoints
        super.init()
    }
}

// Renderer that draws each DataModel as a dot
class PointOverlayRenderer: MKOverlayRenderer {
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        // choose a dot size that scales with zoom
        let radius: CGFloat = max(2, 8 / zoomScale)
        context.setFillColor(UIColor.systemRed.cgColor)

        // Loop over the DataModel array
        let overlay = self.overlay as! PointOverlay
        for model in overlay.dataPoints {
            // Safely unwrap & convert string lat/long
            guard let latStr = model.zsirka, let lonStr = model.zdelka, let lat = Double(latStr), let lon = Double(lonStr) else { continue }

            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let point = self.point(for: MKMapPoint(coord))
            let rect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
            context.fillEllipse(in: rect)
        }
    }
}
