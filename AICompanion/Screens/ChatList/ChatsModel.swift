//
//  ChatsModel.swift
//  AICompanion
//
//  Created by Артур Кулик on 01.10.2024.
//

import Foundation

struct ChatModel: Codable, Hashable, Equatable {
    var id = UUID().uuidString
    var companion: CompanionType
    var name: String
    var messages: [MessageModel]
    
    var observer: ChatModelObserver {
        return ChatModelObserver(self)
    }
}

struct MessageModel: Hashable, Codable {
    var role: String
    var content: String
    var imageURL: String? = nil
}
