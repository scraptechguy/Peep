//
//  PeepView.swift
//  Peep
//
//  Created by Rostislav Brož on 12/9/22.
//

import SwiftUI

struct PeepView: View {
    
    @EnvironmentObject var model: ContentModel
    
    let peepTitle: LocalizedStringKey = "peepTitle"
    let peepText1: LocalizedStringKey = "peepText1"
    let peepText2: LocalizedStringKey = "peepText2"
    let peepText3: LocalizedStringKey = "peepText3"
    let peepText4: LocalizedStringKey = "peepText4"
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack {
                    Image("peep_initial")
                        .padding(.top, 50)
                        .padding(.bottom, 20)
                    
                    Text(peepTitle)
                        .font(.title2.bold())
                        .foregroundColor(Color("Font"))
                        .padding(.vertical)
                    
                    Text(peepText1)
                        .foregroundColor(Color("Font"))
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                    
                    Text(peepText2)
                        .foregroundColor(Color("Font"))
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                    
                    Text(peepText3)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.bottom)
                    
                    Image("peep_initial")
                        .resizable()
                        .frame(width: 24, height: 20)
                        .padding(.bottom)
                    
                    Text(peepText4)
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
            .environmentObject(ContentModel())
    }
}
