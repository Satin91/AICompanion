//
//  UIImageExtensions.swift
//  AICompanion
//
//  Created by Артур Кулик on 24.10.2024.
//

import UIKit

extension UIImage {
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    func resized(sizeReduce: CGFloat, isOpaque: Bool = false) -> UIImage? {
        let canvas = CGSize(width: size.width * sizeReduce, height: size.height * sizeReduce)
        let format = imageRendererFormat
        format.opaque = isOpaque
        
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
}
