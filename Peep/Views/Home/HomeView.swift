//
//  HomeView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/8/22.
//

import SwiftUI
import MapKit

struct HomeView: View {
    
    @EnvironmentObject var model: ContentModel
    @EnvironmentObject var data: FetchData
    @EnvironmentObject var net: NetworkMonitor
    
    @State private var showOfflineAlert = false
    @State var selectedPlace: DataModel?
    @State private var zoomLevel: Double = 0.05
    @State private var mapCenter = CLLocationCoordinate2D()
    @State private var centerPlacemark: CLPlacemark?
    @State private var regionChangeWorkItem: DispatchWorkItem?
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    let offlineAlert: LocalizedStringKey = "offlineAlert"
    
    private var cacheExists: Bool {
        let fm = FileManager.default
        // system Caches directory
        let caches = fm.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        // “PeepCache” subfolder
        let dir = caches.appendingPathComponent("PeepCache", isDirectory: true)
        // the exact file
        let file = dir.appendingPathComponent("searchablePlaces.json")
        
        return fm.fileExists(atPath: file.path)
    }
    
    var body: some View {
        ZStack {
            Map(selectedPlace: $selectedPlace)
                .ignoresSafeArea()
            
            VStack {
                NavigationBar(centerPlacemark: $centerPlacemark)
                
                Spacer()
            }
            
            Group {
                locationButton()
                
                PlaceDetail(place: selectedPlace ?? DataModel.init(id: ""))
                
                if model.showingGallery {
                    
                    Gallery(place: selectedPlace!)
                    
                }
            }.preferredColorScheme(model.isLightMode ? .light : .dark)
                .onChange(of: model.annotationSelected, perform: { newValue in
                    if !model.annotationSelected {
                        
                        model.shouldDeselectAnnotations = true
                        
                    }
                })
                .onChange(of: model.authorizationState, perform: { newValue in
                    if model.authorizationState == .authorizedAlways || model.authorizationState == .authorizedWhenInUse {
                        
                        model.shouldCheckIsOnLocation = true
                        
                    }
                    
                    model.shouldDeselectAnnotations = true
                })
                
            SearchView(centerPlacemark: $centerPlacemark)
                .environmentObject(data)
                .opacity(model.showingSearch ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: model.showingSearch)
            
            SettingsView()
                .opacity(model.showingSettings ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: model.showingSettings)
        }.onChange(of: EquatableCoordinate(model.mapView.region.center)) { newCenter in
            // Cancel the previous task if it exists
            regionChangeWorkItem?.cancel()
            
            // Create a new debounced task
            let workItem = DispatchWorkItem {
                let location = CLLocation(latitude: newCenter.latitude, longitude: newCenter.longitude)
                let csLocale = Locale(identifier: "cs-CZ")
                CLGeocoder().reverseGeocodeLocation(location, preferredLocale: csLocale) { placemarks, error in
                    if let placemark = placemarks?.first, error == nil {
                        withAnimation {
                            centerPlacemark = placemark
                        }
                    }
                }
            }
            
            regionChangeWorkItem = workItem
            
            // Execute after 1 seconds if not cancelled
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: workItem)
        }
        .onAppear {
            if !net.isOnline && !cacheExists {
                
                showOfflineAlert = true
                
            }
        }
        .onChange(of: net.isOnline) { online in
            if online {
                
                data.fetchData()
                
            } else if !cacheExists {
                
                showOfflineAlert = true
                
            }
        }
        .alert("Offline!", isPresented: $showOfflineAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(offlineAlert)
        }
    }
    
    @ViewBuilder
    func locationButton() -> some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
                    if model.authorizationState == .authorizedAlways || model.authorizationState == .authorizedWhenInUse {
                        
                        withAnimation {
                            if !model.isOnLocation {
                                
                                model.goToLocation = true
                                model.isOnLocation = true
                                
                            }
                        }
                        
                    } else {
                        
                        withAnimation(.spring(blendDuration: 0.5)) {
                            model.didClickOnLocationButtonWhenLocationOff = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.spring(blendDuration: 0.5)) {
                                model.didClickOnLocationButtonWhenLocationOff = false
                            }
                        }
                        
                    }
                }, label: {
                    if model.authorizationState == .authorizedAlways || model.authorizationState == .authorizedWhenInUse {
                        
                        Image(systemName: model.isOnLocation ? "location.fill" : "location")
                            .foregroundColor(.primary)
                            .padding()
                            .background {
                                ZStack {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .overlay(.thinMaterial)
                                        .mask(
                                            RoundedRectangle(cornerRadius: 30, style: .circular)
                                        )
                                }
                        }
                        
                    } else {
                        
                        Image(systemName: "location")
                            .foregroundColor(.primary)
                            .padding()
                            .background {
                                ZStack {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .overlay(.thinMaterial)
                                        .mask(
                                            RoundedRectangle(cornerRadius: 30, style: .circular)
                                        )
                                }
                        }
                        
                    }
                }).padding(.trailing)
            }.padding(.bottom, screenSize.height / 10.2)
                .padding(.bottom)
        }.ignoresSafeArea()
    }
}

struct EquatableCoordinate: Equatable {
    var latitude: Double
    var longitude: Double

    init(_ coord: CLLocationCoordinate2D) {
        self.latitude = coord.latitude
        self.longitude = coord.longitude
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .preferredColorScheme(.dark)
            .environmentObject(ContentModel())
            .environmentObject(FetchData())
            .environmentObject(NetworkMonitor.shared)
    }
}
