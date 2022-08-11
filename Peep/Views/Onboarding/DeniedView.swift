//
//  DeniedView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/8/22.
//

import SwiftUI

struct DeniedView: View {
    @EnvironmentObject var model: ContentModel
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            VStack {
                Image("broken_initial")
                
                Text("Peep needs to **track your location** in order for the app to **work**")
                    .padding(25)
                    .foregroundColor(Color("Font"))
                    .multilineTextAlignment(.center)
                
                HStack {
                    Text("He'll use it wisely... ")
                        .font(.system(size: 12))
                        .foregroundColor(Color("Font"))
                    
                    Link(destination: URL(string: "https://youtu.be/dQw4w9WgXcQ")!) {
                        Text("**Privacy Policy**")
                            .font(.system(size: 12))
                            .foregroundColor(Color("Font"))
                    }
                }
            }
        }
    }
}

struct DeniedView_Previews: PreviewProvider {
    static var previews: some View {
        DeniedView()
            .environmentObject(ContentModel())
    }
}
