//
//  OnboardingModel.swift
//  Peep
//
//  Created by Rostislav Brož on 11/18/22.
//

import SwiftUI

/// Represents a single page in the app’s onboarding/intro flow.
struct Intro: Identifiable {
    /// Unique identifier for SwiftUI `ForEach` and diffing.
    var id: String = UUID().uuidString
    
    /// The name of the image asset to display on this onboarding page.
    var imageName: String
    
    /// The localized title text for this onboarding page.
    var title: String
    
    /// The localized descriptive text for this onboarding page.
    var text: String
}

/// The list of onboarding pages shown to the user on first launch.
///
/// - Note: Text values are localized via `String(localized:)` to support multiple languages.
var intros: [Intro] = [
    .init(imageName: "sundials", title: String(localized: "onboardingHeading1"), text: String(localized: "onboardingText1")),
    .init(imageName: "detail", title: String(localized: "onboardingHeading2"), text: String(localized: "onboardingText2")),
]
