//
//  SongsHomeView.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 30/04/26.
//

import SwiftUI

struct SongsHomeView: View {
    @Bindable var viewModel: SongsHomeViewModel
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            CollapsingHeaderView(
                searchText: $viewModel.searchText,
                navigationTitle: String(localized: "Songs")
            ) {
                if viewModel.displayedTracks.isEmpty {
                    EmptySearchPlaceholderView(searchText: viewModel.searchText)
                } else {
                    ForEach(Array(viewModel.displayedTracks.enumerated()), id: \.element.id) { index, item in
                        SongRowView(
                            item: item,
                            onTapRow: { viewModel.playTrack(at: index) },
                            onMore: { viewModel.onMoreTapped(for: item) }
                        )
                    }
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .player:
                    PlayerView(playbackQueue: viewModel.playbackQueue)
                }
            }
        }
        .onChange(of: viewModel.searchText) { _, _ in
            viewModel.applySearchQuery()
        }
    }
}

#Preview("Songs home") {
    @Previewable @State var viewModel = SongsHomeViewModel()
    SongsHomeView(viewModel: viewModel)
}
