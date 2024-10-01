//
//  MainView.swift
//  AICompanion
//
//  Created by Артур Кулик on 28.09.2024.
//

import SwiftUI

struct ChatsView: View {
    @ObservedObject var viewModel: ChatsViewModel
    
    init(storageManager: StorageManager) {
        self._viewModel = ObservedObject(wrappedValue: ChatsViewModel(storageManager: storageManager))
    }
    
    var body: some View {
        NavigationView {
            content
                .background(Colors.background)
        }
    }
    
    var content: some View {
        VStack {
            navigation
            headerText
                .padding(.top, Layout.Padding.large)
//            createChatButton
            chatsList
            Spacer()
            startChatButton
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, Layout.Padding.horizontalEdges)
    }
    
    var chatsList: some View {
        ScrollView(.vertical) {
            ForEach(viewModel.chats, id: \.self) { chat in
                ActualChatView(chatName: chat.name, lastMessage: chat.messages.last?.content ?? "Сообщений нет") {
                    viewModel.showChatView(model: chat)
                }
            }.onAppear {
                print(viewModel.chats.count)
            }
        }
    }
    
    var navigation: some View {
        VStack(spacing: .zero) {
            NavigationLink(
                destination: ChatView(model: ChatModel(name: "", messages: []) ),
                isActive: $viewModel.isShowChatView,
                label: {
                    EmptyView()
                })
        }
    }
    
    var createChatButton: some View {
        Button {
            viewModel.createChat(name: "New chat!")
        } label: {
            Image(systemName: "plus")
                .resizable()
                .foregroundColor(.white)
                .frame(width: 25, height: 25)
                .padding()
                .background(
                    Colors.red
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                
        }
    }
    
    var headerText: some View {
            Text("A")
                .foregroundColor(Colors.green)
                .font(Fonts.museoSans(weight: .bold, size: 32))
            +
            Text("I")
                .foregroundColor(Colors.green)
                .font(Fonts.museoSans(weight: .bold, size: 32))
            +
            Text(" Companion")
                .foregroundColor(Colors.white)
                .font(Fonts.museoSans(weight: .bold, size: 26))
    }
    
    var startChatButton: some View {
        Button {
            viewModel.createChat(name: "Новый чат")
        } label: {
            Text("Добавить чат")
                .font(Fonts.museoSans(weight: .regular, size: 18))
                .foregroundColor(.white)
                .padding()
                .background(
                    Colors.primary
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    struct ActualChatView: View {
        var chatName: String
        var lastMessage: String
        var onTap: () -> Void
        
        var body: some View {
            content
        }
        
        var content: some View {
            Button {
                onTap()
            } label: {
                HStack {
                VStack(spacing: 4) {
                        Text(chatName)
                            .font(Fonts.museoSans(weight: .medium, size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(lastMessage)
                            .font(Fonts.museoSans(weight: .regular, size: 14))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18))
                        .foregroundColor(Colors.primary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: Layout.Radius.defaultRadius)
                        .fill(Colors.white.opacity(0.05))
                        .stroke(Colors.white.opacity(0.1), lineWidth: 1.5)
                
                )
            }


//            .clipShape(RoundedRectangle(cornerRadius: Layout.Radius.defaultRadius))
        }
    }
}
