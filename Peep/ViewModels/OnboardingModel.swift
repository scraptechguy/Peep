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
    
}

var intros: [Intro] = [

    .init(imageName: "rotty_mad", title: "Don't be a jerk"),
    .init(imageName: "rotty_coolaf", title: "Be cool af"),

]
