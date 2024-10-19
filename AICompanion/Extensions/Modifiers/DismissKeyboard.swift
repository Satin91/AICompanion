//
//  DismissKeyboard.swift
//  AICompanion
//
//  Created by Артур Кулик on 19.10.2024.
//

import SwiftUI

struct DismissingKeyboard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                let keyWindow = UIApplication.shared.connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .map({$0 as? UIWindowScene})
                    .compactMap({$0})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first
                keyWindow?.endEditing(true)
            }
    }
}

extension View {
    func dismissingKeyboard() -> some View {
        modifier(DismissingKeyboard())
    }
}
