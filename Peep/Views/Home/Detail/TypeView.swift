//
//  TypeView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/29/22.
//

import SwiftUI

struct TypeView: View {
    
    @EnvironmentObject var model: ContentModel
    
    var place: DataModel
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 50) {
                    HStack {
                        Text("Type: ")
                        
                        Text(place.thodin ?? "???")
                    }.bold()
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)
                    
                    Group {
                        ExplanationItem(item: "S", explanation: "Vertical sundial")
                        
                        ExplanationItem(item: "V", explanation: "Horizontal sundial")
                        
                        ExplanationItem(item: "R", explanation: "Equatorial sundial")
                        
                        ExplanationItem(item: "P", explanation: "Polar sundial")
                        
                        ExplanationItem(item: "PP", explanation: "Ring polar sundial")
                        
                        ExplanationItem(item: "PJ", explanation: "Southern polar sundial")
                    }
                    
                    Group {
                        ExplanationItem(item: "K", explanation: "Spherical sundial")
                        
                        ExplanationItem(item: "A", explanation: "Analemmatic sundial")
                        
                        ExplanationItem(item: "E", explanation: "\"Extra\" sundial")
                        
                        ExplanationItem(item: "Y", explanation: "Symbol only sundial")
                        
                        ExplanationItem(item: "O", explanation: "Horologe")
                        
                        ExplanationItem(item: "M", explanation: "Portable sundial")
                    }
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            model.showingType = false
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

struct TypeView_Previews: PreviewProvider {
    static var previews: some View {
        TypeView(place: DataModel())
            .environmentObject(ContentModel())
    }
}
