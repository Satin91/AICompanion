//
//  ContentView.swift
//  AICompanion
//
//  Created by Артур Кулик on 26.09.2024.
//

import SwiftUI

struct MainView: View {
    enum KeyboardForeground: Hashable {
            case foreground
        }
    @ObservedObject var viewModel = MainViewModel()
    @FocusState var isKeyboardForeground: KeyboardForeground?
    @State var text = ""
    
    var body: some View {
        content
            .background(Color.gray.opacity(0.2))
    }
    
    var content: some View {
        VStack {
            messagesContainer
            textFieldContainer
            sendButton
        }
    }
    
    var sendButton: some View {
        Button {
            viewModel.sendMessage()
        } label: {
            Text("Отправить")
        }
        .buttonStyle(.bordered)
    }
    
    private var messagesContainer: some View {
        ScrollView(.vertical) {
            ForEach(viewModel.messages, id: \.self) { message in
                messageView(message: message)
                    .padding(.vertical, 4)
            }.rotationEffect(.degrees(180))
                .padding(16)
                .animation(.easeInOut, value: viewModel.messages)
        }.rotationEffect(.degrees(180))
    }
    
    private var textFieldContainer: some View {
         HStack(spacing: Layout.Padding.small) {
             TextField("Enter text", text: $viewModel.message)
                 .font(.system(size: 14))
                 .focused($isKeyboardForeground, equals: .foreground)
                 .padding()
                 .background(Colors.dark)
                 .cornerRadius(Layout.Radius.defaultRadius, antialiased: true)
//             Button {
//                 isKeyboardForeground = nil
//                 guard !text.isEmpty else { return }
//                 viewModel.sendMessage()
//                 text = ""
//             } label: {
//                 Image(systemName: "paperplane.fill")
//                     .font(.system(size: 26))
//                     .foregroundColor(text.isEmpty ? Colors.neutral : Colors.primary)
//             }
             
         }
         .padding(.vertical, Layout.Padding.small)
         .padding(.horizontal, Layout.Padding.horizontalEdges)
         .background(Colors.chatBackground)
     }
    
    @ViewBuilder private func messageView(message: Message) -> some View {
        if message.isUser {
            userMessageView(text: message.content)
        } else {
            companionMessageView(text: message.content)
        }
    }
    
    private func companionMessageView(text: String) -> some View {
         HStack {
             Text(text)
                 .font(.system(size: 14))
//                 .foregroundColor(Colors.dark)
                 .padding()
                 .background(Colors.light)
                 .cornerRadius(Layout.Radius.smallRadius)
             Spacer()
         }
     }
    
    private func userMessageView(text: String) -> some View {
           HStack {
               Spacer()
               Text(text)
                   .font(.system(size: 14))
//                   .foregroundColor(Colors.primary)
                   .padding()
                   .background(Colors.primarySecondary)
                   .cornerRadius(Layout.Radius.smallRadius)
           }
       }
}

#Preview {
    MainView()
}
