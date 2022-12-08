//
//  HelpView.swift
//  Peep
//
//  Created by Rostislav Brož on 12/8/22.
//

import SwiftUI

struct HelpView: View {
    
    @EnvironmentObject var model: ContentModel
    
    @State private var index: Int = 0
    @State private var screenIsLast = false
    
    let detailGalleryGuide: LocalizedStringKey = "detailGalleryGuide"
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack {
                TabView(selection: $index) {
                    Image("Help1")
                        .resizable()
                        .scaledToFit()
                        .padding(.bottom, 50)
                        .tag(0)
                    
                    Image("Help2")
                        .resizable()
                        .scaledToFit()
                        .padding(.bottom, 50)
                        .tag(1)
                    
                    Image("dangerous_initial")
                        .tag(2)
                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 650)
                    .ignoresSafeArea()
            }
        }.preferredColorScheme(model.isLightMode ? .dark : .light)
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
            .environmentObject(ContentModel())
            .preferredColorScheme(.dark)
    }
}
