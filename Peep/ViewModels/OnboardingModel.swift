//
//  OnboardingModel.swift
//  Peep
//
//  Created by Rostislav Brož on 11/18/22.
//

import SwiftUI

struct Intro: Identifiable {
    
    var id: String = UUID().uuidString
    var imageName: String
    var title: String
    var text: String
    
}

var intros: [Intro] = [

    .init(imageName: "sundials", title: String(localized: "onboardingHeading1"), text: String(localized: "onboardingText1")),
    .init(imageName: "detail", title: String(localized: "onboardingHeading2"), text: String(localized: "onboardingText2")),

]
