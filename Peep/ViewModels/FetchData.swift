//
//  FetchData.swift
//  Peep
//
//  Created by Rostislav Brož on 8/13/22.
//

import Foundation
import SwiftUI

class FetchData: ObservableObject {
    @Published var dataList = [DataModel]()
    @Published var finishedLoading = false
    
    init() {
        
        let url = URL(string: "https://raw.githubusercontent.com/scraptechguy/Peep/refs/heads/main/Database/database3.json")!
            
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                if let todoData = data {
                    
                    print("using online data")
                    
                    var decodedData = try JSONDecoder().decode([DataModel].self, from: todoData)
                    // Remove duplicates
                    decodedData = Dictionary(grouping: decodedData, by: { "\($0.adresa ?? "")|\($0.zsirka ?? "")|\($0.zdelka ?? "")" }).compactMap { $0.value.first }
                    
                    DispatchQueue.main.async { [self] in
                        withAnimation {
                            finishedLoading = true
                        }
                    
                        self.dataList = decodedData
                    }
                    
                } else {
                    
                    print("using offline data")
                    
                    guard let url = Bundle.main.url(forResource: "OfflineDatabase", withExtension: "geojson")
                    else {
                        
                        print("Json file not found")
                        
                        return
                        
                    }
                    
                    let data = try Data(contentsOf: url)
                    var decodedData = try JSONDecoder().decode([DataModel].self, from: data)
                    // Remove duplicates
                    decodedData = Dictionary(grouping: decodedData, by: { "\($0.adresa ?? "")|\($0.zsirka ?? "")|\($0.zdelka ?? "")" }).compactMap { $0.value.first }
                    
                    DispatchQueue.main.async { [self] in
                        withAnimation {
                            finishedLoading = true
                        }
                        
                        self.dataList = decodedData
                    }
                    
                }
            } catch let error {
                
                print(error)
                
            }
        }.resume()
    }
}
