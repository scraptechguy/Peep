//
//  ExplanationItem.swift
//  Peep
//
//  Created by Rostislav Brož on 11/23/22.
//

import SwiftUI

/// A single row that shows a short label (e.g., a letter or code)
/// next to a longer explanatory text, styled to fit within a compact width.
struct ExplanationItem: View {
    /// Cached screen bounds used to size the explanation text.
    let screenSize: CGRect = UIScreen.main.bounds
    
    /// The short item code, letter, or symbol displayed prominently.
    let item: String
    
    /// The longer description explaining the item.
    let explanation: String
    
    var body: some View {
        HStack {
            Spacer()
            
            // Prominent leading token (e.g., “S”)
            Text(item)
                .bold()
                .font(.title)
                .frame(width: 35, height: 35)
                .minimumScaleFactor(0.1) // allow shrinking if localization gets long
            
            Spacer()
            
            // Main explanatory text
            Text(explanation)
                .frame(width: screenSize.width / 1.7, alignment: .leading)
                .minimumScaleFactor(0.1)
            
            Spacer()
        }.foregroundColor(Color("Font"))
    }
}

struct ExplanationItem_Previews: PreviewProvider {
    static var previews: some View {
        ExplanationItem(item: "S", explanation: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
    }
}
