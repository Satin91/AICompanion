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
    
    @State var sheetShown = false
    
    var body: some View {
        NavigationView {
            content
                .toolbar(.hidden)
                .sheet(isPresented: $sheetShown) {
                    sheetView
                        .presentationDetents([.medium, .large])
                }
        }
    }
    
    var content: some View {
        VStack(spacing: .zero) {
            navigation
            headerContainer
                .padding(.top, Layout.Padding.large)
                .padding(.bottom, Layout.Padding.medium)
                .background(Colors.lightDark)
            Divider()
                .padding(.horizontal, -Layout.Padding.horizontalEdges)
            chatsList
                .padding(.horizontal, Layout.Padding.horizontalEdges)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Colors.background)
    }
    
    var chatsList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ForEach(viewModel.chats, id: \.self) { chat in
                ActualChatView(chatName: chat.name, lastMessage: chat.messages.last?.content ?? "Сообщений нет") {
                    viewModel.showChatView(model: chat)
                }
            }
            .padding(.top, Layout.Padding.medium)
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
    
    var headerContainer: some View {
        headerText
            .frame(maxWidth: .infinity)
            .overlay {
                createChatButton
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
    }
    
    var headerText: some View {
            Text("AI")
                .foregroundColor(Colors.green)
                .font(Fonts.museoSans(weight: .bold, size: 32))
            +
            Text(" Companion")
                .foregroundColor(Colors.white)
                .font(Fonts.museoSans(weight: .bold, size: 26))
    }
    
    var createChatButton: some View {
        Button {
            sheetShown.toggle()
//            viewModel.createChat(name: "Новый чат")
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22))
                .foregroundColor(Colors.primary)
                .padding(.trailing, Layout.Padding.horizontalEdges)
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
                        .fill(Colors.lightDark)
                        .stroke(Colors.white.opacity(0.1), lineWidth: 1)
                    
                )
            }
            //            .clipShape(RoundedRectangle(cornerRadius: Layout.Radius.defaultRadius))
        }
    }
    
    var sheetView: some View {
        Button {
            
        } label: {
            Text("Создать чат")
                .padding()
                .background(Colors.primary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }

    }
}
