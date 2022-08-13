//
//  FetchData.swift
//  Peep
//
//  Created by Rostislav Brož on 8/13/22.
//

import Foundation

class FetchData: ObservableObject {
    
    @Published var dataList = [DataModel]()
    
    init () {
        let url = URL(string: "https://astro.troja.mff.cuni.cz/mira/sh/json.php")!
        
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            do {
                if let todoData = data {
                    let decodedData = try JSONDecoder().decode([DataModel].self, from: todoData)
                    
                    DispatchQueue.main.async {
                        self.dataList = decodedData
                    }
                } else {
                    print("No data received")
                }
            } catch let error {
                print(error)
            }
        }.resume()
    }
}
