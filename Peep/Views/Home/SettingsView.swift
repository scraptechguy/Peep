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
    
    @State private var showingDirections = false
    @State private var showingType = false
    @State private var showingPointer = false
    @State private var showingDial = false
    @State private var showingState = false
    @State private var url = "https://images.fineartamerica.com/images-medium-large-5/sundial-on-the-wall-of-a-church-martin-bondscience-photo-library.jpg"
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 5) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        Text("Slovec 1")
                            .font(.system(size: 25))
                            .foregroundColor(Color("Font"))
                            .padding(.horizontal)
                    }
                    
                    Text("budova bývalého statku, zemědělské družstvo")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 18) {
                            Button(action: {
                                showingDirections = true
                            }, label: {
                                VStack {
                                    Image(systemName: "car")
                                        .foregroundColor(Color("Item"))
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color("Item"))
                                                .frame(width: 52, height: 52)
                                        )
                                    
                                    Text("Directions")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color("Font"))
                                }
                            }).sheet(isPresented: {$showingDirections}()) {DirectionsView()}
                            
                            Button(action: {
                                
                            }, label: {
                                VStack {
                                    Text("S" ?? "?")
                                        .bold()
                                        .frame(width: 20)
                                        .foregroundColor(Color("Item"))
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color("Item"))
                                                .frame(width: 52, height: 52)
                                        )
                                    
                                    Text("Type")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color("Font"))
                                        
                                }
                            })
                            
                            Button(action: {
                                
                            }, label: {
                                VStack {
                                    Text("K" ?? "?")
                                        .bold()
                                        .frame(width: 20)
                                        .foregroundColor(Color("Item"))
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color("Item"))
                                                .frame(width: 52, height: 52)
                                        )
                                    
                                    Text("Pointer")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color("Font"))
                                        
                                }
                            })
                            
                            Button(action: {
                                
                            }, label: {
                                VStack {
                                    Text("CA" ?? "?")
                                        .bold()
                                        .frame(width: 20)
                                        .foregroundColor(Color("Item"))
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color("Item"))
                                                .frame(width: 52, height: 52)
                                        )
                                    
                                    Text("Dial")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color("Font"))
                                        
                                }
                            })
                            
                            Button(action: {
                                
                            }, label: {
                                VStack {
                                    Text("Z" ?? "?")
                                        .bold()
                                        .frame(width: 20)
                                        .foregroundColor(Color("Item"))
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color("Item"))
                                                .frame(width: 52, height: 52)
                                        )
                                    
                                    Text("State")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color("Font"))
                                        
                                }
                            })
                        }.padding([.top, .leading])
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 18) {
                            ForEach(model.list.indices, id: \.self) { i in
                                AsyncImage(url: URL(string: url))
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipped()
                                    .mask(
                                        RoundedRectangle(cornerRadius: 22)
                                    )
                            }
                        }.padding([.leading])
                    }
                    
                    Text("More information")
                        .textCase(.uppercase)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                        .padding([.top, .leading])
                        .padding(.bottom, 8)
                    
                    VStack(alignment: .leading) {
                        Divider()
                        
                        HStack(spacing: 20) {
                            Text("Azimuth: ")
                                .foregroundColor(Color("Font"))
                                .frame(width: 100)
                            
                            Text("10")
                                .bold()
                                .foregroundColor(Color("Font"))
                        }.padding(.leading)
                        
                        Divider()
                        
                        HStack(spacing: 20) {
                            Text("Built: ")
                                .foregroundColor(Color("Font"))
                                .frame(width: 100)
                            
                            Text("1900")
                                .bold()
                                .foregroundColor(Color("Font"))
                        }.padding(.leading)
                        
                        Divider()
                        
                        HStack(spacing: 20) {
                            Text("Evc: ")
                                .foregroundColor(Color("Font"))
                                .frame(width: 100)
                            
                            Text("NB 9")
                                .bold()
                                .foregroundColor(Color("Font"))
                        }.padding(.leading)
                        
                        Divider()
                        
                        HStack(spacing: 20) {
                            Text("Website: ")
                                .foregroundColor(Color("Font"))
                                .frame(width: 100)
                            
                            Text("https://astro.troja.mff.cuni.cz/mira/sh/json2.php")
                                .lineLimit(1)
                        }.padding(.leading)
                        
                        Divider()
                    }
                }.padding(.top)
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
