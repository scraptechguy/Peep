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
    
    @State var selectedPlace: DataModel?
    
    var body: some View {
        ZStack {
            Map(selectedPlace: $selectedPlace)
                .ignoresSafeArea()
            
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
                }.padding(.top, 50)
                
                Spacer()
                
                Group {
                    if selectedPlace != nil {
                        PlaceDetail(place: selectedPlace!)
                    } else {
                        Text("Hahah")
                    }
                }.frame(width: screenSize.width, height: 250)
                    .background(
                        .thinMaterial
                    )
                    .mask(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                    )
            }.ignoresSafeArea()
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
