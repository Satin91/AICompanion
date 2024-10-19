//
//  Redux.swift
//  AICompanion
//
//  Created by Артур Кулик on 13.10.2024.
//

import SwiftUI
import PhotosUI
import Combine

struct ChatView: View {
    @EnvironmentObject private var coordinator: Coordinator
    
    @StateObject var store: ChatViewStore
    
    @FocusState var isKeyboardForeground: Bool
    @State var textFieldText = ""
    @State var isSelectedImageLoading = false
    @State var isShowAttachItems = false
    
    private let fontSize: CGFloat = 14
    
    init(chat: ChatModelObserver) {
        _store = StateObject(wrappedValue: ChatViewStore(initialState: ChatState(chat: chat), networkService: ChatsNetworkService()))
    }
    @State var isShowCamera = false
    @State var isShowPicker = false
    
    var body: some View {
        content
            .background(Colors.background.ignoresSafeArea(.all))
            .toolbar(.hidden)
            .onTapGesture {
                isShowAttachItems = false
            }
            .onAppear {
                store.dispatch(.onViewAppear)
            }
            .fullScreenCover(isPresented: $isShowCamera){
                camera
            }
            .sheet(isPresented: $isShowPicker) {
                imagePicker
            }
    }
    
    var content: some View {
        VStack(spacing: .zero) {
            navigationBarView
                .zIndex(1)
            Group {
                messagesView
                textFieldContainer
                    .overlay {
                        previewPhotoContainer
                            .offset(y: -135)
                            .padding(.horizontal, Layout.Padding.horizontalEdges)
                        attachContentMenu
                            .offset(y: -115)
                            .padding(.horizontal, Layout.Padding.extraSmall)
                    }
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
            isShowAttachItems = false
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
    
    @ViewBuilder var previewPhotoContainer: some View {
        if let imageData = store.state.sendableImageData {
            HStack {
                let image = Image(uiImage: UIImage(data: imageData) ?? UIImage())
                    .resizable()
                    .scaledToFill()
                image
                    .allowsHitTesting(false)
                    .frame(width: 150, height: 150)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 22)
                    )
                    .background(
                        image
                            .allowsHitTesting(false)
                            .frame(width: 154, height: 154)
                            .blur(radius: 15)
                            .clipShape(RoundedRectangle(cornerRadius: 22))
                    )
                    .background(Color.gray.frame(width: 130, height: 130))
                    .overlay {
                        ProgressView()
                            .opacity(isSelectedImageLoading ? 1 : 0)
                    }
                    .overlay {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 20, height: 20)
                            .padding(6)
                            .background(.thinMaterial)
                            .clipShape(Circle())
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .padding(.top, 14)
                            .padding(.trailing, 14)
                            .onTapGesture {
                                store.dispatch(.closePhotoPreview)
                            }
                    }
                Spacer()
            }
            .shadow(color: Colors.background.opacity(0.4), radius: 15)
        }
    }
    
    private var textFieldContainer: some View {
        HStack(spacing: Layout.Padding.small) {
            showAttachContentButton
            textField
            sendMessageButton
        }
        .ignoresSafeArea(.all)
        .padding(.top, Layout.Padding.extraSmall)
        .padding(.bottom, Layout.Padding.small)
        .padding(.horizontal, Layout.Padding.horizontalEdges)
        .padding(.bottom, 24)
        .background(Colors.background2)
    }
    
    var showAttachContentButton: some View {
        Button {
            isShowAttachItems = true
        } label: {
            Image(systemName: "paperclip")
                .font(.system(size: 26, weight: .light))
                .foregroundColor(Colors.primarySecondary)
        }
    }
    
    @ViewBuilder
    var attachContentMenu: some View {
        if isShowAttachItems {
            VStack(spacing: .zero) {
                makeAttachMenuItem(image: "camera.circle.fill", text: "Сделать снимок") {
                    self.isShowCamera = true
                    self.isShowAttachItems = false
                }
                Divider()
                makeAttachMenuItem(image: "photo.circle.fill", text: "Выбрать изображение") {
                    self.isShowPicker = true
                    self.isShowAttachItems = false
                }
            }
            .frame(width: 230)
            .background(
                Color.clear
                    .background(Colors.background2)
                    .clipShape(RoundedRectangle(cornerRadius: Layout.Radius.smallRadius + 2))
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    
    var camera: some View {
        CameraView { store.dispatch(.displayPhotoFromCamera(photoData: $0)) }
    }
    
    var imagePicker: some View {
        ImagePickerView { store.dispatch(.displayPhotoFromCamera(photoData: $0)) }
    }
    
    var textField: some View {
        BorderedTextField(placeholder: "Введите текст", text: $textFieldText, isKeyboardForeground: _isKeyboardForeground)
    }
    
    var sendMessageButton: some View {
        Button {
            isKeyboardForeground = false
            guard !textFieldText.isEmpty else { return }
            store.dispatch(.sendMessage(text: textFieldText, isHistoryEnabled: store.state.isHistoryEnabled))
            textFieldText = ""
            store.dispatch(.closePhotoPreview)
        } label: {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 26))
                .foregroundColor(textFieldText.isEmpty ? Colors.subtitle : Colors.primary)
                .shadow(color: Colors.primary.opacity(textFieldText.isEmpty ? 0 : 0.3), radius: 5)
                .animation(.easeInOut(duration: 0.1), value: textFieldText.isEmpty)
        }
    }
    
    private func makeAttachMenuItem(image: String, text: String, onTap: @escaping () -> Void) -> some View {
        Button {
            onTap()
        } label: {
            HStack {
                Image(systemName: image)
                    .font(.system(size: 28, weight: .light))
                    .foregroundColor(Colors.primary)
                Spacer()
                Text(text)
                    .font(Fonts.museoSans(weight: .regular, size: 15))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: Layout.Radius.smallRadius)
                    .fill(Colors.background2)
            )
        }
        .buttonStyle(.plain)
    }
}

