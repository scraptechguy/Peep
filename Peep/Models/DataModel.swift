//
//  DataModel.swift
//  Peep
//
//  Created by Rostislav Brož on 8/13/22.
//

import Foundation

/// Represents a single sundial record from the Peep database.
///
/// This model is decoded from JSON provided by the database and
/// contains both descriptive metadata and technical parameters about a sundial.
struct DataModel: Codable, Identifiable {
    /// Unique identifier for the sundial (database primary key).
    var id: String?
    
    /// Street address or location name where the sundial is installed.
    var adresa: String?
    
    /// More specific placement details (e.g., "on south wall", "in courtyard").
    var umisteni: String?
    
    /// Longitude coordinate in decimal degrees (East positive).
    var zdelka: String?
    
    /// Latitude coordinate in decimal degrees (North positive).
    var zsirka: String?
    
    /// Time range the sundial shows (e.g., "6–18").
    var thodin: String?
    
    /// Type of gnomon (shadow-casting part of the sundial).
    var tukazatel: String?
    
    /// Type of hour line numerals (e.g., Roman, Arabic).
    var tciselnik: String?
    
    /// Azimuth orientation of the sundial face (degrees from North).
    var azimut: String?
    
    var dnodus: String?
    
    /// The style of numerals or hour markings.
    var cislice: String?
    
    /// Year or date when the sundial was created.
    var vznik: String?
    
    /// Current condition/state of the sundial (e.g., "good", "damaged").
    var stav: String?
    
    /// Official registry or catalog number.
    var evc: String?
    
    /// Array of URLs for associated images.
    var obrazky: [String]?
    
    /// Public accessibility (e.g., "good", "after buying a ticket")
    var pristup: String?
    
    /// Visual appearance description. (e.g., "with a sign")
    var vzhled: String?
    
    /// Initials of the person that added the sundial to the database.
    var zhotovitel: String?
    
    /// Year when someone last saw the sundial in person.
    var overeni: String?
    
    /// Initials of the person that last saw the sundial in person.
    var overitel: String?
    
    /// Additional notes about the sundial.
    var poznamka: String?
}
