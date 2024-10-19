//
//  GlassBackground.swift
//  AICompanion
//
//  Created by Артур Кулик on 19.10.2024.
//

import SwiftUI

struct GlassBackgroundModifier: ViewModifier {
    var radius: CGFloat
    let lineWidth: CGFloat = 2
    let gradient = LinearGradient(colors: [.white.opacity(0.6), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(gradient, lineWidth: lineWidth)
                    .blendMode(.overlay)
                    .blur(radius: 0)
            )
            .backgroundBlur(radius: 40, opaque: true)
            .background(Color.white.opacity(0.4))
            .clipShape(
                RoundedRectangle(cornerRadius: radius)
            )
    }
}

extension View {
    func glassBackground(radius: CGFloat) -> some View {
        modifier(GlassBackgroundModifier(radius: radius))
    }
}
