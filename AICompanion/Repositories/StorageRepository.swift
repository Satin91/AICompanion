//
//  StorageRepository.swift
//  AICompanion
//
//  Created by Артур Кулик on 29.09.2024.
//

import Foundation
import CoreData
import Combine


final class StorageRepository {
    private var defaults = UserDefaults.standard
    
    func saveObject(object: Encodable, for key: String) throws {
        do {
            let data = try JSONEncoder().encode(object)
            defaults.set(data, forKey: key)
        } catch {
            throw error
        }
    }
    
    func fetchObject(for key: String) -> Data? {
        return defaults.value(forKey: key) as? Data
    }
}
