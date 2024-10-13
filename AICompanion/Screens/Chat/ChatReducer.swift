//
//  ChatReducer.swift
//  AICompanion
//
//  Created by Артур Кулик on 13.10.2024.
//

import Foundation
import Combine

func chatReducer(state: inout ChatState, action: ChatAction) {
    switch action {
    case .sendMessage(let text, _):
        state.chat.messages.append(MessageModel(role: "user", content: text))
        state.isMessageReceiving = true
    case .receiveComplete(let model):
        state.isMessageReceiving = false
        state.chat = model
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
    case .delete(message: let message):
        guard let firstIndex = state.chat.messages.firstIndex(of: message) else { return }
        state.chat.messages.remove(at: firstIndex)
    case .onViewAppear:
        state.navigationTitle = state.chat.companion.name
    }
    
}