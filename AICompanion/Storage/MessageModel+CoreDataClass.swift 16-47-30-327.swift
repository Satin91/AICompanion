//
//  MessageModel+CoreDataClass.swift
//  AICompanion
//
//  Created by Артур Кулик on 01.10.2024.
//
//

import Foundation
import CoreData


public class MessageModel: NSManagedObject {
    
    
    @NSManaged public var content: String?
    @NSManaged public var role: String?
}


