//
//  MainViewModel.swift
//  AICompanion
//
//  Created by Артур Кулик on 28.09.2024.
//

import Foundation

final class MainViewModel: ObservableObject {
    @Published var isShowChatView = false
    
    func showChatView() {
        isShowChatView = true
    }
}
