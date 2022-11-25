//
//  StateView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/29/22.
//

import SwiftUI

struct StateView: View {
    
    @EnvironmentObject var model: ContentModel
    
    var place: DataModel
    
    let detailState: LocalizedStringKey = "detailState"
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 50) {
                    HStack {
                        Text(detailState)
                        
                        Text(place.stav ?? "???")
                    }.bold()
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)
                    
                    ExplanationItem(item: "V", explanation: String(localized: "stateV"))
                    
                    ExplanationItem(item: "D", explanation: String(localized: "stateD"))
                    
                    ExplanationItem(item: "P", explanation: String(localized: "stateP"))
                    
                    ExplanationItem(item: "PZ", explanation: String(localized: "statePZ"))
                    
                    ExplanationItem(item: "U", explanation: String(localized: "stateU"))
                    
                    ExplanationItem(item: "C", explanation: String(localized: "stateC"))
                    
                    ExplanationItem(item: "Z", explanation: String(localized: "stateZ"))
                    
                    ExplanationItem(item: "X", explanation: String(localized: "stateX"))
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            model.showingState = false
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

struct StateView_Previews: PreviewProvider {
    static var previews: some View {
        StateView(place: DataModel())
            .environmentObject(ContentModel())
    }
}
