//
//  TabBarView.swift
//  AICompanion
//
//  Created by Артур Кулик on 17.10.2024.
//



import SwiftUI

struct TabBarItem {
    var view: AnyView
    var image: String
    var text: String
    init(view: any View, image: String, text: String) {
        self.view = AnyView(view)
        self.image = image
        self.text = text
    }
}

struct TabBarView: View {
    @Binding var currentTab: Int
    
    var items: [TabBarItem]
    var onTapItem: (Int) -> Void
    
    private let tabBarHeight: CGFloat = 65
    
    var body: some View {
        content
            .ignoresSafeArea(.all)
    }
    
    @ViewBuilder var content: some View {
        VStack(spacing: .zero) {
            items[currentTab].view
                .frame(maxHeight: .infinity)
            tabBarContainer
        }
    }
    
    var tabBarContainer: some View {
        VStack(spacing: .zero) {
            Divider()
            HStack {
                ForEach(0..<items.count, id: \.self) { index in
                    makeTabBarItem(item: items[index], of: index)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: tabBarHeight)
            .padding(.bottom, Layout.Padding.small)
            .background(
                Rectangle()
                    .fill(Colors.background2)
            )
        }
    }
    
    func makeTabBarItem(item: TabBarItem, of index: Int) -> some View {
        Button {
            onTapItem(index)
        } label: {
            let isSelected = index == currentTab
            
            ZStack {
                Image(systemName: item.image)
                    .resizable()
                    .fontWeight(.regular)
                Image(systemName: item.image + ".fill")
                    .resizable()
                    .opacity(index == currentTab ? 1 : 0)
            }
            .scaledToFill()
            .foregroundColor(isSelected ? Colors.white : Colors.subtitle.opacity(0.7))
            .frame(width: 24, height: 24)
            .frame(maxWidth: .infinity)
            .offset(y: index == currentTab ? -8 : 0)
            .animation(.bouncy(duration: 0.3, extraBounce: 0.15), value: currentTab)
            .overlay {
                if isSelected {
                    Text(item.text)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Colors.white)
                        .opacity(isSelected ? 1 : 0)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .offset(y: 12)
                }
            }
            .frame(maxHeight: .infinity)
        }
        .buttonStyle(.borderless)
    }
}
