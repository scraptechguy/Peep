//
//  HelpModel.swift
//  Peep
//
//  Created by Rostislav Brož on 12/9/22.
//

import SwiftUI

struct Help: Identifiable {
    
    var id: String = UUID().uuidString
    var imageName: String
    var title: String
    var text: String
    
}

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

]
