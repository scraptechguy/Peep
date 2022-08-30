//
//  SomethingWentWrong.swift
//  Peep
//
//  Created by Rostislav Brož on 8/11/22.
//

import SwiftUI

struct SomethingWentWrong: View {
    var body: some View {
        ZStack {
            Color("Background").ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image("broken_initial")
                
                Text("*Something* went wrong")
                    .padding(.top, 25)
                    .font(.system(size: 20))
                    .foregroundColor(Color("Font"))
                    .multilineTextAlignment(.center)
                
                Text("Try reopening the app")
                    .padding(.top, 1)
                    .font(.system(size: 15))
                    .foregroundColor(Color("Font"))
                    .multilineTextAlignment(.center)
                
                Spacer()
                Spacer()
            }
        }
    }
}

struct SomethingWentWrong_Previews: PreviewProvider {
    static var previews: some View {
        SomethingWentWrong()
    }
}
