//
//  DirectionsView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/29/22.
//

import SwiftUI

struct DirectionsView: View {
    
    @EnvironmentObject var model: ContentModel
    
    var place: DataModel
    let screenSize: CGRect = UIScreen.main.bounds
    
    let detailDirections: LocalizedStringKey = "detailDirections"
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 5) {
                VStack(alignment: .leading, spacing: 5) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        Text(place.adresa ?? "No address found")
                            .font(.system(size: 25))
                            .foregroundColor(Color("Font"))
                            .padding(.horizontal)
                    }.frame(width: screenSize.width / 1.25)
                    
                    HStack {
                        Text(detailDirections)
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        if let lat = place.zsirka, let long = place.zdelka, let name = place.adresa {
                            
                            Link(String(localized: "detailDirectionsOpen"), destination: URL(string:"http://maps.apple.com/?ll=\(lat),\(long)&q=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!)
                                .font(.system(size: 15))
                            
                        }
                    }
                }.padding(.vertical)
                
                if model.authorizationState == .authorizedAlways || model.authorizationState == .authorizedWhenInUse {
                    
                    DirectionsMap(place: place)
                        .ignoresSafeArea()
                    
                } else {
                    
                    VStack {
                        Text("This feature is only available with location tracking turned on")
                            .foregroundColor(Color("Font"))
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Text(String(localized: "settingsLocationHeading"))
                            .foregroundColor(Color.blue)
                            .multilineTextAlignment(.center)
                            .onTapGesture {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    if UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    }
                                }
                            }
                    }.frame(maxWidth: .infinity, alignment: .center)
                        .frame(maxHeight: .infinity, alignment: .center)
                    
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            model.showingDirections = false
                        }
                    }, label: {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                            
                            Image(systemName: "multiply")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }.frame(width: 35, height: 35)
                            .padding(.trailing)
                            .padding(.top, 12)
                    })
                }
                
                Spacer()
            }
        }.preferredColorScheme(model.isLightMode ? .light : .dark)
    }
}
