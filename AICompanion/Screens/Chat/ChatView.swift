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
    
    private let fontSize: CGFloat = 14
    
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
        MessagesView(messages: viewModel.chatModel.messages) { message in
            viewModel.deleteMessage(message: message)
        }
        .onTapGesture {
            isKeyboardForeground = false
        }
    }
    
    private var navigationBarView: some View {
        NavigationBarView()
            .addCentralContainer {
                Text(viewModel.chatModel.companion.name)
                    .overlay {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .offset(x: 30)
                            .opacity(viewModel.isCompanionThinking ? 1 : 0)
                    }
                
            .font(Fonts.museoSans(weight: .bold, size: 22))
            .foregroundColor(Colors.subtitle)
            }
            .addLeftContainer {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Назад")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(Colors.primarySecondary)
                }
            }
            .addRightContainer({
                ToggleView(isActive: $viewModel.isMemoryEnabled) { isActive in
                    viewModel.isMemoryEnabled.toggle()
                }
            })
            .frame(height: 50)
            .padding(.horizontal, Layout.Padding.horizontalEdges)
            .overlay(content: {
                Divider()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            })
            .background(Colors.background2)
    }
    
    private var textFieldContainer: some View {
        HStack(spacing: Layout.Padding.small) {
            TextField("Введите текст",
                      text: $text,
                      prompt: Text("Введите текст")
                .font(Fonts.museoSans(weight: .regular,
                                      size: fontSize))
                    .foregroundColor(Colors.subtitle),
                      axis: .vertical
            )
            .font(Fonts.museoSans(weight: .regular, size: fontSize))
            .foregroundColor(Colors.white)
            .focused($isKeyboardForeground, equals: true)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Layout.Radius.defaultRadius)
                    .fill(Colors.background)
                    .stroke(Colors.white.opacity(0.1), lineWidth: 1)
            )
            sendMessageButton
        }
        .ignoresSafeArea(.all)
        .padding(.top, Layout.Padding.extraSmall)
        .padding(.bottom, Layout.Padding.small)
        .padding(.horizontal, Layout.Padding.horizontalEdges)
        .padding(.bottom, 24)
        .background(Colors.background2)
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
                .foregroundColor(text.isEmpty ? Colors.subtitle : Colors.primary)
                .shadow(color: Colors.primary.opacity(text.isEmpty ? 0 : 0.3), radius: 5)
                .animation(.easeInOut(duration: 0.1), value: text.isEmpty)
        }
    }
}

#Preview {
    ChatView(model: ChatModel(companion: .gpt4o, name: "", messages: [.init(role: "assistant", content: "")]), chatsService: ChatsStorageInteractor() )
}
