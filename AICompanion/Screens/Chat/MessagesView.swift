//
//  MessagesView.swift
//  AICompanion
//
//  Created by Артур Кулик on 09.10.2024.
//

import SwiftUI

struct MessagesView: View {
   var messages: [MessageModel] {
        didSet {
            isAnimate.toggle()
        }
    }
    
    private let textLineSpacing: CGFloat = 5
    @State var viewIsAppear = false
    @State var isAnimate = false
    var isKeyboardShow: FocusState<Bool>.Binding
    
    var scrollOffset: CGFloat {
        isKeyboardShow.wrappedValue ? -295 : 0
    }
    
    var body: some View {
        content
            .onAppear {
                isAnimate.toggle()
            }
    }
    
    var content: some View {
        messagesContainer
//            .onTapGesture {
//                isKeyboardShow.toggle()
//            }
    }
    
    private var messagesContainer: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ScrollViewReader { sr in
                VStack(spacing: .zero) {
                    Spacer()
                    ForEach(0..<messages.count, id: \.self) { index in
                        messageView(message: messages[index])
                            .padding(.vertical, 16)
                            .id(index)
                            .contextMenu(
                                ContextMenu {
                                    Button(role: .cancel, action: {
                                        UIPasteboard.general.string = messages[index].content
                                        //                                        viewModel.deleteChat(model: chat)
                                    }) {
                                        Label("Копировать", systemImage: "doc.on.clipboard")
                                    }
                                }
                            )
                    }
                }
                .onChange(of: isAnimate) { count in
                        sr.scrollTo(messages.count - 1)   // << scroll to view with id
                }
                .onChange(of: messages.count) { count in
                        withAnimation {
                            sr.scrollTo(count - 1)   // << scroll to view with id
                        }
                }
            }
            .padding(.horizontal, Layout.Padding.horizontalEdges)
//            .offset(y: scrollOffset)
//            .animation(.spring(duration: 0.4, bounce: 0, blendDuration: 0.2), value: isKeyboardShow.wrappedValue)
        }
    }
    
    @ViewBuilder private func messageView(message: MessageModel) -> some View {
        if message.role == "user" {
            userMessageView(text: message.content)
        } else {
            companionMessageView(text: message.content)
        }
    }
    
    private func companionMessageView(text: String) -> some View {
         HStack {
             Text(text)
                 .font(Fonts.museoSans(weight: .regular, size: 16))
                 .lineSpacing(textLineSpacing)
                 .foregroundColor(Colors.white)
                 .padding()
                 .background(Colors.lightDark)
                 .cornerRadius(4)
                 .cornerRadius(Layout.Radius.defaultRadius, corners: [.bottomRight, .topLeft, .topRight])
             Spacer()
         }
         .shadow(color: Color.black.opacity(0.18), radius: 10, x: 5, y: 5)
     }
    
    private func userMessageView(text: String) -> some View {
        HStack {
            Spacer()
            Text(text)
                .font(Fonts.museoSans(weight: .regular, size: 16))
                .lineSpacing(textLineSpacing)
                .foregroundColor(Colors.light)
                .padding()
                .background(Colors.primary)
                .cornerRadius(4)
                .cornerRadius(Layout.Radius.defaultRadius, corners: [.bottomLeft, .topLeft, .topRight])
        }
        .shadow(color: Colors.primary.opacity(0.35), radius: 10, x: 5, y: 5)
    }
}
