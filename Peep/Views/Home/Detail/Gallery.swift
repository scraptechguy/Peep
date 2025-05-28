//
//  Gallery.swift
//  Peep
//
//  Created by Rostislav Brož on 11/22/22.
//

import SwiftUI
import Photos

struct Gallery: View {
    
    @EnvironmentObject var model: ContentModel
    
    @State private var uiImages: [Int: UIImage] = [:]
    
    var place: DataModel
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    let detailGalleryHeading: LocalizedStringKey = "detailGalleryHeading"
    let detailGalleryGuide: LocalizedStringKey = "detailGalleryGuide"
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            let images = place.obrazky ?? []

            TabView(selection: $model.index) {
                ForEach(Array(images.enumerated()), id: \.offset) { pair in
                    let i = pair.offset
                    let imageName = pair.element

                    GeometryReader { proxy in
                        if let url = URL(string: "https://astro.mff.cuni.cz/mira/sh/icons/640x640/\(imageName)") {
                            GalleryImageView(
                                index: i,
                                screenSize: screenSize,
                                imageURL: url,
                                proxy: proxy,
                                uiImages: $uiImages
                            )
                        } else {
                            Text("Invalid image URL for index \(i)")
                        }
                    }
                    .tag(i)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(width: screenSize.width, height: screenSize.height)
           
            VStack {
                Spacer()
                Text(detailGalleryGuide)
                    .font(.title3)
                    .padding(.bottom, 105)
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            model.showingGallery = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                model.index = 0
                            }
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                            Image(systemName: "multiply")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }.frame(width: 35, height: 35)
                            .padding(.trailing)
                            .padding(.top, 45)
                    }
                }
                Spacer()
            }
        }
    }
}

struct GalleryImageView: View {
    let index: Int
    let screenSize: CGRect
    let imageURL: URL
    let proxy: GeometryProxy

    @State var prompt: String = ""
    @Binding var uiImages: [Int: UIImage]
    
    let detailGalleryPromptDenied: LocalizedStringKey = "detailGalleryPromptDenied"
    let detailGalleryPromptSettings: LocalizedStringKey = "detailGalleryPromptSettings"
    let detailGalleryPromptSucceeded: LocalizedStringKey = "detailGalleryPromptSucceeded"
    let detailGalleryPromptFailed: LocalizedStringKey = "detailGalleryPromptFailed"

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if let uiImage = uiImages[index] {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: screenSize.width / 1.2, height: screenSize.width / 1.2)
                            .clipped()
                            .mask(RoundedRectangle(cornerRadius: 22))
                    } else {
                        ProgressView()
                            .task {
                                do {
                                    let (data, _) = try await URLSession.shared.data(from: imageURL)
                                    if let image = UIImage(data: data) {
                                        uiImages[index] = image
                                    }
                                } catch {
                                    withAnimation {
                                        prompt = "failed save"
                                    }
                                        
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        withAnimation {
                                            prompt = ""
                                        }
                                    }
                                    
                                    print("Download failed: \(error)")
                                }
                            }
                    }
                    Spacer()
                }
                Spacer()
            }.shadow(color: Color.gray.opacity(0.3), radius: 10, x: 0, y: 10)
            .frame(width: screenSize.width, height: screenSize.height / 1.5)
            
            VStack {
                if let uiImage = uiImages[index] {
                    
                    Button(action: {
                        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                            if status == .authorized || status == .limited {
                                
                                UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                                
                                withAnimation {
                                    prompt = "successful save"
                                }
                                    
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    withAnimation {
                                        prompt = ""
                                    }
                                }
                                
                            } else {
                                
                                withAnimation {
                                    prompt = "denied"
                                }
                                    
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation {
                                        prompt = ""
                                    }
                                }
                                
                            }
                        }
                    }, label: {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                            Image(systemName: "arrow.down.to.line.alt")
                                .font(.title3)
                                .foregroundColor(Color("Font"))
                        }.frame(width: 45, height: 45)
                    }).padding(.top, screenSize.height / 2)
                }
                
                switch prompt {
                    case "successful save":
                        Text(detailGalleryPromptSucceeded)
                        .font(.footnote)
                    
                    case "failed save":
                        Text(detailGalleryPromptFailed)
                        .font(.footnote)
                    
                    case "denied":
                        HStack(spacing: 5) {
                            Text(detailGalleryPromptDenied)
                                .font(.caption)
                            
                            Button(action: {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    if UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    }
                                }
                            }, label: {
                                Text(detailGalleryPromptSettings)
                                    .font(.caption)
                                    .foregroundColor(Color("Font"))
                            })
                        }

                    default:
                        Text("")
                    }
            }
        }.rotation3DEffect(.degrees(proxy.frame(in: .global).minX / -10), axis: (x: 0, y: 1, z: 0))
            .blur(radius: abs(proxy.frame(in: .global).minX / 40))
    }
}
