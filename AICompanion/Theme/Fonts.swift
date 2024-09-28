//
//  Fonts.swift
//  Messenger
//
//  Created by Артур Кулик on 08.06.2023.
//

import SwiftUI

enum Fonts: String {
    case light = "MuseoSansCyrl-100"
    case regular = "MuseoSansCyrl-300"
    case medium = "MuseoSansCyrl-500"
    case bold = "MuseoSansCyrl-700"
    
    static func museoSans(weight: Fonts, size: CGFloat) -> Font {
        Font.custom(weight.rawValue, size: size)
    }
}
