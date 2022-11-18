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

    .init(imageName: "peep_initial", title: "Peep is a good bird"),
    .init(imageName: "peep_initial", title: "Really good bird"),

]
