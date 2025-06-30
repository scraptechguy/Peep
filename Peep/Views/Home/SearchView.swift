//
//  SearchView.swift
//  Peep
//
//  Created by Rostislav Brož on 27.05.2025.
//

import SwiftUI

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
    
    var filteredPlaces: [String] {
      let base = searchText.isEmpty
        ? model.searchableAddresses.filter { $0.localizedCaseInsensitiveContains(model.placemark?.locality ?? "") }
        : model.searchableAddresses.filter { $0.localizedCaseInsensitiveContains(searchText) }
      return base
    }
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
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
                            ForEach(Array(filteredPlaces.enumerated()), id: \.offset) { index, place in
                                placeRow(for: place)
                            }
                        }

                        // Extra space at the bottom
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: screenSize.height / 2)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .listRowSeparator(.hidden)
                            .disabled(true) // Prevent any interaction
                    }
                    
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
    func placeRow(for place: String) -> some View {
        Button(action: {
            model.showingSearch = false
            model.searchKeyboardIsFocused = false
            isFocused = false
        }, label: {
            VStack(alignment: .leading, spacing: 0) {
                Text(place)
                    .foregroundColor(Color("Font"))
                    .padding(.vertical, 12)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
