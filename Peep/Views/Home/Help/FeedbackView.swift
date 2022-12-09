//
//  FeedbackView.swift
//  Peep
//
//  Created by Rostislav Brož on 12/9/22.
//

import SwiftUI

struct FeedbackView: View {
    
    @State var text: String = ""
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack {
                Divider()
                
                if #available(iOS 16.0, *) {
                    TextField("Here you can share feedback with the developers!", text: $text, axis: .vertical)
                        .lineLimit(10, reservesSpace: true)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.horizontal)
                } else {
                    TextField("Here you can share feedback with the developers!", text: $text)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    
                }, label: {
                    Text("Send feedback")
                        .font(.title3.bold())
                        .frame(width: screenSize.width / 1.9, height: 55)
                        .foregroundColor(.white)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .background(.ultraThinMaterial)
                                .background(
                                    Image("Blob")
                                        .scaleEffect(1.2)
                                )
                                .mask(
                                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                                )
                        }
                }).padding(.bottom, 5)
                
                Text("Do **not** share any personal or sensitive information, feedback is completely annonymous.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 50)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 25)
            }
        }
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
            .preferredColorScheme(.dark)
    }
}
