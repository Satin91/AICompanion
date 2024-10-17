//
//  UserSettingsView.swift
//  AICompanion
//
//  Created by Артур Кулик on 17.10.2024.
//

import SwiftUI

struct UserSettingsView: View {
    var body: some View {
        content
            .background(Colors.background.ignoresSafeArea(.all))
    }
    
    var content: some View {
        Text("User settings view")
            .foregroundColor(Colors.white)
            
    }
}

#Preview {
    UserSettingsView()
}
