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
    @Binding var selectedPlace: DataModel?
    
    func getAnnotations(center: CLLocationCoordinate2D, cache: inout [String: MKPointAnnotation]) -> [MKPointAnnotation] {
        let visibleSpan = model.mapView.region.span
        let paddingFactor: Double = 2.0  // <- you can adjust this
        let latRange = visibleSpan.latitudeDelta * paddingFactor / 2
        let lonRange = visibleSpan.longitudeDelta * paddingFactor / 2
        
        var annotations: [MKPointAnnotation] = []

        for place in model.searchablePlaces {
            guard let latStr = place.zsirka, let lonStr = place.zdelka, let lat = Double(latStr), let lon = Double(lonStr) else { continue }

            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)

            // Keep only pins inside visible area + span padding
            guard abs(lat - center.latitude) <= latRange && abs(lon - center.longitude) <= lonRange else { continue }

            let key = place.adresa ?? UUID().uuidString

            if let annotation = cache[key] {
                
                // Already cached, update coordinate if needed
                annotation.coordinate = coordinate
                annotations.append(annotation)
                
            } else {
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = place.adresa ?? ""
                cache[key] = annotation
                annotations.append(annotation)
                
            }
        }

        return annotations
    }
    
    // MARK: - makeUIView()
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = model.mapView
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: Constants.annotationReusedId)
        mapView.delegate = context.coordinator
        mapView.showsCompass = false
        
        if model.authorizationState == .authorizedAlways || model.authorizationState == .authorizedWhenInUse {
            
            mapView.showsUserLocation = true // Show user on the map
            
        }
        
        return mapView
    }
    
    // MARK: - updateUIView() & dismantleUIView()
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if model.initialRegionCentered {
            
            DispatchQueue.main.async {
                model.initialRegionCentered = false
            }
            
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let coordinate = model.locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            uiView.setRegion(region, animated: false)
            
            let initialAnnotations = getAnnotations(center: coordinate, cache: &context.coordinator.annotationCache)
            uiView.removeAnnotations(uiView.annotations.filter { !($0 is MKUserLocation) })
            uiView.addAnnotations(initialAnnotations)
        
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
        
        let zoomThreshold: CLLocationDegrees = 0.15
        
        var region = MKCoordinateRegion.self
        var model: ContentModel
        var map: Map
        var compassButton: MKCompassButton?
        var pointOverlay: PointOverlay?
        var annotationCache: [String: MKPointAnnotation] = [:]
        
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
                
                return view
            }

            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.annotationReusedId, for: annotation) as! MKMarkerAnnotationView

            // Enable native clustering by assigning an identifier
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
            let center = mapView.region.center
            let latDelta = mapView.region.span.latitudeDelta

            // Zoomed out — show overlay, remove annotations
            if latDelta > zoomThreshold {
                
                mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })

                if pointOverlay == nil {
                    
                    pointOverlay = PointOverlay(dataPoints: model.searchablePlaces)
                    mapView.addOverlay(pointOverlay!)
                    
                }

            // Zoomed in — remove overlay, show annotations
            } else {
                
                if let overlay = pointOverlay {
                    
                    mapView.removeOverlay(overlay)
                    pointOverlay = nil
                    
                }

                // Get annotations without flickering
                var cache = annotationCache
                let newAnnotations = map.getAnnotations(center: center, cache: &cache)
                annotationCache = cache

                let current = mapView.annotations.compactMap { $0 as? MKPointAnnotation }
                let toRemove = current.filter { old in !newAnnotations.contains(where: { $0 === old }) }
                let toAdd = newAnnotations.filter { new in !current.contains(where: { $0 === new }) }

                mapView.removeAnnotations(toRemove)
                mapView.addAnnotations(toAdd)
                
            }
            
            if model.shouldSearchAfterRegionChange {
                
                model.shouldSearchAfterRegionChange = false

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
            for place in model.searchablePlaces {
                
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
