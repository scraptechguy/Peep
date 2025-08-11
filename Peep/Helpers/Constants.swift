//
//  Constants.swift
//  Peep
//
//  Created by Rostislav Brož on 8/30/22.
//

import Foundation

/// Global constants used across the app.
struct Constants {
    private init() {} // prevent instantiation
    
    /// Reuse identifier for place annotations (`MKMarkerAnnotationView`) in the map.
    /// Used when registering/dequeueing the annotation view.
    static var annotationReusedId = "place"
}
