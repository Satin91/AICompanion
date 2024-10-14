//
//  Coordinator.swift
//  AICompanion
//
//  Created by Артур Кулик on 13.10.2024.
//

import SwiftUI


enum Page: Hashable {
    static func == (lhs: Page, rhs: Page) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .chatsList:
            hasher.combine(UUID())
        case .chatView:
            hasher.combine(UUID())
        }
    }
    
    case chatsList(chatsStorage: ChatsStorageInteractorProtocol)
    case chatView(chat: ChatModel, chatsStorage: ChatsStorageInteractorProtocol)
}

final class Coordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    func push(page: Page) {
        path.append(page)
    }
    
    func back() {
        path.removeLast()
    }
    
    
    @ViewBuilder func build(page: Page) -> some View {
        switch page {
        case .chatsList( let chatsStore):
            ChatListView(chatsService: chatsStore)
        case .chatView(let chat, let chatsStorage):
            ChatView(chat: chat, chatsStorage: chatsStorage)
        }
    }
}

struct CoordinatorView: View {
    var chatsStorage: ChatsStorageInteractorProtocol
    @StateObject private var coordinator = Coordinator()
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.build(page: .chatsList(chatsStorage: chatsStorage))
                .navigationDestination(for: Page.self) { page in
                    coordinator.build(page: page)
                }
        }
        .environmentObject(coordinator)
    }
}
