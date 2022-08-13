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
        List(data.dataList) { x in
            VStack {
                Text(x.title)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
