//
//  HelpView.swift
//  Peep
//
//  Created by Rostislav Brož on 12/8/22.
//

import SwiftUI

struct HelpView: View {
    
    @EnvironmentObject var model: ContentModel
    
    @State private var index: Int = 0
    @State private var screenIsLast = false
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    let detailGalleryGuide: LocalizedStringKey = "detailGalleryGuide"
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack {
                TabView(selection: $index) {
                    ForEach(guides.indices, id: \.self) { i in
                        GeometryReader { proxy in
                            let size = proxy.size
                            
                            VStack {
                                VStack {
                                    guideScreen(size: size, index: i)
                                }.rotation3DEffect(.degrees(proxy.frame(in: .global).minX / -10), axis: (x: 0, y: 1, z: 0))
                                    .shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 10)
                                    .blur(radius: abs(proxy.frame(in: .global).minX / 40))
                            }.frame(width: screenSize.width, height: screenSize.height / 1.5, alignment: .center)
                        }.tag(i)
                    }
                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(maxHeight: .infinity)
                    .ignoresSafeArea()
            }
        }.preferredColorScheme(model.isLightMode ? .dark : .light)
    }
    
    @ViewBuilder
    func guideScreen(size: CGSize, index: Int) -> some View {
        let guide = guides[index]
        
        VStack {
            Image(guide.imageName)
                .resizable()
                .scaledToFit()
            
            Text(guide.title)
                .font(.title2.bold())
            
            Text(guide.text)
                .multilineTextAlignment(.center)
                .padding()
            
            Text("\(index + 1)/11")
                .font(.footnote.bold())
        }
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpView()
            .environmentObject(ContentModel())
    }
}
