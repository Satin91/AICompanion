//
//  ContentView.swift
//  AICompanion
//
//  Created by Артур Кулик on 26.09.2024.
//

import SwiftUI

struct ChatView: View {
    enum KeyboardForeground: Hashable {
            case foreground
        }
    @ObservedObject var viewModel = ChatViewModel()
    @FocusState var isKeyboardForeground: KeyboardForeground?
    @State var text = ""
    let textLineSpacing: CGFloat = 5
    
    var body: some View {
        content
            .background(Color.gray.opacity(0.2))
    }
    
    var content: some View {
        VStack(spacing: .zero) {
            messagesContainer
            textFieldContainer
        }
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
            TextField(
                "Enter text",
                text: $text,
                prompt: Text("Enter text")
                    .font(Fonts.museoSans(weight: .regular,
                size: 16))
                    .foregroundColor(Colors.neutral),
                axis: .vertical
            )
                .font(Fonts.museoSans(weight: .regular, size: 16))
                .foregroundColor(Colors.light)
                .focused($isKeyboardForeground, equals: .foreground)
                .padding()
                .background(Colors.dark)
                .cornerRadius(Layout.Radius.defaultRadius, antialiased: true)
            Button {
                isKeyboardForeground = nil
                guard !text.isEmpty else { return }
                viewModel.sendMessage(text: text)
                text = ""
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 26))
                    .foregroundColor(text.isEmpty ? Colors.neutral : Colors.primary)
            }
            
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
                 .font(Fonts.museoSans(weight: .regular, size: 16))
                 .lineSpacing(textLineSpacing)
                 .foregroundColor(Colors.dark)
                 .padding()
                 .background(Colors.light)
                 .cornerRadius(4)
                 .cornerRadius(Layout.Radius.defaultRadius, corners: [.bottomRight, .topLeft, .topRight])
             Spacer()
         }
         
         .shadow(color: Color.black.opacity(0.2), radius: 10, x: 5, y: 5)
     }
    
    private func userMessageView(text: String) -> some View {
        HStack {
            Spacer()
            Text(text)
                .font(Fonts.museoSans(weight: .regular, size: 16))
                .lineSpacing(textLineSpacing)
                .foregroundColor(Colors.light)
                .padding()
                .background(Colors.primary)
                .cornerRadius(4)
                .cornerRadius(Layout.Radius.defaultRadius, corners: [.bottomLeft, .topLeft, .topRight])
        }
        .shadow(color: Colors.primary.opacity(0.35), radius: 10, x: 5, y: 5)
    }
}

#Preview {
    ChatView()
}
