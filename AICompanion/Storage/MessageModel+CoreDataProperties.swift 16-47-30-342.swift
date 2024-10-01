//
//  MessageModel+CoreDataProperties.swift
//  AICompanion
//
//  Created by Артур Кулик on 01.10.2024.
//
//

import Foundation
import CoreData


extension MessageModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageModel> {
        return NSFetchRequest<MessageModel>(entityName: "MessageModel")
    }

}

extension MessageModel : Identifiable {

}
