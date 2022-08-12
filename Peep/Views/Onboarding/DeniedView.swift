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
                Spacer()
                Spacer()
                
                Image("broken_initial")
                
                Text("Peep needs to **track your location** in order for the app to **work**")
                    .padding(25)
                    .foregroundColor(Color("Font"))
                    .multilineTextAlignment(.center)
                
                HStack {
                    Text("He'll use it wisely... ")
                        .font(.system(size: 12))
                        .foregroundColor(Color("Font"))
                    
                    Link(destination: URL(string: "https://github.com/scraptechguy/Peep/blob/main/docs/PRIVACY.md")!) {
                        Text("**Privacy Policy**")
                            .font(.system(size: 12))
                            .foregroundColor(Color("Font"))
                    }
                }
                
                Spacer()
                
                HStack {
                    Image("Blob")
                        .resizable()
                        .scaleEffect(2)
                        .mask(Circle())
                        .frame(width: 8, height: 8)
                    
                    Text("Open iPhone **Settings**")
                        .font(.system(size: 15))
                }
                
                HStack {
                    Image("Blob")
                        .resizable()
                        .scaleEffect(2)
                        .mask(Circle())
                        .frame(width: 8, height: 8)
                    
                    Text("Scroll till you see **Peep**")
                        .font(.system(size: 15))
                }
                
                HStack {
                    Image("Blob")
                        .resizable()
                        .scaleEffect(2)
                        .mask(Circle())
                        .frame(width: 8, height: 8)
                    
                    Text("**Allow** location use")
                        .font(.system(size: 15))
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
        }
    }
}

struct DeniedView_Previews: PreviewProvider {
    static var previews: some View {
        DeniedView()
            .preferredColorScheme(.dark)
            .environmentObject(ContentModel())
    }
}
