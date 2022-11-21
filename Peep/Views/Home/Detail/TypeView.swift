//
//  TypeView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/29/22.
//

import SwiftUI

struct TypeView: View {
    
    @EnvironmentObject var model: ContentModel
    
    var body: some View {
        ZStack {
            Text("Hello world")
        }.preferredColorScheme(model.isLightMode ? .light : .dark)
    }
}

struct TypeView_Previews: PreviewProvider {
    static var previews: some View {
        TypeView()
    }
}
