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
    @StateObject var viewModel: ChatViewModel
    
    init(model: ChatModel, storageManager: StorageManager) {
        self._viewModel = StateObject(wrappedValue: ChatViewModel(model: model, storageManager: storageManager))
    }
    @Environment(\.presentationMode) private var presentationMode
    @FocusState var isKeyboardForeground: KeyboardForeground?
    @State var text = ""
    
    let textLineSpacing: CGFloat = 5
    
    var body: some View {
        content
//            .navigationTitle(viewModel.isCompanionThinking ? "Думает..." : "")
            .background(Colors.background.ignoresSafeArea(.all))
            .toolbar(.hidden)
    }
    
    var content: some View {
        VStack(spacing: .zero) {
            navigationBarView
            messagesContainer
            textFieldContainer
        }
    }
    
    private var navigationBarView: some View {
        NavigationBarView()
            .addCentralContainer({ Text(viewModel.isCompanionThinking ? "Думает..." : "") })
            .addLeftContainer {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                            .fontWeight(.medium)
                    }
                }
            }
            .addRightContainer({
                Toggle("", isOn: $viewModel.isMemoryEnabled)
            })
            .frame(height: 60)
            .padding(.horizontal, Layout.Padding.horizontalEdges)
            .overlay(content: {
                Divider()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            })
            .background(Colors.lightDark)
    }
    
    private var messagesContainer: some View {
        ScrollView(.vertical, showsIndicators: false) {
//            VStack {
                ForEach(viewModel.chatModel.messages, id: \.self) { message in
                    messageView(message: message)
                        .padding(.vertical, 4)
                    
                }
//                thinkingView
//            }
            .rotationEffect(.degrees(180))
            .padding(16)
            .animation(.easeInOut, value: viewModel.chatModel.messages)
        }
        .rotationEffect(.degrees(180))
        .onTapGesture {
            isKeyboardForeground = nil
        }
    }
    
    @ViewBuilder var thinkingView: some View {
        if viewModel.isCompanionThinking {
            companionMessageView(text: "Думаю что вам ответить...")
                
        }
    }
    
    private var textFieldContainer: some View {
        HStack(spacing: Layout.Padding.small) {
            TextField("Введите текст",
                text: $text,
                prompt: Text("Введите текст")
                    .font(Fonts.museoSans(weight: .regular,
                size: 16))
                    .foregroundColor(Colors.neutral),
                axis: .vertical
            )
                .font(Fonts.museoSans(weight: .regular, size: 16))
                .foregroundColor(Colors.light)
                .focused($isKeyboardForeground, equals: .foreground)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: Layout.Radius.defaultRadius)
                        .fill(Colors.lightDark)
                        .stroke(Colors.white.opacity(0.1), lineWidth: 1)
                    )
//                .cornerRadius(Layout.Radius.defaultRadius, antialiased: true)
            sendMessageButton
        }
         .padding(.vertical, Layout.Padding.small)
         .padding(.horizontal, Layout.Padding.horizontalEdges)
         .background(Colors.lightDark)
     }
    
    var sendMessageButton: some View {
        Button {
            isKeyboardForeground = nil
            guard !text.isEmpty else { return }
            viewModel.send(message: text)
            text = ""
        } label: {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 26))
                .foregroundColor(text.isEmpty ? Colors.neutral : Colors.primary)
        }
    }
    
    @ViewBuilder private func messageView(message: MessageModel) -> some View {
        if message.role == "user" {
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
                 .foregroundColor(Colors.white)
                 .padding()
                 .background(Colors.lightDark)
                 .cornerRadius(4)
                 .cornerRadius(Layout.Radius.defaultRadius, corners: [.bottomRight, .topLeft, .topRight])
             Spacer()
         }
         .shadow(color: Color.black.opacity(0.18), radius: 10, x: 5, y: 5)
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
    ChatView(model: ChatModel(companion: .gpt4o, name: "", messages: []), storageManager: StorageManager() )
}
