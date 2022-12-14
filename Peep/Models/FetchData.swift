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
        
        let url = URL(string: "https://astro.troja.mff.cuni.cz/mira/sh/json3.php")!
            
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                
                if !ContentModel().useOfflineDatabase {
                    
                    if let todoData = data {
                        
                        print("using online data cos I can")
                        
                        let decodedData = try JSONDecoder().decode([DataModel].self, from: todoData)
                        
                        DispatchQueue.main.async { [self] in
                            withAnimation {
                                finishedLoading = true
                            }
                            
                            self.dataList = decodedData
                        }
                        
                    } else {
                        
                        print("using offline data cos I have to")
                        
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
                    
                    print("using offline data cos user said so")
                    
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
