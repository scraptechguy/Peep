//
//  SettingsView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/9/22.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var data: FetchData
    @EnvironmentObject var model: ContentModel
    
    let screenSize: CGRect = UIScreen.main.bounds
    let pre = Locale.preferredLanguages[0]
    
    let settingsHeading: LocalizedStringKey = "settingsHeading"
    let settingsSectionGeneral: LocalizedStringKey = "settingsSectionGeneral"
    let settingsColorScheme: LocalizedStringKey = "settingsColorScheme"
    let settingsAppLanguage: LocalizedStringKey = "settingsAppLanguage"
    let settingsAppLanguageValue: LocalizedStringKey = "settingsAppLanguageValue"
    let settingsSectionGeneralFooter: LocalizedStringKey = "settingsSectionGeneralFooter"
    
    let settingsSectionInformation: LocalizedStringKey = "settingsSectionInformation"
    let settingsFeedback: LocalizedStringKey = "settingsFeedback"
    let settingsPrivacyPolicy: LocalizedStringKey = "settingsPrivacyPolicy"
    let settingsHelp: LocalizedStringKey = "settingsHelp"
    let settingsCredits: LocalizedStringKey = "settingsCredits"
    let settingsSectionInformationFooter: LocalizedStringKey = "settingsSectionInformationFooter"
    
    let settingsSectionLinks: LocalizedStringKey = "settingsSectionLinks"
    let settingsWebsite: LocalizedStringKey = "settingsWebsite"
    
    let settingsSectionDeveloperSettings: LocalizedStringKey = "settingsSectionDeveloperSettings"
    let settingsBug: LocalizedStringKey = "settingsBug"
    let settingsFeature: LocalizedStringKey = "settingsFeature"
    
    let settingsFooter: LocalizedStringKey = "settingsFooter"
    
    let settingsThanks: LocalizedStringKey = "settingsThanks"
    let settingsCopyright: LocalizedStringKey = "settingsCopyright"
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            NavigationView {
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
                        
                        Link(destination: URL(string: "https://apps.apple.com/cz/app/peep-the-world-of-sundials/id6747686124?action=write-review")!) {
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
                                UIPasteboard.general.string = "https://apps.apple.com/cz/app/peep-the-world-of-sundials/id6747686124?action=write-review"
                            }, label: {
                                Label("Copy to clipboard", systemImage: "rectangle.on.rectangle")
                            })
                        }
                        .listRowBackground(Color("ListRowBackground"))
                    }.foregroundColor(.primary)
                    
                    // MARK: - Developer settings
                    
                    Section(header: Text(settingsSectionDeveloperSettings).foregroundColor(.secondary)) {
                        Link(destination: URL(string: "https://github.com/scraptechguy/Peep/issues/new?assignees=&labels=&template=bug_report.md&title=")!) {
                            HStack {
                                Label(settingsBug, systemImage: "exclamationmark.triangle")
                                
                                Spacer()
                                
                                Text("GitHub")
                                    .foregroundColor(.secondary)
                                
                                Image(systemName: "arrow.up.right")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(action: {
                                UIPasteboard.general.string = "https://github.com/scraptechguy/Peep/issues/new?assignees=&labels=&template=bug_report.md&title="
                            }, label: {
                                Label("Copy to clipboard", systemImage: "rectangle.on.rectangle")
                            })
                        }
                        .listRowBackground(Color("ListRowBackground"))
                        
                        Link(destination: URL(string: "https://github.com/scraptechguy/Peep/issues/new?assignees=&labels=&template=feature_request.md&title=")!) {
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
                                UIPasteboard.general.string = "https://github.com/scraptechguy/Peep/issues/new?assignees=&labels=&template=feature_request.md&title="
                            }, label: {
                                Label("Copy to clipboard", systemImage: "rectangle.on.rectangle")
                            })
                        }
                        .listRowBackground(Color("ListRowBackground"))
                    }.foregroundColor(.primary)
                    
                    // MARK: - Footer
                    
                    Section(footer:
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 0) { Text(settingsFooter).foregroundColor(.secondary); Link(destination: URL(string: "https://github.com/scraptechguy")!) {
                                    Text("@scraptechguy").foregroundColor(.primary)
                                }
                            }
                        }
                    ) {
                        NavigationLink(destination: CreditsView().navigationBarTitle(settingsCredits)) {
                            Text(settingsCredits)
                        }.listRowBackground(Color("ListRowBackground"))
                        
                        Button(action: {
                            
                        }, label: {
                            Text("\(String(localized: "settingsVersion")) \(Bundle.main.versionBuildString)")
                                .background(
                                    AnimatedBlobView()
                                        .frame(width: 400, height: 414)
                                        .offset(x: 330, y: 0)
                                        .scaleEffect(1)
                                )
                        }).simultaneousGesture(LongPressGesture(minimumDuration: 1.5).onEnded { _ in
                            model.didLongPressed = true
                        }).sheet(isPresented: {$model.didLongPressed}()) {PeepView()}
                            .foregroundColor(.secondary)
                            .listRowBackground(Color("ListRowBackground"))
                    }
                    
                    Text(settingsCopyright)
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                        .foregroundStyle(Color.secondary)
                        .padding(.horizontal)
                        .listRowBackground(Color.clear)
                        .padding(.bottom, 60)
                }.listStyle(.insetGrouped)
                    .navigationTitle(settingsHeading)
                    .background {
                        Color("Background")
                            .ignoresSafeArea()
                    }
                    .scrollContentBackground(.hidden)
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
                    })
                }
                
                Spacer()
            }
        }.preferredColorScheme(model.isLightMode ? .light : .dark)
    }
}

extension Bundle {
    // CFBundleShortVersionString
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    }
    
    // CFBundleVersion
    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "?"
    }
    
    // e.g. "v1.2.3 (45)"
    var versionBuildString: String {
        "\(appVersion) (\(buildNumber))"
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(ContentModel())
            .environmentObject(FetchData())
    }
}
