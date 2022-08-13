//
//  DataModel.swift
//  Peep
//
//  Created by Rostislav Brož on 8/13/22.
//

import Foundation

struct DataModel: Codable, Identifiable {
    
    var id: String?
    var adresa: String?
    var umisteni: String?
    var zdelka: String?
    var zsirka: String?
    var thodin: String?
    var tukazatel: String?
    var tciselnik: String?
    var azimut: String?
    var dnodus: String?
    var cislice: String?
    var vznik: String?
    var stav: String?
    var evc: String?
    var obrazky: String?

}
