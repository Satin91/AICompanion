//
//  ToggleView.swift
//  AICompanion
//
//  Created by Артур Кулик on 09.10.2024.
//

import SwiftUI

struct ToggleView: View {
    
    @Binding var isActive: Bool
    
    var thumbDiameter: CGFloat = 18
    var thumbColor = Colors.white
    var backgroundColor = Colors.background
    
    var onTapToggle: (Bool) -> Void = { _ in }
    
    private var toggleWidth: CGFloat {
        thumbDiameter * 2.5
    }
    
    var body: some View {
        content
            .onTapGesture {
                onTapToggle(!isActive)
            }
            .sensoryFeedback(.impact, trigger: isActive)
    }
    
    var content: some View {
        HStack {
            thumbView
                .frame(maxWidth: .infinity, alignment: isActive ? .trailing : .leading)
                .animation(.easeInOut(duration: 0.2), value: isActive)
        }
        .frame(width: toggleWidth)
        .background(toggleBackgroundView)
    }
    
    private var thumbView: some View {
        Circle()
            .frame(height: thumbDiameter)
            .foregroundColor(thumbColor)
            .padding(3)
    }
    
    private var toggleBackgroundView: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(isActive ? Colors.primary : backgroundColor)
            .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}
