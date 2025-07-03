//
//  SearchView.swift
//  Peep
//
//  Created by Rostislav Brož on 27.05.2025.
//

import SwiftUI
import MapKit

struct SearchView: View {
    @EnvironmentObject var model: ContentModel
    @EnvironmentObject var data: FetchData
    
    @Binding var centerPlacemark: CLPlacemark?
    
    @State private var searchText: String = ""
    
    @FocusState private var isFocused: Bool
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    let homeSearch: LocalizedStringKey = "homeSearch"
    let homeSearchLoading: LocalizedStringKey = "homeSearchLoading"
    let homeSearchNoMatches: LocalizedStringKey = "homeSearchNoMatches"
    let homeSearchGuideAddress: LocalizedStringKey = "homeSearchGuideAddress"
    let homeSearchGuideDescription: LocalizedStringKey = "homeSearchGuideDescription"
    let stateZ: LocalizedStringKey = "stateZ"
    
    var filteredPlaces: [DataModel] {
        let matches: [DataModel]
        
        if searchText.isEmpty {
            
            let region = centerPlacemark?.locality ?? ""
            matches = data.dataList.filter {
                $0.adresa?.localizedCaseInsensitiveContains(region) ?? false
            }
            
        } else {
            
            matches = data.dataList.filter {
                $0.adresa?.localizedCaseInsensitiveContains(searchText) ?? false
            }
            
        }

        // check if we have a user location, sort by distance
        guard let userLoc = model.mapView.userLocation.location else {
            return matches
        }

        return matches.sorted { a, b in
            // build CLLocation for each place
            let aLoc = CLLocation(latitude: Double(a.zsirka ?? "") ?? 0, longitude: Double(a.zdelka ?? "") ?? 0)
            let bLoc = CLLocation(latitude: Double(b.zsirka ?? "") ?? 0, longitude: Double(b.zdelka ?? "") ?? 0)

            return userLoc.distance(from: aLoc) < userLoc.distance(from: bLoc)
        }
    }
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            ZStack {
                if model.searchableAddresses.isEmpty {
                    
                    ProgressView(homeSearchLoading)
                        .padding(.top)
                    
                    Spacer()
                    
                } else if !searchText.trimmingCharacters(in: .whitespaces).isEmpty && filteredPlaces.isEmpty {
                    
                    Spacer()
                    
                    Text(homeSearchNoMatches)
                        .foregroundColor(.secondary)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                } else {
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            Spacer().frame(height: screenSize.width / 7.5)
                            
                            ForEach(Array(filteredPlaces.enumerated()), id: \.offset) { index, place in
                                placeRow(for: place)
                            }
                        }
                    }
                    
                }
                
                VStack {
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .frame(width: screenSize.width / 1.1, height: screenSize.width / 8)
                            .mask(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                            )
                        
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color("Font"))
                                .onTapGesture {
                                    model.searchKeyboardIsFocused = false
                                    model.showingSearch = false
                                    isFocused = false
                                }
                            
                            TextField(homeSearch, text: $searchText)
                                .foregroundColor(Color("Font"))
                                .focused($isFocused)
                                .keyboardType(.asciiCapable)
                            
                            Spacer()
                        }.padding(.horizontal, 22)
                            .frame(width: screenSize.width / 1.35, alignment: .leading)
                    }
                    
                    Spacer()
                }
            }
        }.onAppear {
            if data.dataList.count > 0 {
                model.loadSearchableAddresses(from: data)
            }
        }
        .onChange(of: data.dataList.count) { newValue in
            if newValue > 0 {
                model.loadSearchableAddresses(from: data)
            }
        }
        .onChange(of: model.searchKeyboardIsFocused) { newValue in
            if model.searchKeyboardIsFocused {
                isFocused = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                searchText = ""
            }
        }
        .onChange(of: model.searchKeyboardIsFocused) { newValue in
            if model.searchKeyboardIsFocused {
                
                isFocused = true
                
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                searchText = ""
            }
        }
    }
    
    @ViewBuilder
    func placeRow(for place: DataModel) -> some View {
        Button(action: {
            // hide search view and keyboard
            model.searchKeyboardIsFocused = false
            model.showingSearch = false
            isFocused = false
            
            // move the map to the place location
            if let latStr = place.zsirka, let lonStr = place.zdelka, let lat = Double(latStr), let lon = Double(lonStr) {
                
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                
                DispatchQueue.main.async {
                    // Set the map region
                    model.mapView.setRegion(region, animated: true)

                    // Try selecting the annotation using the Coordinator's cache
                    if let coordinator = model.mapView.delegate as? Map.Coordinator {
                        let key = place.adresa ?? ""
                        if let annotation = coordinator.annotationCache[key] {
                            if !model.mapView.annotations.contains(where: { $0 === annotation }) {
                                model.mapView.addAnnotation(annotation)
                            }

                            model.mapView.selectAnnotation(annotation, animated: true)
                        } else {
                            print("No cached annotation for key: \(key)")
                        }
                    }
                }
                
            }
        }, label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    VStack {
                        Text(place.adresa ?? "")
                            .foregroundColor(Color("Font"))
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                        
                        if place.umisteni != "" {
                            
                            if place.stav == "Z" {
                                
                                Text(stateZ)
                                    .foregroundColor(.red)
                                    .font(.footnote)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                
                            } else {
                                
                                Text(place.umisteni ?? "")
                                    .foregroundColor(.secondary)
                                    .font(.footnote)
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                
                            }
                            
                        }
                    }.padding(.vertical)
                    
                    if let userLocation = model.mapView.userLocation.location, let lat = Double(place.zsirka ?? ""), let long = Double(place.zdelka ?? "") {
                        let placeLoc = CLLocation(latitude: lat, longitude: long)
                        let km = userLocation.distance(from: placeLoc) / 1_000
                        
                        Text(String(format: "%.1f km", km))
                            .foregroundColor(.secondary)
                            .padding(.trailing)
                    }
                }
                
                
                Divider()
            }
        })
    }
}
