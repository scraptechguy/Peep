//
//  AnimatedBlobView.swift
//  Peep
//
//  Created by Rostislav Brož on 8/30/22.
//

import SwiftUI

/// A softly morphing, rotating “blob” background drawn with `Canvas`.
/// - Uses `TimelineView(.animation)` to update on the animation clock,
///   so the shape morphs smoothly without manual timers.
/// - The path deforms by modulating control points with cosine waves of
///   different periods (`angle1`, `angle2`) and then the whole view rotates.
struct AnimatedBlobView: View {
    /// Triggers the continuous rotation once the view appears.
    @State var appear = false
    
    var body: some View {
        // Drives time for Canvas re-draws using the system animation timeline.
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                // Time base for the current frame
                let now = timeline.date.timeIntervalSinceReferenceDate
                
                // Two cosine oscillators with different speeds.
                // Using different periods keeps the motion from repeating too quickly.
                // `now % 3 * 60°` ~ swings quickly; `now % 6 * 10°` ~ subtle drift.
                let angle1 = cos(Angle.degrees(now.remainder(dividingBy: 3) * 60).radians)
                let angle2 = cos(Angle.degrees(now.remainder(dividingBy: 6) * 10).radians)
                
                // Construct a blobby Bezier path.
                var path = Path()
                let width = 390.0
                let height = 414.0
                
                // The path points are tweaked by angle1/angle2 to make it “breathe”.
                path.move(to: CGPoint(x: 0.9923*width, y: 0.42593*height))
                path.addCurve(to: CGPoint(x: 0.6355*width*angle2, y: height), control1: CGPoint(x: 0.92554*width*angle2, y: 0.77749*height*angle2), control2: CGPoint(x: 0.91864*width*angle2, y: height))
                path.addCurve(to: CGPoint(x: 0.08995*width, y: 0.60171*height), control1: CGPoint(x: 0.35237*width*angle1, y: height), control2: CGPoint(x: 0.2695*width, y: 0.77304*height))
                path.addCurve(to: CGPoint(x: 0.34086*width, y: 0.06324*height*angle1), control1: CGPoint(x: -0.0896*width, y: 0.43038*height), control2: CGPoint(x: 0.00248*width, y: 0.23012*height*angle1))
                path.addCurve(to: CGPoint(x: 0.9923*width, y: 0.42593*height), control1: CGPoint(x: 0.67924*width, y: -0.10364*height*angle1), control2: CGPoint(x: 1.05906*width, y: 0.07436*height*angle2))
                path.closeSubpath()
                
                // Fill with a Peep brand gradient.
                // Canvas uses absolute points, so we set a start/end in that space.
                context.fill(path, with: .linearGradient(Gradient(colors: [Color("PeepYellow"), Color("PeepBlue")]), startPoint: .init(x: 0, y: 0), endPoint: .init(x: 400, y: 400)))
            }
        }
        // Entire blob rotates continuously.
        .rotationEffect(.degrees(appear ? 360 : 0))
        .onAppear {
            // Respect users who prefer less animation.
            if UIAccessibility.isReduceMotionEnabled { return }
            
            // Linear spin, 10s per rotation, infinite, no auto-reverse.
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                appear = true
            }
        }
    }
}

struct AnimatedBlobView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedBlobView()
    }
}
