//
//  CollapsingHeaderView.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 29/04/26.
//

import SwiftUI

struct CollapsingHeaderView<Content: View>: View {
    private let scrollTopID = "collapsingScrollTop"

    /// Scroll distance (pt) over which the search fades from opaque to hidden, after `fadeLeadIn`.
    private let collapseDistance: CGFloat = 65
    /// Scroll distance (pt) before the fade begins (search stays fully opaque until then).
    private let fadeLeadIn: CGFloat = 50

    private let navigationTitle: String
    private let searchPlaceholder: String

    @State private var scrollDistance: CGFloat = 0

    @Binding private var searchText: String
    @ViewBuilder private let content: () -> Content

    init(
        searchText: Binding<String>,
        navigationTitle: String,
        searchPlaceholder: String = String(localized: "Search"),
        @ViewBuilder content: @escaping () -> Content
    ) {
        _searchText = searchText
        self.navigationTitle = navigationTitle
        self.searchPlaceholder = searchPlaceholder
        self.content = content
    }

    /// 0 = fully expanded search, 1 = past collapse threshold (toolbar / compact state).
    private var collapseProgress: CGFloat {
        min(1, max(0, (scrollDistance - fadeLeadIn) / max(collapseDistance, 1)))
    }

    private var inlineSearchOpacity: CGFloat {
        1 - collapseProgress
    }

    private var isCollapsed: Bool {
        collapseProgress >= 1
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ScrollDistanceTracker(scrollDistance: $scrollDistance)
                        .id(scrollTopID)

                    SearchBarField(text: $searchText, placeholder: searchPlaceholder, opacity: inlineSearchOpacity)
                        .animation(.easeInOut(duration: 0.2), value: scrollDistance)

                    content()
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                toolbarView(with: proxy)
            }
            .animation(.easeInOut(duration: 0.2), value: isCollapsed)
        }
    }
    
    @ToolbarContentBuilder
    private func toolbarView(with proxy: ScrollViewProxy) -> some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            if isCollapsed {
                Button {
                    withAnimation(.easeOut(duration: 0.28)) {
                        proxy.scrollTo(scrollTopID, anchor: .top)
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                }
                .accessibilityLabel(String(localized: "Scroll to search"))
                .transition(.opacity.combined(with: .scale(scale: 0.85)))
            }
        }
    }
}

#Preview {
    CollapsingHeaderViewPreviewHost()
}

private struct CollapsingHeaderViewPreviewHost: View {
    @State private var searchText: String = ""
    private let listNames = Array(1...30).map { "Item \($0)" }
    
    var body: some View {
        NavigationStack {
            CollapsingHeaderView(searchText: $searchText, navigationTitle: "Test", searchPlaceholder: "Search") {
                ForEach(listNames, id: \.self) {
                    Text($0)
                }
            }
        }
    }
}
