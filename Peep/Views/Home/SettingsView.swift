//
//  SettingsView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/9/22.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var data = FetchData()
    @EnvironmentObject var model: ContentModel
    
    let screenSize: CGRect = UIScreen.main.bounds
    let pre = Locale.preferredLanguages[0]
    
    let settingsHeading: LocalizedStringKey = "settingsHeading"
    let settingsSectionGeneral: LocalizedStringKey = "settingsSectionGeneral"
    let settingsColorScheme: LocalizedStringKey = "settingsColorScheme"
    let settingsAppLanguage: LocalizedStringKey = "settingsAppLanguage"
    let settingsAppLanguageValue: LocalizedStringKey = "settingsAppLanguageValue"
    let settingsReach: LocalizedStringKey = "settingsReach"
    let settingsSectionGeneralFooter: LocalizedStringKey = "settingsSectionGeneralFooter"
    
    let settingsSectionInformation: LocalizedStringKey = "settingsSectionInformation"
    let settingsFeedback: LocalizedStringKey = "settingsFeedback"
    let settingsPrivacyPolicy: LocalizedStringKey = "settingsPrivacyPolicy"
    let settingsHelp: LocalizedStringKey = "settingsHelp"
    let settingsSectionInformationFooter: LocalizedStringKey = "settingsSectionInformationFooter"
    
    let settingsSectionLinks: LocalizedStringKey = "settingsSectionLinks"
    let settingsWebsite: LocalizedStringKey = "settingsWebsite"
    
    let settingsSectionDeveloperSettings: LocalizedStringKey = "settingsSectionDeveloperSettings"
    let settingsFeature: LocalizedStringKey = "settingsFeature"
    let settingsOfflineDB: LocalizedStringKey = "settingsOfflineDB"
    let settingsSectionDeveloperSettingsSubtitle: LocalizedStringKey = "settingsSectionDeveloperSettingsSubtitle"
    
    let settingsFooter: LocalizedStringKey = "settingsFooter"
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            NavigationView {
                if #available(iOS 16.0, *) {
                    
                    List {
                        
                        // MARK: - General
                        
                        Section(header: Text(settingsSectionGeneral).foregroundColor(.secondary), footer: Text(settingsSectionGeneralFooter).foregroundColor(.secondary)) {
                            Toggle(isOn: $model.isLightMode) {
                                Label(settingsColorScheme, systemImage: model.isLightMode ? "sun.max.fill" : "sun.min")
                            }.listRowBackground(Color("ListRowBackground"))
                            
                            HStack {
                                Label(settingsAppLanguage, systemImage: "character.book.closed")
                                
                                Spacer()
                                
                                Text(settingsAppLanguageValue)
                                    .foregroundColor(.secondary)
                                
                                Image(systemName: "arrow.up.right")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }.onTapGesture {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    if UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    }
                                }
                            }
                            .listRowBackground(Color("ListRowBackground"))
                            
                            HStack {
                                Label(settingsReach, systemImage: "globe.americas")
                                    .padding(.trailing)
                                
                                Slider(value: $model.latlongDelta, in: 0.1...0.35)
                            }.listRowBackground(Color("ListRowBackground"))
                        }.foregroundColor(.primary)
                        
                        if model.authorizationState == .denied || model.authorizationState == .restricted {
                            
                            Section(footer: Text(String(localized: "settingsLocationFooter")).foregroundColor(.secondary)) {
                                Text(String(localized: "settingsLocationHeading"))
                                    .foregroundColor(Color.blue)
                                    .onTapGesture {
                                        if let url = URL(string: UIApplication.openSettingsURLString) {
                                            if UIApplication.shared.canOpenURL(url) {
                                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                            }
                                        }
                                    }
                                    .listRowBackground(Color("ListRowBackground"))
                            }
                            
                        }
                        
                        // MARK: - Information
                        
                        Section(header: Text(settingsSectionInformation).foregroundColor(.secondary), footer: Text(settingsSectionInformationFooter).foregroundColor(.secondary)) {
                            NavigationLink(destination: HelpView().navigationBarTitle(settingsHelp)) {
                                Label(settingsHelp, systemImage: "questionmark")
                            }.listRowBackground(Color("ListRowBackground"))
                            
                            Link(destination: URL(string: "https://astro.troja.mff.cuni.cz/mira/sh/sh.php")!) {
                                HStack {
                                    Label(settingsWebsite, systemImage: "heart.text.square")
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "link")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                            }.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(action: {
                                    UIPasteboard.general.string = "https://astro.troja.mff.cuni.cz/mira/sh/sh.php"
                                }, label: {
                                    Label("Copy to clipboard", systemImage: "rectangle.on.rectangle")
                                })
                            }
                            .listRowBackground(Color("ListRowBackground"))
                            
                            Link(destination: URL(string: "https://github.com/scraptechguy/Peep/blob/main/docs/PRIVACY.md")!) {
                                HStack {
                                    Label(settingsPrivacyPolicy, systemImage: "person.badge.key")
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "link")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                            }.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(action: {
                                    UIPasteboard.general.string = "https://github.com/scraptechguy/Peep/blob/main/docs/PRIVACY.md"
                                }, label: {
                                    Label("Copy to clipboard", systemImage: "rectangle.on.rectangle")
                                })
                            }
                            .listRowBackground(Color("ListRowBackground"))
                            
                            Link(destination: URL(string: "https://github.com/scraptechguy/Peep")!) {
                                HStack {
                                    Label("GitHub", systemImage: "xserve")
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "link")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                            }.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(action: {
                                    UIPasteboard.general.string = "https://github.com/scraptechguy/Peep"
                                }, label: {
                                    Label("Copy to clipboard", systemImage: "rectangle.on.rectangle")
                                })
                            }
                            .listRowBackground(Color("ListRowBackground"))
                            
                            Link(destination: URL(string: "https://apps.apple.com/us/app/p%C3%ADp/id6444575713")!) {
                                HStack {
                                    Label(settingsFeedback, systemImage: "leaf")
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Text("App Store")
                                        .foregroundColor(.secondary)
                                    
                                    Image(systemName: "arrow.up.right")
                                        .font(.footnote)
                                        .foregroundColor(.gray)

                                }
                            }.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(action: {
                                    UIPasteboard.general.string = "https://apps.apple.com/us/app/p%C3%ADp/id6444575713"
                                }, label: {
                                    Label("Copy to clipboard", systemImage: "rectangle.on.rectangle")
                                })
                            }
                            .listRowBackground(Color("ListRowBackground"))
                        }.foregroundColor(.primary)
                        
                        // MARK: - Developer settings
                        
                        Section(header: Text(settingsSectionDeveloperSettings).foregroundColor(.secondary), footer: Text(settingsSectionDeveloperSettingsSubtitle).foregroundColor(.secondary)) {
                            Link(destination: URL(string: "https://github.com/scraptechguy/Peep/issues/new")!) {
                                HStack {
                                    Label(settingsFeature, systemImage: "pencil.and.outline")
                                    
                                    Spacer()
                                    
                                    Text("GitHub")
                                        .foregroundColor(.secondary)
                                    
                                    Image(systemName: "arrow.up.right")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(action: {
                                    UIPasteboard.general.string = "https://github.com/scraptechguy/Peep/issues/new"
                                }, label: {
                                    Label("Copy to clipboard", systemImage: "rectangle.on.rectangle")
                                })
                            }
                            .listRowBackground(Color("ListRowBackground"))
                            
                            Toggle(isOn: $model.useOfflineDatabase) {
                                Label(settingsOfflineDB, systemImage: "wifi.slash")
                            }.listRowBackground(Color("ListRowBackground"))
                            
                            Toggle(isOn: $model.devLogOn) {
                                HStack(spacing: 0) {
                                    Label("Dev log ", systemImage: "pc")
                                    
                                    Text("beta")
                                        .foregroundColor(Color("Green"))
                                }
                            }.listRowBackground(Color("ListRowBackground"))
                        }.foregroundColor(.primary)
                        
                        Section(footer: HStack(spacing: 0) { Text(settingsFooter).foregroundColor(.secondary); Link(destination: URL(string: "https://github.com/scraptechguy")!) { Text("@scraptechguy").foregroundColor(.primary) }}.padding(.bottom, 60)) {
                            Button(action: {
                                
                            }, label: {
                                Label("\(String(localized: "settingsVersion")) 1.1.0", systemImage: "server.rack")
                                    .background(
                                        AnimatedBlobView()
                                            .frame(width: 400, height: 414)
                                            .offset(x: 300, y: 0)
                                            .scaleEffect(1)
                                    )
                            }).simultaneousGesture(LongPressGesture(minimumDuration: 1.5).onEnded { _ in
                                model.didLongPressed = true
                            }).sheet(isPresented: {$model.didLongPressed}()) {PeepView()}
                                .listRowBackground(Color("ListRowBackground"))
                        }.foregroundColor(.secondary)
                    }.listStyle(.insetGrouped)
                        .navigationTitle(settingsHeading)
                        .background {
                            Color("Background")
                                .ignoresSafeArea()
                        }
                        .scrollContentBackground(.hidden)
                    
                } else {
                    
                    List {
                        
                        // MARK: - General
                        
                        Section(header: Text(settingsSectionGeneral).foregroundColor(.secondary), footer: Text(settingsSectionGeneralFooter).foregroundColor(.secondary)) {
                            Toggle(isOn: $model.isLightMode) {
                                Label(settingsColorScheme, systemImage: model.isLightMode ? "sun.max.fill" : "sun.min")
                            }
                            
                            HStack {
                                Label(settingsAppLanguage, systemImage: "character.book.closed")
                                
                                Spacer()
                                
                                Text(settingsAppLanguageValue)
                                    .foregroundColor(.secondary)
                                
                                Image(systemName: "arrow.up.right")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }.onTapGesture {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    if UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    }
                                }
                            }
                            
                            HStack {
                                Label(settingsReach, systemImage: "globe.americas")
                                    .padding(.trailing)
                                
                                Slider(value: $model.latlongDelta, in: 0.1...0.35)
                            }
                        }.foregroundColor(.primary)
                        
                        if model.authorizationState == .denied || model.authorizationState == .restricted {
                            
                            Section(footer: Text(String(localized: "settingsLocationFooter")).foregroundColor(.secondary)) {
                                Text(String(localized: "settingsLocationHeading"))
                                    .foregroundColor(Color.blue)
                                    .onTapGesture {
                                        if let url = URL(string: UIApplication.openSettingsURLString) {
                                            if UIApplication.shared.canOpenURL(url) {
                                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                            }
                                        }
                                    }
                            }
                            
                        }
                        
                        // MARK: - Information
                        
                        Section(header: Text(settingsSectionInformation).foregroundColor(.secondary), footer: Text(settingsSectionInformationFooter).foregroundColor(.secondary)) {
                            NavigationLink(destination: HelpView().navigationBarTitle(settingsHelp)) {
                                Label(settingsHelp, systemImage: "questionmark")
                            }
                            
                            NavigationLink(destination: FeedbackView().navigationBarTitle(settingsFeedback)) {
                                Label(settingsFeedback, systemImage: "leaf")
                            }
                            
                            Link(destination: URL(string: "https://astro.troja.mff.cuni.cz/mira/sh/sh.php")!) {
                                HStack {
                                    Label(settingsWebsite, systemImage: "heart.text.square")
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "link")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                            }.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(action: {
                                    UIPasteboard.general.string = "https://astro.troja.mff.cuni.cz/mira/sh/sh.php"
                                }, label: {
                                    Label("Copy to clipboard", systemImage: "rectangle.on.rectangle")
                                })
                            }
                            
                            Link(destination: URL(string: "https://github.com/scraptechguy/Peep/blob/main/docs/PRIVACY.md")!) {
                                HStack {
                                    Label(settingsPrivacyPolicy, systemImage: "person.badge.key")
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "link")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                            }.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(action: {
                                    UIPasteboard.general.string = "https://github.com/scraptechguy/Peep/blob/main/docs/PRIVACY.md"
                                }, label: {
                                    Label("Copy to clipboard", systemImage: "rectangle.on.rectangle")
                                })
                            }
                            
                            Link(destination: URL(string: "https://github.com/scraptechguy/Peep")!) {
                                HStack {
                                    Label("GitHub", systemImage: "xserve")
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "link")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                            }.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(action: {
                                    UIPasteboard.general.string = "https://github.com/scraptechguy/Peep"
                                }, label: {
                                    Label("Copy to clipboard", systemImage: "rectangle.on.rectangle")
                                })
                            }
                        }.foregroundColor(.primary)
                        
                        // MARK: - Developer settings
                        
                        Section(header: Text(settingsSectionDeveloperSettings).foregroundColor(.secondary), footer: Text(settingsSectionDeveloperSettingsSubtitle).foregroundColor(.secondary)) {
                            Link(destination: URL(string: "https://github.com/scraptechguy/Peep/issues/new")!) {
                                HStack {
                                    Label(settingsFeature, systemImage: "pencil.and.outline")
                                    
                                    Spacer()
                                    
                                    Text("GitHub")
                                        .foregroundColor(.secondary)
                                    
                                    Image(systemName: "arrow.up.right")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(action: {
                                    UIPasteboard.general.string = "https://github.com/scraptechguy/Peep/issues/new"
                                }, label: {
                                    Label("Copy to clipboard", systemImage: "rectangle.on.rectangle")
                                })
                            }
                            
                            Toggle(isOn: $model.useOfflineDatabase) {
                                Label(settingsOfflineDB, systemImage: "wifi.slash")
                            }
                            
                            Toggle(isOn: $model.devLogOn) {
                                HStack(spacing: 0) {
                                    Label("Dev log ", systemImage: "pc")
                                    
                                    Text("beta")
                                        .foregroundColor(Color("Green"))
                                }
                            }
                        }.foregroundColor(.primary)
                        
                        Section(footer: HStack(spacing: 0) { Text(settingsFooter).foregroundColor(.secondary); Link(destination: URL(string: "https://github.com/scraptechguy")!) { Text("@scraptechguy").foregroundColor(.primary) }}) {
                            Button(action: {
                                
                            }, label: {
                                Label("\(String(localized: "settingsVersion")) 1.0.0", systemImage: "server.rack")
                                    .background(
                                        AnimatedBlobView()
                                            .frame(width: 400, height: 414)
                                            .offset(x: 300, y: 0)
                                            .scaleEffect(1)
                                    )
                            }).simultaneousGesture(LongPressGesture(minimumDuration: 1.5).onEnded { _ in
                                model.didLongPressed = true
                            }).sheet(isPresented: {$model.didLongPressed}()) {PeepView()}
                        }.foregroundColor(.secondary)
                    }.listStyle(.insetGrouped)
                        .navigationTitle(settingsHeading)
                    
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            model.showingSettings = false
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
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(ContentModel())
            .environmentObject(FetchData())
    }
}
