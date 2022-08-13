//
//  HomeView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/8/22.
//

import SwiftUI

struct HomeView: View {
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    @State var search = ""
    @State var showingSettings = false
    @State var selectedPlace: Place?
    @State var isRotated = false
    
    var body: some View {
        ZStack {
            Map(selectedPlace: $selectedPlace)
                .ignoresSafeArea()
                .sheet(item: $selectedPlace) { place in
                    PlaceDetail()
                }
            
            VStack {
                HStack {
                    TextField("Search the globe", text: $search)
                        .padding(.all, 20.0)
                        .frame(width: screenSize.width / 1.35, height: screenSize.width / 6)
                        .background(.ultraThinMaterial)
                        .mask(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                        )
                    
                    Button(action: {
                        showingSettings = true
                    }, label: {
                        ZStack {
                            Rectangle()
                                .fill(.ultraThinMaterial)
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
    }
}
