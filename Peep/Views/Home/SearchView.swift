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
    let homeSearchButtonYourLocation: LocalizedStringKey = "homeSearchButtonYourLocation"
    let homeSearchButtonFeatured: LocalizedStringKey = "homeSearchButtonFeatured"
    let homeSearchButtonExplore: LocalizedStringKey = "homeSearchButtonExplore"
    let homeSearchGuideAddress: LocalizedStringKey = "homeSearchGuideAddress"
    let homeSearchGuideDescription: LocalizedStringKey = "homeSearchGuideDescription"
    let stateZ: LocalizedStringKey = "stateZ"
    let unavailableFeatureLocation: LocalizedStringKey = "unavailableFeatureLocation"
    
    private var isTyping: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    
    // MARK: - Filtered places
    
    private var filteredPlaces: [DataModel] {
        // Grab the list of places
        let source = model.searchablePlaces
        
        // Get the user region (e.g. Prague)
        let region = centerPlacemark?.locality ?? ""

        // Normalize the user query
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Show nothing until we know the region or the user types.
        if query.isEmpty && region.isEmpty {
            return []
        }
        
        // Do your “empty search = region” vs “typed search” filter
        let matches: [DataModel] = {
            if query.isEmpty {
                
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
    
    
    // MARK: - Close places
    
    private var closePlaces: [DataModel] {
        guard let userLoc = model.mapView.userLocation.location else { return [] }
        
        // Grab the list of places
        let source = model.searchablePlaces
        
        if let center = centerPlacemark?.location {
            let withinKm: Double = 30
            let matches = source.filter { place in
                if let latStr = place.zsirka, let lonStr = place.zdelka,
                   let lat = Double(latStr), let lon = Double(lonStr) {
                    let dKm = center.distance(from: CLLocation(latitude: lat, longitude: lon)) / 1000.0
                    return dKm <= withinKm
                }
                return false
            }
            
            if !matches.isEmpty {
                return matches.sorted { a, b in
                    let aLoc = CLLocation(latitude: Double(a.zsirka ?? "") ?? 0, longitude: Double(a.zdelka ?? "") ?? 0)
                    let bLoc = CLLocation(latitude: Double(b.zsirka ?? "") ?? 0, longitude: Double(b.zdelka ?? "") ?? 0)
                    
                    return userLoc.distance(from: aLoc) < userLoc.distance(from: bLoc)
                }
            }
        }
        
        return []
    }
    
    
    // MARK: - Random places
    
    @State private var randomSeed: Int = Int(Date().timeIntervalSinceReferenceDate)
    
    private func stableID(for p: DataModel) -> String {
        if let id = p.id, !id.isEmpty { return id }
        return "\((p.zsirka ?? ""))|\((p.zdelka ?? ""))|\((p.adresa ?? ""))"
    }
    
    // Bumps whenever randomSeed changes → new order on each refresh.
    private var randomPlaces: [DataModel] {
        let source = model.searchablePlaces
        
        func key(_ p: DataModel) -> Int {
            var hasher = Hasher()
            hasher.combine(stableID(for: p)) // stable identity
            hasher.combine(randomSeed)       // the “refresh” knob
            return hasher.finalize()
        }

        let ordered = source.sorted { key($0) < key($1) }
        guard let userLoc = model.mapView.userLocation.location else { return ordered }
        
        return Array(ordered.prefix(15)).sorted { a, b in
            let aLoc = CLLocation(latitude: Double(a.zsirka ?? "") ?? 0, longitude: Double(a.zdelka ?? "") ?? 0)
            let bLoc = CLLocation(latitude: Double(b.zsirka ?? "") ?? 0, longitude: Double(b.zdelka ?? "") ?? 0)
            
            return userLoc.distance(from: aLoc) < userLoc.distance(from: bLoc)
        }
    }
    
    
    // MARK: - Featured places
    
    private var featuredPlaces: [DataModel] {
        let base = model.searchablePlaces.filter { ($0.stav ?? "") != "Z" }
        let sorted = base.sorted { lhs, rhs in
            (lhs.adresa ?? "").localizedCaseInsensitiveCompare(rhs.adresa ?? "") == .orderedAscending
        }
        
        return Array(sorted.prefix(15))
    }
    
    
    // MARK: - Tabs
    
    // Which tab is active
    private enum FilterTab { case location, featured, random }

    // Current selection (default to Location)
    @State private var selectedTab: FilterTab = .location
    
    private var displayedPlaces: [DataModel] {
        // While typing, always show query results.
        if isTyping {
            return filteredPlaces
        }
        
        switch selectedTab {
        case .location:
            return closePlaces
        case .featured:
            return featuredPlaces
        case .random:
            return randomPlaces
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            ZStack {
                if model.searchablePlaces.isEmpty {
                    
                    ProgressView(homeSearchLoading)
                        .padding(.top)
                    
                    Spacer()
                    
                } else if isTyping && filteredPlaces.isEmpty {
                    
                    Spacer()
                    
                    Text(homeSearchNoMatches)
                        .foregroundColor(.secondary)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                } else {
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            if closePlaces.isEmpty && selectedTab == .location {
                                VStack {
                                    Text(unavailableFeatureLocation)
                                        .foregroundColor(Color("Font"))
                                        .multilineTextAlignment(.center)
                                        .padding()
                                    
                                    Text(String(localized: "settingsLocationHeading"))
                                        .foregroundColor(Color.blue)
                                        .multilineTextAlignment(.center)
                                        .onTapGesture {
                                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                                if UIApplication.shared.canOpenURL(url) {
                                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                                }
                                            }
                                        }
                                }.frame(maxWidth: .infinity, alignment: .center)
                                    .frame(maxHeight: .infinity, alignment: .center)
                            }
                            
                            ForEach(Array(displayedPlaces.enumerated()), id: \.offset) { index, place in
                                placeRow(for: place)
                            }
                        }
                    }
                    // enable pull-to-refresh only when Random is active (and not typing)
                    .conditionalRefreshable(selectedTab == .random && !isTyping) {
                        // bump the seed to recompute randomPlaces
                        await MainActor.run { randomSeed &+= 1 }
                    }
                    
                }
            }
        }.safeAreaInset(edge: .top) {
            VStack(spacing: 10) {
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
                
                if !isTyping {
                    ScrollView(.horizontal) {
                        HStack(spacing: 5) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTab = .location
                                }
                            }, label: {
                                Label(homeSearchButtonYourLocation, systemImage: selectedTab == .location ? "location.fill" : "location")
                                    .foregroundStyle(selectedTab == .location ? Color.primary : Color.secondary)
                                    .padding(.horizontal)
                                    .padding(.vertical, 5)
                                    .background(
                                        Rectangle()
                                            .fill(.ultraThinMaterial)
                                            .mask(
                                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            )
                                    )
                            })
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTab = .featured
                                }
                            }, label: {
                                Label(homeSearchButtonFeatured, systemImage: selectedTab == .featured ? "star.fill" : "star")
                                    .foregroundStyle(selectedTab == .featured ? Color.primary : Color.secondary)
                                    .padding(.horizontal)
                                    .padding(.vertical, 5)
                                    .background(
                                        Rectangle()
                                            .fill(.ultraThinMaterial)
                                            .mask(
                                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            )
                                    )
                            })
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTab = .random
                                }
                            }, label: {
                                Label(homeSearchButtonExplore, systemImage: selectedTab == .random ? "globe.europe.africa.fill" : "globe.europe.africa")
                                    .foregroundStyle(selectedTab == .random ? Color.primary : Color.secondary)
                                    .padding(.horizontal)
                                    .padding(.vertical, 5)
                                    .background(
                                        Rectangle()
                                            .fill(.ultraThinMaterial)
                                            .mask(
                                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            )
                                    )
                            })
                        }.padding(.horizontal)
                    }.frame(width: screenSize.width)
                        .scrollIndicators(.hidden)
                }
            }
        }
        .onAppear {
            model.loadCachedSearchablePlaces()
            
            if !data.dataList.isEmpty {
                model.loadSearchablePlaces(from: data)
            }
        }
        .onChange(of: data.dataList.count) { oldValue, newValue in
            if newValue > 0 {
                model.loadSearchablePlaces(from: data)
            }
        }
        .onChange(of: model.searchKeyboardIsFocused) {
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

fileprivate extension View {
    @ViewBuilder
    func conditionalRefreshable(
        _ condition: Bool,
        action: @escaping () async -> Void
    ) -> some View {
        if condition {
            self.refreshable { await action() }
        } else {
            self
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(centerPlacemark: .constant(nil))
            .environmentObject(ContentModel())
            .environmentObject(FetchData())
    }
}
