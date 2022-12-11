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
    .init(imageName: "Help3", title: String(localized: "onboardingHeading2"), text: String(localized: "onboardingText2")),
    .init(imageName: "Help4", title: String(localized: "onboardingHeading2"), text: String(localized: "onboardingText2")),
    .init(imageName: "Help5", title: String(localized: "onboardingHeading2"), text: String(localized: "onboardingText2")),
    .init(imageName: "Help6", title: String(localized: "onboardingHeading2"), text: String(localized: "onboardingText2")),
    .init(imageName: "Help7", title: String(localized: "onboardingHeading2"), text: String(localized: "onboardingText2")),
    .init(imageName: "Help8", title: String(localized: "onboardingHeading2"), text: String(localized: "onboardingText2")),
    .init(imageName: "Help9", title: String(localized: "onboardingHeading2"), text: String(localized: "onboardingText2")),
    .init(imageName: "Help10", title: String(localized: "onboardingHeading2"), text: String(localized: "onboardingText2")),

]
