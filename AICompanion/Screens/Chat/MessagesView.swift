//
//  MessagesView.swift
//  AICompanion
//
//  Created by Артур Кулик on 09.10.2024.
//

import SwiftUI

struct MessagesView: View {
    var messages: [MessageModel]
    
    private let textLineSpacing: CGFloat = 2.5
    private let fontSize: CGFloat = 14
    @State var isAnimate = false
    @State var onDeleteClosure: (MessageModel) -> Void = { _ in }
    @State var messageToDelete: MessageModel = .init(role: "", content: "")
    
    var body: some View {
        content
            .onAppear {
                isAnimate.toggle()
            }
    }
    
    var content: some View {
        messagesContainer
    }
    
    private var messagesContainer: some View {
        ScrollViewReader { sr in
            ScrollView(.vertical, showsIndicators: false) {
                messagesList
                .onAppear(perform: {
                    sr.scrollTo(messages.count - 1)
                })
                .onChange(of: messages.count) {
                    withAnimation {
                        sr.scrollTo(messages.count - 1)
                    }
                }
            }
            .padding(.horizontal, Layout.Padding.small)
            .padding(.leading, -6)
        }
    }
    
    var messagesList: some View {
        LazyVStack {
            ForEach(0..<messages.count, id: \.self) { index in
                messageView(message: messages[index])
                    .padding(.vertical, 8)
                    .id(index)
            }
        }
    }
    
    @ViewBuilder private func messageView(message: MessageModel) -> some View {
        if message.role == "user" {
            userMessageView(message: message)
        } else {
            companionMessageView(message: message)
        }
    }
    
    private func userMessageView(message: MessageModel) -> some View {
        HStack {
            Spacer(minLength: 40)
            Text(message.content)
                .font(Fonts.museoSans(weight: .regular, size: fontSize))
                .lineSpacing(textLineSpacing)
                .foregroundColor(Colors.white)
                .padding(10)
                .background(Colors.background2)
                .cornerRadius(4)
                .cornerRadius(Layout.Radius.smallRadius + 2, corners: [.bottomLeft, .topLeft, .topRight])
                .contextMenu(menuItems: {
                    contextMenuView(message)
                }
                )
        }
    }
    
    private func companionMessageView(message: MessageModel) -> some View {
        HStack(alignment: .top, spacing: .zero) {
            Image(systemName: "aqi.low", variableValue: 0.52)
                .font(.system(size: 26, weight: .medium))
                .foregroundColor(Colors.primary)
            Text(LocalizedStringKey(message.content))
                .font(Fonts.museoSans(weight: .regular, size: fontSize))
                .lineSpacing(textLineSpacing)
                .foregroundColor(Colors.subtitle)
                .padding(.vertical, 10)
                .padding(.horizontal, 4)
                .cornerRadius(Layout.Radius.smallRadius + 2, corners: [.bottomRight, .topLeft, .topRight])
                .contextMenu(menuItems: {
                    contextMenuView(message)
                }
                )
            Spacer()
        }
    }
    
    func onDelete(_ closure: (MessageModel) -> Void) -> MessagesView {
        closure(messageToDelete)
        return self
    }
    
    func contextMenuView(_ message: MessageModel) -> some View {
        Group {
            Button(role: .cancel, action: {
                UIPasteboard.general.string = message.content
            }) {
                Label("Копировать", systemImage: "doc.on.clipboard")
            }
            ShareLink("Поделиться", items: [message.content])
            
            Button(role: .destructive, action: {
                self.onDeleteClosure(message)
            }) {
                Label("Удалить", systemImage: "trash")
            }
        }
    }
}
