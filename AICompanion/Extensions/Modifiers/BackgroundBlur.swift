//
//  BackgroundBlur.swift
//  AICompanion
//
//  Created by Артур Кулик on 19.10.2024.
//

import SwiftUI

class UIBackdropView: UIView {
    override class var layerClass: AnyClass {
        NSClassFromString("CABackdropLayer") ?? CALayer.self
    }
}

struct Backdrop: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIBackdropView {
        UIBackdropView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

struct Blur: View {
    var radius: CGFloat
    var opaque: Bool
    
    var body: some View {
        Backdrop()
            .blur(radius: radius, opaque: opaque)
    }
}

extension View {
    func backgroundBlur(radius: CGFloat = 20, opaque: Bool = true) -> some View {
        self
            .background {
                Blur(radius: radius, opaque: opaque)
            }
    }
}
