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
    @EnvironmentObject var FetchData: FetchData
    
    @Binding var centerPlacemark: CLPlacemark?
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    @State private var lastSearchedMapRect: MKMapRect?
    
    // Fractional padding to apply around the *last* rect
    private let paddingFraction: Double = 0.1
    var hasUnsearchedArea: Bool {
        guard let last = lastSearchedMapRect else { return true }
        let current = model.mapView.visibleMapRect
        
        // Compute padding based on the last rect’s size
        let padX = last.size.width  * paddingFraction
        let padY = last.size.height * paddingFraction

        // Expand last rect by padding
        let paddedLast = last.insetBy(dx: -padX, dy: -padY)

        // If paddedLast fully contains current, there's no unsearched area
        return !paddedLast.contains(current)
    }
    
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
                        
                        if FetchData.finishedLoading == false {
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
            
            Button(action: {
                model.searchCurrentMapArea()
                
                // record *exactly* what the map is showing right now
                lastSearchedMapRect = model.mapView.visibleMapRect
            }, label: {
                Text("Search this area")
                    .bold()
                    .foregroundColor(Color("Font"))
                    .frame(width: screenSize.width / 3, height: screenSize.height / 25)
                    .padding(.horizontal)
                    .background(.thinMaterial)
                    .mask(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                    )
                    .opacity(hasUnsearchedArea ? 1 : 0)
                    .animation(.easeInOut(duration: 0.2), value: hasUnsearchedArea)
            })
        }.preferredColorScheme(model.isLightMode ? .light : .dark)
    }
}
