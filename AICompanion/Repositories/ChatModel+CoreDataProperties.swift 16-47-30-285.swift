//
//  ChatModel+CoreDataProperties.swift
//  AICompanion
//
//  Created by Артур Кулик on 01.10.2024.
//
//

import Foundation
import CoreData


extension ChatModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatModel> {
        return NSFetchRequest<ChatModel>(entityName: "ChatModel")
    }

    @NSManaged public var messages: [MessageModel]?
    @NSManaged public var name: String?

}

extension ChatModel : Identifiable {

}
