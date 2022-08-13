//
//  SettingsView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/9/22.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var data = FetchData()
    
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            VStack {
                Text("Sloveč 1")
                    .font(.system(size: 30))
                    .foregroundColor(Color("Font"))
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.dark)
    }
}
