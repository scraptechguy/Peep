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

    .init(imageName: "Help1", title: String(localized: "onboardingHeading1"), text: String(localized: "onboardingText1")),
    .init(imageName: "Help2", title: String(localized: "onboardingHeading2"), text: String(localized: "onboardingText2")),

]
