//
//  ChatsModel.swift
//  AICompanion
//
//  Created by Артур Кулик on 01.10.2024.
//

import Foundation

struct ChatModel: Codable, Hashable {
    var id = UUID().uuidString
    var name: String
    var messages: [MessageModel]
}

struct MessageModel: Hashable, Codable{
    var role: String
    var content: String
}
