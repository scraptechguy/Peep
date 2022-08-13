//
//  PlaceDetail.swift
//  Peep
//
//  Created by Rostislav Brož on 8/9/22.
//

import SwiftUI

struct PlaceDetail: View {
    var place: DataModel
    
    var body: some View {
        VStack {
            Text(place.adresa ?? "")
                .foregroundColor(Color("Font"))
        }
    }
}
