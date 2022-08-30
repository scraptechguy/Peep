//
//  HomeView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/8/22.
//

import SwiftUI

struct HomeView: View {
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    @EnvironmentObject var model: ContentModel
    
    @State var selectedPlace: DataModel?
    
    var body: some View {
        ZStack {
            Map(selectedPlace: $selectedPlace)
                .ignoresSafeArea()
            
            VStack {
                NavigationBar()
                
                Spacer()
                
                Group {
                    if selectedPlace != nil {
                        PlaceDetail(place: selectedPlace!)
                    } else {
                        Text("Hahah")
                    }
                }.frame(width: screenSize.width, height: 250)
                    .background(
                        .thinMaterial
                    )
                    .mask(
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                    )
            }.ignoresSafeArea()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .preferredColorScheme(.dark)
            .environmentObject(ContentModel())
    }
}
