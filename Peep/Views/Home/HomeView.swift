//
//  HomeView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/8/22.
//

import SwiftUI

struct HomeView: View {
    
    @State var search = ""
    @State var showingSettings = false
    @State var selectedPlace: Place?
    
    var body: some View {
        ZStack {
            Map(selectedPlace: $selectedPlace)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    TextField("Search the globe", text: $search)
                        .padding(.all, 20.0)
                        .frame(width: 270)
                        .background(
                            Rectangle()
                                .fill(.thinMaterial)
                        )
                        .mask(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                        )
                    
                    Button(action: {
                        showingSettings = true
                    }, label: {
                        ZStack {
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 60, height: 60)
                                .mask(
                                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                                )
                            
                            Image(systemName: "gear")
                                .resizable()
                                .foregroundColor(.white)
                                .frame(width: 20, height: 20)
                        }
                    }).sheet(isPresented: {$showingSettings}()) {SettingsView()}
                }
                
                Spacer()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .preferredColorScheme(.dark)
    }
}
