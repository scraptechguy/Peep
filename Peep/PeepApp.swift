//
//  PeepApp.swift
//  Peep
//
//  Created by Rostislav Brož on 8/8/22.
//

import SwiftUI

/// App entry point and root scene configuration.
/// Creates and injects shared observable models into the SwiftUI environment
/// so any descendant view can access them via `@EnvironmentObject`.
@main
struct PeepApp: App {
    // Using @StateObject ensures each model is initialized exactly once per scene.
    @StateObject private var contentModel = ContentModel()
    @StateObject private var fetchData = FetchData()

    /// Defines the app’s scenes. On iOS this is typically a single `WindowGroup`.
    var body: some Scene {
        WindowGroup {
            // Root of the view hierarchy.
            LaunchView()
                // Global app state: owns MKMapView/CLLocationManager + UI flags.
                .environmentObject(contentModel)
                // Data pipeline: fetches + validates the remote (and fallback) JSON.
                .environmentObject(fetchData)
                // Network reachability (singleton) published to the whole app.
                .environmentObject(NetworkMonitor.shared)
        }
    }
}
