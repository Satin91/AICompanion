//
//  Endpoint.swift
//  AICompanion
//
//  Created by Артур Кулик on 28.09.2024.
//

import Foundation



enum CompanionType: String, Codable, CaseIterable {
    case gpt4o = "gpt-4o"
    case gpt4o_mini = "gpt-4o-mini"
    case gpt3_5_turbo = "gpt-3.5-turbo"
    case claude3_5_sonnet = "claude-3.5-sonnet"
    case mistralLarge = "mistral-large"
}


//MARK: - Name
extension CompanionType {
    var name: String {
        switch self {
        case .gpt4o:
            "GPT4o"
        case .gpt4o_mini:
            "GPT4o Mini"
        case .gpt3_5_turbo:
            "GPT 3.5"
        case .claude3_5_sonnet:
            "Claude Sonnet"
        case .mistralLarge:
            "Mistral Large"
        }
    }
}

//MARK: - Description
extension CompanionType {
    var description: String {
        switch self {
        case .gpt4o:
            return "Флагманская модель с высоким интеллектом для решения сложных, многоэтапных задач"
        case .gpt4o_mini:
            return "Доступная и интеллектуальная компактная модель для быстрых и легких задач"
        case .gpt3_5_turbo:
            return "Предыдущая и доступная модель с более низкой производительностью, но всё ещё большой базой данных"
        case .claude3_5_sonnet:
            return "Новаторский прогресс в генеративном искусственном интеллекте, предлагающий уникальное сочетание скорости, доступности и качества"
        case .mistralLarge:
            return "Производительный, точный, новый. Доступнее чем Cloude Sonnet"
        }
    }
}

//MARK: - Base URL
extension CompanionType {
    var baseURL: String {
        switch self {
        case .gpt4o:
            return Constants.API.gpTunnelSendMessageURL
        case .gpt4o_mini:
            return Constants.API.gpTunnelSendMessageURL
        case .gpt3_5_turbo:
            return Constants.API.gpTunnelSendMessageURL
        case .claude3_5_sonnet:
            return Constants.API.sonnetBaseURL
        case .mistralLarge:
            return Constants.API.botHubBaseURL
        }
    }
}
