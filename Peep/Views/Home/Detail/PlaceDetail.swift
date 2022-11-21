//
//  PlaceDetail.swift
//  Peep
//
//  Created by Rostislav Brož on 8/9/22.
//

import SwiftUI

struct PlaceDetail: View {
    
    @EnvironmentObject var model: ContentModel
    
    let minHeight: CGFloat = 70
    let maxHeight: CGFloat = 600
    
    @State private var showingType = false
    @State private var showingPointer = false
    @State private var showingDial = false
    @State private var showingState = false
    
    var place: DataModel
    let screenSize: CGRect = UIScreen.main.bounds
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear
                .ignoresSafeArea()
            
            VStack {
                ZStack {
                    Capsule()
                        .frame(width: 40, height: 6)
                        .foregroundColor(.secondary)
                }.frame(height: 20)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.00001))
                    .gesture(dragGesture)
                
                ScrollView(showsIndicators: false) {
                    if place.id != "" {
                        
                        VStack(alignment: .leading, spacing: 5) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                Text(place.adresa ?? "No address found")
                                    .font(.system(size: 25))
                                    .foregroundColor(Color("Font"))
                                    .padding(.horizontal)
                            }
                            
                            if place.umisteni != "" {
                                
                                Text(place.umisteni ?? "No description")
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                            } else {
                                
                                Text("No description")
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 18) {
                                    Button(action: {
                                        model.showingDirections = true
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
                                    }).sheet(isPresented: {$model.showingDirections}()) {DirectionsView(place: place)}
                                    
                                    Button(action: {
                                        showingType = true
                                    }, label: {
                                        VStack {
                                            Text(place.thodin ?? "?")
                                                .bold()
                                                .frame(width: 20)
                                                .lineLimit(1)
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
                                    }).sheet(isPresented: {$showingType}()) {TypeView()}
                                    
                                    Button(action: {
                                        showingPointer = true
                                    }, label: {
                                        VStack {
                                            Text(place.tukazatel ?? "?")
                                                .bold()
                                                .frame(width: 20)
                                                .lineLimit(1)
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
                                    }).sheet(isPresented: {$showingPointer}()) {PointerView()}
                                    
                                    Button(action: {
                                        showingDial = true
                                    }, label: {
                                        VStack {
                                            Text(place.tciselnik ?? "?")
                                                .bold()
                                                .frame(width: 20)
                                                .lineLimit(1)
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
                                    }).sheet(isPresented: {$showingDial}()) {DialView()}
                                    
                                    Button(action: {
                                        showingState = true
                                    }, label: {
                                        VStack {
                                            Text(place.stav ?? "?")
                                                .bold()
                                                .frame(width: 20)
                                                .lineLimit(1)
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
                                    }).sheet(isPresented: {$showingState}()) {StateView()}
                                }.padding([.top, .leading])
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 18) {
                                    ForEach(place.obrazky?.indices ?? [""].indices, id: \.self) { i in
                                        AsyncImage(url: URL(string: "https://astro.mff.cuni.cz/mira/sh/icons/640x640/\(place.obrazky?[i] ?? "")"))
                                            .scaledToFill()
                                            .frame(width: 150, height: 150)
                                            .clipped()
                                            .mask(
                                                RoundedRectangle(cornerRadius: 22)
                                            )
                                    }
                                }.padding([.vertical, .leading])
                            }
                            
                            Text("More information")
                                .textCase(.uppercase)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                                .padding(.leading)
                                .padding(.bottom, 8)
                            
                            VStack(alignment: .center) {
                                HStack {
                                    Spacer()
                                    
                                    VStack {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color("Item"))
                                                .frame(width: 120, height: 120)
                                            
                                            Image(systemName: "sun.max.fill")
                                                .frame(width: 20)
                                                .foregroundColor(Color("Item"))
                                                .padding()
                                        }
                                        
                                        Text("Azimuth")
                                            .font(.system(size: 10))
                                            .foregroundColor(Color("Font"))
                                    }
                                    
                                    Spacer()
                                    
                                    VStack {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color("Item"))
                                                .frame(width: 120, height: 120)
                                            
                                            Image(systemName: "sun.max.fill")
                                                .frame(width: 20)
                                                .foregroundColor(Color("Item"))
                                                .padding()
                                        }
                                        
                                        Text("Azimuth")
                                            .font(.system(size: 10))
                                            .foregroundColor(Color("Font"))
                                    }
                                    
                                    Spacer()
                                }.padding(.top, 5)
                            }.frame(width: screenSize.width)
                        }
                    } else {
                        
                        Text("Hello world")
                        
                    }
                }
            }.frame(height: model.currentHeight)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.clear)
                        .overlay(.ultraThinMaterial)
                        .mask(RoundedRectangle(cornerRadius: 30))
                }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()
            .preferredColorScheme(model.isLightMode ? .light : .dark)
    }
    
    @State private var prevDragTranslation = CGSize.zero
    var dragGesture: some Gesture {
        
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { value in
                let dragAmount = value.translation.height - prevDragTranslation.height
                
                if model.currentHeight < maxHeight && model.currentHeight > minHeight {
                    
                    model.currentHeight -= dragAmount
                    
                } else {
                    
                    model.currentHeight -= dragAmount / 20
                    
                }
                
                prevDragTranslation = value.translation
            }
            .onEnded { value in
                prevDragTranslation = .zero
            }
        
    }
}

