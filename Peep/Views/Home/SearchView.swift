//
//  SearchView.swift
//  Peep
//
//  Created by Rostislav Brož on 27.05.2025.
//

import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject var model: ContentModel
    
    @State private var searchText: String = ""
    
    @FocusState private var isFocused: Bool
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    let homeSearch: LocalizedStringKey = "homeSearch"
    
    var filteredPlaces: [String] {
        if searchText.isEmpty {
            
            var addresses: [String] = []
            
            for place in model.searchableAddresses {
                
                addresses.append(place)
                
            }
            
            return addresses.filter {
                $0.localizedCaseInsensitiveContains(model.placemark?.locality ?? "")
            }
            
        } else {
            
            var addresses: [String] = []
            
            for place in model.searchableAddresses {
                
                addresses.append(place)
                
            }
            
            return addresses.filter {
                $0.localizedCaseInsensitiveContains(searchText)
            }
            
        }
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
                    
                    ProgressView("Loading...")
                        .padding(.top)
                    
                    Spacer()
                    
                } else {
                    
                    ScrollView {
                        LazyVStack(spacing: 0) { // spacing: 0 to match List row style
                            ForEach(filteredPlaces, id: \.self) { item in
                                Button(action: {
                                    
                                }, label: {
                                    VStack(alignment: .leading, spacing: 0) {
                                        Text(item)
                                            .foregroundColor(Color("Font"))
                                            .padding(.vertical, 12)
                                            .padding(.horizontal)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Divider() // Matches default List row separator
                                    }
                                })
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
        }.onChange(of: model.searchKeyboardIsFocused) { newValue in
            if model.searchKeyboardIsFocused {
                
                isFocused = true
                
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                searchText = ""
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(ContentModel())
    }
}
