//
//  LaunchView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/8/22.
//

import SwiftUI

struct LaunchView: View {
    
    @EnvironmentObject var model: ContentModel
    @ObservedObject var data = FetchData()
    
    var body: some View {
        Group {
            // If user is already authorized (or denied), go straight to HomeView.
            if model.authorizationState == .authorizedAlways || model.authorizationState == .authorizedWhenInUse || model.authorizationState == .denied {
                
                HomeView()
                
            }
            // Otherwise, if onboarding has never been shown yet, show onboarding:
            else if !model.didShowOnboarding {
                
                OnboardingView()
                
            }
            // If onboarding was shown but we still have .notDetermined (user never tapped Allow/Deny), go to a “Request permission” screen (or simply re-run the request).
            else {
                
                RequestView()
                
            }
        }
        .onAppear {
            // Always sync the published state from the system’s current authorizationStatus.
            model.authorizationState = model.locationManager.authorizationStatus
        }
        .onAppear {
            // 1) Restore cache
            model.loadCachedSearchableAddresses()
            // 2) As soon as our dataList is non-empty, repopulate & persist
            if data.dataList.count > 0 {
                model.loadSearchableAddresses(from: data)
            }
        }
        .onChange(of: data.dataList.count) { newCount in
            if newCount > 0 {
                model.loadSearchableAddresses(from: data)
            }
        }
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
            .environmentObject(ContentModel())
            .environmentObject(FetchData())
    }
}
