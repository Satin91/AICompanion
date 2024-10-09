//
//  ViewModifiers.swift
//  AICompanion
//
//  Created by Артур Кулик on 09.10.2024.
//

import SwiftUI

struct RisingAboveKeyboardViewModifier: ViewModifier {
    @State private var offset: CGFloat = 0
    let bottomSafeAreaPoints: CGFloat = 18
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .animation(.spring(duration: 0.35), value: offset)
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    let vle = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                    let height = vle.height
                    offset = -height + bottomSafeAreaPoints
                }
                
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { notification in
                    offset = 0
                }
            }
    }
}

extension View {
    func risingAboveKeyboard() -> some View {
        self.modifier(RisingAboveKeyboardViewModifier())
    }
}
