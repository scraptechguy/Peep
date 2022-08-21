//
//  SettingsView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/9/22.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var data = FetchData()
    
    @State private var url = "https://images.fineartamerica.com/images-medium-large-5/sundial-on-the-wall-of-a-church-martin-bondscience-photo-library.jpg"
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 5) {
                GeometryReader() { geometry in
                    AsyncImage(url: URL(string: url))
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                }.ignoresSafeArea(.all, edges: .top)
               
                Group {
                    Text("Sloveč 1")
                        .padding([.leading, .top])
                        .font(.system(size: 25))
                        .foregroundColor(Color("Font"))
                    
                    Text("budova bývalého statku, zemědělské družstvo")
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
                    
                    Text("https://astro.troja.mff.cuni.cz/mira/sh/json2.php")
                        .lineLimit(1)
                }
                
                Divider()
                    .padding(10)
                    .padding(.horizontal)
                
                HStack(spacing: 0) {
                    Text("Sundial type: ")
                        .padding(.leading)
                        .foregroundColor(Color("Font"))
                    
                    Text("**S**")
                }
                
                Divider()
                    .padding(10)
                    .padding(.horizontal)
                
                HStack(spacing: 0) {
                    Text("Pointer type: ")
                        .padding(.leading)
                        .foregroundColor(Color("Font"))
                    
                    Text("**P**")
                }
                
                Divider()
                    .padding(10)
                    
                Spacer()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.dark)
    }
}
