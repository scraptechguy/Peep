//
//  DialView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/29/22.
//

import SwiftUI

struct DialView: View {
    
    @EnvironmentObject var model: ContentModel
    
    var place: DataModel
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 50) {
                    HStack {
                        Text("Dial: ")
                        
                        Text(place.tciselnik ?? "???")
                    }.bold()
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)
                    
                    Group {
                        ExplanationItem(item: "C", explanation: "Dial has numbers")
                        
                        ExplanationItem(item: "Z", explanation: "Dial has labels")
                        
                        ExplanationItem(item: "R", explanation: "Dial has tics (every 1/number h)")
                        
                        ExplanationItem(item: "O", explanation: "1 - 24 range")
                        
                        ExplanationItem(item: "P", explanation: "1 - 12 range")
                    }
                    
                    Group {
                        ExplanationItem(item: "L", explanation: "Summer time dial")
                        
                        ExplanationItem(item: "D", explanation: "Dial has date lines (number)")
                        
                        ExplanationItem(item: "A", explanation: "Analemma")
                        
                        ExplanationItem(item: "S", explanation: "\"Special\" dial")
                        
                        ExplanationItem(item: "G", explanation: "Dial has gnomonic error")
                    }
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            model.showingDial = false
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

struct DialView_Previews: PreviewProvider {
    static var previews: some View {
        DialView(place: DataModel())
            .environmentObject(ContentModel())
    }
}
