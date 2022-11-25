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
    
    let detailDial: LocalizedStringKey = "detailDial"
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 50) {
                    HStack {
                        Text(detailDial)
                        
                        Text(place.tciselnik ?? "???")
                    }.bold()
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)
                    
                    Group {
                        ExplanationItem(item: "C", explanation: String(localized: "dialC"))
                        
                        ExplanationItem(item: "Z", explanation: String(localized: "dialZ"))
                        
                        ExplanationItem(item: "R", explanation: String(localized: "dialR"))
                        
                        ExplanationItem(item: "O", explanation: String(localized: "dialO"))
                        
                        ExplanationItem(item: "P", explanation: String(localized: "dialP"))
                    }
                    
                    Group {
                        ExplanationItem(item: "L", explanation: String(localized: "dialL"))
                        
                        ExplanationItem(item: "D", explanation: String(localized: "dialD"))
                        
                        ExplanationItem(item: "A", explanation: String(localized: "dialA"))
                        
                        ExplanationItem(item: "S", explanation: String(localized: "dialS"))
                        
                        ExplanationItem(item: "G", explanation: String(localized: "dialG"))
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
