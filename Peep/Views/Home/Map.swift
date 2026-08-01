//
//  Map.swift
//  Peep
//
//  Created by Rostislav Brož on 8/8/22.
//

import SwiftUI
import MapKit

/// SwiftUI wrapper around a shared `MKMapView`.
/// Handles:
/// - Pin clustering and efficient annotation diffing
/// - A "heatmap-lite" overlay of dots when zoomed out (for performance)
/// - Programmatic jumps to user location
/// - Selection sync between MapKit and SwiftUI (bottom sheet, etc.)
struct Map: UIViewRepresentable {
    
    @EnvironmentObject var model: ContentModel
    
    /// The place selected in SwiftUI (drives the detail sheet).
    @Binding var selectedPlace: DataModel?
    
    /// Builds or updates `MKPointAnnotation`s within the visible (padded) map area.
    ///
    /// - Parameters:
    ///   - center: The center of the current map region.
    ///   - cache: A reusable dictionary of annotations keyed by address to prevent churn.
    /// - Returns: A list of annotations that should be present on the map.
    ///
    /// Notes:
    /// - We *reuse* annotations from `cache` to avoid flicker and extra allocation.
    /// - We filter by a rectangle defined by the current span * paddingFactor.
    func getAnnotations(center: CLLocationCoordinate2D, cache: inout [String: MKPointAnnotation]) -> [MKPointAnnotation] {
        let visibleSpan = model.mapView.region.span
        let paddingFactor: Double = 2.0  // <- adjustable
        let latRange = visibleSpan.latitudeDelta * paddingFactor / 2
        let lonRange = visibleSpan.longitudeDelta * paddingFactor / 2
        
        var annotations: [MKPointAnnotation] = []
        
        // About 3–4 metres in Czechia.
        let duplicateLongitudeOffset: CLLocationDegrees = 0.0001
        var coordinateOccurrences: [String: Int] = [:]

        for place in model.searchablePlaces {
            guard let latStr = place.zsirka, let lonStr = place.zdelka, let lat = Double(latStr), let lon = Double(lonStr) else { continue }

            // Keep only pins inside visible area + span padding.
            guard abs(lat - center.latitude) <= latRange && abs(lon - center.longitude) <= lonRange else { continue }
            
            let coordinateKey = "\(lat.bitPattern):\(lon.bitPattern)"
            let duplicateIndex = coordinateOccurrences[coordinateKey, default: 0]
            coordinateOccurrences[coordinateKey] = duplicateIndex + 1

            let coordinate = CLLocationCoordinate2D(
                latitude: lat,
                longitude: lon + Double(duplicateIndex) * duplicateLongitudeOffset
            )

            // Use address as a stable key if available.
            let key = place.id ?? UUID().uuidString

            if let annotation = cache[key] {
                // Already cached, update its current data.
                annotation.coordinate = coordinate
                annotation.title = place.adresa ?? ""
                annotation.subtitle = place.id
                annotations.append(annotation)
            } else {
                // Create and cache a new point annotation.
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = place.adresa ?? ""
                annotation.subtitle = place.id
                cache[key] = annotation
                annotations.append(annotation)
            }
        }

        return annotations
    }
    
    
    // MARK: - makeUIView()
    
    /// Creates and configures the shared `MKMapView`.
    /// - Registers annotation views, enables clustering, sets delegate.
    func makeUIView(context: Context) -> MKMapView {
        let mapView = model.mapView
        
        // Register default cluster view + pin view.
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: Constants.annotationReusedId)
        mapView.delegate = context.coordinator
        mapView.showsCompass = false
        
        // Show the blue location dot only when authorized.
        if model.authorizationState == .authorizedAlways || model.authorizationState == .authorizedWhenInUse {
            mapView.showsUserLocation = true // Show user on the map
        }
        
