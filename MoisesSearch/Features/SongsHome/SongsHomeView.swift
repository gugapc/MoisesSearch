//
//  SongsHomeView.swift
//  MoisesSearch
//
//  Created by Gustavo Pereira Cavalcanti on 30/04/26.
//

import SwiftUI

struct SongsHomeView: View {
    @Bindable var viewModel: SongsHomeViewModel
    let albumRepository: any AlbumRepository

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            CollapsingHeaderView(
                searchText: $viewModel.searchText,
                navigationTitle: String(localized: "Songs")
            ) {
                if let message = viewModel.searchErrorMessage {
                    SearchErrorView(
                        message: message,
                        onRetry: viewModel.retrySearch
                    )
                } else if viewModel.isSearchLoading, viewModel.displayedTracks.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else if viewModel.displayedTracks.isEmpty {
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
                case .album(let collectionId):
                    Text(verbatim: "Album \(collectionId) — coming soon")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("album_destination_placeholder_\(collectionId)")
                }
            }
        }
        .onChange(of: viewModel.searchText) { _, _ in
            viewModel.scheduleDebouncedSearch()
        }
    }
}

#Preview("Songs home") {
    @Previewable @State var viewModel = SongsHomeViewModel()
    SongsHomeView(viewModel: viewModel, albumRepository: EmptyAlbumRepository())
}
