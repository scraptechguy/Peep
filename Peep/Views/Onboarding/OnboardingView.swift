//
//  OnboardingView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/8/22.
//

import SwiftUI

struct OnboardingView: View {
    
    @EnvironmentObject var model: ContentModel
    
    @State var showOnboardingScreens: Bool = false
    @State var currentIndex: Int = 0
    
    let introHeading: LocalizedStringKey = "introHeading"
    let introText: LocalizedStringKey = "introText"
    let introButton: LocalizedStringKey = "introButton"
    
    let skipButton: LocalizedStringKey = "skipButton"
    
    let onboardingHeading1: LocalizedStringKey = "onboardingHeading1"
    let onboardingText1: LocalizedStringKey = "onboardingText1"
    
    let onboardingHeading2: LocalizedStringKey = "onboardingHeading2"
    let onboardingText2: LocalizedStringKey = "onboardingText2"
    
    let welcomeHeading: LocalizedStringKey = "welcomeHeading"
    let welcomeText: LocalizedStringKey = "welcomeText"
    let nextButton: LocalizedStringKey = "nextButton"
    let welcomeSubtitle: LocalizedStringKey = "welcomeSubtitle"
    let privacyButton: LocalizedStringKey = "privacyButton"
    
    let signUpHeading: LocalizedStringKey = "signUpHeading"
    let signUpPasswordHeading: LocalizedStringKey = "signUpPassword"
    let signUpReenterPasswordHeading: LocalizedStringKey = "signUpReenterPassword"
    
    let logInHeading: LocalizedStringKey = "logInHeading"
    let logInPasswordHeading: LocalizedStringKey = "logInPassword"
    let logInForgot: LocalizedStringKey = "logInForgot"
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            IntroScreen()
            
            OnboardingScreens()
            
