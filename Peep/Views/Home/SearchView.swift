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
    
    @Binding var selectedPlace: DataModel?
    
    @State private var searchText: String = ""
    
    @FocusState private var isFocused: Bool
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    let homeSearch: LocalizedStringKey = "homeSearch"
    let homeSearchLoading: LocalizedStringKey = "homeSearchLoading"
    let homeSearchNoMatches: LocalizedStringKey = "homeSearchNoMatches"
    
    var filteredPlaces: [DataModel] {
        if searchText.isEmpty {
            return data.dataList.filter { place in
                place.adresa?.localizedCaseInsensitiveContains(model.placemark?.locality ?? "") ?? false
            }
        } else {
            return data.dataList.filter { place in
                place.adresa?.localizedCaseInsensitiveContains(searchText) ?? false
            }
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
                                    model.showingSearch = false
                                    model.searchKeyboardIsFocused = false
                                    isFocused = false
                                }
                            
                            TextField(homeSearch, text: $searchText)
                                .foregroundColor(Color("Font"))
                                .focused($isFocused)
                            
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
            model.showingSearch = false
            model.searchKeyboardIsFocused = false
            isFocused = false
            model.mapView.region = .init(center: CLLocationCoordinate2D(latitude: 50.0755, longitude: 14.4378), latitudinalMeters: 1000, longitudinalMeters: 1000)
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
                            
                            Text(place.umisteni ?? "")
                                .foregroundColor(.secondary)
                                .font(.footnote)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)
                            
                        }
                    }.padding(.vertical)
                    
                    Text(place.stav ?? "")
                        .foregroundColor(Color("Font"))
                        .padding(.trailing)
                }
                
                
                Divider()
            }
        })
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(selectedPlace: .constant(nil))
            .environmentObject(ContentModel())
            .environmentObject(FetchData())
    }
}
