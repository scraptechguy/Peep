//
//  OnboardingView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/8/22.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var model: ContentModel
    
    let screenSize: CGRect = UIScreen.main.bounds
    
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
                    Image("peep_initial")
                        .scaleEffect(0.9)
                    
                    Text("Peep is a good bird")
                        .padding(30)
                        .font(.system(size: 20))
                        .foregroundColor(Color("Font"))
                        .multilineTextAlignment(.center)
                }.tag(1)
                
                VStack {
                    Image("dangerous_initial")
                        .scaleEffect(0.9)
                    
                    Text("Peep wants to use **your location** to deliver accurate data, click **next** to allow him to do so")
                        .padding(30)
                        .font(.system(size: 20))
                        .foregroundColor(Color("Font"))
                        .multilineTextAlignment(.center)
                }.tag(2)
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .frame(height: screenSize.width / 0.9)
            
            VStack {
                Spacer()
                
                if tabSelection == 0 {
                    Button(action: {
                        withAnimation {
                            tabSelection = 1
                        }
                    }, label: {
                        Text("Let's go!")
                            .padding(.bottom, 40)
                            .font(.system(size: 25))
                            .foregroundColor(Color("Font"))
                    })
                } else if tabSelection == 1 {
                    Button(action: {
                        withAnimation {
                            tabSelection = 2
                        }
                    }, label: {
                        Text("Okay!")
                            .padding(.bottom, 40)
                            .font(.system(size: 25))
                            .foregroundColor(Color("Font"))
                    })
                } else {
                    ZStack {
                        Button(action: {
                            model.requestGeolocationPermission()
                        }, label: {
                            Text("Next")
                                .padding(.bottom, 40)
                                .font(.system(size: 25))
                                .foregroundColor(Color("Font"))
                        })
                        
                        HStack(spacing: 0) {
                            Text("By proceeding you agree to our ")
                                .font(.system(size: 12))
                                .foregroundColor(Color("Font"))
                            
                            Link(destination: URL(string: "https://github.com/scraptechguy/Peep/blob/main/docs/PRIVACY.md")!) {
                                Text("**Privacy Policy**")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color("Font"))
                            }
                        }.padding(.top, 30)
                    }
                }
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
