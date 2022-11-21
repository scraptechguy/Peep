//
//  PointerView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/29/22.
//

import SwiftUI

struct PointerView: View {
    
    @EnvironmentObject var model: ContentModel
    
    var body: some View {
        ZStack {
            Text("Hello world")
        }.preferredColorScheme(model.isLightMode ? .light : .dark)
    }
}

struct PointerView_Previews: PreviewProvider {
    static var previews: some View {
        PointerView()
    }
}
