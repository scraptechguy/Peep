//
//  DeniedView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/8/22.
//

import SwiftUI

struct DeniedView: View {
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            VStack {
                Image("broken_initial")
                
                Text("Peep needs to **track your location** in order for the app to **work**")
                    .padding(25)
                    .foregroundColor(Color("Font"))
                    .multilineTextAlignment(.center)
                
                Text("He'll use it wisely")
                    .font(.system(size: 12))
                    .foregroundColor(Color("Font"))
            }
            
            VStack {
                Spacer()
                
                
            }
        }
    }
}

struct DeniedView_Previews: PreviewProvider {
    static var previews: some View {
        DeniedView()
    }
}