        return mapView
    }
    
    
    // MARK: - updateUIView()
    
    /// Keeps MapKit state in sync with SwiftUI model updates.
    ///
    /// Responsibilities:
    /// - Handle first-time centering on user location
    /// - Perform programmatic "Go to my location"
    /// - Keep `isOnLocation` flag in sync for the locate button UI
    /// - Respect requests to deselect annotations
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // First-time center on user's location (triggered by ContentModel after first fix).
        if model.initialRegionCentered {
            DispatchQueue.main.async {
                model.initialRegionCentered = false
            }
            
            // Reasonable starting span; avoids starting "too zoomed in"
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let coordinate = model.locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            uiView.setRegion(region, animated: false)
            
            // Seed initial annotations for the freshly centered region.
            let initialAnnotations = getAnnotations(center: coordinate, cache: &context.coordinator.annotationCache)
            uiView.removeAnnotations(uiView.annotations.filter { !($0 is MKUserLocation) })
            uiView.addAnnotations(initialAnnotations)
        }
        
        // Keep user location visibility in sync with permissions.
        if model.authorizationState == .authorizedAlways || model.authorizationState == .authorizedWhenInUse {
            uiView.showsUserLocation = true // Show user on the map
        }
        
        // Programmatic clear of selection (e.g., when closing the sheet)
        if model.shouldDeselectAnnotations {
            uiView.selectedAnnotations = []
            
            DispatchQueue.main.async {
                model.shouldDeselectAnnotations = false
            }
        }
        
        // If SwiftUI thinks something is selected but MapKit does not, normalize state.
        if model.annotationSelected {
            if uiView.selectedAnnotations.count == 0 {
                DispatchQueue.main.async {
                    withAnimation {
                        model.annotationSelected = false
                        model.currentHeight = UIScreen.main.bounds.height / 11
                    }
                }
            }
        }
        
        // Jump to user's current coordinate when asked by the model.
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
    }
    
    
    // MARK: - dismantleUIView
    
    /// Cleans up annotations when the SwiftUI view is torn down.
    static func dismantleUIView(_ uiView: MKMapView, coordinator: ()) {
        uiView.removeAnnotations(uiView.annotations)
    }
    
    
    // MARK: Coordinator Class
    
    /// Creates the coordinator that acts as `MKMapViewDelegate`.
    /// Centralizes MapKit callbacks and cross-talk with `ContentModel`.
    func makeCoordinator() -> Coordinator {
        return Coordinator(model: self.model, map: self)
    }
    
    /// Handles MapKit delegate work:
    /// - Annotation view configuration and clustering
    /// - Region changes → switch overlay vs pins and diff annotations
    /// - Selection behavior and "zoom into cluster" UX
    /// - Custom overlay rendering (dot cloud)
    class Coordinator: NSObject, MKMapViewDelegate {
        /// LatitudeDelta threshold that toggles between overlay (wide) and pins (tight).
        let zoomThreshold: CLLocationDegrees = 0.15
        
        // References to the model and the wrapping SwiftUI struct.
        var region = MKCoordinateRegion.self
        var model: ContentModel
        var map: Map
        var pointOverlay: PointOverlay?
        
        /// Reuse pool for pin annotations keyed by address.
        /// Keeps the same instances alive to prevent flicker.
        var annotationCache: [String: MKPointAnnotation] = [:]
        
        init(model: ContentModel, map: Map) {
            self.model = model
            self.map = map
        }
        
        
        // MARK: - mapView(viewFor:)
        
        /// Provides views for annotations and clusters.
        /// - Returns:
        ///   - `nil` for the user location (use default blue dot)
        ///   - A numbered cluster marker when MapKit forms a cluster
        ///   - A marker pin with a callout and detail button for regular places
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Don't treat user as an annotation.
            if annotation is MKUserLocation { return nil }
            
            // Cluster bubble with a count glyph
            if let cluster = annotation as? MKClusterAnnotation {
                let view = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier, for: cluster) as! MKMarkerAnnotationView
                view.markerTintColor = .systemRed
                view.glyphText = "\(cluster.memberAnnotations.count)"
                
                return view
            }

            // Regular pin with callout
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.annotationReusedId, for: annotation) as! MKMarkerAnnotationView

            // Enable native clustering by assigning an identifier.
            annotationView.clusteringIdentifier = "place"
            annotationView.canShowCallout = true
            
            // Callout subtitle
            let detailLabel = UILabel()
            detailLabel.text = String(localized: "annotationCalloutLabel")
            detailLabel.font = UIFont.systemFont(ofSize: 12)
            detailLabel.textColor = UIColor.secondaryLabel
            annotationView.detailCalloutAccessoryView = detailLabel
            
            // ⓘ disclosure button
            let detailButton = UIButton(type: .detailDisclosure)
            detailButton.tintColor = UIColor.label
            annotationView.rightCalloutAccessoryView = detailButton
            
            return annotationView
        }
        
        
        // MARK: - mapView(regionDidChangeAnimated:)
        
        /// Responds to pan/zoom changes:
        /// - If zoomed out beyond `zoomThreshold`: remove pins, show dot overlay.
        /// - If zoomed in: remove overlay and diff in the right pins for the current view.
        /// - Syncs "on location" flag and handles pending selection after a search.
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let center = mapView.region.center
            let latDelta = mapView.region.span.latitudeDelta
            
            // Updates map heading variable.
            DispatchQueue.main.async { [self] in
                model.mapHeading = mapView.camera.heading
            }

            // Zoomed out — show overlay, remove annotations.
            if latDelta > zoomThreshold {
                // Remove all pins except the user dot.
                mapView.removeAnnotations(mapView.annotations.filter { !($0 is MKUserLocation) })

                // Add a simple dot overlay representing all data points.
                if pointOverlay == nil {
                    pointOverlay = PointOverlay(dataPoints: model.searchablePlaces)
                    mapView.addOverlay(pointOverlay!)
                }
            // Zoomed in — remove overlay, show annotations.
            } else {
                // Remove overlay if present.
                if let overlay = pointOverlay {
                    mapView.removeOverlay(overlay)
                    pointOverlay = nil
                }

                // Efficiently compute which annotations should be visible *now*.
                var cache = annotationCache
                let newAnnotations = map.getAnnotations(center: center, cache: &cache)
                annotationCache = cache

                // Diff against what's currently on the map (identity by instance pointer).
                let current = mapView.annotations.compactMap { $0 as? MKPointAnnotation }
                let toRemove = current.filter { old in !newAnnotations.contains(where: { $0 === old }) }
                let toAdd = newAnnotations.filter { new in !current.contains(where: { $0 === new }) }

                mapView.removeAnnotations(toRemove)
                mapView.addAnnotations(toAdd)
            }
            
            // If a search requested a region change, handle optional pending selection.
            if model.shouldSearchAfterRegionChange {
                model.shouldSearchAfterRegionChange = false

                // If we stored a pending place, select its annotation.
                if let place = model.pendingSelectionPlace {
                    // Select the annotation that matches the place ID.
                    if let annotation = mapView.annotations
                        .compactMap({ $0 as? MKPointAnnotation })
                        .first(where: { $0.subtitle == place.id }) {
                        mapView.selectAnnotation(annotation, animated: true)
                    }
                }

                // Clear out the pending place
                model.pendingSelectionPlace = nil
            }
            
            // If SwiftUI thought a pin was selected but MapKit says otherwise, collapse the sheet.
            if model.annotationSelected {
                if mapView.selectedAnnotations.count == 0 {
                    DispatchQueue.main.async { [self] in
                        withAnimation {
                            model.annotationSelected = false
                            model.currentHeight = UIScreen.main.bounds.height / 11
                        }
                    }
                }
            }
                
            // Keep "on location" glow in sync with the current map center.
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
        
        
        // MARK: - mapView(didSelect:)
        
        /// When a cluster bubble is tapped, zoom in by halving the current span.
        /// Deselect immediately so the bubble disappears during the zoom animation.
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let cluster = view.annotation as? MKClusterAnnotation else { return }
            
            // compute a tighter region centered on the cluster
            let newSpan = MKCoordinateSpan(latitudeDelta: mapView.region.span.latitudeDelta  / 2, longitudeDelta: mapView.region.span.longitudeDelta / 2)
            let zoomRegion = MKCoordinateRegion(center: cluster.coordinate, span: newSpan)
            mapView.setRegion(zoomRegion, animated: true)
        
            // deselect so the cluster pin goes away immediately
            mapView.deselectAnnotation(cluster, animated: false)
        }
        
        
        // MARK: - mapView(calloutAccessoryControlTapped:)
        
        /// Handles tapping the ⓘ button on a pin callout:
        /// - Syncs selection back to SwiftUI (`selectedPlace`, `annotationSelected`)
        /// - Expands bottom sheet
        /// - Recenters the map with a slight upward offset so the sheet doesn't cover the pin
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            // Find the tapped place by its database ID.
            guard let annotation = view.annotation as? MKPointAnnotation, let placeID = annotation.subtitle,
                let place = model.searchablePlaces.first(where: { $0.id == placeID })
            else {
                return
            }

            map.selectedPlace = place
            model.annotationSelected = true

            withAnimation {
                model.currentHeight = 400
            }

            // Center on the annotation's actual displayed coordinate.
            // This preserves the duplicate-coordinate longitude shift.
            let relativeOffset = mapView.region.span.latitudeDelta * 0.2
            let coordinate = CLLocationCoordinate2D(
                latitude: annotation.coordinate.latitude - relativeOffset,
                longitude: annotation.coordinate.longitude
            )
            let region = MKCoordinateRegion(
                center: coordinate,
                span: mapView.region.span
            )
            mapView.setRegion(region, animated: true)
        }

        
        // MARK: - Overlay rendering
        
        /// Returns a renderer for simple "dot cloud" overlay.
        /// Fallback to a default renderer for unknown overlays.
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let ov = overlay as? PointOverlay {
                return PointOverlayRenderer(overlay: ov)
            }
            
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

/// Overlay holding the full dataset for "zoomed-out" rendering as dots.
/// This avoids thousands of annotations when zoomed out, which is costly.
class PointOverlay: NSObject, MKOverlay {
    let dataPoints: [DataModel]

    /// Covers the whole world.
    var boundingMapRect: MKMapRect = .world

    /// Required by `MKOverlay` (not used for positioning).
    var coordinate: CLLocationCoordinate2D = .init(latitude: 0, longitude: 0)

    init(dataPoints: [DataModel]) {
        self.dataPoints = dataPoints
        super.init()
    }
}

/// Simple renderer that draws each `DataModel` as a red dot.
/// Scales dot radius with zoom so it doesn't become too tiny or huge.
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
