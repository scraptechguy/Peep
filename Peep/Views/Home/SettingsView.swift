//
//  SettingsView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/9/22.
//

import SwiftUI

struct SettingsView: View {
    
    let screenSize: CGRect = UIScreen.main.bounds 
    
    @ObservedObject var data = FetchData()
    @EnvironmentObject var model: ContentModel
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            NavigationView {
                List {
                    Section {
                        Menu {
                            Button(action: {
                                    
                                }, label: {
                                    Label("Soon to be account label", systemImage: "sparkles")
                                        .foregroundColor(.red)
                            })
                        } label: {
                            HStack {
                                Group {
                                    VStack {
                                        Text("Peep")
                                            .font(.title2.weight(.semibold))
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                            .padding(.horizontal, 10)
                                            .frame(maxWidth: .infinity)
                                        
                                        Text("Peep")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity)
                                    }
                                }.frame(maxWidth: .infinity, alignment: .leading)
                                
                                Image("peep_initial")
                                    .resizable()
                                    .frame(width: 40, height: 35)
                            }.frame(maxWidth: .infinity)
                                .background(
                                    AnimatedBlobView()
                                        .frame(width: 400, height: 414)
                                        .offset(x: 200, y: 0)
                                        .scaleEffect(1)
                                )
                                .padding()
                        }

                    }
                    
                    Section(header: Text("Information").foregroundColor(.secondary)) {
                        NavigationLink(destination: SomethingWentWrong()) {
                            Label("Feedback", systemImage: "person")
                        }
                        
                        NavigationLink(destination: SomethingWentWrong()) {
                            Label("How does it work?", systemImage: "lightbulb")
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
                    
                    Section(header: Text("Developer").foregroundColor(.secondary), footer: Text("Dev log displays what the app is doing on the bottom of your screen").foregroundColor(.secondary)) {
                        Toggle(isOn: $model.devLogOn) {
                            Label("Dev log", systemImage: "pc")
                        }
                    }.foregroundColor(.primary)
                    
                    Section {
                        Label("Version 0.0.1", systemImage: "server.rack")
                            .background(
                                Image("Blob2")
                            )
                        
                        Text("Made with Ɛ> by Rosťa")
                            .font(.footnote)
                            .foregroundColor(.secondary)
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
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.dark)
            .environmentObject(ContentModel())
    }
}
