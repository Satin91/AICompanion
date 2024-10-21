//
//  Constants.swift
//  AICompanion
//
//  Created by Артур Кулик on 28.09.2024.
//

import SwiftUI

enum Constants {
    
    enum CommonNames {
        static let avatarPlaceholder = "avatarPlaceholder"
    }
    
    enum API {
        static let gpTunnelSendMessageURL = "https://gptunnel.ru/v1/chat/completions"
        static let getBalanceURL = "https://gptunnel.ru/v1/balance"
        static let botHubBaseURL = "https://bothub.chat/api/v2/openai/v1/chat/completions"
        static let sonnetBaseURL = "https://ask.chadgpt.ru/api/public/claude-3.5-sonnet"
        static let haikuBaseURL = "https://ask.chadgpt.ru/api/public/claude-3-haiku"
        
        enum User {
            static let getCurrentUserPath = "api/v1/users/me/"
            static let updateUserPath = "api/v1/users/me/"
        }
    }
}

enum Layout {
    enum Padding {
        static let horizontalEdges: CGFloat = 16
        static let extraSmall: CGFloat = 8
        static let small: CGFloat = 16
        static let medium: CGFloat = 24
        static let large: CGFloat = 40
    }
    
    enum Sizes {
        static let smallControl: CGFloat = 36
        static let mediumControl: CGFloat = 57
    }
    
    enum Radius {
        static let smallRadius: CGFloat = 8
        static let defaultRadius: CGFloat = 16
        static let largeRadius: CGFloat = 32
    }
}

enum Colors {
    static let background = Color("background")
    static let background2 = Color("background2")
    static let stroke = Color("stroke")
    static let white = Color("white")
    static let subtitle = Color("subtitle")
    static let primary = Color("primary")
    static let primarySecondary = Color("primarySecondary")
    static let green = Color("green")
    static let red = Color("red")
    static let orange = Color("orange")
    static let yellow = Color("yellow")

}
