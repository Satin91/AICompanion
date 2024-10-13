//
//  MainView.swift
//  AICompanion
//
//  Created by Артур Кулик on 28.09.2024.
//

import SwiftUI

struct ChatListView: View {
    @ObservedObject var viewModel: ChatListViewModel
    @EnvironmentObject var coordinator: Coordinator
    
    init(chatsService: ChatsStorageInteractorProtocol) {
        self._viewModel = ObservedObject(wrappedValue: ChatListViewModel(chatsService: chatsService))
    }
    
    @State var sheetShown = false
    
    var body: some View {
        NavigationView {
            content
                .toolbar(.hidden)
                .sheet(isPresented: $sheetShown) {
                    CreateChatView(
                        onTapCreateButton: { viewModel.createChat(name: $0 ) },
                        onTapCompanion: { viewModel.selectCompanion($0) },
                        sheetShown: $sheetShown,
                        selectedCompanion: $viewModel.selectedCompanion
                    )
                        .presentationDetents([.medium])
                }
        }
    }
    
    var content: some View {
        VStack(spacing: .zero) {
            headerContainer
                .padding(.top, Layout.Padding.large)
                .padding(.bottom, Layout.Padding.medium)
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
                    coordinator.push(page: .chatView(chat: chat, chatsStorage: viewModel.chatsService))
                }
                .padding(.top)
                .contextMenu(
                    ContextMenu {
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
                .foregroundColor(Colors.primary)
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
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Colors.primarySecondary)
                .padding(.trailing, Layout.Padding.horizontalEdges)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var balanceView: some View {
        VStack(spacing: .zero) {
            Group {
                Text("Баланс: ")
                    .font(Fonts.museoSans(weight: .medium , size: 16))
                    .foregroundColor(Colors.primarySecondary)
                +
                Text(String(format: "%.2f", viewModel.balance) + " ₽")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Colors.white)
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
                    VStack(alignment: .leading, spacing: 8) {
                        Text(chatModel.name)
                            .font(Fonts.museoSans(weight: .bold, size: 20))
                            .foregroundColor(Colors.white)
                        Text(chatModel.messages.last?.content ?? "Сообщений нет")
                            .font(Fonts.museoSans(weight: .regular, size: 14))
                            .foregroundColor(Colors.subtitle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                    }
                    .foregroundColor(Colors.white)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18))
                        .foregroundColor(Colors.primarySecondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: Layout.Radius.defaultRadius)
                    .fill(Colors.background2)
                    .padding(1)
                )
                .overlay {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Colors.background2)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            .frame(width: 80)
                        Text(chatModel.companion.name)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    .frame(height: 18)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .offset(x: 30, y: -9)
                }
            }
        }
    }
    
    struct CreateChatView: View {
        @State var chatName = ""
        
        var onTapCreateButton: (String) -> Void
        var onTapCompanion: (CompanionType) -> Void
        @Binding var sheetShown: Bool
        @Binding var selectedCompanion: CompanionType
        
        var body: some View {
            content
        }
        
        var content: some View {
            VStack(spacing: 22) {
                TextField("Введите имя", text: $chatName)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
//                            .fill(Color.background2)
                            .stroke(Colors.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding()
                companionsView
                Text(selectedCompanion.description)
                    .font(Fonts.museoSans(weight: .regular, size: 18))
                    .foregroundColor(Colors.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 90)
                    .padding(Layout.Padding.horizontalEdges)
                
                Button {
                    onTapCreateButton(chatName)
                    chatName = ""
                    sheetShown.toggle()
                } label: {
                    Text("Создать")
                        .fontWeight(.semibold)
                        .foregroundColor(Colors.background2.opacity(0.8))
                        .padding(.horizontal, 56)
                        .padding(.vertical, 8)
                        .background(Colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                Spacer()
            }
            .padding(.top, Layout.Padding.medium)
            .frame(maxWidth: .infinity)
            .background(Colors.background)
        }
        
        var companionsView: some View {
            LazyVGrid(columns: columns, alignment: .center , spacing: 16, content: {
                ForEach(CompanionType.allCases, id: \.self) { type in
                    makeBorderedButton(title: type.name, isSelected: type == selectedCompanion) { onTapCompanion(type) }
                }
            })
        }
        
        var columns: [GridItem] = [
            GridItem(.fixed(100), spacing: 16),
            GridItem(.fixed(100), spacing: 16),
            GridItem(.fixed(100), spacing: 16)
        ]
        
        func makeBorderedButton(title: String, isSelected: Bool, onTap: @escaping () -> Void) -> some View {
            Button {
                onTap()
            } label: {
                Text(title)
                    .font(Fonts.museoSans(weight: .regular, size: 12))
                    .foregroundColor(Colors.white)
                    .frame(width: 100, height: 26)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? Colors.primary.opacity(0.4) : Color.clear)
                            .stroke(isSelected ? Colors.primary : Colors.white.opacity(0.1), lineWidth: 1)
                        
                    )
            }.buttonStyle(.plain)
        }
        
        }
}
