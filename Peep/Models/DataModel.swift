//
//  DataModel.swift
//  Peep
//
//  Created by Rostislav Brož on 8/13/22.
//

import Foundation

struct DataModel: Codable, Identifiable {
    
    var id: Int
    var title: String
    var body: String
    
}
