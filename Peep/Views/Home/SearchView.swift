//
//  SearchView.swift
//  Peep
//
//  Created by Rostislav Brož on 27.05.2025.
//

import SwiftUI

struct SearchView: View {
    
    @EnvironmentObject var model: ContentModel
    
    @FocusState var isFocused: Bool
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(width: screenSize.width / 1.1, height: screenSize.width / 6)
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
                        
                        TextField("Search", text: .constant(""))
                            .foregroundColor(Color("Font"))
                            .focused($isFocused)
                        
                        Spacer()
                    }.padding(.horizontal, 22)
                        .frame(width: screenSize.width / 1.35, alignment: .leading)
                }
                
                Spacer()
            }
        }.onChange(of: model.searchKeyboardIsFocused) { newValue in
            if model.searchKeyboardIsFocused {
                isFocused = true
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
