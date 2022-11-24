//
//  FetchData.swift
//  Peep
//
//  Created by Rostislav Brož on 8/13/22.
//

import Foundation

class FetchData: ObservableObject {
    
    @Published var dataList = [DataModel]()
    
    init() {
        
        let url = URL(string: "https://astro.troja.mff.cuni.cz/mira/sh/json3.php")!
        
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                
                if let todoData = data {
                    
                    ContentModel().devLog = "Downloading online data..."
                    
                    let decodedData = try JSONDecoder().decode([DataModel].self, from: todoData)
                    
                    DispatchQueue.main.async {
                        self.dataList = decodedData
                        ContentModel().devLog = "Online data downloaded, using online database..."
                    }
                    
                } else {
                    
                    guard let url = Bundle.main.url(forResource: "OfflineDatabase", withExtension: "geojson")
                    else {
                        
                        print("Json file not found")
                        
                        return
                        
                    }
                    
                    let data = try Data(contentsOf: url)
                    let decodedData = try JSONDecoder().decode([DataModel].self, from: data)
                    self.dataList = decodedData
                    
                    ContentModel().devLog = "No data received, using offline database..."
                    
                }
                
            } catch let error {
                
                print(error)
                
            }
        }.resume()
        
    }
}
