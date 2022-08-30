//
//  SettingsView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/9/22.
//

import SwiftUI

struct SettingsView: View {
    
    let screenSize: CGRect = UIScreen.main.bounds 
    
    @ObservedObject var data = FetchData()
    @EnvironmentObject var model: ContentModel
    
    var body: some View {
        Text("")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.dark)
            .environmentObject(ContentModel())
    }
}
