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
    @State private var filteredResults: [DataModel] = [] 
    
    @FocusState private var isFocused: Bool
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    let homeSearch: LocalizedStringKey = "homeSearch"
    let homeSearchLoading: LocalizedStringKey = "homeSearchLoading"
    let homeSearchNoMatches: LocalizedStringKey = "homeSearchNoMatches"
    let homeSearchGuideAddress: LocalizedStringKey = "homeSearchGuideAddress"
    let homeSearchGuideDescription: LocalizedStringKey = "homeSearchGuideDescription"
    let stateZ: LocalizedStringKey = "stateZ"
    
    var filteredPlaces: [DataModel] {
        // Grab the list of places
        let source = model.searchablePlaces

        // Normalize the user query
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Do your “empty search = region” vs “typed search” filter
        let matches: [DataModel] = {
            if query.isEmpty {
                
                let region = centerPlacemark?.locality ?? ""
                return source.filter { $0.adresa?.localizedCaseInsensitiveContains(region) ?? false }
                
            } else {
                
                return source.filter { $0.adresa?.localizedCaseInsensitiveContains(query) ?? false }
            }
        }()

        // If we have a user location, sort by distance, otherwise return the raw matches
        guard let userLoc = model.mapView.userLocation.location else { return matches }

        return matches.sorted { a, b in
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
                if model.searchablePlaces.isEmpty {
                    
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
                            
                            if !searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                                
                                Button(action: {
                                    searchText = ""
                                }, label: {
                                    Image(systemName: "multiply")
                                        .foregroundStyle(Color.secondary)
                                })
                                
                            }
                        }.padding(.horizontal, 22)
                            .frame(width: screenSize.width / 1.1, alignment: .leading)
                    }
                    
                    Spacer()
                }
            }
        }.onAppear {
            model.loadCachedSearchablePlaces()
            
            if !data.dataList.isEmpty {
                model.loadSearchablePlaces(from: data)
            }
        }
        .onChange(of: data.dataList.count) { newValue in
            if newValue > 0 {
                model.loadSearchablePlaces(from: data)
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
    
    // Computes your “filteredPlaces” logic off the main thread,
    // then dispatches the final array back onto the main queue.
    private func computeFilteredResults() {
        // capture current inputs
        let allPlaces = data.dataList
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let regionName = centerPlacemark?.locality ?? ""

        DispatchQueue.global(qos: .userInitiated).async {
            // Filter by region or searchText:
            let matches: [DataModel] = allPlaces.filter {
                let address = $0.adresa ?? ""
                return query.isEmpty ? address.localizedCaseInsensitiveContains(regionName) : address.localizedCaseInsensitiveContains(query)
            }

            // Sort by distance (if we have the user’s location):
            let sorted: [DataModel]
            if let userLoc = model.mapView.userLocation.location {
                sorted = matches.sorted { a, b in
                    let aLoc = CLLocation(latitude: Double(a.zsirka ?? "") ?? 0, longitude: Double(a.zdelka ?? "") ?? 0)
                    let bLoc = CLLocation(latitude: Double(b.zsirka ?? "") ?? 0, longitude: Double(b.zdelka ?? "") ?? 0)
                    return userLoc.distance(from: aLoc) < userLoc.distance(from: bLoc)
                }
            } else {
                sorted = matches
            }

            // Back to the main thread to update your @State:
            DispatchQueue.main.async {
                self.filteredResults = sorted
            }
        }
    }
    
    @ViewBuilder
    func placeRow(for place: DataModel) -> some View {
        Button(action: {
            // Hide search view and keyboard
            model.searchKeyboardIsFocused = false
            model.showingSearch = false
            isFocused = false
            
            // Move the map to the place location
            if let latStr = place.zsirka, let lonStr = place.zdelka, let lat = Double(latStr), let lon = Double(lonStr) {
                
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                
                DispatchQueue.main.async {
                    model.pendingSelectionPlace = place
                    model.shouldSearchAfterRegionChange = true
                    
                    // Center the map
                    model.mapView.setRegion(region, animated: true)
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