            NavigationBar()
        }.animation(.interactiveSpring(response: 1.1, dampingFraction: 0.85, blendDuration: 0.85), value: showOnboardingScreens)
            .preferredColorScheme(model.isLightMode ? .light : .dark)
    }
    
    // MARK: - Intro screen
    
    @ViewBuilder
    func IntroScreen() -> some View {
        GeometryReader {
            let size = $0.size
            
            VStack(spacing: 10) {
                Text(introHeading)
                    .bold()
                    .font(.largeTitle)
                
                Text(introText)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Group {
                    Image("jump")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size.width / 1.5, height: size.height / 2)
                }.frame(maxWidth: .infinity, alignment: .leading)
                
                Text(introButton)
                    .bold()
                    .font(.system(size: 17))
                    .padding(.horizontal, 40)
                    .padding(.vertical)
                    .foregroundColor(.white)
                    .background(.ultraThinMaterial)
                    .background(
                        Image("Blob")
                            .scaleEffect(1.2)
                    )
                    .mask(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                    )
                    .onTapGesture {
                        showOnboardingScreens.toggle()
                    }
                    .padding(.top, 20)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .offset(y: showOnboardingScreens ? -size.height : 0)
        }
    }
    
    // MARK: - Navigation bar
    
    @ViewBuilder
    func NavigationBar() -> some View {
        let screenIsLast = currentIndex == intros.count
        
        HStack {
            Button(action: {
                if currentIndex > 0 {
                    
                    currentIndex -= 1
                    
                } else if currentIndex == 0 {
                    
                    showOnboardingScreens.toggle()
                    
                }
            }, label: {
                Image(systemName: "chevron.left")
                    .font(.title3.bold())
                    .foregroundColor(Color("Font"))
            })
            
            Spacer()
            
            Button(action: {
                currentIndex = intros.count
            }, label: {
                Text(skipButton)
                    .foregroundColor(Color("Font"))
            }).opacity(screenIsLast ? 0 : 1)
                .animation(.easeInOut, value: screenIsLast)
        }.padding(.horizontal, 15)
            .padding(.top, 10)
            .frame(maxHeight: .infinity, alignment: .top)
            .offset(y: showOnboardingScreens ? 0 : -120)
    }
    
    // MARK: - Onboarding screen
    
    @ViewBuilder
    func OnboardingScreen(size: CGSize, index: Int) -> some View {
        let intro = intros[index]
        
        VStack(spacing: 10) {
            Text(intro.title)
                .bold()
                .font(.system(size: 28))
                .offset(x: -size.width * CGFloat(currentIndex - index))
                .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5).delay(currentIndex == index ? 0 : 0.2).delay(currentIndex == index ? 0.2 : 0), value: currentIndex)
            
            Text(intro.text)
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .offset(x: -size.width * CGFloat(currentIndex - index))
                .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5).delay(0.1).delay(currentIndex == index ? 0.2 : 0), value: currentIndex)
            
            Image(intro.imageName)
                .resizable()
                .frame(width: 250, height: 250)
                .mask(
                    RoundedRectangle(cornerRadius: 22)
                )
                .padding(.top, 70)
                .padding(.horizontal, 20)
                .offset(x: -size.width * CGFloat(currentIndex - index))
                .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5).delay(currentIndex == index ? 0.2 : 0).delay(currentIndex == index ? 0.2 : 0), value: currentIndex)
        }.padding(.bottom, 150)
    }
    
    // MARK: - Onboarding screens
    
    @ViewBuilder
    func OnboardingScreens() -> some View {
        let screenIsLast = currentIndex == intros.count
        
        GeometryReader {
            let size = $0.size
                
            ZStack {
                ForEach(intros.indices, id: \.self) { index in
                    OnboardingScreen(size: size, index: index)
                }
                
                WelcomeScreen(size: size, index: intros.count)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .bottom) {
                    ZStack {
                        Image(systemName: "chevron.right")
                            .font(.title3.bold())
                            .scaleEffect(!screenIsLast ? 1 : 0.001)
                            .opacity(!screenIsLast ? 1 : 0)
                        
                        HStack {
                            Text(nextButton)
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Image(systemName: "arrow.right")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                        }.padding(.horizontal, 15)
                            .scaleEffect(screenIsLast ? 1 : 0.001)
                            .frame(height: screenIsLast ? nil : 0)
                            .opacity(screenIsLast ? 1 : 0)
                    }.frame(width: screenIsLast ? size.width / 1.5 : 55, height: screenIsLast ? 50 : 55)
                        .foregroundColor(.white)
                        .background {
                            RoundedRectangle(cornerRadius: screenIsLast ? 10 : 30, style: screenIsLast ? .continuous : .circular)
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
                            if currentIndex == intros.count {
                                
                                model.requestGeolocationPermission()
                                
                            } else {
                                
                                currentIndex += 1
                                
                            }
                        }
                        .offset(y: screenIsLast ? -40 : -90)
                        .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5), value: screenIsLast)
                }
                .overlay(alignment: .bottom) {
                    let screenIsLast = currentIndex == intros.count
                    
                    HStack(spacing: 5) {
                        Text(welcomeSubtitle)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Link(destination: URL(string: "https://github.com/scraptechguy/Peep/blob/main/docs/PRIVACY.md")!) {
                            Text(privacyButton)
                                .font(.system(size: 14))
                                .foregroundColor(Color("Font"))
                        }
                    }.offset(y: screenIsLast ? -12 : 100)
                        .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5), value: screenIsLast)
                }
                .offset(y: showOnboardingScreens ? 0 : size.height)
        }
    }
    
    // MARK: - Welcome screen
    
    @ViewBuilder
    func WelcomeScreen(size: CGSize, index: Int) -> some View {
        VStack(spacing: 10) {
            Image("dangerous_initial")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 120)
                .padding(.bottom, 60)
                .padding(.horizontal, 20)
                .offset(x: -size.width * CGFloat(currentIndex - index))
                .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5).delay(currentIndex == index ? 0.2 : 0).delay(currentIndex == index ? 0.1 : 0), value: currentIndex)
            
            Text(welcomeHeading)
                .bold()
                .font(.system(size: 28))
                .offset(x: -size.width * CGFloat(currentIndex - index))
                .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5).delay(currentIndex == index ? 0 : 0.2).delay(currentIndex == index ? 0.2 : 0), value: currentIndex)
                .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5).delay(0.1).delay(currentIndex == index ? 0.1 : 0), value: currentIndex)
            
            Text(welcomeText)
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .offset(x: -size.width * CGFloat(currentIndex - index))
                .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5).delay(currentIndex == index ? 0 : 0.2).delay(currentIndex == index ? 0.1 : 0), value: currentIndex)
        }.offset(y: -30)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(ContentModel())
            .preferredColorScheme(.dark)
    }
}
