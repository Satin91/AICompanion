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
    @State var chatName = ""
    
    var body: some View {
        NavigationView {
            content
                .toolbar(.hidden)
                .sheet(isPresented: $sheetShown) {
                    sheetView
                        .presentationDetents([.medium])
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
            balanceView
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
                ActualChatView(chatModel: chat) {
                    viewModel.showChatView(model: chat)
                }
                .padding(.top)
                .contextMenu(
                    ContextMenu {
//                        Button(action: {
//                            
//                        }) {
//                            Label("Изменить", systemImage: "pencil")
//                        }
                        
                        Button(role: .destructive, action: {
                            viewModel.deleteChat(model: chat)
                        }) {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                )
            }
            .padding(.top, Layout.Padding.medium )
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
                showCreateChatBottomSheetButton
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
    
    var showCreateChatBottomSheetButton: some View {
        Button {
            sheetShown.toggle()
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22))
                .foregroundColor(Colors.primary)
                .padding(.trailing, Layout.Padding.horizontalEdges)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var balanceView: some View {
        VStack(spacing: .zero) {
            Group {
                Text("Баланс: ")
                    .font(Fonts.museoSans(weight: .medium , size: 16))
                    .foregroundColor(Colors.green)
                +
                Text(String(format: "%.2f", viewModel.balance) + " ₽")
                    .font(.system(size: 14, weight: .semibold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Layout.Padding.horizontalEdges)
            .padding(.vertical)
            Divider()
        }
    }
    
    struct ActualChatView: View {
        var chatModel: ChatModel
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
                        Text(chatModel.name)
                            .font(Fonts.museoSans(weight: .medium, size: 16))
                        Text(chatModel.messages.last?.content ?? "Сообщений нет")
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
                .overlay {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Colors.lightDark)
                            .stroke(Colors.white.opacity(0.1), lineWidth: 1)
                            .frame(width: 80)
                        Text(chatModel.companion.name)
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    .frame(height: 18)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .offset(x: 30, y: -9)
                }
            }
        }
    }
    
    var sheetView: some View {
        VStack(spacing: 28) {
            TextField("Введите имя", text: $chatName)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.lightDark)
                        .stroke(Colors.white.opacity(0.1), lineWidth: 1)
                )
                .padding()
            HStack {
                Spacer()
                makeBorderedButton(title: "GPT4o", isSelected: viewModel.selectedCompanion == .gpt4o) { viewModel.selectCompanion(.gpt4o) }
                Spacer()
                makeBorderedButton(title: "GPT4o mini", isSelected: viewModel.selectedCompanion == .gpt4o_mini) { viewModel.selectCompanion(.gpt4o_mini) }
                Spacer()
                makeBorderedButton(title: "GPT 3.5", isSelected: viewModel.selectedCompanion == .gpt3_5_turbo) { viewModel.selectCompanion(.gpt3_5_turbo) }
                Spacer()
            }
            
            Text(viewModel.selectedCompanion.description)
                .font(Fonts.museoSans(weight: .regular, size: 18))
                .foregroundColor(Colors.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 80)
                .padding(Layout.Padding.horizontalEdges)
            
            Button {
                viewModel.createChat(name: chatName)
                chatName = ""
                sheetShown.toggle()
            } label: {
                Text("Добавить")
                    .fontWeight(.medium)
                    .foregroundColor(Colors.background)
                    .padding(.horizontal, 56)
                    .padding(.vertical, 8)
                    .background(Colors.green)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .padding(.top, Layout.Padding.medium)
        .frame(maxWidth: .infinity)
        .background(Colors.background)
    }
    
    func makeBorderedButton(title: String, isSelected: Bool, onTap: @escaping () -> Void) -> some View {
        Button {
            onTap()
        } label: {
            Text(title)
                .font(Fonts.museoSans(weight: .regular, size: 12))
                .frame(width: 100, height: 26)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Colors.primary.opacity(0.4) : Color.clear)
                        .stroke(isSelected ? Colors.primary : Colors.white.opacity(0.1), lineWidth: 1)
                    
                )
        }.buttonStyle(.plain)
    }
}
