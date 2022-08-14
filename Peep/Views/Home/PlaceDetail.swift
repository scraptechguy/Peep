//
//  PlaceDetail.swift
//  Peep
//
//  Created by Rostislav Brož on 8/9/22.
//

import SwiftUI

struct PlaceDetail: View {
    
    var place: DataModel
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 5) {
                GeometryReader() { geometry in
                    AsyncImage(url: URL(string: "https://astro.mff.cuni.cz/mira/sh/icons/90x60/\(place.obrazky ?? "1_NB_09-DP-1984.jpg")"))
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                }.ignoresSafeArea(.all, edges: .top)
               
                Group {
                    Text(place.adresa ?? "")
                        .padding([.leading, .top])
                        .font(.system(size: 25))
                        .foregroundColor(Color("Font"))
                    
                    Text(place.umisteni ?? "")
                        .padding(.leading)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                    
                    Divider()
                        .padding(10)
                }
                
                HStack(spacing: 0) {
                    Text("**Website:** ")
                        .padding(.leading)
                        .foregroundColor(Color("Font"))
                    
                    Link(destination: URL(string: "https://astro.troja.mff.cuni.cz/mira/sh/sh.php?rec=\(place.id ?? "16394")")!) {
                        Text(place.id ?? "No id found")
                    }
                }
                
                Divider()
                    .padding(10)
                    .padding(.horizontal)
                
                HStack(spacing: 0) {
                    Text("Sundial type: ")
                        .padding(.leading)
                        .foregroundColor(Color("Font"))
                    
                    Text(place.thodin ?? "")
                        .bold()
                }
                
                Divider()
                    .padding(10)
                    .padding(.horizontal)
                
                Group {
                    HStack(spacing: 0) {
                        Text("Pointer type: ")
                            .padding(.leading)
                            .foregroundColor(Color("Font"))
                        
                        Text(place.tukazatel ?? "")
                            .bold()
                    }
                    
                    Divider()
                        .padding(10)
                        .padding(.horizontal)
                }
                
                HStack(spacing: 0) {
                    Text("Dial type: ")
                        .padding(.leading)
                        .foregroundColor(Color("Font"))
                    
                    Text(place.tciselnik ?? "")
                        .bold()
                }
                
                Divider()
                    .padding(10)
                    
                Spacer()
            }
        }
    }
}
