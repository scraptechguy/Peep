//
//  PlaceDetail.swift
//  Peep
//
//  Created by Rostislav Brož on 8/9/22.
//

import SwiftUI

struct PlaceDetail: View {
    
    @EnvironmentObject var model: ContentModel
    
    let minHeight: CGFloat = UIScreen.main.bounds.height / 10.2
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
                        
                        // MARK: - Address, x button and description
                        
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
                                        model.currentHeight = UIScreen.main.bounds.height / 10.2
                                    }
                                    
                                    model.devLog = String(localized: "annotationDeselected")
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
                            
                            // MARK: - Properties
                            
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
                                    }
                                    
                                    Button(action: {
                                        model.showingType = true
                                    }, label: {
                                        VStack {
                                            if place.thodin == "" {
                                                
                                                Text("?")
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
                                                
                                            } else {
                                                
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
                                                
                                            }
                                            
                                            Text(detailType)
                                                .font(.system(size: 10))
                                                .foregroundColor(Color("Font"))
                                            
                                        }
                                    }).sheet(isPresented: {$model.showingType}()) {
                                        TypeView(place: place)
                                    }
                                    
                                    Button(action: {
                                        model.showingPointer = true
                                    }, label: {
                                        VStack {
                                            if place.tukazatel == "" {
                                                
                                                Text("?")
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
                                                
                                            } else {
                                                
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
                                                
                                            }
                                            
                                            Text(detailIndicator)
                                                .font(.system(size: 10))
                                                .foregroundColor(Color("Font"))
                                            
                                        }
                                    }).sheet(isPresented: {$model.showingPointer}()) {
                                        IndicatorView(place: place)
                                    }
                                    
                                    Button(action: {
                                        model.showingDial = true
                                    }, label: {
                                        VStack {
                                            if place.tciselnik == "" {
                                                
                                                Text("?")
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
                                                
                                            } else {
                                                
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
                                                
                                            }
                                            
                                            Text(detailDial)
                                                .font(.system(size: 10))
                                                .foregroundColor(Color("Font"))
                                            
                                        }
                                    }).sheet(isPresented: {$model.showingDial}()) {
                                        DialView(place: place)
                                    }
                                    
                                    Button(action: {
                                        model.showingState = true
                                    }, label: {
                                        VStack {
                                            if place.stav == "Z" {
                                                Text(place.stav ?? "?")
                                                    .bold()
                                                    .minimumScaleFactor(0.1)
                                                    .frame(width: 20, height: 20)
                                                    .lineLimit(1)
                                                    .foregroundColor(.red)
                                                    .padding()
                                                    .background(
                                                        RoundedRectangle(cornerRadius: 15)
                                                            .stroke(.red)
                                                            .frame(width: 52, height: 52)
                                                    )
                                                
                                                Text(detailState)
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.red)
                                            } else {
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
                                        }
                                    }).sheet(isPresented: {$model.showingState}()) {
                                        StateView(place: place)
                                    }
                                }.padding([.top, .leading])
                            }
                            
                            // MARK: - Image scroll view
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 18) {
                                    ForEach(place.obrazky?.indices ?? [""].indices, id: \.self) { i in
                                        Button(action: {
                                            withAnimation {
                                                model.index = i
                                                model.showingGallery = true
                                            }
                                        }, label: {
                                            AsyncImage(url: URL(string: "https://astro.mff.cuni.cz/mira/sh/icons/640x640/\(place.obrazky?[i] ?? "")")) { phase in
                                                
                                                if let image = phase.image {
                                                    
                                                    image
                                                    
                                                } else if phase.error != nil {
                                                    
                                                    ProgressView()
                                                    
                                                } else {
                                                    
                                                    ProgressView()
                                                    
                                                }
                                                
                                            }.scaledToFill()
                                                .frame(width: 150, height: 150)
                                                .clipped()
                                                .mask(
                                                    RoundedRectangle(cornerRadius: 22)
                                                )
                                        })
                                    }
                                }.padding([.vertical, .horizontal])
                            }
                            
                            // MARK: - More info
                            
                            Text(detailSectionInformation)
                                .textCase(.uppercase)
                                .font(.system(size: 15))
                                .foregroundColor(.secondary)
                                .padding(.leading)
                                .padding(.bottom, 8)
                            
                            VStack(alignment: .center) {
                               HStack {
                                   Text(String(localized: "comingSoon"))
                                       .bold()
                                       .font(.title3)
                                       .padding(.bottom, 50)
                               }.padding(.top, 5)
                           }.frame(width: screenSize.width)
                           
                            /*
                            HStack {
                                Spacer()
                                
                                Button(action: {
                                    
                                }, label: {
                                    VStack {
                                        Image(systemName: "clock")
                                            .frame(width: screenSize.width / 2.5, height: screenSize.width / 2.5)
                                            .background {
                                                Rectangle()
                                                    .foregroundColor(Color.clear)
                                                    .overlay(.thinMaterial)
                                                    .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                                            }
                                        
                                        Text("Appearance")
                                            .font(.system(size: 10))
                                            .foregroundColor(Color("Font"))
                                    }
                                })
                                
                                Spacer()
                                
                                Button(action: {
                                    
                                }, label: {
                                    VStack {
                                        Compass()
                                            .frame(width: screenSize.width / 2.5, height: screenSize.width / 2.5)
                                            .background {
                                                Rectangle()
                                                    .foregroundColor(Color.clear)
                                                    .overlay(.thinMaterial)
                                                    .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
                                            }
                                        
                                        Text("Azimuth")
                                            .font(.system(size: 10))
                                            .foregroundColor(Color("Font"))
                                    }
                                })
                                
                                Spacer()
                            }.frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top)
                                .padding(.bottom, 50)
                            */
                        }
                    } else {
                        
                        // MARK: - Place not selected
                        
                        VStack {
                            Text(detailGuide)
                                .font(.title3)
                                .padding(.horizontal)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)
                            
                            Text(String(localized: "comingSoon"))
                                .bold()
                                .font(.title3)
                                .padding(.top, 50)
                                .padding(.bottom, 30)
                        }
                        
                    }
                }
            }.frame(height: model.currentHeight)
                .frame(maxWidth: .infinity)
                .background {
                    Rectangle()
                        .fill(Color.clear)
                        .overlay(.ultraThinMaterial)
                        .cornerRadius(30, corners: [.topLeft, .topRight])
                }
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .ignoresSafeArea()
            .preferredColorScheme(model.isLightMode ? .light : .dark)
    }
    
    // MARK: - Drag gesture
    
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

// MARK: .cornerRadius() struct and extension

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        return Path(path.cgPath)
        
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        
        clipShape( RoundedCorner(radius: radius, corners: corners) )
        
    }
}

struct PlaceDetail_Previews: PreviewProvider {
    static var previews: some View {
        PlaceDetail(place: DataModel())
            .environmentObject(ContentModel())
    }
}
