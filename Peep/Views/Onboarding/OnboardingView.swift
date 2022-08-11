//
//  OnboardingView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/8/22.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var model: ContentModel
    
    @State private var tabSelection = 0
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            TabView(selection: $tabSelection) {
                VStack {
                    HStack {
                        Image("jump_initial")
                            .scaleEffect(1.3)
                        
                        Spacer()
                    }
                    
                    Text("Let's **jump** right in!")
                        .font(.system(size: 22))
                        .foregroundColor(Color("Font"))
                }.tag(0)
                
                VStack {
            
                    
                    Text("Peep needs to know **your location** to deliver accurate data")
                        .padding()
                        .font(.system(size: 22))
                        .foregroundColor(Color("Font"))
                        .multilineTextAlignment(.center)
                    
                    
                }.tag(1)
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .frame(height: 400)
            
            VStack {
                Spacer()
                
                Button(action: {
                    if tabSelection == 0 {
                        withAnimation {
                            tabSelection = 1
                        }
                    } else {
                        model.requestGeolocationPermission()
                    }
                }, label: {
                    Text("Next >")
                        .padding(.bottom, 40)
                        .font(.system(size: 22))
                        .foregroundColor(Color("Font"))
                })
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .preferredColorScheme(.dark)
    }
}
