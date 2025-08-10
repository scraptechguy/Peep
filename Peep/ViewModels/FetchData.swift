//
//  FetchData.swift
//  Peep
//
//  Created by Rostislav Brož on 8/13/22.
//

import Foundation
import SwiftUI
import Combine

class FetchData: ObservableObject {
    @Published var dataList = [DataModel]()
    @Published var finishedLoading = false
    @Published var databaseOnline = true
    @Published var jsonValid = true
    
    init() {
        fetchData()
    }
        
    func fetchData() {
        let url = URL(string: "https://astro.troja.mff.cuni.cz/mira/sh/json4.php")!
        let fallbackUrl = URL(string: "https://raw.githubusercontent.com/scraptechguy/Peep/refs/heads/main/Database/database4.json")!
        var needsFallback = false

        URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data, error == nil {
                    
                    do {
                        #if DEBUG
                        print("Using online data")
                        #endif
                        
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
                        #if DEBUG
                        print("Primary decode failed: \(error)")
                        #endif
                        
                        needsFallback = true
                        
                        DispatchQueue.main.async { [self] in
                            jsonValid = false
                        }
                    }
                    
                } else {
                    
                    #if DEBUG
                    print("Primary fetch failed: \(error?.localizedDescription ?? "unknown error")")
                    #endif
                    
                    needsFallback = true
                    
                    DispatchQueue.main.async { [self] in
                        databaseOnline = false
                    }
                    
                }

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
                                #if DEBUG
                                print("Fallback decode failed: \(error)")
                                #endif
                            }
                            
                        } else {
                            
                            #if DEBUG
                            print("Fallback fetch failed: \(error2?.localizedDescription ?? "unknown error")")
                            #endif
                            
                        }
                    }.resume()
                    
                }
            }.resume()
        }
    
    private func deduplicatedAndValidated(_ data: [DataModel]) -> [DataModel] {
        let grouped = Dictionary(grouping: data, by: { "\($0.adresa?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? "")|" + "\($0.zsirka?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")|" + "\($0.zdelka?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")" })
                
        #if DEBUG
        let duplicates = grouped.filter { $0.value.count > 1 }

        for (key, entries) in duplicates {
            print("🔁 Duplicate key: \(key)")
            for entry in entries {
                print("    ↪️ \(entry.adresa ?? "[no address]") | lat: \(entry.zsirka ?? "nil"), lon: \(entry.zdelka ?? "nil")")
            }
        }
        #endif
        
        let unique = grouped.compactMap { $0.value.first }
        
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
