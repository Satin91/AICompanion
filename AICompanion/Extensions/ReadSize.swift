//
//  ReadSize.swift
//  AICompanion
//
//  Created by Артур Кулик on 12.10.2024.
//

import SwiftUI

struct SizeCalculator<T: Equatable>: ViewModifier {
    
    var size: (CGSize) -> Void
    var value: T
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            size(proxy.size)
                        }
                        .onChange(of: value) {
                            size(proxy.size)
                        }
                }
            )
    }
}

extension View {
    func readSize<T: Equatable>(value: T = 0, in size: @escaping (CGSize) -> Void) -> some View {
        modifier(SizeCalculator(size: size, value: value))
    }
}

