//
//  DeniedView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/8/22.
//

import SwiftUI

struct DeniedView: View {
    
    @EnvironmentObject var model: ContentModel
    
    let deniedMainText: LocalizedStringKey = "deniedMainText"
    let deniedSubtitle: LocalizedStringKey = "deniedSubtitle"
    let deniedGuide: LocalizedStringKey = "deniedGuide"
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            VStack {
                Image("broken_initial")
                
                Text(deniedMainText)
                    .padding(25)
                    .foregroundColor(Color("Font"))
                    .multilineTextAlignment(.center)
                
                HStack {
                    Text(deniedSubtitle)
                        .font(.system(size: 12))
                        .foregroundColor(Color("Font"))
                    
                    Link(destination: URL(string: "https://github.com/scraptechguy/Peep/blob/main/docs/PRIVACY.md")!) {
                        Text("**Privacy Policy**")
                            .font(.system(size: 12))
                            .foregroundColor(Color("Font"))
                    }
                }
                
                Text(deniedGuide)
                    .padding(15)
                    .foregroundColor(Color("Font"))
                    .multilineTextAlignment(.center)
            }
        }.preferredColorScheme(model.isLightMode ? .light : .dark)
    }
}

struct DeniedView_Previews: PreviewProvider {
    static var previews: some View {
        DeniedView()
            .preferredColorScheme(.dark)
            .environmentObject(ContentModel())
    }
}
