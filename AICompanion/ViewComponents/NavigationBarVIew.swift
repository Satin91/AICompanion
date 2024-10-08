//
//  NavigationBarView.swift
//  AICompanion
//
//  Created by Артур Кулик on 05.10.2024.
//

import SwiftUI

final class Containers {
    var leftContainer = AnyView(EmptyView())
    var rightContainer = AnyView(EmptyView())
    var centralContainer = AnyView(EmptyView())
}

struct NavigationBarView: View {
    private var containers = Containers()
    
    var body: some View {
        ZStack {
            containers.leftContainer
                .frame(maxWidth: .infinity, alignment: .leading)
            containers.rightContainer
                .frame(maxWidth: .infinity, alignment: .trailing)
            containers.centralContainer
                .frame(maxWidth: .infinity, alignment: .center)
        }
//        .padding(.horizontal, Layout.Padding.horizontalEdges)
    }
    
    func addLeftContainer(_ container: () -> any View) -> NavigationBarView {
        containers.leftContainer = AnyView(container())
        return self
    }
    func addRightContainer(_ container: () -> any View) -> NavigationBarView {
        containers.rightContainer = AnyView(container())
        return self
    }
    func addCentralContainer(_ container: () -> any View) -> NavigationBarView {
        containers.centralContainer = AnyView(container())
        return self
    }
}
