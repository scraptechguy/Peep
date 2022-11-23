//
//  ExplanationItem.swift
//  Peep
//
//  Created by Rostislav Brož on 11/23/22.
//

import SwiftUI

struct ExplanationItem: View {
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    let item: String
    let explanation: String
    
    var body: some View {
        HStack {
            Spacer()
            
            Text(item)
                .bold()
                .font(.title)
                .frame(width: 35, height: 35)
                .minimumScaleFactor(0.1)
            
            Spacer()
            
            Text(explanation)
                .frame(width: screenSize.width / 1.7)
            
            Spacer()
        }.foregroundColor(Color("Font"))
    }
}

struct ExplanationItem_Previews: PreviewProvider {
    static var previews: some View {
        ExplanationItem(item: "S", explanation: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
    }
}
