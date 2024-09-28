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

//created = 1727478189;
//id = 66f739ae92b35d000110c1a1;
//model = "gpt-4o-mini";
//object = "chat.completion";
//"system_fingerprint" = "fp_15ceb02af4";
//usage =     {
//    "completion_cost" = "0.017279999999999997";
//    "completion_tokens" = 36;
//    "completion_tokens_details" =         {
//        "reasoning_tokens" = 0;
//    };
//    "prompt_cost" = "0.0018";
//    "prompt_tokens" = 15;
//    "total_cost" = "0.019079999999999996";
//    "total_tokens" = 51;
