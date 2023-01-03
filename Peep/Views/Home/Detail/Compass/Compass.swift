//
//  Compass.swift
//  Peep
//
//  Created by Rostislav Brož on 12/21/22.
//
/*
import SwiftUI

struct Compass: View {
    
    @ObservedObject var compassHeading = ContentModel()
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    var body: some View {
        VStack {
            ZStack {
                ForEach(Marker.markers(), id: \.self) { marker in
                    CompassMarkerView(marker: marker, compassDegress: self.compassHeading.degrees)
                }
            }.frame(width: screenSize.width / 2.5, height: screenSize.width / 2.5)
                .rotationEffect(Angle(degrees: self.compassHeading.degrees))
                .statusBar(hidden: true)
        }
    }
}
struct CompassMarkerView: View {
    
    @ObservedObject var compassHeading = ContentModel()
    
    let marker: Marker
    let compassDegress: Double
    var body: some View {
        VStack {
            Capsule()
                .frame(width: self.capsuleWidth(), height: self.capsuleHeight())
                .foregroundColor(self.capsuleColor())
            Text(marker.label)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .rotationEffect(self.textAngle())
                    .padding(.bottom, 80)
        }.rotationEffect(Angle(degrees: marker.degrees))
    }
    
    private func capsuleWidth() -> CGFloat {
        return marker.degrees == 0 ? 4 : 1
    }
    private func capsuleHeight() -> CGFloat {
        return marker.degrees == 0 ? 22 : 12
    }
    private func capsuleColor() -> Color {
        return marker.degrees == 0 ? .green : .primary
    }
    private func textAngle() -> Angle {
        return Angle(degrees: -self.compassDegress - self.marker.degrees)
    }
}
struct Marker: Hashable {
    let degrees: Double
    let label: String
    init(degrees: Double, label: String = "") {
        self.degrees = degrees
        self.label = label
    }
    
    static func markers() -> [Marker] {
        return [
            Marker(degrees: 0, label: "N"),
            Marker(degrees: 15),
            Marker(degrees: 30),
            Marker(degrees: 45),
            Marker(degrees: 60),
            Marker(degrees: 75),
            Marker(degrees: 90, label: "E"),
            Marker(degrees: 105),
            Marker(degrees: 120),
            Marker(degrees: 135),
            Marker(degrees: 150),
            Marker(degrees: 165),
            Marker(degrees: 180, label: "S"),
            Marker(degrees: 195),
            Marker(degrees: 210),
            Marker(degrees: 225),
            Marker(degrees: 240),
            Marker(degrees: 255),
            Marker(degrees: 270, label: "w"),
            Marker(degrees: 285),
            Marker(degrees: 300),
            Marker(degrees: 315),
            Marker(degrees: 330),
            Marker(degrees: 345)
        ]
    }
}
struct Compass_Previews: PreviewProvider {
    static var previews: some View {
        Compass()
            .environmentObject(ContentModel())
    }
}
*/
