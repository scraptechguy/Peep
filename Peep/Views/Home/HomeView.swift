//
//  HomeView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/8/22.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var model: ContentModel
    
    @State var selectedPlace: DataModel?
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    var body: some View {
        ZStack {
            Map(selectedPlace: $selectedPlace)
                .ignoresSafeArea()
            
            VStack {
                NavigationBar()
                
                Spacer()   
            }
            
            PlaceDetail(place: selectedPlace ?? DataModel.init(id: ""))
            
            if model.showingGallery {
                
                Gallery(place: selectedPlace!)
                
            }
        }.preferredColorScheme(model.isLightMode ? .light : .dark)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .preferredColorScheme(.dark)
            .environmentObject(ContentModel())
    }
}
