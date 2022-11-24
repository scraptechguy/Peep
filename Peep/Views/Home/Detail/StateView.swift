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
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 50) {
                    HStack {
                        Text("State: ")
                        
                        Text(place.stav ?? "???")
                    }.bold()
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)
                    
                    ExplanationItem(item: "V", explanation: "Sundials are in great shape")
                    
                    ExplanationItem(item: "D", explanation: "Sundials are in a pretty good shape")
                    
                    ExplanationItem(item: "P", explanation: "Sundials are slightly damaged")
                    
                    ExplanationItem(item: "PZ", explanation: "Sundials are severly damaged")
                    
                    ExplanationItem(item: "PZ", explanation: "Sundials are considerably damaged")
                    
                    ExplanationItem(item: "U", explanation: "All that's left is the indicator")
                    
                    ExplanationItem(item: "C", explanation: "All that's left is the dial")
                    
                    ExplanationItem(item: "Z", explanation: "Sundials are destroyed")
                    
                    ExplanationItem(item: "X", explanation: "Sundials are yet to be built")
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
