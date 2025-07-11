//
//  FetchData.swift
//  Peep
//
//  Created by Rostislav Brož on 8/13/22.
//

import Foundation
import SwiftUI

class FetchData: ObservableObject {
    @Published var useOfflineDatabase1 = false
    @Published var dataList = [DataModel]()
    @Published var finishedLoading = false
    
    init() {
        
        let url = URL(string: "https://raw.githubusercontent.com/scraptechguy/Peep/refs/heads/main/Database/database3.json")!
            
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                
                if !self.useOfflineDatabase1 {
                    
                    if let todoData = data {
                        
                        print("using online data")
                        
                        let decodedData = try JSONDecoder().decode([DataModel].self, from: todoData)
                        
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
                        let decodedData = try JSONDecoder().decode([DataModel].self, from: data)
                        
                        DispatchQueue.main.async { [self] in
                            withAnimation {
                                finishedLoading = true
                            }
                            
                            self.dataList = decodedData
                        }
                        
                    }
                    
                } else {
                    
                    guard let url = Bundle.main.url(forResource: "OfflineDatabase", withExtension: "geojson")
                    else {
                        
                        print("Json file not found")
                        
                        return
                        
                    }
                    
                    print("using offline data (user request)")
                    
                    let data = try Data(contentsOf: url)
                    let decodedData = try JSONDecoder().decode([DataModel].self, from: data)
                    
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
