//
//  RequestView.swift
//  Peep
//
//  Created by Rostislav Brož on 26.05.2025.
//

import SwiftUI

struct RequestView: View {
    
    @EnvironmentObject var model: ContentModel
    
    let welcomeHeading: LocalizedStringKey = "welcomeHeading"
    let welcomeText: LocalizedStringKey = "welcomeText"
    let nextButton: LocalizedStringKey = "nextButton"
    let welcomeSubtitle: LocalizedStringKey = "welcomeSubtitle"
    let privacyButton: LocalizedStringKey = "privacyButton"
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            
            Image("dangerous_initial")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150)
                .padding(.bottom, 60)
                .padding(.horizontal, 20)
            
            Text(welcomeHeading)
                .bold()
                .font(.system(size: 28))
            
            Text(welcomeText)
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer()
            
            ZStack {
                ZStack {
                    HStack {
                        Text(nextButton)
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Image(systemName: "arrow.right")
                            .font(.title3.bold())
                            .foregroundColor(.white)
                    }.padding(.horizontal, 15)
                        .scaleEffect(1)
                        .frame(height: nil)
                }.frame(width: screenSize.width / 1.5, height: 50)
                    .foregroundColor(.white)
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .background(.ultraThinMaterial)
                            .background(
                                Image("Blob")
                                    .scaleEffect(1.2)
                            )
                            .mask(
                                RoundedRectangle(cornerRadius: 15, style: .continuous)
                            )
                    }
                    .onTapGesture {
                        model.requestGeolocationPermission()
                    }
            }.frame(width: screenSize.width / 1, height: 50)
                .overlay(alignment: .bottom) {
                    HStack(spacing: 5) {
                        Text(welcomeSubtitle)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Link(destination: URL(string: "https://github.com/scraptechguy/Peep/blob/main/docs/PRIVACY.md")!) {
                            Text(privacyButton)
                                .font(.system(size: 14))
                                .foregroundColor(Color("Font"))
                        }
                    }.offset(y: screenSize.height / 28)
                }
        }.offset(y: -30)
            .preferredColorScheme(model.isLightMode ? .light : .dark)
    }
}

struct RequestView_Previews: PreviewProvider {
    static var previews: some View {
        RequestView()
            .environmentObject(ContentModel())
    }
}
