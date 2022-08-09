//
//  Place.swift
//  Peep
//
//  Created by Rostislav Brož on 8/9/22.
//

import Foundation

class Place: Decodable, Identifiable, ObservableObject {
    
    var id: String?
    var name: String?
    var location: Location?
    var coordinates: Coordinates?
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case name
        case location
        case coordinates
        
    }
}


struct Location: Decodable {
    
    var address1: String?
    var address2: String?
    var address3: String?
    var city: String?
    var zipCode: String?
    var country: String?
    var displayAddress: [String]?
    
    enum CodingKeys: String, CodingKey {
        
        case address1
        case address2
        case address3
        case city
        case zipCode
        case country
        case displayAddress
        
    }
}


struct Coordinates: Decodable {
    
    var latitude: Double?
    var longitude: Double?
    
}
