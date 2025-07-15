//
//  NavigationBar.swift
//  Peep
//
//  Created by Rostislav Brož on 8/30/22.
//

import SwiftUI
import MapKit

struct NavigationBar: View {
    
    @EnvironmentObject var model: ContentModel
    @EnvironmentObject var data: FetchData
    
    @Binding var centerPlacemark: CLPlacemark?
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.thinMaterial)
                        .frame(width: screenSize.width / 1.35, height: screenSize.width / 8)
                        .mask(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                        )
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color("Font"))
                        
                        if model.authorizationState == .denied || model.authorizationState == .restricted {
                                
                            Text(String(localized: "noLocation"))
                                .tracking(model.didClickOnLocationButtonWhenLocationOff ? 2 : 0)
                                .foregroundColor(Color("Font"))
                                .lineLimit(1)
                                .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5), value: model.didClickOnLocationButtonWhenLocationOff)
                            
                        } else {
                            
                            Text(centerPlacemark == nil ? model.placemark?.locality ?? String(localized: "noRegion") : centerPlacemark?.locality ?? String(localized: "noRegion"))
                                .foregroundColor(Color("Font"))
                                .lineLimit(1)
                            
                        }
                        
                        Spacer()
                        
                        if !data.finishedLoading {
                            ProgressView()
                        }
                    }.padding(.horizontal, 22)
                        .frame(width: screenSize.width / 1.35, alignment: .leading)
                }.onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        model.showingSearch = true
                        model.searchKeyboardIsFocused = true
                    }
                }
                
                Button(action: {
                    model.showingSettings = true
                }, label: {
                    ZStack {
                        Rectangle()
                            .fill(.thinMaterial)
                            .frame(width: screenSize.width / 8, height: screenSize.width / 8)
                            .mask(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                            )
                        
                        Image(systemName: "gear")
                            .foregroundColor(Color("Font"))
                    }
                })
            }
        }.preferredColorScheme(model.isLightMode ? .light : .dark)
    }
}
