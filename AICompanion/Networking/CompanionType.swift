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
}


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
        }
    }
}

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
            return ""
        }
    }
}
