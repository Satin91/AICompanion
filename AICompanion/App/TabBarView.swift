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
    @State var filledImages: [String] = []
    
    private let tabBarHeight: CGFloat = 60
    
    init(currentTab: Binding<Int>, items: [TabBarItem], onTapItem: @escaping (Int) -> Void) {
        self.items = items
        self.onTapItem = onTapItem
        self.filledImages = items.map { $0.image }
        self._currentTab = currentTab
    }
    var body: some View {
        content
            .ignoresSafeArea(.all)
            .onAppear {
                filledImages = items.map { $0.image }
            }
    }
    
    @ViewBuilder var content: some View {
        VStack(spacing: .zero) {
            items[currentTab].view
                .frame(maxHeight: .infinity)
            Spacer(minLength: 0)
            tabBarContainer
        }
    }
    
    var tabBarContainer: some View {
        
        return HStack {
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
    
    func makeTabBarItem(item: TabBarItem, of index: Int) -> some View {
        Button {
            onTapItem(index)
        } label: {
            let isSelected = index == currentTab
            
            ZStack {
                Image(systemName: item.image)
                    .resizable()
                    .fontWeight(.thin)
                Image(systemName: item.image + ".fill")
                    .resizable()
                    .opacity(index == currentTab ? 1 : 0)
            }
            .scaledToFill()
            .foregroundColor(isSelected ? Colors.primary : Colors.subtitle.opacity(0.7))
            .frame(width: 24, height: 24)
            .frame(maxWidth: .infinity)
            .offset(y: index == currentTab ? -8 : 0)
            .animation(.bouncy(duration: 0.4, extraBounce: 0.15), value: currentTab)
            .overlay {
                if isSelected {
                    Text(item.text)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(Colors.primary.opacity(0.6))
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
