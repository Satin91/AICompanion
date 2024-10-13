//
//  Redux.swift
//  AICompanion
//
//  Created by Артур Кулик on 12.10.2024.
//

import SwiftUI
import Combine

final class MVIContainer<Intent, Model>: ObservableObject {

    let intent: Intent
    let model: Model

    private var cancellable: Set<AnyCancellable> = []

    /* Unfortunately, you can’t specify the type ObjectWillChangePublisher
       through generics, so we’ll specify it with an additional property */
    init(intent: Intent, model: Model, modelChangePublisher: ObjectWillChangePublisher) {
        self.intent = intent
        self.model = model

        /* It's necessary to ensure that changes in the Model will
           receive View, and not just Container */
        modelChangePublisher
            .receive(on: RunLoop.main)
            .sink(receiveValue: objectWillChange.send)
            .store(in: &cancellable)
    }
}

final class ChatModelModel: ChatModelProtocol, ChatModelActionsProtocol,  ObservableObject {
    @Published var messages: [MessageModel] = []
    @Published var navigationTitle: String = ""
    @Published var isHistoryEnabled: Bool = false
    @Published var isLoadingMessage: Bool = false
    
    func updateMessages(message: [MessageModel]) {
        self.messages = message
        print("Update messages \(message.count)")
    }
    
    func updateLoadingState(isLoading: Bool) {
        self.isLoadingMessage = isLoading
    }
    
    func updateHistoyState(isEnabled: Bool) {
        isHistoryEnabled = isEnabled
    }
}
//
//extension ChatModelModel:  {
//    
//}

final class ChatIntent: ChatIntentProtocol {
    var chatsStorage: ChatsStorageInteractorProtocol
    var networkService: NetworkService
    var chatModelActions: ChatModelActionsProtocol!
    var cancellable = Set<AnyCancellable>()
    var chat: ChatModel
    
    init(chat: ChatModel, chatsStorage: ChatsStorageInteractorProtocol, networkService: NetworkService, chatModelActions: ChatModelActionsProtocol) {
        self.chatsStorage = chatsStorage
        self.networkService = networkService
        self.chatModelActions = chatModelActions
        self.chat = chat
        print("Chat model \(chat.messages)")
        chatModelActions.updateMessages(message: chat.messages)
    }
    
    
    
    func sendMessage(text: String, isHistoryEnabled: Bool) {
        let newMessage = MessageModel(role: "user", content: text)
        chat.messages.append(newMessage)
        
        var messages = chat.messages
        
        let singleMessage: [MessageModel] = [MessageModel(role: "user", content: text)]
        
        chatModelActions.updateLoadingState(isLoading: true)
        chatModelActions.updateMessages(message: self.chat.messages)
        
        networkService.sendMessage(message: isHistoryEnabled ? messages : singleMessage, companion: chat.companion)
            .sink(receiveCompletion: { compl in
                self.chatModelActions.updateLoadingState(isLoading: false)
            }, receiveValue: { value in
                print("received Value", value)
                self.chat.messages.append(MessageModel(role: "assistant", content: value.message) )
                self.chatModelActions.updateMessages(message: self.chat.messages)
                self.chatsStorage.updateChat(chat: self.chat)
//                self.getBalance()
            })
            .store(in: &cancellable)
    }
    
    
}

protocol ChatIntentProtocol {
    var chatsStorage: ChatsStorageInteractorProtocol { get }
    var networkService: NetworkService { get }
    func sendMessage(text: String, isHistoryEnabled: Bool)
}

protocol ChatModelProtocol {
    var navigationTitle: String { get set }
    var messages: [MessageModel] { get set }
    var isHistoryEnabled: Bool { get set }
    var isLoadingMessage: Bool { get set }
}

protocol ChatModelActionsProtocol: AnyObject {
    func updateMessages(message: [MessageModel])
    func updateLoadingState(isLoading: Bool)
    func updateHistoyState(isEnabled: Bool)
}
