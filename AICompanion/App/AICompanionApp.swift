//
//  AICompanionApp.swift
//  AICompanion
//
//  Created by Артур Кулик on 26.09.2024.
//

import SwiftUI

@main
struct AICompanionApp: App {
    
    let storageManager = StorageRepository()
    let chatsService = ChatsStorageInteractor()
    @State var colorScheme = ColorScheme.dark
    
    var body: some Scene {
        WindowGroup {
            CoordinatorView(chatsStorage: chatsService)
        }
    }
}
