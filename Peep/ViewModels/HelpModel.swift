//
//  HelpModel.swift
//  Peep
//
//  Created by Rostislav Brož on 12/9/22.
//

import SwiftUI

/// Represents a single help/guide entry in the in-app help system.
struct Help: Identifiable {
    /// Unique identifier for SwiftUI `ForEach` and list diffing.
    var id: String = UUID().uuidString
    
    /// The name of the image asset to display for this help entry.
    var imageName: String
    
    /// The localized title text for this help entry.
    var title: String
    
    /// The localized descriptive or instructional text for this help entry.
    var text: String
}

/// The list of all help/guide entries displayed in the help section of the app.
///
/// Each entry contains a localized title, descriptive text, and an associated image.
/// The array order determines the display order in the UI.
var guides: [Help] = [
    .init(imageName: "Help1", title: String(localized: "helpHeading1"), text: String(localized: "helpText1")),
    .init(imageName: "Help2", title: String(localized: "helpHeading2"), text: String(localized: "helpText2")),
    .init(imageName: "Help3", title: String(localized: "helpHeading3"), text: String(localized: "helpText3")),
    .init(imageName: "Help4", title: String(localized: "helpHeading4"), text: String(localized: "helpText4")),
    .init(imageName: "Help5", title: String(localized: "helpHeading5"), text: String(localized: "helpText5")),
    .init(imageName: "Help6", title: String(localized: "helpHeading6"), text: String(localized: "helpText6")),
    .init(imageName: "Help7", title: String(localized: "helpHeading7"), text: String(localized: "helpText7")),
    .init(imageName: "Help8", title: String(localized: "helpHeading8"), text: String(localized: "helpText8")),
    .init(imageName: "Help9", title: String(localized: "helpHeading9"), text: String(localized: "helpText9")),
    .init(imageName: "Help10", title: String(localized: "helpHeading10"), text: String(localized: "helpText10")),
    .init(imageName: "Help11", title: String(localized: "helpHeading11"), text: String(localized: "helpText11")),
]
