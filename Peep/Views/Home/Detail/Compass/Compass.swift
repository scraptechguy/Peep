//
//  Compass.swift
//  Peep
//
//  Created by Rostislav Brož on 12/21/22.
//

import SwiftUI

struct Compass: View {
    
    @ObservedObject var compassHeading = CompassHeading()
    
    var body: some View {
        VStack {
            Capsule()
                .frame(width: 5,
                       height: 50)

            // 1
            ZStack {
                // 2
                ForEach(Marker.markers(), id: \.self) { marker in
                    CompassMarkerView(marker: marker,
                                      compassDegress: 0)
                }
            }
            .frame(width: 300,
                   height: 300)
            .rotationEffect(Angle(degrees: self.compassHeading.degrees))
            .statusBar(hidden: true)
        }
    }
}


struct CompassMarkerView: View {
    let marker: Marker
    let compassDegress: Double

    var body: some View {
        VStack {
            Capsule()
                    .frame(width: self.capsuleWidth(),
                            height: self.capsuleHeight())
                    .foregroundColor(self.capsuleColor())
                    .padding(.bottom, 120)

            Text(marker.label)
                    .fontWeight(.bold)
                    .rotationEffect(self.textAngle())
                    .padding(.bottom, 80)
        }.rotationEffect(Angle(degrees: marker.degrees))
    }
    
    private func capsuleWidth() -> CGFloat {
        return marker.degrees == 0 ? 7 : 3
    }

    private func capsuleHeight() -> CGFloat {
        return marker.degrees == 0 ? 45 : 30
    }

    private func capsuleColor() -> Color {
        return marker.degrees == 0 ? .primary : .primary
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
            Marker(degrees: 30),
            Marker(degrees: 60),
            Marker(degrees: 90, label: "E"),
            Marker(degrees: 120),
            Marker(degrees: 150),
            Marker(degrees: 180, label: "S"),
            Marker(degrees: 210),
            Marker(degrees: 240),
            Marker(degrees: 270, label: "w"),
            Marker(degrees: 300),
            Marker(degrees: 330)
        ]
    }
}


struct Compass_Previews: PreviewProvider {
    static var previews: some View {
        Compass()
    }
}
