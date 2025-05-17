//
//  ChatViewModel.swift
//  AICompanion
//
//  Created by Arthur on 1.05.25.
//

import SwiftUI
import Combine

final class ChatViewModel: ObservableObject {
    @Published var textFieldText: String = ""
    @Published var navigationTitle: String = ""
    @Published var isHistoryEnabled: Bool = false
    @Published var isMessageReceiving = false
    @Published var isLoadingPhotoFromPicker = false
    @Published var sendableImageData: Data?
    @Published var chat: ChatModelObserver
    @Published var alertText: String = ""
    @Published var isShowAlert: Bool = false
    
    private var isStreamOpened = false
    
    private var messageIndex = 0
    private let network = ChatsNetworkService()
    private var cancellable = Set<AnyCancellable>()
    
    init(chat: ChatModelObserver) {
        self.chat = chat
        navigationTitle = chat.value.companion.name
        subscribe()
    }
    
    func subscribe() {
        
        network.connectToStream()
            .receive(on: DispatchQueue.main)
            .subscribe(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    self.isStreamOpened = false
                case .failure(let error):
                    self.isStreamOpened = false
                    self.errorReceiveMessage(error: error)
                }
                
            } receiveValue: { model in
                let copyChat = self.chat
                print("DEBUG: model \(model)")
                self.isMessageReceiving = true
                switch model.streamStatus {
                case .open:
                    if !self.isStreamOpened {
                        let receivedMessage = MessageModel(role: "assistant", content: model.message)
                        copyChat.value.messages.append(receivedMessage)
                    } else {
                        let lastMessageIndex = self.chat.value.messages.count - 1
                        copyChat.value.messages[lastMessageIndex].content += model.message
                    }
                    self.isStreamOpened = true
                case .finished:
                    self.isStreamOpened = false
                }
                
                // reload interface with reassign property
                self.chat = copyChat
            }
            .store(in: &cancellable)
        
    }
    
    func disconnectStream() {
        
    }
    
    func sendMessage(text: String, isHistoryEnabled: Bool = false) {
        self.isHistoryEnabled = isHistoryEnabled
        let sendableMessage = MessageModel(role: "user", content: text)
        self.chat.value.messages.append(sendableMessage)
        
        isMessageReceiving = true
        let companion = chat.value.companion
//        let last12Messages = Array(chat.value.messages.suffix(12))
//        self.network.sendMessage(message: isHistoryEnabled ? last12Messages : [sendableMessage])
        self.network.sendMessage(message: sendableMessage, companion: companion)
    }
    
    func delete(message: MessageModel) {
        guard let firstIndex = chat.value.messages.firstIndex(of: message) else {
            return
        }
        chat.value.messages.remove(at: firstIndex)
    }
    
    func tapFavorite(message: MessageModel) {
        guard let firstIndex = chat.value.messages.firstIndex(of: message) else {
            return
        }
        chat.value.messages[firstIndex].isFavorite!.toggle()
    }
    
    func deleteAllMessages() {
        chat.value.messages = []
    }
    
    func toggleHistoryValue() {
        isHistoryEnabled.toggle()
    }
    
    func displayPhotoFromCamera(photoData: Data) {
        
        isLoadingPhotoFromPicker = true
        sendableImageData = UIImage(data: photoData)?.pngData()
        isLoadingPhotoFromPicker = false
        
    }
    func closePhotoPreview() {
        sendableImageData = nil
    }
    
    func errorReceiveMessage(error: NetworkError) {
        isMessageReceiving = false
        switch error {
        case .notFound:
            navigationTitle = "Not found"
        case .cantDecodeThis(let text):
            navigationTitle = text
        case .serverError(let code, let text):
            alertText = text + "\(code) code"
        }
    }
}
