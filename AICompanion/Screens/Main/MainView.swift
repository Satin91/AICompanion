//
//  MainView.swift
//  AICompanion
//
//  Created by Артур Кулик on 28.09.2024.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    
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
            Spacer()
            startChatButton
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var navigation: some View {
        VStack(spacing: .zero) {
            NavigationLink(
                destination: ChatView(),
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
                .foregroundColor(Colors.dark)
                .font(Fonts.museoSans(weight: .bold, size: 26))
    }
    
    var startChatButton: some View {
        Button {
            viewModel.showChatView()
        } label: {
            Text("Начать общение")
                .font(Fonts.museoSans(weight: .regular, size: 18))
                .foregroundColor(.white)
                .padding()
                .background(
                    Colors.dark
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}


#Preview {
    MainView()
}
