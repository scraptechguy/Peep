//
//  CreditsView.swift
//  Peep
//
//  Created by Rostislav Brož on 09.08.2025.
//

import SwiftUI

struct CreditsView: View {
    @EnvironmentObject var model: ContentModel
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    let settingsThanks: LocalizedStringKey = "settingsThanks"
    let settingsAuthors: LocalizedStringKey = "settingsAuthors"
    let settingsThanksOthers: LocalizedStringKey = "settingsThanksOthers"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text(settingsThanks)
                    .font(.footnote)
                    .foregroundStyle(Color.primary)
                    .listRowBackground(Color.clear)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
                    .padding(.horizontal)
                
                Text(settingsAuthors)
                    .font(.footnote)
                    .foregroundStyle(Color.primary)
                    .listRowBackground(Color.clear)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Text(settingsThanksOthers)
                    .font(.footnote)
                    .foregroundStyle(Color.primary)
                    .listRowBackground(Color.clear)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 40)
            }
        }
    }
}

struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsView()
            .environmentObject(ContentModel())
    }
}
