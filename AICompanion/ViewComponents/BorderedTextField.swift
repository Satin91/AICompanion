//
//  BorderedTextField.swift
//  AICompanion
//
//  Created by Артур Кулик on 17.10.2024.
//

import SwiftUI

struct BorderedTextField: View {
    let placeholder: String
    @Binding var text: String
    @FocusState var isKeyboardForeground: Bool
    var axis: Axis = .vertical
    private let fontSize: CGFloat = 14
    
    var body: some View {
        content
    }
    
    var content: some View {
        TextField(
            placeholder, // Localized string key
            text: $text,
            prompt: Text(placeholder).font(Fonts.museoSans(weight: .regular,
            size: fontSize)
        )
            .foregroundColor(Colors.subtitle),axis: axis)
        .font(Fonts.museoSans(weight: .regular, size: fontSize))
        .foregroundColor(Colors.white)
        .focused($isKeyboardForeground, equals: true)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Layout.Radius.defaultRadius)
                .fill(Colors.background)
                .stroke(Colors.stroke, lineWidth: 1)
        )
    }
}
