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
                    
                    let decodedData = try JSONDecoder().decode([DataModel].self, from: todoData)
                    
                    DispatchQueue.main.async {
                        self.dataList = decodedData
                    }
                    
                } else {
                    
                    print("No data received, using offline database")
                    
                    guard let url = Bundle.main.url(forResource: "OfflineDatabase", withExtension: "geojson")
                    else {
                        
                        print("Json file not found")
                        
                        return
                        
                    }
                    
                    let data = try Data(contentsOf: url)
                    let decodedData = try JSONDecoder().decode([DataModel].self, from: data)
                    self.dataList = decodedData
                    
                }
                
            } catch let error {
                
                print(error)
                
            }
        }.resume()
        
    }
}
