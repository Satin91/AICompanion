//
//  ChatViewStore.swift
//  AICompanion
//
//  Created by Артур Кулик on 14.10.2024.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

struct ChatState {
    var textFieldText: String = ""
    var navigationTitle: String = ""
    var isHistoryEnabled: Bool = false
    var isMessageReceiving = false
    var isLoadingPhotoFromPicker = false
    var sendableImageData: Data?
    var chat: ChatModelObserver
    var alertText: String = ""
    var isShowAlert: Bool = false
}

enum ChatAction {
    case connectToStream
    case sendMessage(text: String, isHistoryEnabled: Bool)
    case delete(message: MessageModel)
    case tapFavorite(message: MessageModel)
    case deleteAllMessages
    case receiveComplete(ChatModel)
    case errorReceiveMessage(error: NetworkError)
    case displayPhotoFromCamera(photoData: Data)
    case closePhotoPreview
    case toggleHistoryValue
    case onViewAppear
}


class ChatViewStore: ViewStore {
    @Published var state: ChatState
    
    var network: ChatsNetworkService
    var cancellable = Set<AnyCancellable>()
    var speechSentisizer = AVSpeechSynthesizer()
    private var currentMessageIndex: Int = 0
    
    init(initialState: ChatState, networkService: ChatsNetworkService) {
        self.state = initialState
        self.network = networkService
    }
    
    internal func reduce(state: inout ChatState, action: ChatAction) -> AnyPublisher<ChatAction, Never>? {
        switch action {
        case .connectToStream:
            var model = state.chat.value
            return self.network
                .connectToStream()
                .receive(on: DispatchQueue.main)
                .subscribe(on: DispatchQueue.main)
                .map { value in
                    if self.currentMessageIndex == value.created {
                        let count = model.messages.count - 1
                        model.messages[count].content = value.message
                    } else {
                        let receivedMessage = MessageModel(role: "assistant", content: value.message)
                        model.messages.append(receivedMessage)
                    }
                    return .receiveComplete(model) }
                .catch { error in
                    return Just(.errorReceiveMessage(error: error))
                }
                .eraseToAnyPublisher()
        case .sendMessage(let text, let isHistoryEnabled):
            let compressionalyJpeg = UIImage(data: state.sendableImageData ?? Data())?.resized(sizeReduce: 0.4, isOpaque: false)!.jpegData(compressionQuality: 0.2)
            let sendableMessage = MessageModel(role: "user", content: text, imageData: compressionalyJpeg)
            
            state.chat.value.messages.append(sendableMessage)
            state.isMessageReceiving = true
            
            // Для удешевления контекст берётся с 10 последних сообщений
            let last12Messages = Array(state.chat.value.messages.suffix(12))
            
            self.network.sendMessage(message: isHistoryEnabled ? last12Messages : [sendableMessage], companion: state.chat.value.companion)
            
            return .none
//                .sendMessage(message: isHistoryEnabled ? last12Messages : [sendableMessage], companion: model.companion)
//                .subscribe(on: DispatchQueue.main)
//                .map { value in
//                    let receivedMessage = MessageModel(role: "assistant", content: value.message)
//                    model.messages.append(receivedMessage)
//                    return .receiveComplete(model) }
//                .catch { error in
//                    return Just(.errorReceiveMessage(error: error))
//                }
//                .eraseToAnyPublisher()
            
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
                state.alertText = text + "\(code) code"
            }
        case .closePhotoPreview:
            state.sendableImageData = nil
            
        case .displayPhotoFromCamera(photoData: let data):
            state.isLoadingPhotoFromPicker = true
            state.sendableImageData = UIImage(data: data)?.pngData()
            state.isLoadingPhotoFromPicker = false
        case .delete(message: let message):
            guard let firstIndex = state.chat.value.messages.firstIndex(of: message) else { return .none }
            state.chat.value.messages.remove(at: firstIndex)
        case .tapFavorite(message: let message):
            guard let firstIndex = state.chat.value.messages.firstIndex(of: message) else { return .none}
            state.chat.value.messages[firstIndex].isFavorite!.toggle()
        case .deleteAllMessages:
            state.chat.value.messages = []
        case .onViewAppear:
            state.navigationTitle = state.chat.value.companion.name
        }
        
        return .none
    }
}
