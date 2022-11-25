//
//  PointerView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/29/22.
//

import SwiftUI

struct IndicatorView: View {
    
    @EnvironmentObject var model: ContentModel
    
    var place: DataModel
    
    let detailIndicator: LocalizedStringKey = "detailIndicator"
    let indicatorFooter: LocalizedStringKey = "indicatorFooter"
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 50) {
                    HStack {
                        Text(detailIndicator)
                        
                        Text(place.tukazatel ?? "???")
                    }.bold()
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)
                    
                    ExplanationItem(item: "P", explanation: String(localized: "indicatorP"))
                    
                    ExplanationItem(item: "PN", explanation: String(localized: "indicatorPN"))
                    
                    ExplanationItem(item: "K", explanation: String(localized: "indicatorK"))
                    
                    ExplanationItem(item: "KN", explanation: String(localized: "indicatorKN"))
                    
                    Text(indicatorFooter)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            model.showingPointer = false
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

struct PointerView_Previews: PreviewProvider {
    static var previews: some View {
        IndicatorView(place: DataModel())
            .environmentObject(ContentModel())
    }
}
