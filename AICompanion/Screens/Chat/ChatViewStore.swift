//
//  ChatViewStore.swift
//  AICompanion
//
//  Created by Артур Кулик on 14.10.2024.
//

import Foundation
import SwiftUI
import PhotosUI
import Combine


struct ChatState {
    var textFieldText: String = ""
    var navigationTitle: String = ""
    var isHistoryEnabled: Bool = false
    var isMessageReceiving = false
    var isLoadingPhotoFromPicker = false
    var pickerPhotoData: Data?
    var chat: ChatModelObserver
}

enum ChatAction {
    case sendMessage(text: String, isHistoryEnabled: Bool)
    case delete(message: MessageModel)
    case receiveComplete(ChatModel)
    case errorReceiveMessage(error: NetworkError)
    case displayPhotoFromPicker(item: PhotosPickerItem?)
    case toggleHistoryValue
    case onViewAppear
}


class ChatViewStore: ViewStore {
    @Published var state: ChatState
    
    var network: ChatsNetworkService
    var cancellable = Set<AnyCancellable>()
    
    init(initialState: ChatState, networkService: ChatsNetworkService) {
        self.state = initialState
        self.network = networkService
    }
    
    func reduce(state: inout ChatState, action: ChatAction) -> AnyPublisher<ChatAction, Never>? {
        switch action {
            
        case .sendMessage(let text, let isEnabled):
            let compressionalyJpeg = UIImage(data: state.pickerPhotoData ?? Data())?.jpegData(compressionQuality: 0.2)
            let sendableMessage = MessageModel(role: "user", content: text, imageData: compressionalyJpeg)
            state.chat.value.messages.append(sendableMessage)
            state.isMessageReceiving = true
            var model = state.chat.value
            return self.network
                .sendMessage(message: isEnabled ? model.messages : [sendableMessage], companion: model.companion)
                .subscribe(on: DispatchQueue.main)
                .map { value in
                    let receivedMessage = MessageModel(role: "assistant", content: value.message)
                    model.messages.append(receivedMessage)
                    return .receiveComplete(model) }
                .catch { error in
                    return Just(.errorReceiveMessage(error: error))
                }
                .eraseToAnyPublisher()
            
        case .receiveComplete(let model):
            state.isMessageReceiving = false
            state.chat.value = model
            
        case .toggleHistoryValue:
            state.isHistoryEnabled.toggle()
            
        case .errorReceiveMessage(error: let error):
            state.isMessageReceiving = false
            switch error {
            case .notFound:
                state.navigationTitle = "Not found"
            case .cantDecodeThis(let text):
                state.navigationTitle = text
            case .serverError(let code, let text):
                state.navigationTitle = text
            }
        case .displayPhotoFromPicker(item: let item):
            guard let item = item else {
                //TODO: Make image hide logic
                state.pickerPhotoData = nil
                return .none
            }
            
            Task { [weak self] in
                self?.state.isLoadingPhotoFromPicker = true
                
                do {
                    let data = try await item.loadTransferable(type: Data.self)
                    self?.state.pickerPhotoData = data
                } catch {
                    print("Image nil")
                }
                
                self?.state.isLoadingPhotoFromPicker = false
            }
            
        case .delete(message: let message):
            guard let firstIndex = state.chat.value.messages.firstIndex(of: message) else { return .none }
            state.chat.value.messages.remove(at: firstIndex)
            
        case .onViewAppear:
            state.navigationTitle = state.chat.value.companion.name
        }
        
        return .none
    }
    deinit {
        print("DEINIT CHAT VIEW STORE")
    }
}
