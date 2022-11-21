//
//  StateView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/29/22.
//

import SwiftUI

struct StateView: View {
    
    @EnvironmentObject var model: ContentModel
    
    var body: some View {
        ZStack {
            SomethingWentWrong()
        }.preferredColorScheme(model.isLightMode ? .light : .dark)
    }
}

struct StateView_Previews: PreviewProvider {
    static var previews: some View {
        StateView()
            .environmentObject(ContentModel())
    }
}
