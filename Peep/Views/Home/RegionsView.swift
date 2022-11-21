//
//  RegionsView.swift
//  Peep
//
//  Created by Rostislav Brož on 9/19/22.
//

import SwiftUI

struct RegionsView: View {
    
    @EnvironmentObject var model: ContentModel
    
    let settingsRegions: LocalizedStringKey = "settingsRegions"
    let settingsRegionsCzechiaSouth: LocalizedStringKey = "settingsRegionsCzechiaSouth"
    let ettingsRegionsCzechiaNorth: LocalizedStringKey = "ettingsRegionsCzechiaNorth"
    let settingsRegionsCzechiaWest: LocalizedStringKey = "settingsRegionsCzechiaWest"
    let settingsRegionsCzechiaEast: LocalizedStringKey = "settingsRegionsCzechiaEast"
    let settingsRegionsSubtitle2: LocalizedStringKey = "settingsRegionsSubtitle2"
    
    var body: some View {
        List {
            Section(header: Text(settingsRegions), footer: Text(settingsRegionsSubtitle2)) {
                ForEach(model.regions.indices, id: \.self) { i in
                    Button(action: {
                            
                        }, label: {
                            HStack {
                                Text(model.regions[i])
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                
                                Image(systemName: "checkmark")
                                    .foregroundColor(.primary)
                            }
                    })
                }
            }
        }.preferredColorScheme(model.isLightMode ? .light : .dark)
    }
}

struct RegionsView_Previews: PreviewProvider {
    static var previews: some View {
        RegionsView()
            .environmentObject(ContentModel())
            .preferredColorScheme(.dark)
    }
}
