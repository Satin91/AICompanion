//
//  ChatConfigModel.swift
//  AICompanion
//
//  Created by Артур Кулик on 29.09.2024.
//

import Foundation
import CoreData
struct ChatConfigModel {
    var name: String
    var messages: [MessageModel]
    var chatModel: ChatRequestModel
}
