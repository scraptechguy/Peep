//
//  PlaceDetail.swift
//  Peep
//
//  Created by Rostislav Brož on 8/9/22.
//

import SwiftUI

struct PlaceDetail: View {
    
    var place: DataModel
    let screenSize: CGRect = UIScreen.main.bounds
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                AsyncImage(url: URL(string: "https://astro.mff.cuni.cz/mira/sh/icons/640x640/\(place.obrazky ?? "1_NB_09-DP-1984.jpg")"))
                    .scaledToFill()
                    .frame(width: screenSize.width, height: screenSize.width)
                    .clipped()
                    .ignoresSafeArea(.all, edges: .top)
                
                VStack {
                    Spacer()
                        
                    ScrollView(.horizontal, showsIndicators: false) {
                        Text(place.adresa ?? "")
                            .padding()
                            .font(.system(size: 25))
                            .foregroundColor(Color("Font"))
                            .frame(width: screenSize.width / 0.1)
                            .lineLimit(1)
                            .background(.ultraThinMaterial)
                    }
                }
            }
                        
            List {
                Section(header: Text("Additional information")) {
                    HStack {
                        Text("Description: ")
                            .foregroundColor(Color("Font"))
                        
                        Text(place.umisteni ?? "")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Website: ")
                            .foregroundColor(Color("Font"))
                        
                        Link(destination: URL(string: "https://astro.troja.mff.cuni.cz/mira/sh/sh.php?rec=\(place.id ?? "16394")")!) {
                            Text(place.id ?? "No id found")
                        }
                    }
                    
                    HStack {
                        Text("Sundial type: ")
                            .foregroundColor(Color("Font"))
                        
                        Text(place.thodin ?? "")
                            .bold()
                    }
                    
                    HStack {
                        Text("Pointer type: ")
                            .foregroundColor(Color("Font"))
                        
                        Text(place.tukazatel ?? "")
                            .bold()
                    }
                    
                    HStack {
                        Text("Dial type: ")
                            .foregroundColor(Color("Font"))
                        
                        Text(place.tciselnik ?? "")
                            .bold()
                    }
                }
            }
        }
    }
}
