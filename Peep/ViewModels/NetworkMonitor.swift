//
//  NetworkMonitor.swift
//  Peep
//
//  Created by Rostislav Brož on 15.07.2025.
//

import Network
import Combine

/// Monitors the device's network connectivity status using `NWPathMonitor`
/// and publishes changes to SwiftUI views via Combine.
///
/// Use `NetworkMonitor.shared.isOnline` to reactively update the UI when
/// connectivity changes. Automatically starts monitoring on initialization.
final class NetworkMonitor: ObservableObject {
    /// Shared singleton instance for global access.
    static let shared = NetworkMonitor()

    /// `true` if the device currently has an active network connection.
    /// - Published: SwiftUI views can bind to this property to update UI automatically.
    @Published private(set) var isOnline: Bool = true

    /// Low-level network path monitor from Apple's Network framework.
    private let monitor = NWPathMonitor()
    
    /// Background serial queue on which the `NWPathMonitor` runs.
    private let queue = DispatchQueue(label: "NetworkMonitor")

    /// Initializes the monitor and starts listening for network status changes.
    /// - Note: This is private to enforce singleton usage via `NetworkMonitor.shared`.
    private init() {
        // Called whenever the network path changes (e.g., Wi-Fi ↔︎ Cellular, offline)
        monitor.pathUpdateHandler = { [weak self] path in
            // Switch to the main thread before updating a @Published property
            DispatchQueue.main.async {
                self?.isOnline = (path.status == .satisfied)
            }
        }
        
        // Start the monitor on the background queue
        monitor.start(queue: queue)
    }
}
