//
//  Gallery.swift
//  Peep
//
//  Created by Rostislav Brož on 11/22/22.
//

import SwiftUI

struct Gallery: View {
    
    @EnvironmentObject var model: ContentModel
    
    var place: DataModel
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    let detailGalleryHeading: LocalizedStringKey = "detailGalleryHeading"
    let detailGalleryGuide: LocalizedStringKey = "detailGalleryGuide"
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .frame(width: screenSize.width, height: screenSize.height)
                .ignoresSafeArea()
            
            TabView(selection: $model.index) {
                ForEach(place.obrazky?.indices ?? [""].indices, id: \.self) { i in
                    GeometryReader { proxy in
                        VStack {
                            Spacer()
                            
                            HStack {
                                Spacer()
                                
                                AsyncImage(url: URL(string: "https://astro.mff.cuni.cz/mira/sh/icons/640x640/\(place.obrazky?[i] ?? "")"))
                                    .scaledToFill()
                                    .frame(width: screenSize.width / 1.2, height: screenSize.width / 1.2)
                                    .clipped()
                                    .mask(
                                        RoundedRectangle(cornerRadius: 22)
                                    )
                                    .rotation3DEffect(.degrees(proxy.frame(in: .global).minX / -10), axis: (x: 0, y: 1, z: 0))
                                    .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 10)
                                    .blur(radius: abs(proxy.frame(in: .global).minX / 40))
                                
                                Spacer()
                            }
                            
                            Spacer()
                        }.frame(width: screenSize.width, height: screenSize.height / 1.5, alignment: .center)
                    }.tag(i)
                }
            }.tabViewStyle(.page(indexDisplayMode: .never))
                .frame(width: screenSize.width, height: screenSize.height, alignment: .center)
           
            VStack {
                Spacer()
                
                Text(detailGalleryGuide)
                    .font(.title3)
                    .padding(.bottom, 100)
            }.frame(height: screenSize.height)
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            model.showingGallery = false
                            model.index = 0
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
                            .padding(.top, 45)
                    })
                }
                
                Spacer()
            }
        }
    }
}
