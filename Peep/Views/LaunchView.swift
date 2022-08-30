//
//  LaunchView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/8/22.
//

import SwiftUI

struct LaunchView: View {
    
    @EnvironmentObject var model: ContentModel
    
    var body: some View {
        if model.authorizationState == .notDetermined {
            
            OnboardingView()
            
        } else if model.authorizationState == .authorizedAlways || model.authorizationState == .authorizedWhenInUse {
            
            ZStack {
                HomeView()
                
                if model.devLogOn {
                    DevLog()
                }
            }
            
        } else if model.authorizationState == .denied {
            
            DeniedView()
            
        }
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
            .environmentObject(ContentModel())
    }
}
