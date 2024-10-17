//
//  UserSettingsView.swift
//  AICompanion
//
//  Created by Артур Кулик on 17.10.2024.
//

import SwiftUI

struct UserSettingsView: View {
    
    @State var nameText = ""
    @State var isToggleActive = false
    @FocusState var isKeyboardForeground: Bool
    
    @StateObject var appSettings: AppSettingsInteractor
    
    var body: some View {
        content
            .background(Colors.background.ignoresSafeArea(.all))
    }
    
    var content: some View {
        settingsList
            .padding(.horizontal, Layout.Padding.horizontalEdges)
    }
    
    var settingsList: some View {
        VStack(spacing: 14) {
            nameTextFieldRow
                .padding(.top, Layout.Padding.large * 4)
            colorSchemeRow
            Spacer(minLength: .zero)
        }
    }
    
    var nameTextFieldRow: some View {
        BorderedTextField(placeholder: "Введите своё имя", text: $nameText, isKeyboardForeground: _isKeyboardForeground, axis: .horizontal)
    }
    
    var colorSchemeRow: some View {
        HStack {
            Text("Цветовая схема")
                .foregroundColor(Colors.white)
                .font(Fonts.museoSans(weight: .bold, size: 18))
            Spacer()
            ToggleView(isActive: appSettings.colorScheme.value == .light) { isActive in
                appSettings.colorScheme.send(isActive == true ? .light : .dark)
                
            }
        }
        .padding(.horizontal, Layout.Padding.small)
        .frame(height: 60)
        .background(
            Colors.background2.clipShape(RoundedRectangle(cornerRadius: Layout.Radius.defaultRadius))
        )
        
        
    }
}

#Preview {
    UserSettingsView(appSettings: AppSettingsInteractor())
}
