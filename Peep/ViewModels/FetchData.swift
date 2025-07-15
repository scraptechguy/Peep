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
    
    init() {
        fetchData()
    }
        
    func fetchData() {
        let url = URL(string: "https://raw.githubusercontent.com/scraptechguy/Peep/refs/heads/main/Database/database3.json")!
        
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                if let todoData = data {
                    
                    print("using online data")
                    
                    var decodedData = try JSONDecoder().decode([DataModel].self, from: todoData)
                    // Remove duplicates and validate coordinates
                    decodedData = self.deduplicatedAndValidated(decodedData)
                    
                    DispatchQueue.main.async { [self] in
                        withAnimation {
                            finishedLoading = true
                        }
                        
                        self.dataList = decodedData
                    }
                    
                } else {
                    
                    print("offline")
                    
                }
            } catch let error {
                
                print(error)
                
            }
        }.resume()
    }
    
    private func deduplicatedAndValidated(_ data: [DataModel]) -> [DataModel] {
        let grouped = Dictionary(grouping: data, by: {
            "\($0.adresa?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? "")|" +
            "\($0.zsirka?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")|" +
            "\($0.zdelka?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")"
        })
        
        let unique = grouped.compactMap { $0.value.first }
        
        let valid = unique.filter { place in
            guard let latStr = place.zsirka,
                  let lonStr = place.zdelka,
                  let lat = Double(latStr),
                  let lon = Double(lonStr),
                  lat >= -90, lat <= 90,
                  lon >= -180, lon <= 180 else {
                print("Invalid coords in: \(place.adresa ?? "[no address]") — lat: \(place.zsirka ?? "nil"), lon: \(place.zdelka ?? "nil")")
                return false
            }
            return true
        }
        
        return valid
    }
}
