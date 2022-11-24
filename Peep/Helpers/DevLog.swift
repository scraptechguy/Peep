//
//  DevLog.swift
//  Peep
//
//  Created by Rostislav Brož on 8/30/22.
//

import SwiftUI

struct DevLog: View {
    
    @EnvironmentObject var model: ContentModel
    
    var body: some View {
        Text(model.devLog)
            .font(.system(size: 12))
            .foregroundColor(Color("Font"))
            .frame(height: 33)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading)
            .background(.ultraThinMaterial)
            .mask(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
            )
            .padding(.horizontal)
    }
}

struct DevLog_Previews: PreviewProvider {
    static var previews: some View {
        DevLog()
            .environmentObject(ContentModel())
    }
}
