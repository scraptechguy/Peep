//
//  NavigationBar.swift
//  Peep
//
//  Created by Rostislav Brož on 8/30/22.
//

import SwiftUI

struct NavigationBar: View {
    
    @EnvironmentObject var model: ContentModel
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    var body: some View {
        HStack {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(width: screenSize.width / 1.35, height: screenSize.width / 6)
                    .mask(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                    )
                
                HStack {
                    Image(systemName: "location")
                    
                    Text(model.placemark?.locality ?? "Loading...")
                }.padding(.leading, 22)
            }
            
            Button(action: {
                model.showingSettings = true
            }, label: {
                ZStack {
                    Rectangle()
                        .fill(.thinMaterial)
                        .frame(width: screenSize.width / 6, height: screenSize.width / 6)
                        .mask(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                        )
                    
                    Image(systemName: "gear")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.white)
                }
            }).sheet(isPresented: {$model.showingSettings}()) {SettingsView()}
        }
    }
}

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar()
            .environmentObject(ContentModel())
    }
}