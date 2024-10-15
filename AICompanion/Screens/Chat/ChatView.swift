//
//  Redux.swift
//  AICompanion
//
//  Created by Артур Кулик on 13.10.2024.
//

import SwiftUI
import Combine

struct ChatView: View {
    @EnvironmentObject private var coordinator: Coordinator
    
    @StateObject var store: ChatViewStore
    
    @FocusState var isKeyboardForeground: Bool
    @State var text = ""
    
    private let fontSize: CGFloat = 14
    
    init(chat: ChatModelObserver, chatsStorage: ChatsStorageInteractorProtocol) {
        _store = StateObject(
            wrappedValue: ChatViewStore(initialState: ChatState(chat: chat), networkService: ChatsNetworkService(), chatsStorage: chatsStorage)
        )
    }
    
    var body: some View {
        content
            .background(Colors.background.ignoresSafeArea(.all))
            .toolbar(.hidden)
            .onAppear {
                store.dispatch(.onViewAppear)
            }
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
        MessagesView(messages: store.state.chat.value.messages) { message in
            store.dispatch(.delete(message: message))
        }
        .onTapGesture {
            isKeyboardForeground = false
        }
    }
    
    private var navigationBarView: some View {
        NavigationBarView()
            .addCentralContainer {
                Text(store.state.navigationTitle)
                    .overlay {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .offset(x: 30)
                            .opacity(store.state.isMessageReceiving ? 1 : 0)
                    }
                
            .font(Fonts.museoSans(weight: .bold, size: 22))
            .foregroundColor(Colors.subtitle)
            }
            .addLeftContainer {
                Button {
                    coordinator.pop()
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
                ToggleView(isActive: store.state.isHistoryEnabled) { isActive in
                    store.dispatch(.toggleHistoryValue)
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
            store.dispatch(.sendMessage(text: self.text, isHistoryEnabled: store.state.isHistoryEnabled))
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

