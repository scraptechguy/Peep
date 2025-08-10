//
//  FetchData.swift
//  Peep
//
//  Created by Rostislav Brož on 8/13/22.
//

import Foundation
import SwiftUI
import Combine


// Handles downloading, validating, and providing the sundial database to the app.
// Tries the primary live database first, and falls back to a static JSON if unavailable.
// Also checks database reachability and JSON validity for UI indicators.
class FetchData: ObservableObject {
    // The final, deduplicated, and validated list of places available to the app.
    @Published var dataList = [DataModel]()
    
    // Signals to the UI that data is ready for use.
    @Published var finishedLoading = false
    
    // True if the primary database endpoint was reachable.
    @Published var databaseOnline = true
    
    // True if the primary database returned valid JSON that could be decoded into `[DataModel]`.
    @Published var jsonValid = true
    
    // Immediately starts fetching when created.
    init() {
        fetchData()
    }
        
    // Attempts to load the sundial database.
    // - Step 1: Try the live database.
    // - Step 2: If unreachable or invalid, use the fallback hosted on GitHub.
    func fetchData() {
        let url = URL(string: "https://astro.troja.mff.cuni.cz/mira/sh/json4.php")!
        let fallbackUrl = URL(string: "https://raw.githubusercontent.com/scraptechguy/Peep/refs/heads/main/Database/database4.json")!
        var needsFallback = false

        // Attempt primary fetch
        URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data, error == nil {
                    do {
                        #if DEBUG
                        print("Using online data")
                        #endif
                        
                        // Decode and validate primary data
                        var decoded = try JSONDecoder().decode([DataModel].self, from: data)
                        decoded = self.deduplicatedAndValidated(decoded)
                        
                        DispatchQueue.main.async { [self] in
                            withAnimation {
                                finishedLoading = true
                                databaseOnline = true
                            }
                            
                            self.dataList = decoded
                        }
                    } catch {
                        // JSON was invalid → mark invalid and prepare fallback
                        #if DEBUG
                        print("Primary decode failed: \(error)")
                        #endif
                        
                        needsFallback = true
                        
                        DispatchQueue.main.async { [self] in
                            jsonValid = false
                        }
                    }
                } else {
                    // Network error → mark database offline and prepare fallback
                    #if DEBUG
                    print("Primary fetch failed: \(error?.localizedDescription ?? "unknown error")")
                    #endif
                    
                    needsFallback = true
                    
                    DispatchQueue.main.async { [self] in
                        databaseOnline = false
                    }
                }

                // Attempt fallback if needed
                if needsFallback {
                    URLSession.shared.dataTask(with: fallbackUrl) { (data2, response2, error2) in
                        if let data2 = data2, error2 == nil {
                            do {
                                #if DEBUG
                                print("Using fallback online data")
                                #endif
                                
                                var decoded2 = try JSONDecoder().decode([DataModel].self, from: data2)
                                decoded2 = self.deduplicatedAndValidated(decoded2)
                                DispatchQueue.main.async { [self] in
                                    withAnimation { finishedLoading = true }
                                    self.dataList = decoded2
                                }
                            } catch {
                                // Even fallback data is invalid → no database available
                                #if DEBUG
                                print("Fallback decode failed: \(error)")
                                #endif
                            }
                        } else {
                            // Couldn’t fetch fallback either → app will not fetch fresh data
                            #if DEBUG
                            print("Fallback fetch failed: \(error2?.localizedDescription ?? "unknown error")")
                            #endif
                        }
                    }.resume()
                    
                }
            }.resume()
        }
    
    // Removes duplicate places and filters out entries with invalid coordinates.
    // - Duplicates are grouped by lowercase-trimmed address and exact coordinates.
    // - Invalid entries are logged in DEBUG mode.
    private func deduplicatedAndValidated(_ data: [DataModel]) -> [DataModel] {
        // Group by a composite key of address|latitude|longitude.
        let grouped = Dictionary(grouping: data, by: { "\($0.adresa?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? "")|" + "\($0.zsirka?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")|" + "\($0.zdelka?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")" })
                
        #if DEBUG
        // Log duplicates for diagnostic purposes.
        let duplicates = grouped.filter { $0.value.count > 1 }

        for (key, entries) in duplicates {
            print("🔁 Duplicate key: \(key)")
            for entry in entries {
                print("    ↪️ \(entry.adresa ?? "[no address]") | lat: \(entry.zsirka ?? "nil"), lon: \(entry.zdelka ?? "nil")")
            }
        }
        #endif
        
        // Keep the first entry in each group.
        let unique = grouped.compactMap { $0.value.first }
        
        // Validate coordinates to ensure they’re within Earth bounds.
        let valid = unique.filter { place in
            guard let latStr = place.zsirka, let lonStr = place.zdelka, let lat = Double(latStr), let lon = Double(lonStr), lat >= -90, lat <= 90, lon >= -180, lon <= 180 else {
                #if DEBUG
                print("Invalid coords in: \(place.adresa ?? "[no address]") — lat: \(place.zsirka ?? "nil"), lon: \(place.zdelka ?? "nil")")
                #endif
                
                return false
            }
            return true
        }
        
        return valid
    }
}
