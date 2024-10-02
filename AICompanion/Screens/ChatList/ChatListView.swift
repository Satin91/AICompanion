//
//  MainView.swift
//  AICompanion
//
//  Created by Артур Кулик on 28.09.2024.
//

import SwiftUI

struct ChatListView: View {
    @ObservedObject var viewModel: ChatListViewModel
    
    init(storageManager: StorageManager) {
        self._viewModel = ObservedObject(wrappedValue: ChatListViewModel(storageManager: storageManager))
    }
    
    var body: some View {
        NavigationView {
            content
        }
    }
    
    var content: some View {
        VStack {
            navigation
            headerText
                .padding(.top, Layout.Padding.large)
            chatsList
            Spacer()
            createChatButton
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, Layout.Padding.horizontalEdges)
        .background(Colors.background)
    }
    
    var chatsList: some View {
        ScrollView(.vertical, showsIndicators: false) {
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
                destination: ChatView(model: viewModel.selectedChat, storageManager: viewModel.storageManager),
                isActive: $viewModel.isShowChatView,
                label: {
                    EmptyView()
                })
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
    
    var createChatButton: some View {
        Button {
            viewModel.createChat(name: "Новый чат")
        } label: {
            Text("Добавить чат")
                .font(Fonts.museoSans(weight: .medium, size: 18))
                .foregroundColor(Colors.white)
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
                    VStack(alignment: .leading, spacing: 4) {
                        Text(chatName)
                            .font(Fonts.museoSans(weight: .medium, size: 16))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(lastMessage)
                            .font(Fonts.museoSans(weight: .regular, size: 14))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                    }
                    .foregroundColor(Colors.white)
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
