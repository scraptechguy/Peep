//
//  TypeView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/29/22.
//

import SwiftUI

struct TypeView: View {
    
    @EnvironmentObject var model: ContentModel
    
    @State var hasScrolled: Bool = false
    
    var place: DataModel
    
    let detailType: LocalizedStringKey = "detailType"
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 50) {
                    HStack {
                        Text(detailType)
                        
                        Text(place.thodin ?? "???")
                    }.font(.title.bold())
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)
                    
                    Group {
                        ExplanationItem(item: "S", explanation: String(localized: "typeS"))
                        
                        ExplanationItem(item: "V", explanation: String(localized: "typeV"))
                        
                        ExplanationItem(item: "R", explanation: String(localized: "typeR"))
                        
                        ExplanationItem(item: "P", explanation: String(localized: "typeP"))
                        
                        ExplanationItem(item: "PP", explanation: String(localized: "typePP"))
                        
                        ExplanationItem(item: "PJ", explanation: String(localized: "typePJ"))
                    }
                    
                    Group {
                        ExplanationItem(item: "K", explanation: String(localized: "typeK"))
                        
                        ExplanationItem(item: "A", explanation: String(localized: "typeA"))
                        
                        ExplanationItem(item: "E", explanation: String(localized: "typeE"))
                        
                        ExplanationItem(item: "Y", explanation: String(localized: "typeY"))
                        
                        ExplanationItem(item: "O", explanation: String(localized: "typeO"))
                        
                        ExplanationItem(item: "M", explanation: String(localized: "typeM"))
                    }
                }.padding(.bottom)
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
    
    var scrollDetection: some View {
        GeometryReader { proxy in
            let offset = proxy.frame(in: .named("scroll")).minY
            Color.clear.preference(key: ScrollPreferenceKey.self, value: offset)
        }.frame(height: 0)
            .onPreferenceChange(ScrollPreferenceKey.self) { value in
                withAnimation(.easeInOut) {
                    if value < 0 {
                        hasScrolled = true
                    } else {
                        hasScrolled = false
                    }
                }
            }
    }
}

struct TypeView_Previews: PreviewProvider {
    static var previews: some View {
        TypeView(place: DataModel())
            .environmentObject(ContentModel())
    }
}
