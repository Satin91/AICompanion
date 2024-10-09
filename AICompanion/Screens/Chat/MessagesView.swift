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
    @State var onAppear = false
    
    var body: some View {
        content
    }
    
    var content: some View {
        messagesContainer
    }
    
    private var messagesContainer: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ScrollViewReader { sr in
                VStack(spacing: .zero) {
                    ForEach(0..<messages.count, id: \.self) { index in
                        messageView(message: messages[index])
                            .padding(.vertical, 8)
                            .id(index)
                    }
                }
                .onChange(of: messages.count) {
                    withAnimation {
                        sr.scrollTo(messages.count - 1)
                    }
                }
            }
            .padding(.horizontal, Layout.Padding.small)
            
        }
        .defaultScrollAnchor(onAppear ? .zero : .bottom)
    }
    
    @ViewBuilder private func messageView(message: MessageModel) -> some View {
        if message.role == "user" {
            userMessageView(text: message.content)
        } else {
            companionMessageView(text: message.content)
        }
    }
    
    private func companionMessageView(text: String) -> some View {
        HStack(alignment: .top, spacing: .zero) {
            Image(systemName: "aqi.medium")
                .resizable()
                .foregroundColor(Colors.primary)
                .frame(width: 20, height: 20)
                .padding(.top, 10)
            Text(LocalizedStringKey(text))
                .font(Fonts.museoSans(weight: .regular, size: fontSize))

                .lineSpacing(textLineSpacing)
                .foregroundColor(Colors.white)
                .padding(10)
                .cornerRadius(4)
                .cornerRadius(Layout.Radius.smallRadius + 2, corners: [.bottomRight, .topLeft, .topRight])
                .contextMenu(menuItems: {
                    contextMenuView(text)
                }
                    
                    
                )
            Spacer()
        }
        //         .shadow(color: Colors.background2.opacity(0.4), radius: 10, x: 5, y: 5)
        
    }
    
    private func userMessageView(text: String) -> some View {
        HStack {
            Spacer(minLength: 40)
            Text(text)
                .font(Fonts.museoSans(weight: .regular, size: fontSize))
                .lineSpacing(textLineSpacing)
                .foregroundColor(Colors.white)
                .padding(10)
                .background(Colors.background2)
                .cornerRadius(4)
                .cornerRadius(Layout.Radius.smallRadius + 2, corners: [.bottomLeft, .topLeft, .topRight])
                .contextMenu(menuItems: {
                    contextMenuView(text)                }
                    
              
                )
        }
    }
    
    
    func contextMenuView(_ text: String) -> some View {
        Group {
            Button(role: .cancel, action: {
                UIPasteboard.general.string = text
            }) {
                Label("Копировать", systemImage: "doc.on.clipboard")
            }
            ShareLink("Поделиться", items: [text])
        }
    }
}
