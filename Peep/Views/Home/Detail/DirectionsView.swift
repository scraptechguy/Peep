//
//  DirectionsView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/29/22.
//

import SwiftUI

struct DirectionsView: View {
    
    // var place: DataModel
    let screenSize: CGRect = UIScreen.main.bounds 
    
    var body: some View {
        VStack(alignment: .leading ) {
            Text("Sloveč 1")
                .padding([.leading, .top])
                .font(.system(size: 25))
                .foregroundColor(Color("Font"))
            
            Text("budova bývalého statku, zemědělské družstvo")
                .padding(.leading)
                .font(.system(size: 15))
                .foregroundColor(.secondary)
        }
    }
}

struct DirectionsView_Previews: PreviewProvider {
    static var previews: some View {
        DirectionsView()
    }
}
