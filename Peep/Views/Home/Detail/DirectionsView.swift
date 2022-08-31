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
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 5) {
                VStack(alignment: .leading, spacing: 5) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        Text(place.adresa ?? "No address found")
                            .font(.system(size: 25))
                            .foregroundColor(Color("Font"))
                            .padding(.horizontal)
                    }.frame(width: screenSize.width / 1.25)
                    
                    HStack {
                        Text("Directions")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        if let lat = place.zsirka, let long = place.zdelka, let name = place.adresa {
                            
                            Link("Open in Maps", destination: URL(string:"http://maps.apple.com/?ll=\(lat),\(long)&q=\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!)
                                .font(.system(size: 15))
                            
                        }
                    }
                }.padding(.vertical)
                
                DirectionsMap(place: place)
                    .ignoresSafeArea()
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        model.showingDirections = false
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
        }
    }
}
