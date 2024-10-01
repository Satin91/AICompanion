//
//  AICompanionApp.swift
//  AICompanion
//
//  Created by Артур Кулик on 26.09.2024.
//

import SwiftUI
import SwiftData

@main
struct AICompanionApp: App {
    
    let storageManager = StorageManager()
    
    var body: some Scene {
        WindowGroup {
            ChatsView(storageManager: storageManager)
        }
    }
}
