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
        case .chat:
            hasher.combine(UUID())
        case .userSettings:
            hasher.combine(UUID())
        }
    }
    
    case chatsList(storage: ChatsStorageInteractorProtocol)
    case chat(chat: ChatModelObserver)
    case userSettings
}

final class Coordinator: ObservableObject {
    @Published var path = NavigationPath()
    
    func push(page: Page) {
        path.append(page)
    }
    
    func pop() {
        path.removeLast()
    }
    
    @ViewBuilder func build(page: Page) -> some View {
        switch page {
        case .chatsList(let chatStorage):
            ChatListView(chatsService: chatStorage)
        case .chat(let chat):
            ChatView(chat: chat)
        case .userSettings:
            UserSettingsView()
        }
    }
}

struct CoordinatorView: View {
    var chatsStorage: ChatsStorageInteractorProtocol
    
    @StateObject private var coordinator = Coordinator()
    @State var tabIndex = 0
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            TabBarView(
                currentTab: $tabIndex,
                items: [
                    .init(view: coordinator.build(page: .chatsList(storage: chatsStorage)), image: "message", text: "Нообщения"),
                    .init(view: coordinator.build(page: .userSettings), image: "person", text: "Настройки")
                ], onTapItem: { index in
                    self.tabIndex = index
                }
            )
            .navigationDestination(for: Page.self) { page in
                coordinator.build(page: page)
            }
        }
        .environmentObject(coordinator)
    }
}


