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
    
    var place: DataModel
    let screenSize: CGRect = UIScreen.main.bounds
    
    let detailGuide: LocalizedStringKey = "detailGuide"
    
    let detailNoAddress: LocalizedStringKey = "detailNoAddress"
    let detailNoDescription: LocalizedStringKey = "detailNoDescription"
    let detailDirections: LocalizedStringKey = "detailDirections"
    let detailType: LocalizedStringKey = "detailType"
    let detailIndicator: LocalizedStringKey = "detailIndicator"
    let detailDial: LocalizedStringKey = "detailDial"
    let detailState: LocalizedStringKey = "detailState"
    
    let detailSectionInformation: LocalizedStringKey = "detailSectionInformation"
    let detailAzimuth: LocalizedStringKey = "detailAzimuth"
    
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
                    if model.annotationSelected {
                        
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    Text(place.adresa ?? "???")
                                        .font(.system(size: 25))
                                        .foregroundColor(Color("Font"))
                                        .padding(.horizontal)
                                }
                                
                                Button(action: {
                                    withAnimation {
                                        model.annotationSelected = false
                                        model.currentHeight = 90
                                    }
                                }, label: {
                                    ZStack {
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                        
                                        Image(systemName: "multiply")
                                            .font(.title2)
                                            .foregroundColor(.secondary)
                                    }.frame(width: 35, height: 35)
                                        .padding(.horizontal)
                                })
                            }
                            
                            if place.umisteni != "" {
                                
                                Text(place.umisteni ?? "???")
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                            } else {
                                
                                Text(detailNoDescription)
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
                                                .foregroundColor(Color("Font"))
                                                .padding()
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(Color("Font"))
                                                        .frame(width: 52, height: 52)
                                                )
                                            
                                            Text(detailDirections)
                                                .font(.system(size: 10))
                                                .foregroundColor(Color("Font"))
                                        }
                                    }).sheet(isPresented: {$model.showingDirections}()) {
                                        DirectionsView(place: place)
                                            .presentationDetents([.large])
                                    }
                                    
                                    Button(action: {
                                        model.showingType = true
                                    }, label: {
                                        VStack {
                                            Text(place.thodin ?? "?")
                                                .bold()
                                                .minimumScaleFactor(0.1)
                                                .frame(width: 20, height: 20)
                                                .lineLimit(1)
                                                .foregroundColor(Color("Font"))
                                                .padding()
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(Color("Font"))
                                                        .frame(width: 52, height: 52)
                                                )
                                            
                                            Text(detailType)
                                                .font(.system(size: 10))
                                                .foregroundColor(Color("Font"))
                                            
                                        }
                                    }).sheet(isPresented: {$model.showingType}()) {
                                        TypeView(place: place)
                                            .presentationDetents([.large])
                                    }
                                    
                                    Button(action: {
                                        model.showingPointer = true
                                    }, label: {
                                        VStack {
                                            Text(place.tukazatel ?? "?")
                                                .bold()
                                                .minimumScaleFactor(0.1)
                                                .frame(width: 20, height: 20)
                                                .lineLimit(1)
                                                .foregroundColor(Color("Font"))
                                                .padding()
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(Color("Font"))
                                                        .frame(width: 52, height: 52)
                                                )
                                            
                                            Text(detailIndicator)
                                                .font(.system(size: 10))
                                                .foregroundColor(Color("Font"))
                                            
                                        }
                                    }).sheet(isPresented: {$model.showingPointer}()) {
                                        IndicatorView(place: place)
                                            .presentationDetents([.large])
                                    }
                                    
                                    Button(action: {
                                        model.showingDial = true
                                    }, label: {
                                        VStack {
                                            Text(place.tciselnik ?? "?")
                                                .bold()
                                                .minimumScaleFactor(0.1)
                                                .frame(width: 20, height: 20)
                                                .lineLimit(1)
                                                .foregroundColor(Color("Font"))
                                                .padding()
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(Color("Font"))
                                                        .frame(width: 52, height: 52)
                                                )
                                            
                                            Text(detailDial)
                                                .font(.system(size: 10))
                                                .foregroundColor(Color("Font"))
                                            
                                        }
                                    }).sheet(isPresented: {$model.showingDial}()) {
                                        DialView(place: place)
                                            .presentationDetents([.large])
                                    }
                                    
                                    Button(action: {
                                        model.showingState = true
                                    }, label: {
                                        VStack {
                                            Text(place.stav ?? "?")
                                                .bold()
                                                .minimumScaleFactor(0.1)
                                                .frame(width: 20, height: 20)
                                                .lineLimit(1)
                                                .foregroundColor(Color("Font"))
                                                .padding()
                                                .background(
                                                    RoundedRectangle(cornerRadius: 15)
                                                        .stroke(Color("Font"))
                                                        .frame(width: 52, height: 52)
                                                )
                                            
                                            Text(detailState)
                                                .font(.system(size: 10))
                                                .foregroundColor(Color("Font"))
                                            
                                        }
                                    }).sheet(isPresented: {$model.showingState}()) {
                                        StateView(place: place)
                                            .presentationDetents([.large])
                                    }
                                }.padding([.top, .leading])
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 18) {
                                    ForEach(place.obrazky?.indices ?? [""].indices, id: \.self) { i in
                                        Button(action: {
                                            withAnimation {
                                                model.showingGallery = true
                                            }
                                        }, label: {
                                            AsyncImage(url: URL(string: "https://astro.mff.cuni.cz/mira/sh/icons/640x640/\(place.obrazky?[i] ?? "")"))
                                                .scaledToFill()
                                                .frame(width: 150, height: 150)
                                                .clipped()
                                                .mask(
                                                    RoundedRectangle(cornerRadius: 22)
                                                )
                                        })
                                    }
                                }.padding([.vertical, .leading])
                            }
                            
                            Text(detailSectionInformation)
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
                                                .stroke(Color("Font"))
                                                .frame(width: 120, height: 120)
                                            
                                            Image(systemName: "sun.max.fill")
                                                .frame(width: 20)
                                                .foregroundColor(Color("Font"))
                                                .padding()
                                        }
                                        
                                        Text(detailAzimuth)
                                            .font(.system(size: 10))
                                            .foregroundColor(Color("Font"))
                                    }
                                    
                                    Spacer()
                                    
                                    VStack {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 25)
                                                .stroke(Color("Font"))
                                                .frame(width: 120, height: 120)
                                            
                                            Image(systemName: "sun.max.fill")
                                                .frame(width: 20)
                                                .foregroundColor(Color("Font"))
                                                .padding()
                                        }
                                        
                                        Text(detailAzimuth)
                                            .font(.system(size: 10))
                                            .foregroundColor(Color("Font"))
                                    }
                                    
                                    Spacer()
                                }.padding(.top, 5)
                            }.frame(width: screenSize.width)
                        }
                    } else {
                        
                        Text(detailGuide)
                            .font(.title3)
                            .minimumScaleFactor(0.1)
                        
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

