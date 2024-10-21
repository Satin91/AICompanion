//
//  ResponseModel.swift
//  AICompanion
//
//  Created by Артур Кулик on 28.09.2024.
//

import Foundation

struct TokenCostInfo: Decodable {
    var completion_cost: String
    var completion_tokens: String
}

struct ResponseModel: Codable {
    let id, object: String
    let created: Int
//    let provider: String
//    let model: String
    let choices: [Choice]
//    let usage: Usage?
    let message: String
//    let wordsCount: Int
//
//
    enum CodingKeys: String, CodingKey {
        case id
        case object
//        case provider
        case created
//        case model
        case choices
//        case usage
        case message = "response"
        
//        case wordsCount = "used_words_count"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.object = try container.decodeIfPresent(String.self, forKey: .object) ?? ""
        self.created = try container.decodeIfPresent(Int.self, forKey: .created) ?? 0
//        self.model = try container.decodeIfPresent(String.self, forKey: .model) ?? ""
        self.choices = try container.decodeIfPresent([Choice].self, forKey: .choices) ?? []
//        self.usage = try container.decodeIfPresent(Usage.self, forKey: .usage)
        self.message = try container.decodeIfPresent(String.self, forKey: .message) ?? choices.first?.message.content ?? ""
//        self.wordsCount = try container.decodeIfPresent(Int.self, forKey: .wordsCount) ?? 0
//        self.provider = try container.decodeIfPresent(String.self, forKey: .provider) ?? ""
    }
}

// MARK: - Choice
struct Choice: Codable {
    let index: Int
    let message: MessageModel
    let finishReason: String

    enum CodingKeys: String, CodingKey {
        case index, message
        case finishReason = "finish_reason"
    }
}

// MARK: - Usage
struct Usage: Codable {
    let promptTokens, completionTokens, totalTokens: Int
    let promptCost, completionCost, totalCost: Double

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
        case promptCost = "prompt_cost"
        case completionCost = "completion_cost"
        case totalCost = "total_cost"
    }
}

// MARK: - Balance
struct Balance: Codable {
    var orgId: String
    var object: String
    var balance: Double
    var creditLimit: Int

}
