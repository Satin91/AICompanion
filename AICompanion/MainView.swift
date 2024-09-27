//
//  ContentView.swift
//  AICompanion
//
//  Created by Артур Кулик on 26.09.2024.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()

    var body: some View {
        content
    }
    
    var content: some View {
        sendButton
    }
    
    var sendButton: some View {
        Button {
            Task {
                await viewModel.sendMessage()
            }
        } label: {
            Text("Отправить")
        }
        .buttonStyle(.bordered)
    }
}

#Preview {
    MainView()
}
