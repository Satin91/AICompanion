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
    let model: String
    let choices: [Choice]
    let usage: Usage
}

// MARK: - Choice
struct Choice: Codable {
    let index: Int
    let message: Message
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
