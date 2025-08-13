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
    let homeSearchButtonHistory: LocalizedStringKey = "homeSearchButtonHistory"
    let homeSearchClearHistory: LocalizedStringKey = "homeSearchClearHistory"
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
    
    
    // MARK: - History
    
    private let historyKey = "SearchHistory.v1"

    private struct HistoryEntry: Codable, Equatable {
        let key: String              // stable key for de-dup
        let id: String?              // DataModel.id if available
        let adresa: String?          // snapshot for potential fallback display
        let zsirka: String?          // snapshot coords
        let zdelka: String?
        let timestamp: Date          // recency
    }

    // In-memory cache of history (persisted via UserDefaults)
    @State private var history: [HistoryEntry] = []

    // Stable key for places (id preferred; otherwise coords+address)
    private func historyKey(for p: DataModel) -> String {
        if let id = p.id, !id.isEmpty { return "id:\(id)" }
        return "geo:\(p.zsirka ?? "")|\(p.zdelka ?? "")|\(p.adresa ?? "")"
    }

    // Load/save helpers
    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey) else { return }
        if let decoded = try? JSONDecoder().decode([HistoryEntry].self, from: data) {
            history = decoded
        }
    }

    private func saveHistory() {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }

    // Push a place to the top (dedupe, cap at 15)
    private func addToHistory(_ p: DataModel) {
        let key = historyKey(for: p)
        history.removeAll { $0.key == key }   // dedupe
        let entry = HistoryEntry(
            key: key,
            id: p.id,
            adresa: p.adresa,
            zsirka: p.zsirka,
            zdelka: p.zdelka,
            timestamp: Date()
        )
        history.insert(entry, at: 0)
        if history.count > 15 { history.removeLast(history.count - 15) }
        saveHistory()
    }

    // If an id match exists in the live dataset, use it; otherwise try coord match; else skip.
    private var searchHistoryPlaces: [DataModel] {
        let all = model.searchablePlaces
        var out: [DataModel] = []
        out.reserveCapacity(history.count)
        
        for h in history {
            if let id = h.id, let byId = all.first(where: { $0.id == id }) {
                out.append(byId)
                continue
            }
            if let lat = h.zsirka, let lon = h.zdelka {
                if let byGeo = all.first(where: { ($0.zsirka ?? "") == lat && ($0.zdelka ?? "") == lon }) {
                    out.append(byGeo)
                    continue
                }
            }
        }
        
        return out
    }
    
    
    // MARK: - Close places
    
    private var closePlaces: [DataModel] {
        guard let userLoc = model.mapView.userLocation.location else { return [] }
        
        // Grab the list of places
        let source = model.searchablePlaces
        
        let withinKm: Double = 30
        let matches = source.filter { place in
            if let latStr = place.zsirka, let lonStr = place.zdelka,
               let lat = Double(latStr), let lon = Double(lonStr) {
                let dKm = userLoc.distance(from: CLLocation(latitude: lat, longitude: lon)) / 1000.0
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
        let filtered = model.searchablePlaces.filter { ($0.thodin ?? "") == "E" }
        
        guard let userLoc = model.mapView.userLocation.location else { return Array(filtered.prefix(15)) }
        
        let sorted = filtered.sorted { a, b in
            let aLoc = CLLocation(latitude: Double(a.zsirka ?? "") ?? 0, longitude: Double(a.zdelka ?? "") ?? 0)
            let bLoc = CLLocation(latitude: Double(b.zsirka ?? "") ?? 0, longitude: Double(b.zdelka ?? "") ?? 0)
            
            return userLoc.distance(from: aLoc) < userLoc.distance(from: bLoc)
        }
        
        return Array(sorted.prefix(15))
    }
    
    
    // MARK: - Tabs
    
    // Which tab is active
    private enum FilterTab { case history, location, featured, random }

    // Current selection (default to History if not empty, otherwise default to Location)
    @State private var selectedTab: FilterTab = .history
    
    private var displayedPlaces: [DataModel] {
        if isTyping {
            return filteredPlaces
        }
        
        switch selectedTab {
        case .history:
            return searchHistoryPlaces
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
                } else if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && filteredPlaces.isEmpty {
                    Spacer()
                    
                    Text(homeSearchNoMatches)
                        .foregroundColor(.secondary)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            if model.authorizationState != .authorizedAlways && model.authorizationState != .authorizedWhenInUse && !isTyping && selectedTab == .location {
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
                            
                            if isTyping {
                                ForEach(Array(displayedPlaces.enumerated()), id: \.offset) { index, place in
                                    placeRow(for: place)
                                }
                            } else {
                                switch selectedTab {
                                case .history:
                                    ForEach(Array(displayedPlaces.enumerated()), id: \.offset) { index, place in
                                        historyPlaceRow(for: place)
                                    }
                                case .location:
                                    ForEach(Array(displayedPlaces.enumerated()), id: \.offset) { index, place in
                                        placeRow(for: place)
                                    }
                                case .featured:
                                    ForEach(Array(displayedPlaces.enumerated()), id: \.offset) { index, place in
                                        placeRow(for: place)
                                    }
                                case .random:
                                    ForEach(Array(displayedPlaces.enumerated()), id: \.offset) { index, place in
                                        placeRow(for: place)
                                    }
                                }
                            }
                            
                            if selectedTab == .history && !history.isEmpty {
                                Button(action: {
                                    history.removeAll()
                                    saveHistory()
                                }, label: {
                                    Label(homeSearchClearHistory, systemImage: "trash")
                                        .foregroundStyle(Color.red)
                                        .padding()
                                })
                            }
                        }
                    }
                    // enable pull-to-refresh only when Random is active (and not typing)
                    .conditionalRefreshable(selectedTab == .random) {
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
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                    if history.isEmpty {
                                        selectedTab = .location
                                    } else {
                                        selectedTab = .history
                                    }
                                }
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
                                selectedTab = .history
                            }, label: {
                                Label(homeSearchButtonHistory, systemImage: selectedTab == .history ? "magnifyingglass" : "magnifyingglass")
                                    .foregroundStyle(selectedTab == .history ? Color.primary : Color.secondary)
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
                                selectedTab = .location
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
                                selectedTab = .featured
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
                                selectedTab = .random
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
        // Load the history cache when the view appears.
        .onAppear {
            model.loadCachedSearchablePlaces()
            
            if !data.dataList.isEmpty { model.loadSearchablePlaces(from: data) }
            
            loadHistory() // load persisted history
            if history.isEmpty { selectedTab = .location }
        }
        .onChange(of: data.dataList.count) { oldValue, newValue in
            if newValue > 0 { model.loadSearchablePlaces(from: data) }
        }
        .onChange(of: model.searchKeyboardIsFocused) {
            if model.searchKeyboardIsFocused { isFocused = true }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                searchText = ""
            }
        }
    }
    
    
    // MARK: - Place row
    
    @ViewBuilder
    func placeRow(for place: DataModel) -> some View {
        Button(action: {
            // Record in history
            addToHistory(place)
            
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                if history.isEmpty {
                    selectedTab = .location
                } else {
                    selectedTab = .history
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
    
    
    // MARK: - History place row
    
    @ViewBuilder
    func historyPlaceRow(for place: DataModel) -> some View {
        Button(action: {
            // Record in history
            addToHistory(place)
            
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                if history.isEmpty {
                    selectedTab = .location
                } else {
                    selectedTab = .history
                }
            }
        }, label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: "clock")
                        .foregroundStyle(Color.secondary)
                        .padding(.horizontal)
                    
                    VStack {
                        Text(place.adresa ?? "")
                            .foregroundColor(Color("Font"))
                            .padding(.trailing)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                        
                        if place.umisteni != "" {
                            
                            if place.stav == "Z" {
                                
                                Text(stateZ)
                                    .foregroundColor(.red)
                                    .font(.footnote)
                                    .padding(.trailing)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                                
                            } else {
                                
                                Text(place.umisteni ?? "")
                                    .foregroundColor(.secondary)
                                    .font(.footnote)
                                    .padding(.trailing)
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
