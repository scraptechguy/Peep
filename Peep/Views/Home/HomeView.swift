//
//  HomeView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/8/22.
//

import SwiftUI

struct HomeView: View {
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    @EnvironmentObject var model: ContentModel
    
    @State var showingSettings = false
    @State var selectedPlace: DataModel?
    @State var isRotated = false
    
    var body: some View {
        ZStack {
            Map(selectedPlace: $selectedPlace)
                .ignoresSafeArea()
                .sheet(item: $selectedPlace) { place in
                    PlaceDetail(place: place)
                }
            
            VStack {
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
                        showingSettings = true
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
                                .rotationEffect(Angle.degrees(isRotated ? 360 : 0))
                        }
                    }).sheet(isPresented: {$showingSettings}()) {SettingsView()}
                }
                
                Spacer()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .preferredColorScheme(.dark)
            .environmentObject(ContentModel())
    }
}
