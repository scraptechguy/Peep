//
//  RegionsView.swift
//  Peep
//
//  Created by Rostislav Brož on 9/19/22.
//

import SwiftUI

struct RegionsView: View {
    
    @EnvironmentObject var model: ContentModel
    
    var body: some View {
        List {
            Section(header: Text("Regions"), footer: Text("Region you're in is selected automatically")) {
                ForEach(model.regions.indices, id: \.self) { i in
                    Button(action: {
                            
                        }, label: {
                            HStack {
                                Text(model.regions[i])
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                
                                Image(systemName: "checkmark")
                                    .foregroundColor(.primary)
                            }
                    })
                }
            }
        }
    }
}

struct RegionsView_Previews: PreviewProvider {
    static var previews: some View {
        RegionsView()
            .environmentObject(ContentModel())
            .preferredColorScheme(.dark)
    }
}
