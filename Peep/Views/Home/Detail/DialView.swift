//
//  DialView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/29/22.
//

import SwiftUI

struct DialView: View {
    
    @EnvironmentObject var model: ContentModel
    
    var body: some View {
        ZStack {
            SomethingWentWrong()
        }.preferredColorScheme(model.isLightMode ? .light : .dark)
    }
}

struct DialView_Previews: PreviewProvider {
    static var previews: some View {
        DialView()
            .environmentObject(ContentModel())
    }
}
