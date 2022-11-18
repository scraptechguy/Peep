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
    @State var showLogIn: Bool = false
    @State var showSignUp: Bool = false
    @State var currentIndex: Int = 0
    
    @State var status = ""
    
    @State var logInEmail = ""
    @State var logInPassword = ""
    
    @State var signUpEmail = ""
    @State var emailIsValid: Bool = true
    @State var signUpPassword = ""
    @State var signUpReenteredPassword = ""
    
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
    let signUpButton: LocalizedStringKey = "signUpButton"
    let account: LocalizedStringKey = "account"
    let logInButton: LocalizedStringKey = "logInButton"
    
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
            .animation(.interactiveSpring(response: 1.1, dampingFraction: 0.85, blendDuration: 0.85), value: showLogIn)
            .animation(.interactiveSpring(response: 1.1, dampingFraction: 0.85, blendDuration: 0.85), value: showSignUp)
            .preferredColorScheme(model.isDarkMode ? .dark : .light)
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
                    Image("jump_initial")
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
                    .background {
                        Capsule()
                            .fill(Color("AccentColor"))
                    }
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
                if !showLogIn && !showSignUp {
                    if currentIndex > 0 {
                        
                        currentIndex -= 1
                        
                    } else if currentIndex == 0 {
                        
                        showOnboardingScreens.toggle()
                        
                    }
                } else {
                    showLogIn = false
                    showSignUp = false
                }
            }, label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .fontWeight(.semibold)
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
            
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .offset(x: -size.width * CGFloat(currentIndex - index))
                .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5).delay(0.1).delay(currentIndex == index ? 0.2 : 0), value: currentIndex)
            
            Image(intro.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 250, alignment: .top)
                .padding(.horizontal, 20)
                .offset(x: -size.width * CGFloat(currentIndex - index))
                .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5).delay(currentIndex == index ? 0.2 : 0).delay(currentIndex == index ? 0.2 : 0), value: currentIndex)
        }
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
                            .font(.title3)
                            .fontWeight(.semibold)
                            .scaleEffect(!screenIsLast ? 1 : 0.001)
                            .opacity(!screenIsLast ? 1 : 0)
                        
                        HStack {
                            Text(signUpButton)
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Image(systemName: "arrow.right")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }.padding(.horizontal, 15)
                            .scaleEffect(screenIsLast ? 1 : 0.001)
                            .frame(height: screenIsLast ? nil : 0)
                            .opacity(screenIsLast ? 1 : 0)
                    }.frame(width: screenIsLast ? size.width / 1.5 : 55, height: screenIsLast ? 50 : 55)
                        .foregroundColor(.white)
                        .background {
                            RoundedRectangle(cornerRadius: screenIsLast ? 10 : 30, style: screenIsLast ? .continuous : .circular)
                                .fill(Color("AccentColor"))
                        }
                        .onTapGesture {
                            if currentIndex == intros.count {
                                
                                showSignUp = true
                                
                            } else {
                                
                                currentIndex += 1
                                
                            }
                        }
                        .offset(y: screenIsLast ? -40 : -90)
                        .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5), value: screenIsLast)
                        .offset(y: showSignUp ? -size.height * 1.3 : 0)
                        .offset(y: showLogIn ? -size.height * 1.3 : 0)
                }
                .overlay(alignment: .bottom) {
                    let screenIsLast = currentIndex == intros.count
                    
                    HStack(spacing: 5) {
                        Text(account)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            showLogIn = true
                        }, label: {
                            Text(logInButton)
                                .font(.system(size: 14))
                                .foregroundColor(Color("AccentColor"))
                        })
                    }.offset(y: screenIsLast ? -12 : 100)
                        .animation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.5), value: screenIsLast)
                        .offset(y: showSignUp ? -size.height * 1.3 : 0)
                        .offset(y: showLogIn ? -size.height * 1.3 : 0)
                }
                .offset(y: showOnboardingScreens ? 0 : size.height)
        }
    }
    
    // MARK: - Welcome screen
    
    @ViewBuilder
    func WelcomeScreen(size: CGSize, index: Int) -> some View {
        VStack(spacing: 10) {
            Image("rotty_happy")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 250, alignment: .top)
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
            .offset(y: showLogIn ? -size.height : 0)
            .offset(y: showSignUp ? -size.height : 0)
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(ContentModel())
            .preferredColorScheme(.dark)
    }
}
