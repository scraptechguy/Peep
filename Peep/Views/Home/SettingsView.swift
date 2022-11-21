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
    
    let settingsHeading: LocalizedStringKey = "settingsHeading"
    let settingsSectionGeneral: LocalizedStringKey = "settingsSectionGeneral"
    let settingsColorScheme: LocalizedStringKey = "settingsColorScheme"
    let settingsRegions: LocalizedStringKey = "settingsRegions"
    let settingsRegionsSubtitle1: LocalizedStringKey = "settingsRegionsSubtitle1"
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            NavigationView {
                List {
                    Section(header: Text(settingsSectionGeneral).foregroundColor(.secondary), footer: Text(settingsRegionsSubtitle1).foregroundColor(.secondary)) {
                        Toggle(isOn: $model.isLightMode) {
                            Label(settingsColorScheme, systemImage: model.isLightMode ? "sun.max.fill" : "sun.min")
                        }
                        
                        NavigationLink(destination: RegionsView()) {
                            HStack {
                                Label(settingsRegions, systemImage: "globe.europe.africa.fill")
                                
                                Spacer()
                                
                                Text("\(model.regions[0]), ...")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .frame(width: 120)
                            }
                        }
                    }.foregroundColor(.primary)
                    
                    Section(header: Text("Information").foregroundColor(.secondary)) {
                        NavigationLink(destination: SomethingWentWrong()) {
                            Label("Feedback", systemImage: "leaf")
                        }
                        
                        NavigationLink(destination: SomethingWentWrong()) {
                            Label("Privacy policy", systemImage: "person.badge.key")
                        }
                        
                        NavigationLink(destination: SomethingWentWrong()) {
                            Label("Help", systemImage: "questionmark")
                        }
                    }.foregroundColor(.primary)
                    
                    Section(header: Text("Links")) {
                        Link(destination: URL(string: "https://youtu.be/dQw4w9WgXcQ")!) {
                            HStack {
                                Label("Website", systemImage: "sun.min")
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "link")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(action: {
                                    UIPasteboard.general.string = "https://youtu.be/dQw4w9WgXcQ"
                                }, label: {
                                    Label("Copy to clipboard", systemImage: "rectangle.on.rectangle")
                            })
                        }
                        
                        Link(destination: URL(string: "https://github.com/scraptechguy/Peep")!) {
                            HStack {
                                Label("Github", systemImage: "cloud")
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "link")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(action: {
                                    UIPasteboard.general.string = "https://github.com/filiptronicek/StuduWidgets"
                                }, label: {
                                    Label("Copy to clipboard", systemImage: "rectangle.on.rectangle")
                            })
                        }
                    }
                    
                    Section(header: Text("Developer settings").foregroundColor(.secondary), footer: Text("Dev log displays what the app is doing on the bottom of your screen").foregroundColor(.secondary)) {
                        Toggle(isOn: $model.devLogOn) {
                            Label("Dev log", systemImage: "pc")
                        }
                    }.foregroundColor(.primary)
                    
                    Section(footer: HStack(spacing: 0) { Text("Made with Ɛ> by ").foregroundColor(.secondary); Link(destination: URL(string: "https://github.com/scraptechguy")!) { Text("@scraptechguy").foregroundColor(.primary) }}.padding(.bottom, 60)) {
                        Label("Version 0.0.1", systemImage: "server.rack")
                            .background(
                                AnimatedBlobView()
                                    .frame(width: 400, height: 414)
                                    .offset(x: 300, y: 0)
                                    .scaleEffect(1)
                            )
                    }.foregroundColor(.secondary)
                }.listStyle(.insetGrouped)
                    .navigationTitle("Settings")
            }
            
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        model.showingSettings = false
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
            .preferredColorScheme(.dark)
            .environmentObject(ContentModel())
    }
}
