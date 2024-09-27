//
//  Endpoint.swift
//  AICompanion
//
//  Created by Артур Кулик on 28.09.2024.
//

import Foundation

enum ChatModel {
    case gpt4o
    case gpt4o_mini
    case gpt3_5_turbo
    
    var request: URLRequest {
        return RequestModel(endpoint: self).makeRequest()
    }
}
