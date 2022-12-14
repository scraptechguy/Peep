//
//  HomeView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/8/22.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var model: ContentModel
    
    @State var selectedPlace: DataModel?
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    var body: some View {
        ZStack {
            Map(selectedPlace: $selectedPlace)
                .ignoresSafeArea()
            
            VStack {
                NavigationBar()
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        if model.authorizationState == .authorizedAlways || model.authorizationState == .authorizedWhenInUse {
                                
                            withAnimation {
                                if !model.isOnLocation {
                                    
                                    model.goToLocation = true
                                    model.isOnLocation = true
                                    
                                    model.devLog = String(localized: "userLocation")
                                    
                                }
                            }
                                
                        } else {
                            
                            withAnimation(.spring(blendDuration: 0.5)) {
                                model.didClickOnLocationButtonWhenLocationOff = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation(.spring(blendDuration: 0.5)) {
                                    model.didClickOnLocationButtonWhenLocationOff = false
                                }
                            }
                            
                        }
                    }, label: {
                        if model.authorizationState == .authorizedAlways || model.authorizationState == .authorizedWhenInUse {
                            
                            Image(systemName: model.isOnLocation ? "location.fill" : "location")
                                .foregroundColor(.primary)
                                .padding()
                                .background {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .overlay(.ultraThinMaterial)
                                        .mask(
                                            RoundedRectangle(cornerRadius: 30, style: .circular)
                                        )
                                }
                            
                        } else {
                            
                            Image(systemName: "location")
                                .foregroundColor(.primary)
                                .padding()
                                .background {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .overlay(.ultraThinMaterial)
                                        .mask(
                                            RoundedRectangle(cornerRadius: 30, style: .circular)
                                        )
                                }
                            
                        }
                    }).padding(.trailing)
                }.padding(.bottom, screenSize.height / 10.2)
                    .padding(.bottom)
            }.ignoresSafeArea()
            
            PlaceDetail(place: selectedPlace ?? DataModel.init(id: ""))
            
            if model.showingGallery {
                
                Gallery(place: selectedPlace!)
                
            }
        }.preferredColorScheme(model.isLightMode ? .light : .dark)
            .onChange(of: model.annotationSelected, perform: { newValue in
                if !model.annotationSelected {
                    
                    model.shouldDeselectAnnotations = true
                    
                }
            })
            .onChange(of: model.authorizationState, perform: { newValue in
                if model.authorizationState == .authorizedAlways || model.authorizationState == .authorizedWhenInUse {
                    
                    model.shouldCheckIsOnLocation = true
                    
                }
                
                model.shouldDeselectAnnotations = true
            })
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .preferredColorScheme(.dark)
            .environmentObject(ContentModel())
            .environmentObject(FetchData())
    }
}
