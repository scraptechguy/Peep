//
//  AnimatableFontModifier.swift
//  Peep
//
//  Created by Rostislav Brož on 12/18/22.
//

import SwiftUI

struct AnimatableFontModifier: AnimatableModifier {
    var size: Double
    var weight: Font.Weight = .regular
    var design: Font.Design = .default
    
    var animatableData: Double {
        get {size}
        set {size = newValue}
    }
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: weight, design: design))
    }
}

extension View {
    func animatableFont(size: Double, weight: Font.Weight, design: Font.Design) -> some View {
        self.modifier(AnimatableFontModifier(size: size, weight: weight, design: design))
    }
}
