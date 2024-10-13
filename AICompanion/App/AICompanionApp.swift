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
    
    let storageManager = StorageRepository()
    let chatsService = ChatsStorageInteractor()
    
    var body: some Scene {
        WindowGroup {
            CoordinatorView(chatsStorage: chatsService)
                .preferredColorScheme(.dark)
        }
    }
}
