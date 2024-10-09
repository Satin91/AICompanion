//
//  ContentView.swift
//  AICompanion
//
//  Created by Артур Кулик on 26.09.2024.
//

import SwiftUI

struct ChatView: View {
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject var viewModel: ChatViewModel
    @FocusState var isKeyboardForeground: Bool
    
    @State var text = ""
    
    init(model: ChatModel, chatsService: ChatsStorageInteractorProtocol) {
        self._viewModel = StateObject(wrappedValue: ChatViewModel(model: model, chatsService: chatsService))
    }
    
    var body: some View {
        content
            .background(Colors.background.ignoresSafeArea(.all))
            .toolbar(.hidden)
    }
    
    var content: some View {
        VStack(spacing: .zero) {
            navigationBarView
                .zIndex(1)
            Group {
                messagesView
                textFieldContainer
            }
            .risingAboveKeyboard()
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    
    @State var scrollViewOffset: CGFloat = 0
    
    private var messagesView: some View {
        MessagesView(messages: viewModel.chatModel.messages, isKeyboardShow: $isKeyboardForeground)
            .onTapGesture {
                isKeyboardForeground = false
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
            .focused($isKeyboardForeground, equals: true)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Layout.Radius.defaultRadius)
                    .fill(Colors.lightDark)
                    .stroke(Colors.white.opacity(0.1), lineWidth: 1)
            )
            sendMessageButton
        }
        .ignoresSafeArea(.all)
        .padding(.vertical, Layout.Padding.small)
        .padding(.horizontal, Layout.Padding.horizontalEdges)
        .padding(.bottom, 18)
        .background(Colors.lightDark)
        
    }
    
    var sendMessageButton: some View {
        Button {
            isKeyboardForeground = false
            guard !text.isEmpty else { return }
            viewModel.send(message: text)
            text = ""
        } label: {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 26))
                .foregroundColor(text.isEmpty ? Colors.neutral : Colors.primary)
        }
    }
}

#Preview {
    ChatView(model: ChatModel(companion: .gpt4o, name: "", messages: []), chatsService: ChatsStorageInteractor() )
}
