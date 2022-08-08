//
//  HomeView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/8/22.
//

import SwiftUI

struct HomeView: View {
    
    @State var search = ""
    
    var body: some View {
        ZStack {
            Map()
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    TextField("Search the globe", text: $search)
                        .padding(.all, 20.0)
                        .frame(width: 250)
                        .background(
                            Rectangle()
                                .fill(.ultraThinMaterial)
                        )
                        .mask(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                        )
                    
                    Button(action: {
                        
                    }, label: {
                        ZStack {
                            Rectangle()
                                .fill(.thinMaterial)
                                .frame(width: 60, height: 60)
                                .mask(
                                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                                )
                            
                            Image(systemName: "gear")
                                .foregroundColor(.white)
                        }
                    }).padding(.leading, 10)
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
