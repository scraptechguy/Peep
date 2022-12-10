//
//  PeepView.swift
//  Peep
//
//  Created by Rostislav Brož on 12/9/22.
//

import SwiftUI

struct PeepView: View {
    
    @EnvironmentObject var model: ContentModel
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack {
                    Image("peep_initial")
                        .padding(.top, 50)
                        .padding(.bottom, 20)
                    
                    Text("Meet Píp")
                        .font(.title2.bold())
                        .foregroundColor(Color("Font"))
                        .padding(.vertical)
                    
                    Text("Píp is a very busy bird, he keeps track of sundials all around the globe. When he feels rather formal, he calls himself Mr. Peep (makes him feel bigger, but in reality, he's not all that big).")
                        .foregroundColor(Color("Font"))
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                    
                    Text("**peep** *verb* [I usually + adv/prep ] - to secretly look at something for a short time, usually through a hole")
                        .foregroundColor(Color("Font"))
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                    
                    Text("*I saw her peeping into the world of sundials using Píp*.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                    
                    Image("peep_initial")
                        .scaleEffect(0.2)
                    
                    Text("Rare footage of Píp's actual size")
                        .foregroundColor(Color("Font"))
                }.padding(.horizontal)
                    .padding(.horizontal)
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            model.showingSettings = false
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

struct PeepView_Previews: PreviewProvider {
    static var previews: some View {
        PeepView()
    }
}
